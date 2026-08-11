exec sp_RepS    10, 73, 0, 'MaterialsWithDateGap',               'Материалы разделенные датой',    'exec sp_GetMaterialsWithDateGap #@BegDate@#, #@EndDate@#', 101, '', '', null, 1
exec sp_RepS    8, 1, 0,   'SawTask_Statistic',                  'Статистика по раскроям ИЗО',                        '', 0, '', ''
exec sp_RepS    8,  300, 0, 'ArgonCams_IZO',                     'Камеры с аргоном ИЗО',                              '', 0, '', ''

exec sp_RepS    8, 21, 0,  'GlassWasteByProduction',            'Процент отхода по продукции за перод',                        '', 0, '', ''

exec sp_RepS     8,  311, 0, 'SawTaskUE_Period_Detail_Cut_IZO', 'Расчёт зарплаты резка (проверить)',      '', 0
exec sp_RepS     8,  312, 0, 'SawTaskUE_Period_Detail_ZAK_IZO', 'Расчёт зарплаты закалка (проверить)',    '', 0
exec sp_RepS     8,  313, 0, 'SawTaskUE_Period_Detail_Cut_Assembly_IZO',   'Расчёт зарплаты сборка (проверить)',   '', 0



exec sp_RepS    10, 73, 0, 'DepTurn_DepList_Izolux',             'Остатки на дату бух',            'exec sp_GetRest_DepTurnDepList #@idSubDivision@#, #@DocDate@#, 0', 101, '', '', null, 1
exec sp_RepS    10, 73, 0, 'DepTurn_AllDepList_Izolux',          'Остатки на дату',                'exec sp_GetRest_AllDepList #@idSubDivision@#, #@DocDate@#, 0', 101, '', '', null, 1
--update ReportList set bShowInMenu = 1 where RepName in 
--(
--'SawTaskUE_Period_Detail_Cut_IZO',
--'SawTaskUE_Period_Detail_ZAK_IZO',
--'SawTaskUE_Period_Detail_Cut_Assembly_IZO'
--)
go

