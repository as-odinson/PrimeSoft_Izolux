#include "stdafx.h"

#include "LoadHooks.h"

#include <MinHook.h>

#include "..\..\Design\Glass\ProjectViewGrid.h"
#include "..\..\Design\ABMfc\ABCatch.h"

#include "CProjectViewGrid_Export.h"

// STATE

static bool g_bInsideLoadTask = false;
static bool g_bHooksInitialized = false;


// ORIGINALS

typedef void(*tLoadTask) (CProjectViewGrid* pThis, long idTask);
static tLoadTask g_original = NULL;

//////////////////////////////////////////////////////////////////////////

// Хук для команды открытия заказа
void Hook_LoadTask(CProjectViewGrid* pThis, long idTask)
{
  if ( g_bInsideLoadTask )
  {
    g_original(pThis, idTask);
    return;
  }

  g_bInsideLoadTask = true;

  SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("HOOK LoadTask HIT"), false, true);

  CString s;
  s.Format(_T("idTask = %ld"), idTask);

  CProjectViewGrid_Export* pExport =
    reinterpret_cast<CProjectViewGrid_Export*>(pThis);

  pExport->LoadTask(idTask);

  g_bInsideLoadTask = false;
}

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

  InitLoadTaskHook();
}

void InitLoadTaskHook()
{
  //////////////////////////////////////////////////////
  // ПОЛУЧАЕМ RAW адрес метода
  //////////////////////////////////////////////////////

  union
  {
    void (CProjectViewGrid::* method)(long);
    void* addr;
  }
  convert;

  convert.method = &CProjectViewGrid::LoadTask;

  void* target = convert.addr;

  //////////////////////////////////////////////////////

  if ( !target )
  {
    SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("LoadTask address NOT FOUND"), false, true );
    return;
  }

  if ( MH_CreateHook(target, &Hook_LoadTask, reinterpret_cast<void**>(&g_original)) != MH_OK )
  {
    SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("MH_CreateHook FAILED"), false, true);
    return;
  }

  if ( MH_EnableHook(target) != MH_OK )
  {
    SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("MH_EnableHook FAILED"), false, true);
    return;
  }

  SaveError(__TFILE__, __LINE__, __TFUNCTION__, _T("LoadTask HOOK ENABLED"), false, true);
}
