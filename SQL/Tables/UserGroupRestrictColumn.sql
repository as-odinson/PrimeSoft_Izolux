if object_id('dbo.UserGroupRestrictColumn', 'U') is null
begin
  create table dbo.UserGroupRestrictColumn
  (
    idUserGroup int not null,
    idColumn int not null,

    bVisible bit null,
    bEdit bit null,
    bEdit_ToManufakt bit null,
    CaptionUser varchar(255) null,
    Num int null,
    nFormatCell int null,
  )
end
go
