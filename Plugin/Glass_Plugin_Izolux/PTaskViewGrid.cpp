#include "stdafx.h"
#include "PTaskViewGrid.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

PTaskViewGrid_Export::PTaskViewGrid_Export(TCHAR* lpsz)
  : CTaskViewGrid(lpsz)
{
  
}

BEGIN_MESSAGE_MAP(PTaskViewGrid_Export, CTaskViewGrid)
END_MESSAGE_MAP()


void PTaskViewGrid_Export::OnPopupExportUPDToXML()
{
  DoExportUPDToXML();
}

void PTaskViewGrid_Export::DoExportUPDToXML()
{
  try
  {
    AfxMessageBox(_T("EXPORT START"));

    // сюда вставл€ешь всЄ что нужно
    long x = 1;

    // DB / XML / логика Ч только здесь
  }
  catch ( ... )
  {
  }
}