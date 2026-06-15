#include "stdafx.h"
#include "Hook_CTaskView.h"
#include <MinHook.h>

tOnCreate g_originalOnCreate = NULL;

int Hook_OnCreate(CTaskView* pThis, LPCREATESTRUCT lpCreateStruct)
{
  SaveError(__TFILE__, __LINE__, __TFUNCTION__,
    _T("HOOK CTaskView::OnCreate"), false, true);

  int res = g_originalOnCreate(pThis, lpCreateStruct);

  if ( res == -1 )
    return res;
  
  RemoveSelectedTabs(pThis);
  // pThis->m_TabsWnd.ItemRemove(...)

  return res;
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
