#pragma once

class CProjectViewGrid;

void InitProjectViewGrid_SetPriceM2_WithNDSHook();
void PluginAddProtocol(LPCTSTR sProt);

typedef void(*tProjectViewGrid_SetPriceM2_WithNDS)(CProjectViewGrid* pThis, double fPriceM2);

extern tProjectViewGrid_SetPriceM2_WithNDS g_originalProjectViewGrid_SetPriceM2_WithNDS;
