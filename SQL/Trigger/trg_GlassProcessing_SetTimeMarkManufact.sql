if object_id(N'dbo.trg_GlassProcessing_SetTimeMarkManufact', N'TR') is not null
    drop trigger dbo.trg_GlassProcessing_SetTimeMarkManufact
go

-- Гарантия что установим TimeManufact после того как проставим готовность
create trigger dbo.trg_GlassProcessing_SetTimeMarkManufact
on dbo.GlassProcessing
after insert, update
as
begin
    set nocount on

    -- Защита от повторного входа после update внутри триггера
    if trigger_nestlevel() > 1
        return

    update GP
    set
        GP.TimeMarkManufact =
            case
                -- Готовность только что поставили
                when isnull(I.bFinished, 0) = 1
                 and isnull(D.bFinished, 0) = 0
                then
                    case
                        -- Новая запись, дата уже передана приложением
                        when D.ID is null 
                         and I.TimeMarkManufact is not null
                            then I.TimeMarkManufact

                        -- При обновлении приложение передало новую дату
                        when D.ID is not null
                         and I.TimeMarkManufact is not null
                         and
                         (
                             D.TimeMarkManufact is null
                             or I.TimeMarkManufact <> D.TimeMarkManufact
                         )
                            then I.TimeMarkManufact

                        -- Когда в диалге ИзоГласс просто поставили галку готовности, а дату не передали
                        else getdate()
                    end

                -- Готовность сняли
                when isnull(I.bFinished, 0) = 0
                 and isnull(D.bFinished, 0) = 1
                    then null

                else GP.TimeMarkManufact
            end
    from dbo.GlassProcessing GP
    inner join inserted I on I.ID = GP.ID
    left join deleted D on D.ID = I.ID
    where
        (
            isnull(I.bFinished, 0) = 1
            and isnull(D.bFinished, 0) = 0
        )
        or
        (
            isnull(I.bFinished, 0) = 0
            and isnull(D.bFinished, 0) = 1
        )
end
go