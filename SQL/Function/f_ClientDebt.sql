if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[f_ClientDebt]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].f_ClientDebt
go

create function dbo.f_ClientDebt( @EndDate datetime ) returns table
as
return
(
  with ClientTypes as (
    -- Все типы заказов клиента
    select distinct T.idClient as ClientID, T.TypeOrder as Type
    from Task T
    where T.DateComplite < dateadd(day, 1, cast(@EndDate as date))
      and T.nState & 2 = 2

    union

    -- Все типы оплат клиента
    select distinct P.idClient as ClientID, P.nType as Type
    from Payment P
    where P.DatePay < dateadd(day, 1, cast(@EndDate as date))
  ),
  OrderSums as (
    -- Суммы заказов по клиентам и типам
    select
        T.idClient as ClientID,
        T.TypeOrder as Type,
        sum(cast(round(isnull(T.Price, 0), 2) as decimal(19, 2))) as TotalOrderAmount,
        sum(cast(round(isnull(T.Paid, 0), 2) as decimal(19, 2))) as TotalPaidAmount
    from Task T
    where T.DateComplite < dateadd(day, 1, cast(@EndDate as date))
      and T.nState & 2 = 2
    group by T.idClient, T.TypeOrder
  ),
  PaymentSums as (
    -- Суммы оплат по клиентам и типам
    select
        P.idClient as ClientID,
        P.nType as Type,
        sum(cast(round(isnull(P.SumPay, 0), 2) as decimal(19, 2))) as TotalPaymentAmount,
        sum(cast(round(isnull(P.SumAlloc, 0), 2) as decimal(19, 2))) as TotalAllocatedAmount
    from Payment P
    where P.DatePay < dateadd(day, 1, cast(@EndDate as date))
    group by P.idClient, P.nType
  ),
  Result as (
    select
        C.Name as ClientName,
        U.ManagerName,
        CT.Type,
        cast(isnull(OS.TotalOrderAmount, 0) as decimal(19, 2)) as OrderAmount,
        cast(isnull(PS.TotalPaymentAmount, 0) as decimal(19, 2)) as PaymentAmount
    from Client C
    join ClientTypes CT on CT.ClientID = C.ID
    left join OrderSums OS on OS.ClientID = C.ID and OS.Type = CT.Type
    left join PaymentSums PS on PS.ClientID = C.ID and PS.Type = CT.Type
    left join Users U on U.ID = C.idUsers_PrimaryManager
  )

  select
      R.ClientName,
      R.ManagerName,
      R.Type,
      R.OrderAmount,
      R.PaymentAmount,
      case
        when R.OrderAmount > R.PaymentAmount then 1 -- Заказов больше
        when R.OrderAmount < R.PaymentAmount then 2 -- Платежей больше
        else 3 -- Равны
      end as AmountComparison
  from Result R
)
go