if object_id('dbo.UserGroupReportList', 'U') is null
begin
  create table dbo.UserGroupReportList
  (
    idUserGroup int not null,
    idReport int not null,

    ReportStatusDeny bit not null default 0,
  )
end
go

if columnproperty(object_id('UserGroupReportList'), 'ReportStatusGrant', 'IsComputed') is null
begin
  alter table UserGroupReportList add 
   ReportStatusGrant bit not null default 0
end
go

