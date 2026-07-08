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

bool HasProjectRebateSkipFlags(_RecordsetPtr rc)
{
  try
  {
    if ( !rc )
      return false;

    long nCount = rc->RecordCount;

    if ( nCount <= 0 )
      return false;

    // ставим закладку
    _variant_t vBookmark = rc->Bookmark;

    rc->MoveFirst();

    bool bFound = false;

    for ( long i = 0; i < nCount; i++ )
    {
      if ( ConvertDouble(rc, _T("SumWithNDS_Discount"), 0) == 1.0 )
      {
        bFound = true;
        break;
      }

      if ( i + 1 < nCount )
        rc->MoveNext();
    }

    // возвращаемся
    rc->Bookmark = vBookmark;

    return bFound;
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)

  return false;
}

void ClearProjectRebateSkipFlags(_RecordsetPtr rc)
{
  try
  {
    if ( !rc )
      return;

    long nCount = rc->RecordCount;

    if ( nCount <= 0 )
      return;

    // ставим закладку
    _variant_t vBookmark = rc->Bookmark;

    rc->MoveFirst();

    for ( long i = 0; i < nCount; i++ )
    {
      rc->Fields->GetItem("SumWithNDS_Discount")->Value = 0.0;

      if ( i + 1 < nCount )
        rc->MoveNext();
    }

    // возвращаеся
    rc->Bookmark = vBookmark;
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
}

void RecalcAllProjectsPrice(_RecordsetPtr rc)
{
  try
  {
    if ( !rc )
      return;

    _variant_t vBookmark = rc->Bookmark;
    rc->MoveFirst();

    for ( rc->MoveFirst(); !rc->adoEOF; rc->MoveNext() )
      PluginFireGlassPackCalcPrice();

    rc->Bookmark = vBookmark;
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
}

void __fastcall Hook_ProjectViewGrid_SetPriceM2_WithNDS(CProjectViewGrid* pThis, double fPriceM2)
{
  try
  {
    SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("HOOK CProjectViewGrid::SetPriceM2_WithNDS"), false, true);

    _ConnectionPtr  pConn(__uuidof(Connection));
    pConn = pThis->m_Recordset->GetActiveConnection();

    const double MIN_PRICE = 100.0; // Минимальная цена

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
    bool bSkipRebate = ConvertDouble(pThis->m_Recordset, _T("SumWithNDS_Discount"), 0) == (double)1;
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

      // Если скип тогда позиции не применям скидку
      if ( bSkipRebate )
        fRebate = 0; 

      if ( IsPriceByCount )
        fPriceAll = pThis->RoundMoney((fPriceM2R * fRebateCoefReal - fRebate) * fPriceCoef);
      else
        fPriceAll = pThis->RoundMoney((fPriceM2R * fRebateCoefReal - fRebate) * fArea * fPriceCoef);

      fPriceAll += pThis->RoundMoney(fPriceS) + pThis->RoundMoney(fPriceOper);
                  
      // Скидка/наценка на заказ
      double finalPriceAll = fPriceAll * fTaskRebate;

      if ( !bSkipRebate && fRebate > 0 && finalPriceAll < MIN_PRICE )
      {
        // Эта позиция не может принять равномерную скидку.
        // Помечаем её и считаем заново БЕЗ скидки заказа.
        pThis->m_Recordset->Fields->GetItem("SumWithNDS_Discount")->Value = 1.0;
        fRebate = 0; 

        sProtocol.AppendFormat(_T("\r\nСкидка заказа для позиции исключена: сумма %.2f меньше минимума %.2f."), finalPriceAll, MIN_PRICE);

        if ( IsPriceByCount )
          fPriceAll = pThis->RoundMoney((fPriceM2R * fRebateCoefReal - fRebate) * fPriceCoef);
        else
          fPriceAll = pThis->RoundMoney((fPriceM2R * fRebateCoefReal - fRebate) * fArea * fPriceCoef);

        fPriceAll += pThis->RoundMoney(fPriceS) + pThis->RoundMoney(fPriceOper);
        finalPriceAll = fPriceAll * fTaskRebate;
      }

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

    static bool bInRepeatCalc = false;
    bool bLastProject = false;
    
    try
    {
      bLastProject = pThis->m_Recordset->AbsolutePosition == pThis->m_Recordset->RecordCount;
    }
    catch ( ... )
    {
      bLastProject = false;
    }

    if ( bLastProject && !bInRepeatCalc && HasProjectRebateSkipFlags(pThis->m_Recordset) )
    {
      bInRepeatCalc = true;

      RecalcAllProjectsPrice(pThis->m_Recordset);
      ClearProjectRebateSkipFlags(pThis->m_Recordset);

      bInRepeatCalc = false;
    }

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

