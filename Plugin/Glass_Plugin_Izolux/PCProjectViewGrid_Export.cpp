#include "stdafx.h"
#include "PCProjectViewGrid_Export.h"

#include "..\..\Design\ABMfc\ABCatch.h"
#include "..\..\Design\ABMfc\ABMfc_Export.h"
#include "..\..\Design\ABMfc\ADOGridRecord.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

PCProjectViewGrid_Export::PCProjectViewGrid_Export(TCHAR* lpsz)
  : CProjectViewGrid(lpsz)
{
  m_iSort = -1;
  m_bASC = true;
}

PCProjectViewGrid_Export::PCProjectViewGrid_Export()
  : CProjectViewGrid()
{
  m_iSort = -1;
  m_bASC = true;
}

BEGIN_MESSAGE_MAP(PCProjectViewGrid_Export, CProjectViewGrid)
  ON_WM_LBUTTONUP()
END_MESSAGE_MAP()

void PCProjectViewGrid_Export::OnLButtonUp(UINT nFlags, CPoint point)
{
  try
  {
    CCellID cell = GetCellFromPt(point);

    // Запоминаем состояние ДО базовой функции,
    // потому что базовый GridCtrl сбрасывает m_MouseMode.
    bool bHeaderClick = m_eShow     != e_show_union_plot &&
                        cell.row    >= 0 &&
                        cell.row    < GetFixedRowCount() &&
                        cell.col    >= GetFixedColumnCount() &&
                        m_MouseMode != MOUSE_SIZING_COL &&
                        m_MouseMode != MOUSE_SIZING_ROW;

    // Полностью выполняем оригинальную логику приложения.
    CProjectViewGrid::OnLButtonUp(nFlags, point);

    // Добавляем только нашу сортировку поверх штатного поведения.
    if ( bHeaderClick )
      SetGridSort(cell.col, 1);
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
}

void PCProjectViewGrid_Export::SetGridSort(long nSort, int mode)
{
  try
  {
    if ( !m_Recordset ||
      m_Recordset->State != adStateOpen )
      return;

    if ( nSort < 0 ||
      nSort >= GetColumnCount() )
      return;

    int nField = GetFieldNum(nSort);

    if ( nField < 0 )
      return;

    CADOGridLinkField* pField = GetField(nField);

    if ( !pField )
      return;

    CString sFieldName = pField->FieldName;

    if ( sFieldName.IsEmpty() )
      return;

    // Новая колонка — первый клик ASC.
    if ( m_iSort != nSort )
    {
      m_iSort = nSort;
      m_bASC = true;
    }
    else if ( mode == 1 )
    {
     // Повторный клик меняет направление.
      m_bASC = !m_bASC;
    }

    CString sGUID;

    if ( Select_Cur() )
      sGUID = ConvertString(m_Recordset, _T("GUID"));

    CString sSort;

    sSort.Format(_T("%s %s"), sFieldName, m_bASC ? _T("ASC") : _T("DESC"));

    // Сортировка данных.
    m_Recordset->Sort = (_bstr_t)sSort;

    Init_Cells();

    // Штатная стрелочка GridCtrl.
    SetSortAscending(m_bASC ? TRUE : FALSE);
    SetSortColumn((int)nSort);

    // Вернёмся на позицию, которая была выбрана до сортировки.
    if ( sGUID.GetLength() )
      Select_Record(_T("GUID"), (_bstr_t)sGUID, false);

    Invalidate();
    UpdateWindow();
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
}
