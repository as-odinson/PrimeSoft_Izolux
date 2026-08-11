 if object_id('sp_UpdateDepTransDocDateByTask', 'P') is not null
  drop procedure dbo.sp_UpdateDepTransDocDateByTask
go 
  -- [AO] автоматически присвоить дату документа на основании даты отгрузки когда проставлена счет фактура по складу 0, и дату изготовления по складу 2  
create procedure dbo.sp_UpdateDepTransDocDateByTask @dateFrom  datetime = null, @dateTo datetime = null  
as  
begin  
  set nocount on  
    
  if @dateFrom is null or @dateFrom = 0
    set @dateFrom = dateadd(month, datediff(month, 0, getdate()) - 1, 0)

  if @dateTo is null or @dateTo = 0
    set @dateTo = eomonth(getdate())
  declare @nDateType int  
  select  @nDateType = DataCalc from Config where Name = 'nDepGPDateType'  
  
  
  if @dateFrom is null  
    set @dateFrom = cast(getdate() as date)   
  
  if @dateTo is null  
    set @dateTo = cast(getdate() as date)   
  
  
  -- [AO] дата отгрузки когда проставлена счет фактура только по складу 0, по складу 2 дата изготовления  
  if isnull(@nDateType, 0) = 6  
  begin  
    update DT  
    set   
    bEditManually = case   
        when isnull(bEditManually,0) = 1 then 1  
        else 2  
    end,  
    DocDate =  
      cast(   
        case   
          when DT.is1 = 1 and isnull(T.NumCalcFact, '') != '' then T.DateComplite  
          when DT.is2 = 1 then T.DateCompliteGP  
          else DT.DocDate  
        end  
      as date)  
    from DepTrans dt  
    inner join Task t on T.ID = DT.idTask  
    where  
      (  
        case   
          when DT.is1 = 1 and isnull(T.NumCalcFact, '') != '' then T.DateComplite  
          when DT.is2 = 1 then T.DateCompliteGP  
        end >= @dateFrom  
      )  
      and  
      (  
        case   
          when DT.is1 = 1 and isnull(T.NumCalcFact, '') != '' then T.DateComplite  
          when DT.is2 = 1 then T.DateCompliteGP  
        end <= @dateTo  
      )  
      and not exists (  
        select 1  
        from DepClosePeriod  
        where   
          DepClosePeriod.idDepotSubDivision = t.idDepotSubDivision and  
          DT.DocDate < DepClosePeriod.DocDate  
     )  
     and  
     (  
       case   
         when DT.is1 = 1 and isnull(T.NumCalcFact, '') != '' then T.DateComplite  
         when DT.is2 = 1 then T.DateCompliteGP  
       end <= @dateTo  
     )  
     and  
     isnull(dt.bEditManually,0) != 1  
  end  
end  