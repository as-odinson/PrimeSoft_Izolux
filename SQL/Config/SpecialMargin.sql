if not exists(select ID from SpecialMargin where nCode = 55)
begin
  insert into SpecialMargin(Name, nCode, bShow) values('Наценка на трехкамерные сп', 55, 1)
end
go
