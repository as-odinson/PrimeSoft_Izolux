if object_id('dbo.UserGroups', 'U') is null
begin
   create table UserGroups
   (
       ID int identity(1,1) primary key,
       Name varchar(128) not null,
       Commentary varchar(512) null
   )
end
go
