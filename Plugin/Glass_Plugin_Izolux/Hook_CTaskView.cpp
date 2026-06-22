#include "stdafx.h"
#include "Hook_CTaskView.h"
#include <MinHook.h>

tOnCreate g_originalOnCreate = NULL;
tSetGridFilter g_originalSetGridFilter = NULL;

int Hook_OnCreate(CTaskView* pThis, LPCREATESTRUCT lpCreateStruct)
{
  SaveError(__TFILE__, __LINE__, __TFUNCTION__,_T("HOOK CTaskView::OnCreate"), false, true);

  int res = g_originalOnCreate(pThis, lpCreateStruct);

  if ( res == -1 )
    return res;
  
  RemoveSelectedTabs(pThis);
  // pThis->m_TabsWnd.ItemRemove(...)

  return res;
}

long GetRealTaskFilterIndex(CTaskView* pThis, long nFilter)
{
  if ( !pThis || nFilter < 0 )
    return 0;

  int count = pThis->m_TabsWnd.ItemGetCount();

  // After removing tabs visual index is not equal to the old SetGridFilter index.
  // Map current tab text back to original filter number.
  if ( nFilter >= 0 && nFilter < count )
  {
    CString text = pThis->m_TabsWnd.ItemTextGet(nFilter);

    if ( text == _T("Все") )                  return 0;
    if ( text == _T("Предзаказ") )            return 1;
    if ( text == _T("Новые") )                return 2;
    if ( text == _T("Запланировано") )        return 3;
    if ( text == _T("Производить") )          return 4;
    if ( text == _T("Раскроенные") )          return 5;
    if ( text == _T("Част.Изготовлен") )      return 6;
    if ( text == _T("Изготовленные") )        return 7;
    if ( text == _T("Отгруженные") )          return 8;
    if ( text == _T("Частич.Отгруж.") )       return 9;
    if ( text == _T("Редкие/Ожидающие") )     return 10;
    if ( text == _T("Редкие/Отправленые") )   return 11;
    if ( text == _T("Проверены") )            return 12;
    if ( text == _T("На согласование") )      return 13;
    if ( text == _T("Согласовано") )          return 14;
    if ( text == _T("Отказ клиента") )        return 15;
    if ( text == _T("Обработка чертежей") )   return 16;
    if ( text == _T("Обработка ПДО") )        return 17;
  }

  return nFilter;
}

bool Hook_SetGridFilter(CTaskView* pThis, long nFilter)
{
  long realFilter = GetRealTaskFilterIndex(pThis, nFilter);

  return g_originalSetGridFilter(pThis, realFilter);
}


void InitOnCreateHook()
{
  union
  {
    int (CTaskView::* method)(LPCREATESTRUCT);
    void* addr;
  } convert;

  convert.method = &CTaskView::OnCreate;

  void* target = convert.addr;

  if ( !target )
  {
    SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("OnCreate addr not found"), false, true);
    return;
  }

  if ( MH_CreateHook(target, &Hook_OnCreate, reinterpret_cast<void**>(&g_originalOnCreate)) != MH_OK )
  {
    SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("MH_CreateHook failed"), false, true);
    return;
  }

  MH_EnableHook(target);

  SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("CTaskView::OnCreate HOOKED"), false, true);

  union
  {
    bool (CTaskView::* method)(long);
    void* addr;
  } convertSetGridFilter;

  convertSetGridFilter.method = &CTaskView::SetGridFilter;

  void* targetSetGridFilter = convertSetGridFilter.addr;

  if ( !targetSetGridFilter )
  {
    SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("SetGridFilter addr not found"), false, true);
    return;
  }

  if ( MH_CreateHook(targetSetGridFilter, &Hook_SetGridFilter, reinterpret_cast<void**>(&g_originalSetGridFilter)) != MH_OK )
  {
    SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("MH_CreateHook SetGridFilter failed"), false, true);
    return;
  }

  MH_EnableHook(targetSetGridFilter);

  SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("CTaskView::SetGridFilter HOOKED"), false, true);
}

void RemoveSelectedTabs(CTaskView* pThis)
{
  static const CString kRemove[] =
  {
    _T("Новые"),
    _T("Запланировано"),
    _T("Редкие/Ожидающие"),
    _T("Редкие/Отправленые"),
    _T("Проверены")
  };

  int count = pThis->m_TabsWnd.ItemGetCount();

  for ( int i = count - 1; i >= 0; --i )
  {
    CString text = pThis->m_TabsWnd.ItemTextGet(i);

    for ( int k = 0; k < _countof(kRemove); ++k )
    {
      if ( text == kRemove[k] )
      {
        pThis->m_TabsWnd.ItemRemove(i);
        break;
      }
    }
  }
}
