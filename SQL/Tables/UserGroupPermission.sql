if object_id('dbo.UserGroupPermission', 'U') is null
begin
  create table dbo.UserGroupPermission
  (
    idUserGroup int not null primary key,

    TypeOrder0 bit null,
    TypeOrder1 bit null,
    TypeOrder2 bit null,

    bSecurity bit null,
    bPlanSetter bit null,
    bOptionsEdit bit null,
    bTaskAdd bit null,
    bTaskDelete bit null,
    bTaskProcessedDelete bit null,
    bTaskReopen bit null,
    bPositionEdit bit null,
    bTaskPlan bit null,
    bDateManufactEdit bit null,
    bToSaw bit null,
    bExportGPS bit null,
    bTaskReady bit null,
    bUserEdit bit null,

    bLockedTaskEdit bit null,
    bShippedTaskEdit bit null,
    bCreditEdit bit null,
    bFireClientOverdraftTask bit null,
    bManualMaterEdit bit null,
    bOpenOpenedBySomeoneDoc bit null,
    bAllowEditPaidTaskProperty bit null,
    bPreManufaktTask_Edit bit null,

    bShipLock bit null,
    bShipUnlock bit null,
    bAllowIgnoreDayLimitSP bit null,
    bWagesEdit bit null,
    bSetProcessComplete bit null,
    bClearProcessComplete bit null,

    bSetFactReject bit null,
    bRecalcTimeGlassProcSaw bit null,
    bIgnoreErrorParseFormule bit null,
    bChangeAddDepartment bit null,
    bEnableDelFreeZone bit null,
    bViewAnotherTask bit null,
    bShowAnotherTask bit null,
    bCanSavePlot bit null
  )
end
go

