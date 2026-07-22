if object_id('v_SawTask_Statistics', 'V') is not null
    drop view v_SawTask_Statistics
go 

create view v_SawTask_Statistics as  
with cte as
(
    select
        STM.ID as idSawTaskMain,
        STM.Data,
        STM.Name as SawTaskMainName,
        STM.SawedOnlyGP_nCount,
        STM.idAssemblyLine,

        T.ID as idTask,
        T.AccountNum,
        T.DateComplite,

        C.ID as idClient,
        C.Name as ClientName,

        SM.ID as idSectorManufact,
        SM.nType as SectorType,
        SM.Name as SectorName,

        case
            when SM.nType = 1
            then GD.Width * GD.Height / 1000000.0
            else 0
        end as AreaTable,

        case
            when SM.nType = 1
            then 1
            else 0
        end as CountTable,

        case
            when SM.nType in (6, 8, 13)
            then GD.Width * GD.Height / 1000000.0
            else 0
        end as AreaVertmax,

        case
            when SM.nType in (6, 8, 13)
            then 1
            else 0
        end as CountVertmax,

        case
            when SM.nType = 4
            then GD.Width * GD.Height / 1000000.0
            else 0
        end as AreaTriplex,

        case
            when SM.nType = 3
            then GD.Width * GD.Height / 1000000.0
            else 0
        end as AreaFurnace,


        case
            when exists
            (
                select 1
                from GlassDetails GD2
                    inner join GlassProcessing GP2
                        on GP2.idGlassDetails = GD2.ID
                    inner join SectorManufact SM2
                        on SM2.ID = GP2.idSectorManufact
                where GD2.ID = GD.ID
                  and SM2.nType = 3
            )
            then 1
            else 0
        end as IsHardering,

        P.CamCount,
        P.ID as idProject,
        P.nCount,
        P.bShpros,

        B.ID as idBarCode,

        PROD.Name as ProductName,
        PROD.ID   as idProduct,

        GD.ID as idGlassDetails,

        AL.Name as AssemblyLineName,
        AL.Num as AssemblyLineNum,

        TC.Name as TeamCutName,

        case
            when SM.nType = 3
            then TH.Name 
            else ''
        end as TeamHarderingName
        

    from SawTaskMain STM
        inner join GlassDetails GD
            on GD.idSawTaskMain = STM.ID

        inner join GlassProcessing GP
            on GP.idGlassDetails = GD.ID

        inner join SectorManufact SM
            on GP.idSectorManufact = SM.ID

        inner join Barcode B
            on GD.idBarCode = B.ID

        inner join Project P
            on B.idProject = P.ID

        inner join Task T
            on P.idTask = T.ID

        inner join Product PROD
            on GD.idGlass = PROD.ID

        left join Client C
            on T.idClient = C.ID

        left join AssemblyLine AL
            on STM.idAssemblyLine = AL.ID

        left join Team TC
            on STM.idTeam_Cutter = TC.ID

        left join SheduleOperator SO
            on GP.idSheduleOperator = SO.ID

        left join Operator O
            on SO.idOperator = O.ID

        left join Team TH
            on TH.idOperator = O.ID
),
WasteStat as
(
    select
    idGlass,
    idSawTaskMain,

    case
        when SheetArea = 0 then 0
        else round((1 - UsedArea / SheetArea) * 100.0, 2)
    end as WastePct,

    round(
        ((SheetSquare_NoMargin - (IsNull(SumAreaRest, 0) + UsedArea)) * 100.0)
        / SheetSquare_NoMargin,
        2
    ) as WastePctReal

    from
    (
        select
            C.ID,
            C.idGlass,
            C.idSawTaskMain,

            C.SheetSquare_NoMargin,

            BR.SumAreaRest,

            -- ÏËÎÙÀÄÜ Ñ ÎÒÑÒÓÏÎÌ
            C.SheetSquare_NoMargin - isnull(BR.SumAreaRest, 0) as SheetArea,
            -- ÈÑÏÎËÜÇÎÂÀÍÍÀß ÏËÎÙÀÄÜ
            case
                when isnull(C.SquareUsed, 0) > 0
                    then C.SquareUsed
                else isnull(GD.SumAreaDetail, 0)
            end as UsedArea

        from Cutting C
        left join
        (
            select
                idCutting,
                isnull(idDecor, 0) as idDecor,
                sum(Width * Height) as SumAreaDetail
            from GlassDetails
            group by idCutting, isnull(idDecor, 0)
        ) GD on GD.idCutting = C.ID

        left join
        (
            select
                idCutting_Source,
                sum(Width * Height) as SumAreaRest
            from BilletRest
            group by idCutting_Source
        ) BR on BR.idCutting_Source = C.ID

        where C.bMain = 1
    ) Waste
)
select
    WS.WastePct,
    WS.WastePctReal,
    C.*
from cte C
left join WasteStat WS
    on WS.idSawTaskMain = C.idSawTaskMain and
       WS.idGlass = C.idProduct

