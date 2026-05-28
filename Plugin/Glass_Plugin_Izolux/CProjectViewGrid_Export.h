// ProjectViewGrid_Export.h

#pragma once

#include "..\..\Design\Glass\ProjectViewGrid.h"

class CProjectViewGrid_Export : public CProjectViewGrid
{
  DECLARE_DYNCREATE(CProjectViewGrid_Export)

public:
  CProjectViewGrid_Export();

  virtual void LoadTask(long idTask);
};