#include "stdafx.h"
#include "PCTaskViewGrid_Export.h"

#include "..\..\Design\ABMfc\ABCatch.h"
#include "..\..\Design\ABMfc\ABMfc_Export.h"
#include "..\..\Design\ABMfc\ADOGridRecord.h"

#include "..\..\Design\ABMfc\FolderDialog.h"

#include <list>
#include "..\..\Design\Glass\GlobVar.h"

#include "PCExportXml_UPD.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

long nCommandIzolux = ID_RECALC_DEPTRANS_DOCDATE;

PCTaskViewGrid_Export::PCTaskViewGrid_Export(TCHAR* lpsz)
  : CTaskViewGrid(lpsz)
{
  Glass::IProgEventPtr pIPE(GetProgEventDispatch());
  if ( pIPE )
    nCommandIzolux = pIPE->GetNextIDPluginCommand();
}

BEGIN_MESSAGE_MAP(PCTaskViewGrid_Export, CTaskViewGrid)
  ON_COMMAND(ID_EXPORT_UPD_TO_XML, OnPopupExportUPDToXML)
  ON_COMMAND(nCommandIzolux, OnPopupRecalcDepTransDocDate)
END_MESSAGE_MAP()

/////////////
void PCTaskViewGrid_Export::OnPopupRecalcDepTransDocDate()
{
  try
  {
    _ConnectionPtr  pConn(__uuidof(Connection));
    pConn = m_Recordset->GetActiveConnection();

    if ( !pConn && GetConnectFunc() )
      pConn = GetConnectFunc()();

    CString        sSQL;
    sSQL.Format(_T("exec sp_UpdateDepTransDocDateByTask %lf, %lf"), m_pParent->m_dBegin, m_pParent->m_dEnd);
    RunSQL(sSQL, pConn.GetInterfacePtr());
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
}

void PCTaskViewGrid_Export::OnPopupExportUPDToXML()
{
  try
  {
    CWaitCursor  wc;

    _ConnectionPtr  pConn(__uuidof(Connection));
    pConn = m_Recordset->GetActiveConnection();

    // Если нет коннекта, то поднимем его
    if ( !pConn && GetConnectFunc() )
      pConn = GetConnectFunc()();

    if ( !pConn )
      return;

    CArray<long, long> arSelectedId;
    long idDepotSubDivision = 0;
    long idUserSign = 0;

    GetSelIdArray(_T("ID"), arSelectedId);

    CString sPathFolder;
    CString sFilter;
    CFolderDialog  DlgFolder(_T("Выберите папку"), sPathFolder, this, BIF_RETURNONLYFSDIRS | BIF_USENEWUI);

    if ( DlgFolder.DoModal() != IDOK )
      return;

    sPathFolder = DlgFolder.GetFolderPath();
    idDepotSubDivision = ConvertLong(m_Recordset, _T("idDepotSubDivision"));

    // TODO:
    idUserSign = 2;

    PCExportXml_UPD  XML_UPD;
    _RecordsetPtr   rc(__uuidof(Recordset));

    XML_UPD.m_nVersion   = 3;
    XML_UPD.m_idUserSign = idUserSign;
    XML_UPD.m_Connection = pConn;

    int nExported = 0;
    for ( int sel = 0; sel < arSelectedId.GetCount(); sel++ )
    {
      long idTask = arSelectedId[sel];

      sFilter.Format(_T("ID = %li"), idTask);

      m_Recordset->Filter = _bstr_t(sFilter);
      
      CString sClientName   = ConvertString(m_Recordset, _T("ClientName")),
              sDateComplite = ConvertString(m_Recordset, _T("DateComplite")),
              sAccountNum   = ConvertString(m_Recordset, _T("AccountNum"));

      // Очистка на всякий случай от недопустимых символов
      TCHAR* invalidChars = _T("\\/:*?\"<>|.");
      for (TCHAR* p = invalidChars; *p; ++p )
      {
        sClientName.Replace(CString(*p), _T(""));
        sAccountNum.Replace(CString(*p), _T(""));
      }

      sClientName.Trim();
      sAccountNum.Trim();
      sDateComplite.Replace(_T("."), _T("_"));

      CString  sClientFolder = sPathFolder + _T("\\") + sDateComplite;

      if ( !PathFileExists(sClientFolder) )
        if ( !CreateDirectory(sClientFolder, NULL) )
          break;

      sClientFolder += _T("\\") + sClientName;

      if ( !PathFileExists(sClientFolder) )
        if ( !CreateDirectory(sClientFolder, NULL) )
          break;

      CString  sFullFileName = sClientFolder + _T("\\") + sAccountNum + _T("#XML");

      XML_UPD.m_idTask    = idTask;
      XML_UPD.m_sFileName = sFullFileName;
      XML_UPD.m_eDocType  = e_XmlDocType_UKD;
      XML_UPD.DoExport();
      nExported++;
        
      m_Recordset->Filter = _bstr_t(_T(""));
    }

    CString sMsg;
    sMsg.Format(_T("Было выгружено %i отчётов"), nExported);
    ABMessageBox(sMsg);
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
}
