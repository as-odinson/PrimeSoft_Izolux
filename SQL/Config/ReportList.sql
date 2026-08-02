exec sp_RepS    10, 73, 0, 'MaterialsWithDateGap',               'Материалы разделенные датой',    'exec sp_GetMaterialsWithDateGap #@BegDate@#, #@EndDate@#', 101, '', '', null, 1
exec sp_RepS    8, 1, 0,   'SawTask_Statistic',                  'Статистика по раскроям ИЗО',                        '', 0, '', ''
exec sp_RepS    8,  300, 0, 'ArgonCams_IZO',                     'Камеры с аргоном ИЗО',                              '', 0, '', ''

exec sp_RepS    8, 21, 0,  'GlassWasteByProduction',            'Процент отхода по продукции за перод',                        '', 0, '', ''
go

