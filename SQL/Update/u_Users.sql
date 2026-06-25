if columnproperty(object_id('Users'), 'idUserGroup', 'IsComputed') is null
begin
  alter table Users add idUserGroup int null
end
go

if columnproperty(object_id('Users'), 'bUseGroupPermission', 'IsComputed') is null
begin
  alter table Users add bUseGroupPermission bit not null default 0
end
go
