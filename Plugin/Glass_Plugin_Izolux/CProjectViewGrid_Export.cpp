// ProjectViewGrid_Export.cpp

#include "stdafx.h"
#include "CProjectViewGrid_Export.h"

#include "..\..\Design\ABMfc\ABCatch.h"
#include "..\..\Design\ABMfc\ABMfc_Export.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

IMPLEMENT_DYNCREATE(CProjectViewGrid_Export, CProjectViewGrid)

CProjectViewGrid_Export::CProjectViewGrid_Export()
  : CProjectViewGrid(_T("ProjectView\\Grid"))
{
}

void CProjectViewGrid_Export::LoadTask(long idTask)
{
  SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("HIT LoadTask"), false, true);

  // 1. базовая загрузка (оставляем ВСЮ логику системы)
  CProjectViewGrid::LoadTask(idTask);

  if ( !m_rcTask || m_rcTask->State != adStateOpen || IsEmpty(m_rcTask) )
    return;

  m_rcTask->MoveFirst();

  _ConnectionPtr pConn = m_rcTask->GetActiveConnection();
  if ( !pConn )
    return;

  // 2. получаем новое поле отдельно
  CString sSQL;
  sSQL.Format(_T("select NumGovernmentContract from v_Task where ID = %li"), idTask);

  _RecordsetPtr rcExtra(__uuidof(Recordset));
  rcExtra->Open((_bstr_t)sSQL,_variant_t((IDispatch*)pConn),adOpenStatic,adLockReadOnly,adCmdText);

  if ( !rcExtra->adoEOF )
  {
    _variant_t v = rcExtra->Fields->GetItem(_T("NumGovernmentContract"))->Value;
    m_rcTask->AddNew(_bstr_t(_T("NumGovernmentContract")), 0);
    m_rcTask->Fields->GetItem(_T("NumGovernmentContract"))->Value = v;
  }

  rcExtra->Close();
}
