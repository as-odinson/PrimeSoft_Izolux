#include "stdafx.h"

#include "LoadHooks.h"
#include "Hook_CTaskView.h"
#include <MinHook.h>


// STATE
static bool g_bHooksInitialized = false;

//////////////////////////////////////////////////////////////////////////

void InitHooks()
{
  if ( g_bHooksInitialized )
    return;

  g_bHooksInitialized = true;

  if ( MH_Initialize() != MH_OK )
  {
    SaveError(__TFILE__, __LINE__, __TFUNCTION__,_T("MinHook init failed"), false, true);
    return;
  }

  InitOnCreateHook();
}
