#pragma once

#include <Prof-UIS.h>
#include "..\..\Design\Glass\TaskView.h"
#include "..\..\Design\WDOrder\DlgUsersSignAutority.h"

#define ID_EXPORT_UPD_TO_XML 33585
#define ID_RECALC_DEPTRANS_DOCDATE 62000

extern long nCommandIzolux;

class PCTaskViewGrid_Export : public CTaskViewGrid
{
public:
  PCTaskViewGrid_Export(TCHAR* lpsz);

  DECLARE_MESSAGE_MAP()

  afx_msg void OnPopupExportUPDToXML();
  afx_msg void OnPopupRecalcDepTransDocDate();

};