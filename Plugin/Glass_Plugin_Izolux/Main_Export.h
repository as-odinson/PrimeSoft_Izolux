#pragma once

#ifndef __AFXWIN_H__
  #error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"
#include "..\..\Design\ABMfc\ABADO.h"

class CMain_Export : public CWinApp
{
public:
  CMain_Export();

public:
  virtual BOOL InitInstance();

  DECLARE_MESSAGE_MAP()
};