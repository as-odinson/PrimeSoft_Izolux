if object_id('dbo.sp_GetRest_DepTurnDepList_0_2', 'P') is not null
    drop procedure dbo.sp_GetRest_DepTurnDepList_0_2
go

create procedure dbo.sp_GetRest_DepTurnDepList_0_2
    @idSubDivision int,
    @DocDateEnd    datetime,
    @bNDS          bit
as
begin
    set nocount on

    create table #DepList
    (
        ID                   int,
        Name                 varchar(100),
        nOrderDepList        int,
        idDepotSubDivision   int,
        DepType              int
    )

    create table #MaterialColor
    (
        idMaterial int,
        FolderPath varchar(1000)
    )

    /*
        DL.is1 = 1 считаем складом 0 — как в рабочей процедуре.

        Склад 2 пока определяем по окончанию названия:
        "Склад Ступино 2", "Склад Щёлково 2" и т.д.
    */
    insert into #DepList
    (
        ID,
        Name,
        nOrderDepList,
        idDepotSubDivision,
        DepType
    )
    select distinct
        DL.ID,
        DL.Name,
        DL.nOrder,
        DN.idDepotSubDivision,

        case
            when DL.is1 = 1 then 0
            when rtrim(DL.Name) like '% 2' then 2
        end as DepType

    from DepList DL

    inner join DepNameList DNL
        on DNL.idDepList = DL.ID

    inner join DepName DN
        on DN.ID = DNL.idDepName

    where
        (
            DN.idDepotSubDivision = @idSubDivision
            or @idSubDivision = 0
        )
        and
        (
            DL.is1 = 1
            or rtrim(DL.Name) like '% 2'
        )

    /*
        Формируем пару складов 0 и 2
        для каждого подразделения.
    */
    select
        idDepotSubDivision,

        max(case
            when DepType = 0 then ID
        end) as idDepList0,

        max(case
            when DepType = 0 then Name
        end) as DepListName0,

        max(case
            when DepType = 0 then nOrderDepList
        end) as nOrderDepList0,

        max(case
            when DepType = 2 then ID
        end) as idDepList2,

        max(case
            when DepType = 2 then Name
        end) as DepListName2,

        max(case
            when DepType = 2 then nOrderDepList
        end) as nOrderDepList2

    into #DepPairs
    from #DepList
    group by idDepotSubDivision

    insert into #MaterialColor
    (
        idMaterial,
        FolderPath
    )
    select
        M.ID,
        dbo.f_GetTreeMaterialFolder(IsNull(M.IdtGroup, 0))
    from Material M

    /*
        Материализуем результаты функций один раз.
    */
    select
        RC.idMaterial,
        RC.MaterName,
        RC.DocDate,
        RC.MaterArt,
        RC.UnitName,
        RC.DepListName,
        RC.idDepList,
        RC.Rest,
        RC.PriceSum,
        RC.Mass,
        RC.dTotalCount,
        RC.dTotalWeight,
        RC.PriceAvg
    into #RestCross
    from dbo.f_GetRest_Cross(@DocDateEnd, @bNDS) RC

    select
        RT.idMaterial,
        RT.idDepList,
        RT.Rest,
        RT.PriceSum,
        RT.PriceUnit
    into #RestTMC
    from dbo.f_GetrestTMC(@DocDateEnd) RT

    create index IX_RestCross_Material_DepList
        on #RestCross (idMaterial, idDepList)

    create index IX_RestTMC_Material_DepList
        on #RestTMC (idMaterial, idDepList)

    declare @sDepList varchar(2000)

    set @sDepList = ''

    select
        @sDepList = @sDepList + Name + ', '
    from #DepList

    if LEN(@sDepList) > 0
        set @sDepList = left(@sDepList, LEN(@sDepList) - 2)

    /*
        Получаем материалы, которые присутствуют
        хотя бы на одном из складов пары.
    */
    ;with MaterialBySubdivision as
    (
        select distinct
            DP.idDepotSubDivision,
            RC.idMaterial
        from #DepPairs DP

        inner join #RestCross RC
            on RC.idDepList = DP.idDepList0
            or RC.idDepList = DP.idDepList2
    )

    select
        2 as nOrder,

        MBS.idDepotSubDivision,

        MC.idMaterial,

        IsNull(RC0.MaterName, RC2.MaterName) as Name,

        MC.FolderPath,

        @DocDateEnd as DateEnd,

        case
            when @bNDS = 1 then 'с НДС'
            else 'без НДС'
        end as sNDS,

        @sDepList as sDepList,

        IsNull(RC0.MaterArt, RC2.MaterArt) as MaterArt,

        IsNull(RC0.UnitName, RC2.UnitName) as UnitName,

        /* Данные склада 0 */

        DP.nOrderDepList0,

        DP.DepListName0,

        DP.idDepList0,

        RC0.DocDate as DocDate0,

        round(
            IsNull(RT0.Rest, IsNull(RC0.Rest, 0)),
            3
        ) as Rest0,

        IsNull(
            RT0.PriceSum,
            IsNull(RC0.PriceSum, 0)
        ) as PriceSum0,

        RC0.Mass as Mass0,

        RC0.dTotalCount as dTotalCount0,

        RC0.dTotalWeight as dTotalWeight0,

        round(
            IsNull(RC0.PriceAvg, 0),
            2
        ) as PriceAvg0,

        IsNull(
            RT0.PriceUnit,
            IsNull(RC0.PriceAvg, 0)
        ) as Cost0,

        /* Данные склада 2 */

        DP.nOrderDepList2,

        DP.DepListName2,

        DP.idDepList2,

        RC2.DocDate as DocDate2,

        round(
            IsNull(RT2.Rest, IsNull(RC2.Rest, 0)),
            3
        ) as Rest2,

        IsNull(
            RT2.PriceSum,
            IsNull(RC2.PriceSum, 0)
        ) as PriceSum2,

        RC2.Mass as Mass2,

        RC2.dTotalCount as dTotalCount2,

        RC2.dTotalWeight as dTotalWeight2,

        round(
            IsNull(RC2.PriceAvg, 0),
            2
        ) as PriceAvg2,

        IsNull(
            RT2.PriceUnit,
            IsNull(RC2.PriceAvg, 0)
        ) as Cost2

    from MaterialBySubdivision MBS

    inner join #DepPairs DP
        on DP.idDepotSubDivision = MBS.idDepotSubDivision

    inner join #MaterialColor MC
        on MC.idMaterial = MBS.idMaterial

    left join #RestCross RC0
        on RC0.idMaterial = MBS.idMaterial
        and RC0.idDepList = DP.idDepList0

    left join #RestTMC RT0
        on RT0.idMaterial = MBS.idMaterial
        and RT0.idDepList = DP.idDepList0

    left join #RestCross RC2
        on RC2.idMaterial = MBS.idMaterial
        and RC2.idDepList = DP.idDepList2

    left join #RestTMC RT2
        on RT2.idMaterial = MBS.idMaterial
        and RT2.idDepList = DP.idDepList2

    drop table #RestTMC
    drop table #RestCross
    drop table #DepPairs
    drop table #DepList
    drop table #MaterialColor

    set nocount off
end
go