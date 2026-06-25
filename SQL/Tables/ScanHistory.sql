--Types
      --e_type_unknow  = 0, // неизвестный
      --e_type_oper    = 1, // оператор
      --e_type_pyramid = 2, // пирамида
      --e_type_barcode = 3, // СП
      --e_type_ship    = 4 // отгрузка

 if object_id('dbo.ScanHistory', 'U') is null
begin
    create table ScanHistory
    (
      ID bigint identity(1,1) not null,
      idOperator int not null,
      BarCode nvarchar(100) not null,
      Type int not null,
      Message nvarchar(500) null,
      DateScan datetime not null constraint DF_ScanHistory_DateScan default(getdate()),
      constraint PK_ScanHistory primary key clustered (ID)
    )
end
go