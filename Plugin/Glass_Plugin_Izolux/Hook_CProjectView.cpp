#include "stdafx.h"
#include <map>

#include "..\..\Design\ABMfc\ADOGridRecord.h"
#include "..\..\Design\ABMfc\ABMfc_Export.h"
#include "..\..\Design\Glass\ProjectViewGrid.h"

#include <math.h>
#include "..\..\Lib\Memory\Decimal.h"

#include "Hook_CProjectView.h"
#include "ProgEventBridge.h"
#include <MinHook.h>

tProjectViewGrid_SetPriceM2_WithNDS g_originalProjectViewGrid_SetPriceM2_WithNDS = NULL;

const DECIMAL g_PluginConstDec = { 0 };

void Decimal::RoundDouble(double Val)
{
  if ( Val < 0 )
    Val = 0;

  double fPow = pow((double)10, decVal.scale);

  __int64 ResL = (__int64)(Val * fPow);
  double  fRes = ((double)ResL) / fPow;
  double  Remain = Val - fRes;

  if ( Remain >= 5 / pow((double)10, decVal.scale + 1) )
    ResL += 1;

  decVal.Lo64 = ResL;
}

Decimal::Decimal(BYTE Scale, double Val)
  : _variant_t(g_PluginConstDec)
{
  decVal.scale = Scale;
  decVal.signscale = Scale;

  RoundDouble(Val);
}

Decimal::~Decimal(void)
{
}

void __fastcall Hook_ProjectViewGrid_SetPriceM2_WithNDS(CProjectViewGrid* pThis, double fPriceM2)
{
  try
  {
    SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("HOOK CProjectViewGrid::SetPriceM2_WithNDS"), false, true);

    _ConnectionPtr  pConn(__uuidof(Connection));
    pConn = pThis->m_Recordset->GetActiveConnection();

    // Если нет коннекта, то поднимем его
    if ( !pConn && GetConnectFunc() )
      pConn = GetConnectFunc()();

    bool bRecalcPriceLock = ConvertBool(pThis->m_Recordset, _T("bRecalcPriceLock"));
    
    if ( bRecalcPriceLock )
      return;

    CString sProtocol;
    double fPriceM2R = fPriceM2 > 0 ? pThis->RoundMoney(fPriceM2) : 0;

    if (fPriceM2 >= 0)
    {
      if ( pThis->m_sChangedFieldName != _T("PriceByM") && pThis->m_sChangedFieldName != _T("PriceCoef") )
        pThis->m_Recordset->Fields->GetItem("PriceByM")->Value = fPriceM2R;

      int iRoundDigit = pThis->m_nRoundDigit;
      double fNDS_Coef = 1.0 + pThis->m_fNDS / 100.0;
      double fPriceM2NoNDSR = pThis->RoundMoney(fPriceM2R / fNDS_Coef, iRoundDigit);

      pThis->m_Recordset->Fields->GetItem("PriceByMNoNDS")->Value = fPriceM2NoNDSR;
      sProtocol.AppendFormat(_T("\r\nЦ.м2 б.НДС = %.2f / %.2f = %.2f"), fPriceM2R, fNDS_Coef, fPriceM2NoNDSR);
    }
    else
      fPriceM2R = ConvertDouble(pThis->m_Recordset, _T("PriceByM"));

    Decimal dePriceM2R(2, fPriceM2R);

    bool IsPriceByCount = ConvertBool(pThis->m_Recordset, _T("IsPriceByCount"));
    double fArea = ConvertDouble(pThis->m_Recordset, _T("Area"));
    double fRebate = ConvertDouble(pThis->m_Recordset, _T("Rebate"));
    double fRebateCoef = ConvertDouble(pThis->m_Recordset, _T("RebateCoef"), 1);
    double fTaskRebate = ConvertDouble(pThis->m_rcTask, _T("Rebate"));
    double fPriceAll = 0;
    double fRebateCoefReal = 2 - fRebateCoef;

    if ( pThis->m_sChangedFieldName == _T("PriceNDS") )
    {
      if ( IsPriceByCount )
        fPriceAll = pThis->RoundMoney((fPriceM2R * fRebateCoefReal - fRebate) * fTaskRebate);
      else
        fPriceAll = pThis->RoundMoney((fPriceM2R * fRebateCoefReal - fRebate) * fArea * fTaskRebate);
    }
    else
    {
      double fPriceS = ConvertDouble(pThis->m_Recordset, _T("PriceS"));
      double fPriceCoef = ConvertDouble(pThis->m_Recordset, _T("PriceCoef"));
      double fPriceOper = ConvertDouble(pThis->m_Recordset, _T("PriceOperation"));

      if ( IsPriceByCount )
        fPriceAll = pThis->RoundMoney((fPriceM2R * fRebateCoefReal - fRebate) * fPriceCoef);
      else
        fPriceAll = pThis->RoundMoney((fPriceM2R * fRebateCoefReal - fRebate) * fArea * fPriceCoef);

      fPriceAll += pThis->RoundMoney(fPriceS) + pThis->RoundMoney(fPriceOper);
                  
      // Скидка/наценка на заказ
      double finalPriceAll = fPriceAll * fTaskRebate;

      sProtocol.AppendFormat(_T("\r\nСумма с НДС = (%.2f * %.2f - %.2f)"), fPriceM2R, fRebateCoefReal, fRebate);
      if ( !IsPriceByCount )
        sProtocol.AppendFormat(_T(" * %.3f"), fArea);
      sProtocol.AppendFormat(_T(" * %.2f + %.2f + %.2f = %.2f"), fPriceCoef, fPriceS, fPriceOper, fPriceAll);

      sProtocol.AppendFormat(_T("\r\n%.2f * %.2f = %.2f"), fPriceAll, fTaskRebate, finalPriceAll);

      fPriceAll = finalPriceAll > 0
                ? finalPriceAll
                : 0;
    }

    PluginAddProtocol(sProtocol);

    pThis->SetPrice_WithNDS_Reverse(fPriceAll, false, dePriceM2R);

    //g_originalProjectViewGrid_SetPriceM2_WithNDS(pThis, fPriceM2);
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
}

void LoadDBSetting(_ConnectionPtr conn)
{
  //bool g_bLockRecalcPriceOnAllColumn = GetBoolFromSQL(_T("select isnull(d_iNum, 0) as res from Config where Name = 'bLockRecalcPriceOnAllColumn'"),_T("res"), conn.GetInterfacePtr(), true);
}

void InitProjectViewGrid_SetPriceM2_WithNDSHook()
{
  union
  {
    void (CProjectViewGrid::* method)(double);
    void* addr;
  } convert;

  convert.method = &CProjectViewGrid::SetPriceM2_WithNDS;

  void* target = convert.addr;

  if ( !target )
  {
    SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("CProjectViewGrid::SetPriceM2_WithNDS adres not found"), false, true);
    return;
  }

  if ( MH_CreateHook(target, &Hook_ProjectViewGrid_SetPriceM2_WithNDS, reinterpret_cast<void**>(&g_originalProjectViewGrid_SetPriceM2_WithNDS)) != MH_OK )
  {
    SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("MH_CreateHook CProjectViewGrid::SetPriceM2_WithNDS failed"), false, true);
    return;
  }

  if ( MH_EnableHook(target) != MH_OK )
  {
    SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("MH_EnableHook CProjectViewGrid::SetPriceM2_WithNDS failed"), false, true);
    return;
  }

  SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("CProjectViewGrid::SetPriceM2_WithNDS HOOKED"), false, true);
}

