#pragma once

#include <Prof-UIS.h>
#include "..\..\Design\Glass\TaskView.h"

class CTaskView;

typedef int (*tOnCreate)(CTaskView* pThis, LPCREATESTRUCT lpCreateStruct);
typedef bool (*tSetGridFilter)(CTaskView* pThis, long nFilter);

extern tOnCreate      g_originalOnCreate;
extern tSetGridFilter g_originalSetGridFilter;

int Hook_OnCreate(CTaskView* pThis, LPCREATESTRUCT lpCreateStruct);
bool Hook_SetGridFilter(CTaskView* pThis, long nFilter);

void InitOnCreateHook();

void RemoveSelectedTabs(CTaskView* pThis);
long GetRealTaskFilterIndex(CTaskView* pThis, long nFilter);
