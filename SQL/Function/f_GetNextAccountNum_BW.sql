if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[f_GetNextAccountNum_BW]') and xtype in (N'FN', N'IF', N'TF'))
  drop function [dbo].[f_GetNextAccountNum_BW]
go

create function dbo.f_GetNextAccountNum_BW (@idClient int, @TypeOrder int, @idTaskExlude int) RETURNS varchar(100)  
as   
--[OK] Опеределить следующий номер заказа по клиенту, TypeOrder и текущему году  
--     Является аналогом изогласовской f_GetNextAccountNum_BW с некоторыми косметическими изменениями  
begin  
  declare @num                  varchar(100),  
          @TypeOrder1           int,  
          @TypeOrder2           int,  
          @CurDate              datetime,  
          @ShortDate            datetime,  
          @Year                 smallint,  
          @TaskAccountNum_Type  int,  
          @sTaskPrefix          varchar(10)  
  
  -- Смотрим префикс  
  select  @sTaskPrefix = d_string from Config where Name = 'AccountNumPrefix'  
  select  @sTaskPrefix = IsNull(@sTaskPrefix, '')  
  
  -- Тип рассчёта номера нового заказа:  
  -- 0 - по клиентам, 1 - сквозная нумерация  
  select @TaskAccountNum_Type = d_iNum from Config where Name = 'TaskAccountNum'  
  
 --select @ShortDate           = d_iNum-2 from Config where Name = 'BeginCalcNum' --[SE]Не нашел использования в коде  
  
  -- [ab]->[автору] BeginCalcNum - это что за номер? И почему он в дату преобразуется?  
  --                А что делать в новом году? Программа сама не поймет, что надо нумерацию с нуля начинать?  
  --                Раньше понимала.  
  if @ShortDate is null  
    set @ShortDate = convert(datetime,cast(year(getdate())as nvarchar)+'-01-01', 20)  
  
  if @TypeOrder = 1  
  begin  
    set @TypeOrder1 = 1  
    set @TypeOrder2 = 2  
  end  
  else  
  begin  
    set @TypeOrder1 = 0  
    set @TypeOrder2 = 0  
  end  
    
  -- Взять максимальный по данному клиенту или по всем клиентам:  
  select top 1    
    @num = AccountNum  
  from   
    Task   
  where   
    (idClient = @idClient                               or @TaskAccountNum_Type = 1) and  
    ID <> @idTaskExlude and  
    (TypeOrder = @TypeOrder1 or TypeOrder = @TypeOrder2 or @TaskAccountNum_Type = 1) and  
    Date >= @ShortDate  
  order by
    case
      when try_cast(Stuff(AccountNum, 1, len(@sTaskPrefix), '') as int) is not null
      then try_cast(Stuff(AccountNum, 1, len(@sTaskPrefix), '') as int)
      else 0
    end desc
  
  set  @num = Cast( case when IsNumeric(Stuff(isnull(@Num, ''), 1, len(@sTaskPrefix), '')) = 1  
                         Then Cast     (Stuff(       @Num,      1, len(@sTaskPrefix), '') as int) + 1  
                         else 1  
                    end as varchar(100) )    
                      
  -- [ab] У нас Б заказы с нуля начинаются, Изолюксу надо  
  if @TypeOrder = 0   
    set @num = '0' + @num  
  
  -- Вставляем префикс  
  set @num = @sTaskPrefix + @num  
  
  return @num  
end
go
