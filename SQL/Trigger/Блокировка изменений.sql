if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[trg_Warn_ImportantObjects]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[trg_Warn_ImportantObjects]
go

-- Чтобы внести изменения нужно сначала провести синхранизацию
create trigger trg_Warn_ImportantObjects
on database
for 
    create_view,
    alter_view,
    drop_view,
    create_procedure,
    alter_procedure,
    drop_procedure,
    create_function,
    alter_function,
    drop_function
as
begin
    set nocount on

    declare @data xml = eventdata()

    declare @obj sysname = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname')
    declare @schema sysname = @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname')

    if @obj in (
        'v_Invoice_Reject_IZO',
        'v_SawTask_Statistics',
        'v_SawItemSelect_Task',
        'v_Invoice_MXG',
        'v_InvoiceUKD',

        'sp_DepCalcReg_Add_Group',
        'sp_GetNextDepTransNumInvoice',
        'sp_GetPendingDepTrans',
        'sp_Invoice_IZO_Ship_Only',
        'sp_UPD_Task_XLS_Izolux',

        'f_GetNextAccountNum_BW',
        'f_SawTaskUE_Period_Detail_Shipment',
        'f_SawTaskUE_Period_Operator_Shipment'
    )
    begin
        print 'BLOCKED: modification of protected object ' + @schema + '.' + @obj

        rollback
    end
end
go
