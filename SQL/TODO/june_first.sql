set dateformat dmy

;with base as
(
    select
        v.idSawTaskMain,
        v.Data,
        v.SawTaskMainName,

        v.idTask,

        v.ClientName,
        v.AccountNum,
        v.ProductName,
        v.DateComplite,

        v.AreaTable,
        v.AreaVertmax,
        v.AreaTriplex,
        v.AreaFurnace,

        v.CamCount,
        v.nCount,
        v.bShpros,
        v.idProject,
        v.idBarCode,

        v.IsHardering,
        v.WastePct,

        v.AssemblyLineName,
        v.TeamCutName,
        v.TeamHarderingName
    from v_SawTask_Statistics v
    where v.Data >= '02.05.2026' and v.Data <= '01.06.2026'
),
Agg as
(
    select
        idSawTaskMain,
        sum(CamCount * nCount) as FrameCount,
        sum(case when bShpros = 1 then 1 else 0 end) as ShprosCount
    from
    (
        select distinct
            idSawTaskMain,
            idProject,
            CamCount,
            bShpros,
            nCount
        from base
    ) t
    group by idSawTaskMain
)


select 
    base.idSawTaskMain,
    base.IsHardering,
    max(base.Data)                as Data,
    max(base.SawTaskMainName)     as SawTaskMainName,

    stuff(
    (
        select distinct
            ', ' + subBase.ClientName
        from v_SawTask_Statistics subBase
        where subBase.idSawTaskMain = base.idSawTaskMain 
        for xml path('')
    ), 1, 2, '') as Clients,

    stuff(
    (
        select distinct
             '<br> ' + subBase.AccountNum
        from base subBase
        where subBase.idSawTaskMain = base.idSawTaskMain
        for xml path('')
    ), 1, 4, '') as AccountNums,

    stuff(
    (
        select distinct
             ', ' + convert(varchar(10), subBase.ProductName, 104)
        from base subBase
        where subBase.idSawTaskMain = base.idSawTaskMain and
              subBase.IsHardering = 1 and
              base.IsHardering = 1
        for xml path('')
    ), 1, 2, '') as ProductNames,

    stuff(
    (
        select distinct
             ', ' + convert(varchar(10), subBase.ProductName, 104)
        from base subBase
        where subBase.idSawTaskMain = base.idSawTaskMain and
              subBase.IsHardering = 0 and
              base.IsHardering  = 0
        for xml path('')
    ), 1, 2, '') as ProductNamesSimple,

    stuff(
    (
        select distinct
             '\n ' + convert(varchar(10), subBase.DateComplite, 104)
        from base subBase
        where subBase.idSawTaskMain = base.idSawTaskMain
        for xml path('')
    ), 1, 2, '') as DateComplites,

    sum(base.AreaTable)    as AreaTable,
    sum(base.AreaVertmax)  as AreaVertmax,
    sum(base.AreaTriplex)  as AreaTriplex,
    sum(base.AreaFurnace)  as AreaFurnace,
    
   agg.FrameCount,
   agg.ShprosCount,

    count(distinct case when base.CamCount > 0 and base.IsHardering = 1 then base.idBarCode end) as CountSP_Hardering,  
    count(distinct case when base.CamCount > 0 and base.IsHardering = 0 then base.idBarCode end) as CountSP_Table,  

    max(base.AssemblyLineName) as AssemblyLineName,
    max(base.TeamCutName)      as TeamCutName,
    max(base.TeamHarderingName) as TeamHarderingName,

    sum(distinct WastePct) as WastePercent

 from base
left join agg 
    on agg.idSawTaskMain = base.idSawTaskMain

 group by
    base.idSawTaskMain,
    base.IsHardering,
    agg.FrameCount,
    agg.ShprosCount

select *
     from  v_SawTask_Statistics C
 where idSawTaskMain = 2211
 order by IsHardering, idProduct


