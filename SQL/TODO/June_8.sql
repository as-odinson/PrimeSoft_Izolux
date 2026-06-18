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
	v.CountTable,
	v.AreaVertmax,
	v.CountVertmax,
	v.AreaTriplex,
	v.AreaFurnace,

	v.CamCount,
	v.nCount,
	v.bShpros,
	v.idProject,
	v.idBarCode,

	v.IsHardering,
	v.WastePctReal,

	v.AssemblyLineName,
	v.TeamCutName,
	v.TeamHarderingName
	from v_SawTask_Statistics v
	
    where 
     --v.idSawTaskMain = 2220
    v.Data >= '01.05.2026' and v.Data <= '01.06.2026'
    --v.Data >= {sDateBeg} and v.Data <= {sDateEnd}
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
),
ClientOrders as
(
select distinct
	idSawTaskMain,
	ClientName,
	AccountNum
	from base
),
ClientBlock as
(
select
	co1.idSawTaskMain,
	co1.ClientName,

	STRING_AGG(AccountNum, ', ')
            within group (order by AccountNum) as Accounts

    from ClientOrders co1
    group by
        co1.idSawTaskMain,
        co1.ClientName
),

ClientFinal as
(
select
	idSawTaskMain,

	STRING_AGG(
	ClientName +
	case 
            when Accounts is not null 
            then '(' + Accounts + ')'
            else '' 
        end,
        '>>'
    ) as ClientAccountText

    from ClientBlock
    group by idSawTaskMain
),

GlassWaste as
(
    select distinct
        B.idSawTaskMain,
        B.ProductName,
        B.WastePctReal,
        B.IsHardering
    from base B
),

GlassWasteFinal as
(
    select
        idSawTaskMain,
        IsHardering,
        STRING_AGG(
            ProductName +
            case
                when WastePctReal is not null
                then ' (' + cast(WastePctReal as varchar(20)) + '%)'
                else ''
            end,
            '>>'
        ) within group (order by ProductName) as GlassWasteText

    from GlassWaste
    group by idSawTaskMain, IsHardering
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
	 ', ' + subBase.AccountNum
	from base subBase
        where subBase.idSawTaskMain = base.idSawTaskMain
        for xml path('')
    ), 1, 2, '') as AccountNums,

	cf.ClientAccountText,

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

    sum(base.CountTable)   as CountTable,
    sum(base.CountVertmax) as CountVertmax,
    sum(base.AreaTriplex)  as AreaTriplex,
    sum(base.AreaFurnace)  as AreaFurnace,
    
   agg.FrameCount,
   agg.ShprosCount,

    count(distinct case when base.CamCount > 0 and base.IsHardering = 1 then base.idBarCode end) as CountSP_Hardering,  
    count(distinct case when base.CamCount > 0 and base.IsHardering = 0 then base.idBarCode end) as CountSP_Table,  

    max(base.AssemblyLineName) as AssemblyLineName,
    max(base.TeamCutName)      as TeamCutName,
    max(base.TeamHarderingName) as TeamHarderingName,

    GWF.GlassWasteText

 from base
left join agg 
    on agg.idSawTaskMain = base.idSawTaskMain
left join ClientFinal cf
    on cf.idSawTaskMain = base.idSawTaskMain
left join GlassWasteFinal GWF
    on GWF.idSawTaskMain = base.idSawTaskMain and
       GWF.IsHardering   = base.IsHardering

 group by
    base.idSawTaskMain,
    base.IsHardering,
    cf.ClientAccountText,
    agg.FrameCount,
    GWF.GlassWasteText,
    agg.ShprosCount
