create table dbo.GlassProcessing_Audit_Debug
(
    ID int identity(1,1) primary key,
    DateLog datetime not null default getdate(),

    LoginName nvarchar(128) null,
    HostName nvarchar(128) null,
    AppName nvarchar(128) null,
    Spid int null,

    GlassProcessingID int null,
    idGlassDetails int null,
    idSectorManufact int null,

    Old_bFinished bit null,
    New_bFinished bit null,

    Old_TimeProcessingComplete datetime null,
    New_TimeProcessingComplete datetime null,

    Old_TimeMarkManufact datetime null,
    New_TimeMarkManufact datetime null,

    Old_idSheduleOperator int null,
    New_idSheduleOperator int null
)
go

create trigger dbo.trg_GlassProcessing_Audit_Debug
on dbo.GlassProcessing
after update
as
begin
    set nocount on

    insert into dbo.GlassProcessing_Audit_Debug
    (
        LoginName,
        HostName,
        AppName,
        Spid,

        GlassProcessingID,
        idGlassDetails,
        idSectorManufact,

        Old_bFinished,
        New_bFinished,

        Old_TimeProcessingComplete,
        New_TimeProcessingComplete,

        Old_TimeMarkManufact,
        New_TimeMarkManufact,

        Old_idSheduleOperator,
        New_idSheduleOperator
    )
    select
        suser_sname(),
        host_name(),
        app_name(),
        @@spid,

        i.ID,
        i.idGlassDetails,
        i.idSectorManufact,

        d.bFinished,
        i.bFinished,

        d.TimeProcessingComplete,
        i.TimeProcessingComplete,

        d.TimeMarkManufact,
        i.TimeMarkManufact,

        d.idSheduleOperator,
        i.idSheduleOperator
    from inserted i
    inner join deleted d on d.ID = i.ID
    where
        isnull(d.bFinished, 0) <> isnull(i.bFinished, 0)
        or isnull(d.TimeProcessingComplete, '19000101') <> isnull(i.TimeProcessingComplete, '19000101')
        or isnull(d.TimeMarkManufact, '19000101') <> isnull(i.TimeMarkManufact, '19000101')
        or isnull(d.idSheduleOperator, -1) <> isnull(i.idSheduleOperator, -1)
end
go

select distinct GPA.New_idSheduleOperator, O.Name from GlassProcessing_Audit_Debug GPA
join GlassDetails GD on GD.ID = GPA.idGlassDetails
join SheduleOperator sh on sh.ID = GPA.New_idSheduleOperator
join Operator O on O.ID = sh.idOperator
where GD.idSawTaskMain = 2692

