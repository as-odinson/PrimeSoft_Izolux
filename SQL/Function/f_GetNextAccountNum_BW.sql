if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[f_GetNextAccountNum_BW]') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.f_GetNextAccountNum_BW
go

create function dbo.f_GetNextAccountNum_BW (@idClient int, @TypeOrder int, @idTaskExlude int) returns varchar(100)
as
begin
  declare @num                  varchar(100),
          @TypeOrder1           int,
          @TypeOrder2           int,
          @ShortDate            datetime,
          @TaskAccountNum_Type  int,
          @sTaskPrefix          varchar(10)

  -- Префикс заказа, например "С"
  select @sTaskPrefix = d_string
  from Config
  where Name = 'AccountNumPrefix'

  set @sTaskPrefix = isnull(@sTaskPrefix, '')

  -- 0 - нумерация отдельно по клиентам
  -- 1 - сквозная нумерация
  select @TaskAccountNum_Type = d_iNum
  from Config
  where Name = 'TaskAccountNum'

  set @TaskAccountNum_Type = isnull(@TaskAccountNum_Type, 0)

  -- Смотрим заказы только с начала текущего года
  set @ShortDate = convert(datetime, cast(year(getdate()) as varchar(4)) + '-01-01', 20)

  -- Для TypeOrder = 1 общая серия для типов 1 и 2
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

  if @TypeOrder != 1
  begin
    -- Для TypeOrder 0 ищем только номера, начинающиеся с "С0"
    -- Например: С099, С0100, С0101, С0103
    select top 1
      @num = T.AccountNum
    from
      Task T
    where
      (T.idClient = @idClient or @TaskAccountNum_Type = 1) and
      T.ID <> @idTaskExlude and
      (T.TypeOrder = @TypeOrder1 or T.TypeOrder = @TypeOrder2 or @TaskAccountNum_Type = 1) and
      T.Date >= @ShortDate and

      -- Номер обязательно должен начинаться с С0
      left(T.AccountNum, len(@sTaskPrefix) + 1) = @sTaskPrefix + '0' and

      -- После удаления С должны остаться цифры
      try_cast(stuff(T.AccountNum, 1, len(@sTaskPrefix), '') as int) is not null and

      -- ВРЕМЕННО этот заказ у клиента московские окна не смотрим
      not
      (
        T.idClient = 1269 and
        T.AccountNum = 'С0411'
      ) 

    order by
      try_cast(stuff(T.AccountNum, 1, len(@sTaskPrefix), '') as int) desc

    -- С0103 -> убираем С -> 0103 -> 103 + 1 = 104
    set @num = cast(isnull(try_cast(stuff(isnull(@num, ''), 1, len(@sTaskPrefix), '') as int), 0 ) + 1 as varchar(100))

    -- Добавляем С0 -> получаем С0104
    set @num = @sTaskPrefix + '0' + @num
  end
  else
  begin
    -- Для остальных типов ищем любые номера с префиксом С
    select top 1
      @num = T.AccountNum
    from
      Task T
    where
      (T.idClient = @idClient or @TaskAccountNum_Type = 1) and
      T.ID <> @idTaskExlude and
      (T.TypeOrder = @TypeOrder1 or T.TypeOrder = @TypeOrder2 or @TaskAccountNum_Type = 1) and
      T.Date >= @ShortDate and

      -- Номер должен начинаться с С
      left(T.AccountNum, len(@sTaskPrefix)) = @sTaskPrefix and

      -- После удаления С должны остаться цифры
      try_cast(stuff(T.AccountNum, 1, len(@sTaskPrefix), '') as int) is not null
    order by
      try_cast(stuff(T.AccountNum, 1, len(@sTaskPrefix), '') as int) desc

    -- С0411 -> убираем С -> 0411 -> 411 + 1 = 412
    set @num = cast(
      isnull(
        try_cast(stuff(isnull(@num, ''), 1, len(@sTaskPrefix), '') as int),
        0
      ) + 1
      as varchar(100)
    )

    -- Добавляем С -> получаем С412
    set @num = @sTaskPrefix + @num
  end

  return @num
end
go