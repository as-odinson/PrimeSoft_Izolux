Option Explicit

' ============================================================
'  Engine_Auto.vbs
'  Автосборщик большого SQL-скрипта из папок с .sql файлами
'
' Достаточно просто поместить файл в папку, чтобы он попал в итоговый запрос
'  Запуск:
'    cscript //nologo Engine_Auto.vbs
'
'  Порядок выполнения регулируется:
'    - порядком папок в IncludeFolders
'    - именами файлов внутри папки: 001_x.sql, 002_y.sql и т.д.
' ============================================================

Dim UpdateName
UpdateName = "Engin_SQL_Plugin"

Dim OutDir, OutFile
OutDir  = "SQL"
OutFile = OutDir & "\" & UpdateName & ".sql"

Dim RootDir
RootDir = "."

' Рекурсивный поиск
Dim RecursiveScan
RecursiveScan = True

' Если не найдена папка не останавливать
Dim StopIfFolderMissing
StopIfFolderMissing = False

' Если не найден не останавливать
Dim StopIfSqlMissing
StopIfSqlMissing = False

' Вставлять автоматически go
Dim AddGoAfterEachFile
AddGoAfterEachFile = True


' Папки идут именно в таком порядке.
' Хочешь добавить новую категорию — добавь строку сюда и создай папку рядом со скриптом.
Dim IncludeFolders
IncludeFolders = Array( _
  "Tables", _
  "Update", _
  "View", _
  "Function", _
  "SP", _
  "Trigger" _
)

Dim fso, out, scriptDir, rootPath, outPath, fileCount
Set fso = CreateObject("Scripting.FileSystemObject")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
If Len(scriptDir) = 0 Then scriptDir = fso.GetAbsolutePathName(".")

rootPath = fso.GetAbsolutePathName(fso.BuildPath(scriptDir, RootDir))
outPath  = fso.GetAbsolutePathName(fso.BuildPath(scriptDir, OutFile))

If Not fso.FolderExists(fso.BuildPath(scriptDir, OutDir)) Then
  fso.CreateFolder fso.BuildPath(scriptDir, OutDir)
End If

Set out = fso.CreateTextFile(outPath, True, False) ' False = ANSI
fileCount = 0

WriteHeader UpdateName
BuildScript
WriteFooter

out.Close

If StopIfSqlMissing And fileCount = 0 Then
  WScript.Echo "ERROR: .sql файлы не найдены."
  WScript.Quit 1
End If

WScript.Echo "OK: generated " & outPath
WScript.Echo "Files included: " & fileCount
WScript.Quit 0

' ============================================================
'  Основная сборка
' ============================================================

Sub BuildScript()
  Dim i, folderName, folderPath, files

  For i = LBound(IncludeFolders) To UBound(IncludeFolders)
    folderName = IncludeFolders(i)
    folderPath = fso.BuildPath(rootPath, folderName)

    If fso.FolderExists(folderPath) Then
      Set files = CreateObject("System.Collections.ArrayList")
      CollectSqlFiles folderPath, files

      If files.Count > 0 Then
        files.Sort
        WriteSection folderName
        WriteFiles files
      End If
    ElseIf StopIfFolderMissing Then
      Fail "Папка не найдена: " & folderPath
    End If
  Next
End Sub

Sub CollectSqlFiles(ByVal folderPath, ByRef files)
  Dim folder, file, subFolder
  Set folder = fso.GetFolder(folderPath)

  For Each file In folder.Files
    If LCase(fso.GetExtensionName(file.Name)) = "sql" Then
      files.Add file.Path
    End If
  Next

  If RecursiveScan Then
    For Each subFolder In folder.SubFolders
      CollectSqlFiles subFolder.Path, files
    Next
  End If
End Sub

Sub WriteFiles(ByRef files)
  Dim i
  For i = 0 To files.Count - 1
    WriteFileBlock CStr(files(i))
  Next
End Sub

' ============================================================
'  Запись результата
' ============================================================

Sub WriteHeader(ByVal name)
  out.WriteLine "/*"
  out.WriteLine "  Update: " & name
  out.WriteLine "  Generated: " & Now
  out.WriteLine "  Generator: Engine_Auto.vbs"
  out.WriteLine "*/"
  out.WriteLine ""
  out.WriteLine "set nocount on"
  out.WriteLine "go"
End Sub

Sub WriteFooter()
  out.WriteLine ""
  out.WriteLine "print convert(varchar, getdate(), 20) + ' : update script finished'"
  out.WriteLine "go"
End Sub

Sub WriteSection(ByVal sectionName)
  out.WriteLine ""
  out.WriteLine "/* ============================================================"
  out.WriteLine "   " & sectionName
  out.WriteLine "   ============================================================ */"
  out.WriteLine ""
End Sub

Sub WriteFileBlock(ByVal fileName)
  Dim input, line

  fileCount = fileCount + 1

  out.WriteLine ""
  out.WriteLine "print convert(varchar, getdate(), 20) + ' : start " & EscapeSqlText(RelPath(fileName)) & "'"
  out.WriteLine "go"
  out.WriteLine ""
  out.WriteLine "-- ============================================================"
  out.WriteLine "-- File: " & RelPath(fileName)
  out.WriteLine "-- ============================================================"

  Set input = fso.OpenTextFile(fileName, 1, False)

  Do Until input.AtEndOfStream
    line = input.ReadLine
    out.WriteLine PrepareLine(line)
  Loop

  input.Close

  out.WriteLine ""

  If AddGoAfterEachFile Then
    out.WriteLine "go"
  End If

  out.WriteLine "print convert(varchar, getdate(), 20) + ' : finish " & EscapeSqlText(RelPath(fileName)) & "'"
  out.WriteLine "go"
End Sub

' ============================================================
'  Подготовка строк
' ============================================================

Function PrepareLine(ByVal line)
  Dim s
  s = line

  PrepareLine = s
End Function

Function RelPath(ByVal fullPath)
  Dim s
  s = fullPath

  If LCase(Left(s, Len(rootPath))) = LCase(rootPath) Then
    s = Mid(s, Len(rootPath) + 2)
  End If

  RelPath = s
End Function

Function EscapeSqlText(ByVal text)
  EscapeSqlText = Replace(text, "'", "''")
End Function

Function ReplaceRegex(ByVal text, ByVal pattern, ByVal replacement, ByVal ignoreCase)
  Dim re
  Set re = New RegExp
  re.Pattern = pattern
  re.IgnoreCase = ignoreCase
  re.Global = True
  ReplaceRegex = re.Replace(text, replacement)
End Function

Sub Fail(ByVal message)
  On Error Resume Next
  If Not out Is Nothing Then out.Close
  WScript.Echo "ERROR: " & message
  WScript.Quit 1
End Sub
