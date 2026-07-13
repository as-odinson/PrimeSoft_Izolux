if columnproperty(object_id('Project'), 'bSkipRebate', 'IsComputed') is null
begin
  alter table Project add bSkipRebate bit default 0
end
go
