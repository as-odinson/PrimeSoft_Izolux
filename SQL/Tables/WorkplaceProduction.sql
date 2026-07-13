if object_id('dbo.ProductionWorkSession', 'U') is null
begin
  create table dbo.ProductionWorkSession
  (
    ID int identity(1,1) primary key,
    DateWork datetime not null,
    idSectorManufact int not null,
    idOperatorGroup int null,
    idBrigadier int null,
    idOperator int null,
    IsSinglePerson bit not null constraint DF_ProductionWorkSession_IsSinglePerson default(0),
    IsActive bit not null constraint DF_ProductionWorkSession_IsActive default(1),
    CreatedAt datetime not null constraint DF_ProductionWorkSession_CreatedAt default(getdate()),
    HostName varchar(128) null
  )
end
go

if not exists (select 1 from sys.indexes where object_id = object_id('dbo.ProductionWorkSession') and name = 'IX_ProductionWorkSession_Date_Sector_Active')
  create index IX_ProductionWorkSession_Date_Sector_Active
    on dbo.ProductionWorkSession(DateWork, idSectorManufact, IsActive)
go

