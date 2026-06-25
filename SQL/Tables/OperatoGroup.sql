if object_id('dbo.OperatorGroup', 'U') is null
begin
    create table OperatorGroup
    (
        ID int identity(1,1) primary key,
        idOperatorBrigadier int null,
        Name nvarchar(100)
    )
end
go

if object_id('dbo.OperatorGroupItem', 'U') is null
begin
    create table OperatorGroupItem
    (
        ID int identity(1,1) primary key,

        idOperatorGroup int not null,
        idOperator int not null,

        Coef float not null
    )
end
go


--insert into OperatorGroup (Name, idOperatorBrigadier)
--values
--('Закалка1', 5),
--('Закалка2', 12),
--('Резка1', 2),
--('Резка2', 23),
--('Рамка', 26),
--('Отгрузка', 8),
--('Вондек', 26),
--('Лисик', 26)



--select *
--from Operator
--where Name like '%Британ%'
--   or Name like '%Абдулазизов%'
--   or Name like '%Азамов%'
--   or Name like '%Ахмадалиев%'

--select * from OperatorGroup
--update OperatorGroup set  idOperatorBrigadier = -11 where ID = 7

--insert into OperatorGroupItem(idOperatorGroup, idOperator, Coef)
--values
--(1, 5, 11.5),
--(1, 16, 10.0),
--(1, 17, 10.0),
--(1, 11, 11.5),

--(2, 6, 10.0),
--(2, 10, 10.0),
--(2, 18, 11.5),
--(2, 12, 11.5),

--(3, 2, 3.9),
--(3, 19, 2.7),
--(3, 20, 2.7),
--(3, 21, 2.7),

--(4, 4, 3.2),
--(4, 22, 2.8),
--(4, 23, 3.2),
--(4, 24, 2.8),

--(5, 25, 1.15),
--(5, 26, 1.2),
--(5, 27, 1.15),

--(6, 7, 3.3),
--(6, 8, 4.0),
--(6, 28, 2.0),
--(6, 29, 2.0),

--(5, -1, 8.0),
--(5, 30, 6.0),
--(5, 31, 6.0),
--(5, 13, 8.0),

--(5, 32, 7.0),
--(5, 33, 6.0),
--(5, 34, 5.0),

--(5, 1, 7.0),
--(5, 35, 5.0),
--(5, 36, 5.0),
--(5, 37, 7.0)