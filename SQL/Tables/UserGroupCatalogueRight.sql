if object_id('dbo.UserGroupCatalogueRight', 'U') is null
begin
  create table dbo.UserGroupCatalogueRight
  (
    idUserGroup int not null,
    idCatalogue int not null,
    bDenyShow bit null,
    bDenyEdit bit null
  )
end
go
