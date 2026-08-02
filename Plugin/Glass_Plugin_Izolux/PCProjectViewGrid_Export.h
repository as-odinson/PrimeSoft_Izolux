#pragma once

#include <Prof-UIS.h>
#include "..\..\Design\Glass\ProjectViewGrid.h"

class PCProjectViewGrid_Export : public CProjectViewGrid
{
public:
  PCProjectViewGrid_Export();
  PCProjectViewGrid_Export(TCHAR* lpsz);

  DECLARE_MESSAGE_MAP()

protected:
  afx_msg void OnLButtonUp(UINT nFlags, CPoint point);

  void SetGridSort(long nSort, int mode);

  long m_iSort;
  bool m_bASC;
};