#include "stdafx.h"

#include "Main_Export.h"

#include "..\..\Design\ABMfc\ABCatch.h"
#include "PCTaskViewGrid_Export.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

BEGIN_MESSAGE_MAP(CMain_Export, CWinApp)
END_MESSAGE_MAP()

CMain_Export theApp;

/////////////////////////////////////////////////////////////////////////////

const GUID CDECL BASED_CODE _tlid =
{ 0xde5e0645, 0x7a8, 0x43be, { 0xbb, 0xc3, 0x20, 0x97, 0x6b, 0x41, 0xaf, 0x2b } };

const WORD _wVerMajor = 1;
const WORD _wVerMinor = 0;

/////////////////////////////////////////////////////////////////////////////

CMain_Export::CMain_Export()
{

}

BOOL CMain_Export::InitInstance()
{
  CWinApp::InitInstance();

  COleObjectFactory::RegisterAll();

  // InitHooks();

  return TRUE;
}

/////////////////////////////////////////////////////////////////////////////

STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID* ppv)
{
  AFX_MANAGE_STATE(AfxGetStaticModuleState());
  return AfxDllGetClassObject(rclsid, riid, ppv);
}

STDAPI DllCanUnloadNow(void)
{
  AFX_MANAGE_STATE(AfxGetStaticModuleState());
  return AfxDllCanUnloadNow();
}

STDAPI DllRegisterServer(void)
{
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  if ( !AfxOleRegisterTypeLib(AfxGetInstanceHandle(), _tlid) )
    return SELFREG_E_TYPELIB;

  if ( !COleObjectFactory::UpdateRegistryAll() )
    return SELFREG_E_CLASS;

  return S_OK;
}

STDAPI DllUnregisterServer(void)
{
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  if ( !AfxOleUnregisterTypeLib(_tlid, _wVerMajor, _wVerMinor) )
    return SELFREG_E_TYPELIB;

  if ( !COleObjectFactory::UpdateRegistryAll(FALSE) )
    return SELFREG_E_CLASS;

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////

class CExtPopupMenuWnd_Export : public CExtPopupMenuWnd
{
public:
  virtual BOOL UpdateFromMenu(HWND hWndCmdRecv, CMenu* pBuildMenu, bool bPopupMenu = true, bool bTopLevel = true, bool bNoRefToCmdMngr = false)
  {
    BOOL  bRes = FALSE;
    if ( pBuildMenu )
    {
      CMenu* pPopup = pBuildMenu->GetSubMenu(0);

      bRes = pPopup->AppendMenu(MF_SEPARATOR);
      bRes = pPopup->AppendMenu(MF_STRING | MF_ENABLED, nCommandIzolux, _T("Рассчитать даты документов"));
    }
    return CExtPopupMenuWnd::UpdateFromMenu(hWndCmdRecv, pBuildMenu, bPopupMenu, bTopLevel, bNoRefToCmdMngr);
  }
};

/////////////////////////////////////////////////////////////////////////////

extern __declspec(dllexport) void GetPluginFunctionName(LONG Index, char* szFunctionName, long iFunctionNameLeng, char* szMenuItemName, long iMenuItemNameLeng)
{
  if ( Index == 0 )
    strcpy_s(szFunctionName, iFunctionNameLeng, "PluginCreateObject");
  else
    strcpy_s(szFunctionName, iFunctionNameLeng, "break");
}

extern __declspec(dllexport) CObject* PluginCreateObject(const TCHAR* File, const TCHAR* szFunction, CRuntimeClass* pClassFunc, CRuntimeClass* pClassNew)
{
  if ( pClassNew == RUNTIME_CLASS(CExtPopupMenuWnd) && (CString)szFunction == "CTaskViewGrid::OnContextMenu" )
    return new CExtPopupMenuWnd_Export;

  if ( pClassNew == RUNTIME_CLASS(CTaskViewGrid) )
    return new PCTaskViewGrid_Export(_T("CTaskView\\Grid"));

  return NULL;
}
