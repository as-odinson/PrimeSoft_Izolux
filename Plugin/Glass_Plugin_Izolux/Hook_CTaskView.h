#pragma once

#include <Prof-UIS.h>
#include "..\..\Design\Glass\TaskView.h"

class CTaskView;

typedef int (*tOnCreate)(CTaskView* pThis, LPCREATESTRUCT lpCreateStruct);

extern tOnCreate g_originalOnCreate;

int Hook_OnCreate(CTaskView* pThis, LPCREATESTRUCT lpCreateStruct);
void InitOnCreateHook();

void RemoveSelectedTabs(CTaskView* pThis);