#include "stdafx.h"
#include "ProgEventBridge.h"
#include "..\..\Design\ABMfc\ADOGridRecord.h"


namespace
{
  const size_t kProgEventOffsets[] =
  {
    0xA08, // текущий CMainFrame::m_pProgEvent

    // возможные нижние значения для поиска: если адрес m_pProgEvent ниже
    0xA10,
    0xA18,
    0xA20,

    // возможные вверхние значения: если адрес m_pProgEvent выше
    0xA00
  };

  const DISPID kDispIdAddProtocol = 22; // CProgEvent::AddProtocol

  CCmdTarget* g_pCachedProgEvent = NULL;
  bool        g_bProgEventSearchFailed = false;

  bool IsReadablePtr(const void* p)
  {
    if ( !p || p == (void*)-1 )
      return false;

    MEMORY_BASIC_INFORMATION mbi;

    if ( VirtualQuery(p, &mbi, sizeof(mbi)) == 0 )
      return false;

    return mbi.State == MEM_COMMIT      &&
         !(mbi.Protect & PAGE_NOACCESS) &&
         !(mbi.Protect & PAGE_GUARD);
  }

  CWnd* GetMainFrameWnd()
  {
    CWinApp* pApp = AfxGetApp();

    if ( !pApp )
      return NULL;

    return pApp->m_pMainWnd;
  }

  CCmdTarget* GetProgEventByOffset(CWnd* pMainWnd, size_t offset)
  {
    if ( !pMainWnd )
      return NULL;

    BYTE* pMainFrame = (BYTE*)pMainWnd;
    CCmdTarget* pCandidate = *(CCmdTarget**)(pMainFrame + offset);

    if ( !IsReadablePtr(pCandidate) )
      return NULL;

    return pCandidate;
  }

  bool HasAddProtocolMethod(CCmdTarget* pProgEvent)
  {
    if ( !pProgEvent )
      return false;

    IDispatch* pDisp = pProgEvent->GetIDispatch(FALSE);

    if ( !pDisp )
      return false;

    OLECHAR* szName = L"AddProtocol";
    DISPID dispid = DISPID_UNKNOWN;

    HRESULT hr = pDisp->GetIDsOfNames(IID_NULL, &szName, 1, LOCALE_USER_DEFAULT, &dispid);

    return SUCCEEDED(hr) && dispid == kDispIdAddProtocol;
  }

  bool InvokeAddProtocol(CCmdTarget* pProgEvent, LPCTSTR sProt)
  {
    if ( !pProgEvent || !sProt || !*sProt )
      return false;

    IDispatch* pDisp = pProgEvent->GetIDispatch(FALSE);

    if ( !pDisp )
      return false;

    _variant_t vText(sProt);

    DISPPARAMS params;
    ZeroMemory(&params, sizeof(params));

    params.rgvarg = &vText;
    params.cArgs = 1;

    HRESULT hr = pDisp->Invoke(kDispIdAddProtocol, IID_NULL, LOCALE_USER_DEFAULT, DISPATCH_METHOD, &params, NULL, NULL, NULL);

    return SUCCEEDED(hr);
  }

  CCmdTarget* FindProgEvent()
  {
    CWnd* pMainWnd = GetMainFrameWnd();

    if ( !pMainWnd )
      return NULL;

    for ( int i = 0; i < _countof(kProgEventOffsets); i++ )
    {
      CCmdTarget* pCandidate = GetProgEventByOffset(pMainWnd, kProgEventOffsets[i]);

      if ( !pCandidate )
        continue;

      if ( HasAddProtocolMethod(pCandidate) )
      {
        CString sLog;
        sLog.Format(_T("CProgEvent найден адрес: 0x%IX"), kProgEventOffsets[i]);
        SaveError(__TFILE__, __LINE__, __TFUNCTION__, sLog, false, true);

        return pCandidate;
      }
    }

    return NULL;
  }

  CCmdTarget* GetProgEvent()
  {
    if ( g_pCachedProgEvent && IsReadablePtr(g_pCachedProgEvent) )
      return g_pCachedProgEvent;

    if ( g_bProgEventSearchFailed )
      return NULL;

    g_pCachedProgEvent = FindProgEvent();

    if ( !g_pCachedProgEvent )
      g_bProgEventSearchFailed = true;

    return g_pCachedProgEvent;
  }
}

void PluginAddProtocol(LPCTSTR sProt)
{
  try
  {
    if ( !sProt || !*sProt )
      return;

    CCmdTarget* pProgEvent = GetProgEvent();

    if ( !pProgEvent )
      return;

    if ( !InvokeAddProtocol(pProgEvent, sProt) )
    {
      g_pCachedProgEvent = NULL;
      g_bProgEventSearchFailed = false;

      SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("CProgEvent::AddProtocol InvokeAddProtocol failed"), false, true);
    }
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
}
