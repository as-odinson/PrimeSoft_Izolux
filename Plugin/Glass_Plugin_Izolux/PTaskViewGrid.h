#pragma once

#include <Prof-UIS.h>
#include "..\..\Design\Glass\TaskView.h"

#define UKD_EXPORT 33585

class PTaskViewGrid_Export : public CTaskViewGrid
{
public:
  PTaskViewGrid_Export(TCHAR* lpsz);

  DECLARE_MESSAGE_MAP()

  void OnPopupExportUPDToXML();

  void DoExportUPDToXML();
};