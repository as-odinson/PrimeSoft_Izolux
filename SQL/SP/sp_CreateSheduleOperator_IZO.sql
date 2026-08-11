if object_id('dbo.sp_CreateSheduleOperator_IZO', 'P') is not null
  drop procedure dbo.sp_CreateSheduleOperator_IZO
go

-- [ao] создать оператора    
create procedure sp_CreateSheduleOperator_IZO @idOperator int, @date datetime, @idSheduleOperatorNew int output    
as    
begin    
  set nocount on    
    
  set @idSheduleOperatorNew = null    
    
  -- »щем есть ли такой, чтобы не двоить    
  select     
    @idSheduleOperatorNew = ID     
  from     
    SheduleOperator    
  where    
    idOperator = @idOperator and    
    @date >= dtBegin         and    
    @date <  dtEnd    
    
  if @idSheduleOperatorNew is not null    
    return    
    
  -- 2. ѕытаемс€ создать    
  declare     
    @idPlanCalendar int,    
    @nSmena         int,    
    @DatePC         datetime         
      
  select    
    @idPlanCalendar = ID,    
    @nSmena         = nSmena,    
    @DatePC         = Data    
  from    
    PlanCalendar    
  where    
    dbo.f_GetSmenaBeg(Data, nSmena) <= @date and    
    dbo.f_GetSmenaEnd(Data, nSmena) >  @date    
    
  if @idPlanCalendar is null    
  begin    
    -- Ќе заполнен план-календарь - надо создать PlanCalendar    
    exec sp_PlanCalendarMake @date, @date    
     
    -- » еще раз прочитаем данные     
    select    
      @idPlanCalendar = ID,    
      @nSmena         = nSmena,    
      @DatePC         = Data    
    from    
      PlanCalendar    
    where    
      dbo.f_GetSmenaBeg(Data, nSmena) <= @date and    
      dbo.f_GetSmenaEnd(Data, nSmena) >  @date    
    -- return    
  end     
    
  insert into SheduleOperator    
  (    
    idPlanCalendar,    
    idOperator,    
    dtBegin,    
    dtEnd    
  )    
  select    
    @idPlanCalendar,    
    @idOperator,    
    dbo.f_GetSmenaBeg(@DatePC, @nSmena),    
    dbo.f_GetSmenaEnd(@DatePC, @nSmena)    
      
  select @idSheduleOperatorNew = scope_identity()    
    
  -- ƒобавл€ем состав бригады из 1 чел этого оператора    
  insert into ShedulePersonnel    
  (    
    idSheduleOperator,    
    idPersonnel,    
    KTU    
  )    
  select    
    @idSheduleOperatorNew,    
    Operator.idPersonnel,    
    1.0    
  from    
    Operator     
  where    
    ID = @idOperator            
          
  return    
end 