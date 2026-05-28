#include "stdafx.h"

#include "PCExportXml_UPD.h"

#include "..\..\Design\ABMfc\ABCatch.h"
#include "..\..\Design\ABMfc\ABMfc_Export.h"


PCExportXml_UPD::PCExportXml_UPD()
{
  m_idTask = 0;
  m_idUserSign = 0;
  m_Connection = NULL;

  m_rcData.CreateInstance(__uuidof(Recordset));
}

PCExportXml_UPD::~PCExportXml_UPD()
{

}

bool PCExportXml_UPD::DoExport()
{
  try
  {
    if ( !m_Connection )
      return false;

    if ( !m_Connection->State == adStateOpen )
      return false;

    if ( !m_idTask )
      return false;

    if ( m_sFileName.GetLength() == 0 )
      return false;

    // А теперь конвертим

    // Открываем данные
    CString sSQL;

    if ( m_rcData->GetState() == adStateOpen )
      m_rcData->Close();

    sSQL.Format(_T("exec sp_UPD_Task_XLS_Izolux_Export %li, %li, 1 "), m_idTask, m_idUserSign);

    RecordsetOpenReadOpt(m_rcData, _bstr_t(sSQL), m_Connection.GetInterfacePtr());

    if ( IsEmpty(m_rcData) )
      return false;

    m_rcData->MoveFirst();

    // Создаем XML
    CreateFile();
    ComposeHeader();
    ComposeTable();
    ComposeFooter();
    SaveFile();
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
  return false;
}

bool PCExportXml_UPD::CreateFile()
{
  try
  {
    m_XML.Create(_T("Файл"));

    CXmlNode  nodeRoot = m_XML.GetRoot();
    CString  sGUID = ConvertString(m_rcData, _T("TaskGUID"));

    sGUID.Replace(_T("{"), _T(""));
    sGUID.Replace(_T("}"), _T(""));

    nodeRoot.SetAttribute(_T("ВерсФорм"), _T("5.03"));
    nodeRoot.SetAttribute(_T("ВерсПрог"), _T("IzoGlass 2.0"));
    nodeRoot.SetAttribute(_T("ИдФайл"), sGUID);
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
    return false;
}

bool PCExportXml_UPD::ComposeHeader()
{
  try
  {
    CXmlNode      nodeRoot = m_XML.GetRoot();
    COleDateTime  DT(COleDateTime::GetCurrentTime());
    CString       sTime = DT.Format(_T("%H.%M.%S"));

    CString sDateNow        = ConvertString(m_rcData, _T("TodayDateStr")),
            sDateDoc        = ConvertString(m_rcData, _T("InvoiceDateStr")),
            sDatePayDoc     = ConvertString(m_rcData, _T("DatePayDoc")),
            sKomission      = ConvertString(m_rcData, _T("Komission")),
            sSellerNameFull = ConvertString(m_rcData, _T("SellerName_Show")),
            sSellerName     = ConvertString(m_rcData, _T("SellerName")),
            sSellerNameShow = sSellerName + _T(" / ") + sSellerNameFull,
            sSellerOKPO      = ConvertString(m_rcData,_T("SellerOKPO")),
            sNumCalcFactAdd = ConvertString(m_rcData, _T("NumCalcFactAdd")),
            sSellerUNN      = ConvertString(m_rcData, _T("SellerUNN")),
            sSellerKPP      = ConvertString(m_rcData, _T("SellerKPP")),
            sSubDivisionKPP = ConvertString(m_rcData, _T("SubDivisionKPP")),
            sSellerAddress  = ConvertString(m_rcData, _T("SellerAdress_Show")),
            sSellerCountry  = ConvertString(m_rcData, _T("SellerCountry")),
            sSellerRS       = ConvertString(m_rcData, _T("SellerRS")),
            sSellerBank     = ConvertString(m_rcData, _T("SellerBank")),
            sSellerBIC      = ConvertString(m_rcData, _T("SellerBIC")),
            sSellerKS       = ConvertString(m_rcData, _T("SellerKS")),
            sSubDivAddress  = ConvertString(m_rcData, _T("SubDivisionAddress")),
            sSubDivAddress_Ship = ConvertString(m_rcData, _T("SubDivisionAddress_Ship")),

            sConsNameFull   = ConvertString(m_rcData, _T("ConsigneeNameFull")),
            sConsAddress    = ConvertString(m_rcData, _T("AdressSubDiv")),
            sSubDivCountry  = ConvertString(m_rcData, _T("SubDivCountry")),
            sClientCountry  = ConvertString(m_rcData, _T("ClientCountry")),
            sClientNameFull = ConvertString(m_rcData, _T("ClientNameFull")),
            sClientChiefName= ConvertString(m_rcData, _T("ClientChiefName")),
            sClientUNN      = ConvertString(m_rcData, _T("ClientUNN")),
            sClientKPP      = ConvertString(m_rcData, _T("ClientKPP")),
            sClientAddress  = ConvertString(m_rcData, _T("ClientAdress")),
            sClientAdrSD    = ConvertString(m_rcData, _T("ClientAdressSubDiv")),
            sConsAddressNew = ConvertString(m_rcData, _T("ConsigneeAdress")),
            sConsAdrSDNew   = ConvertString(m_rcData, _T("ConsigneeAdressSubDiv")),
            sClientOKPO     = ConvertString(m_rcData, _T("ClientOKPO")),

            sLineCountStr   = ConvertString(m_rcData, _T("LineCountStr1"));
    
    int     iTypeAdress     = ConvertInt(m_rcData,    _T("idDefaultAdress"));

    CStringArray saChiefPartsName;
    ParseString(sClientChiefName, saChiefPartsName, _T(" "));

    CString clientChiefLastName = (saChiefPartsName.GetCount() > 0) ? saChiefPartsName[0]  : _T("_"),
            clientChiefName     = (saChiefPartsName.GetCount() > 1) ? saChiefPartsName[1]  : _T("_"),
            clientChiefSurname  = (saChiefPartsName.GetCount() > 2) ? saChiefPartsName[2]  : _T("_"),

            sNameDoc = _T("Документ об отгрузке товаров (выполнении работ), передаче имущественных прав (документ об оказании услуг)");

    sSellerUNN.Trim();
            
    m_nodeDoc = nodeRoot.NewChild(_T("Документ"));
    
    m_nodeDoc.SetAttribute(_T("КНД"),        _T("1115131"));
    m_nodeDoc.SetAttribute(_T("Функция"),    _T("СЧФДОП"));
    m_nodeDoc.SetAttribute(_T("ДатаИнфПр"),  sDateNow);
    m_nodeDoc.SetAttribute(_T("ВремИнфПр"),  sTime);

    m_nodeDoc.SetAttribute(_T("НаимДокОпр"), sNameDoc);
    m_nodeDoc.SetAttribute(_T("ПоФактХЖ"),   sNameDoc);

    m_nodeDoc.SetAttribute(_T("НаимЭконСубСост"), sSellerNameShow);

    CXmlNode nodeCalcFact = m_nodeDoc.NewChild(_T("СвСчФакт"));

    nodeCalcFact.SetAttribute(_T("НомерДок"), sNumCalcFactAdd);
    nodeCalcFact.SetAttribute(_T("ДатаДок"),  sDateDoc);

    //---
    CXmlNode nodeProd = nodeCalcFact.NewChild(_T("СвПрод"));

    nodeProd.SetAttribute(_T("ОКПО"), sSellerOKPO);

    CXmlNode nodeIDSV = nodeProd.NewChild(_T("ИдСв"));

    CXmlNode nodeJUR = nodeIDSV.NewChild(_T("СвЮЛУч")); 

    nodeJUR.SetAttribute(_T("НаимОрг"), sSellerNameShow);

    nodeJUR.SetAttribute(_T("ИННЮЛ"),   sSellerUNN);
    nodeJUR.SetAttribute(_T("КПП"),     sSubDivisionKPP);

    CXmlNode  nodeAddres  = nodeProd  .NewChild(_T("Адрес" )),
              nodeAddrInf = nodeAddres.NewChild(_T("АдрИнф"));
    
    nodeAddrInf.SetAttribute(_T("КодСтр"),    _T("643"));
    nodeAddrInf.SetAttribute(_T("НаимСтран"), sSellerCountry);
    nodeAddrInf.SetAttribute(_T("АдрТекст"),  sSellerAddress);

    CXmlNode nodeOtpr = nodeCalcFact.NewChild(_T("ГрузОт"));

    CXmlNode nodeGruzOtpr = nodeOtpr.NewChild(_T("ГрузОтпр"));

    nodeGruzOtpr.SetAttribute(_T("ОКПО"), sSellerOKPO);

    CXmlNode nodeIDSV1  = nodeGruzOtpr.NewChild(_T("ИдСв"));
    CXmlNode nodeJUR1   = nodeIDSV1.NewChild(_T("СвЮЛУч")); 

    nodeJUR1.SetAttribute(_T("НаимОрг"), sSellerNameShow);

    nodeJUR1.SetAttribute(_T("ИННЮЛ"),   sSellerUNN );

    nodeJUR1.SetAttribute(_T("КПП"), sSubDivisionKPP);

    CXmlNode nodeAddres1  = nodeGruzOtpr.NewChild(_T("Адрес"));
    CXmlNode nodeAddrInf1 = nodeAddres1.NewChild(_T("АдрИнф"));

    nodeAddrInf1.SetAttribute(_T("КодСтр"),    _T("643"));
    nodeAddrInf1.SetAttribute(_T("НаимСтран"), sSellerCountry);

    nodeAddrInf1.SetAttribute(_T("АдрТекст"), sSubDivAddress_Ship != "" ? sSubDivAddress_Ship : sSubDivAddress);

    //---
    CXmlNode nodeGruzPol = nodeCalcFact.NewChild(_T("ГрузПолуч"));

    if ( !( sClientOKPO == "" ) )
      nodeGruzPol.SetAttribute(_T("ОКПО"), sClientOKPO);

    CXmlNode nodeIDSV2   = nodeGruzPol.NewChild(_T("ИдСв"));

    // Если не ИП
    CString prefix = sConsNameFull.Left(2).MakeLower();
    if ( prefix.CompareNoCase(_T("ип")) == 0 )
    {
      CXmlNode nodeJUR2 = nodeIDSV2.NewChild(_T("СвИП"));

      nodeJUR2.SetAttribute(_T("ИННФЛ"), sClientUNN);

      CXmlNode nodeJUR2Name = nodeJUR2.NewChild(_T("ФИО"));

      nodeJUR2Name.SetAttribute(_T("Фамилия"),  clientChiefLastName);
      nodeJUR2Name.SetAttribute(_T("Имя"),      clientChiefName);
      nodeJUR2Name.SetAttribute(_T("Отчество"), clientChiefSurname);
    }
    else
    {
      CXmlNode nodeJUR2    = nodeIDSV2.NewChild(_T("СвЮЛУч")); 
  
      nodeJUR2.SetAttribute(_T("НаимОрг"), sClientNameFull);
      nodeJUR2.SetAttribute(_T("ИННЮЛ"),   sClientUNN);
      nodeJUR2.SetAttribute(_T("КПП"),     sClientKPP);
    }

    CXmlNode nodeAddres2  = nodeGruzPol.NewChild(_T("Адрес"));
    CXmlNode nodeAddrInf2 = nodeAddres2.NewChild(_T("АдрИнф"));

    nodeAddrInf2.SetAttribute(_T("КодСтр"),    _T("643"));
    nodeAddrInf2.SetAttribute(_T("НаимСтран"), sSubDivCountry);
    
    if ( iTypeAdress == 1 )
      nodeAddrInf2.SetAttribute(_T("АдрТекст"), sClientAddress);
    else if ( iTypeAdress == 2 )
      nodeAddrInf2.SetAttribute(_T("АдрТекст"), sClientAdrSD);
    else if ( iTypeAdress == 3  )
    {
      if ( sClientAdrSD != "" )
        nodeAddrInf2.SetAttribute(_T("АдрТекст"), sClientAdrSD);
      else
        nodeAddrInf2.SetAttribute(_T("АдрТекст"), sClientAddress);
    }
    else
      nodeAddrInf2.SetAttribute(_T("АдрТекст"),  sConsAddress);

    if ( !sKomission.IsEmpty() )
    {
      CString sPRDNumDoc;
      CString sPRDDateDoc;

      CString sTemp = sKomission;
      sTemp.Trim();

      int nPos = sTemp.Find(_T("от"));

      if ( nPos != -1 )
      {
        sPRDNumDoc = sTemp.Left(nPos);
        sPRDNumDoc.Trim();

        sPRDDateDoc = sTemp.Mid(nPos + 2);
        sPRDDateDoc.Trim();
      }
      else
      {
        sPRDNumDoc = sTemp;
      }


      CXmlNode nodePrd = nodeCalcFact.NewChild(_T("СвПРД"));

      nodePrd.SetAttribute(_T("НомерПРД"), sPRDNumDoc);
      nodePrd.SetAttribute(_T("ДатаПРД"), sPRDDateDoc);
    }

    CXmlNode nodeDocOtgr = nodeCalcFact.NewChild(_T("ДокПодтвОтгрНом"));

    nodeDocOtgr.SetAttribute(_T("РеквНомерДок"),  sNumCalcFactAdd );
    nodeDocOtgr.SetAttribute(_T("РеквДатаДок"),    sDateDoc       );
    nodeDocOtgr.SetAttribute(_T("РеквНаимДок"),   sNameDoc);

    CXmlNode nodeClient = nodeCalcFact.NewChild(_T("СвПокуп"));

    if (sClientOKPO != "")
      nodeClient.SetAttribute(_T("ОКПО"), sClientOKPO);

    CXmlNode nodeIDSV3  = nodeClient.NewChild(_T("ИдСв"));

    // Если не ИП
    if ( prefix.CompareNoCase(_T("ип")) == 0 )
    {
      CXmlNode nodeJUR3 = nodeIDSV3.NewChild(_T("СвИП"));
      nodeJUR3.SetAttribute(_T("ИННФЛ"), sClientUNN);

      CXmlNode nodeJUR3Name = nodeJUR3.NewChild(_T("ФИО"));

      nodeJUR3Name.SetAttribute(_T("Фамилия"),  clientChiefLastName);
      nodeJUR3Name.SetAttribute(_T("Имя"),      clientChiefName);
      nodeJUR3Name.SetAttribute(_T("Отчество"), clientChiefSurname);
    }
    else
    {
      CXmlNode nodeJUR3   = nodeIDSV3.NewChild(_T("СвЮЛУч")); 
  
      nodeJUR3.SetAttribute(_T("НаимОрг"), sClientNameFull);
      nodeJUR3.SetAttribute(_T("ИННЮЛ"),   sClientUNN);
      nodeJUR3.SetAttribute(_T("КПП"),     sClientKPP);
    }

    CXmlNode nodeAddres3  = nodeClient.NewChild(_T("Адрес"));
    CXmlNode nodeAddrInf3 = nodeAddres3.NewChild(_T("АдрИнф"));

    nodeAddrInf3.SetAttribute(_T("КодСтр"),    _T("643"));
    nodeAddrInf3.SetAttribute(_T("НаимСтран"), sClientCountry);
    nodeAddrInf3.SetAttribute(_T("АдрТекст"),  sClientAddress);

    //---
    CXmlNode nodePrice = nodeCalcFact.NewChild(_T("ДенИзм"));

    nodePrice.SetAttribute(_T("КодОКВ"),  _T("643"));
    nodePrice.SetAttribute(_T("НаимОКВ"), _T("Российский рубль"));
    //---

    CString sANumCalcFact = ConvertString(m_rcData, _T("A_NumCalcFact"));
    CString ForAccountNum = ConvertString(m_rcData, _T("ForAccountNum"));

    CXmlNode nodeDopSv = nodeCalcFact.NewChild(_T("ДопСвФХЖ1"));
    
    if ( !ForAccountNum.IsEmpty() )
      nodeDopSv.SetAttribute(_T("ИдГосКон"), ForAccountNum);

    if ( !sANumCalcFact.IsEmpty() )
    {
      CXmlNode nodeLastSopr = nodeDopSv.NewChild(_T("СопрДокФХЖ"));

      CString sNumDoc;
      CString sDateDoc;

      CString sTemp = sANumCalcFact;
      sTemp.Trim();

      int nPos = sTemp.Find(_T("от"));

      if ( nPos != -1 )
      {
        sNumDoc = sTemp.Left(nPos);
        sNumDoc.Trim();

        sDateDoc = sTemp.Mid(nPos + 2);
        sDateDoc.Trim();
      }
      else
      {
        sNumDoc = sTemp;
      }

      nodeLastSopr.SetAttribute(_T("РеквНаимДок"), _T("АСЧФ"));
      nodeLastSopr.SetAttribute(_T("РеквНомерДок"), sNumDoc);
      nodeLastSopr.SetAttribute(_T("РеквДатаДок"), sDateDoc);
    }
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
  return false;
}

bool PCExportXml_UPD::ComposeTable()
{
  try
  {
    CXmlNode  nodeTable         = m_nodeDoc.NewChild(_T("ТаблСчФакт"));
    long      nCountStr         = 0;
    double    dSumNoNDS_Total   = ConvertDouble(m_rcData, _T("TaskSumNoNDS")),
              dSumWithNDS_Total = ConvertDouble(m_rcData, _T("Price"   )),
              dSumNDS_Total     = ConvertDouble(m_rcData, _T("SumNDS"  ));
    CString   sSumNoNDS_Total,
              sSumWithNDS_Total,
              sSumNDS_Total;

    for ( m_rcData->MoveFirst(); !m_rcData->adoEOF; m_rcData->MoveNext() )
    {
      nCountStr += 1;

      CString sNumStr,
              sGPName     = ConvertString(m_rcData, _T("GPNameStr")),
              sCode       = ConvertString(m_rcData, _T("Unit_Code_OKEI")),
              sCountArea,
              sPriceWithNDS,
              sPriceNoNDS,
              sSumNoNDS,
              sTaxRate    = ConvertString(m_rcData, _T("Tax_rate")),
              sSumWithNDS,
              sSumNDS     = ConvertString(m_rcData, _T("NDS_Str")),
              sUnit       = ConvertString(m_rcData, _T("UnitName")),
              sCount      = ConvertString(m_rcData, _T("nCount"));

      double  dArea         = ConvertDouble(m_rcData, _T("Area"        )),
              dCountArea    = ConvertDouble(m_rcData, _T("nCountArea"       )),
              dPriceWithNDS = ConvertDouble(m_rcData, _T("PriceWithNDS_M2"  )),
              dPriceNoNDS   = ConvertDouble(m_rcData, _T("PriceNoNDS"       )),
              dSumNoNDS     = ConvertDouble(m_rcData, _T("SumNoNDS"    )),
              dSumWithNDS   = ConvertDouble(m_rcData, _T("PriceWithNDS")),
              dSumNDS       = ConvertDouble(m_rcData, _T("NDS_Num"));

      sNumStr.      Format(_T("%li"   ), nCountStr  );
      sCountArea.   Format(_T("%4.3lf"), dCountArea   );
      sPriceWithNDS.Format(_T("%4.2lf"), dPriceWithNDS);
      sPriceNoNDS.  Format(_T("%4.2lf"), dPriceNoNDS);
      sSumNoNDS.    Format(_T("%4.2lf"), dSumNoNDS  );
      sSumWithNDS.  Format(_T("%4.2lf"), dSumWithNDS);

      if ( sSumNDS != _T("Без НДС") )
        sSumNDS.Format(_T("%4.2lf"), dSumNDS);

      CXmlNode nodeStr = nodeTable.NewChild(_T("СведТов"));

      nodeStr.SetAttribute(_T("НомСтр"),      sNumStr    );
      nodeStr.SetAttribute(_T("НаимТов"),     sGPName    );
      nodeStr.SetAttribute(_T("ОКЕИ_Тов"),    sCode      );
      nodeStr.SetAttribute(_T("НаимЕдИзм"),   sUnit      );
      nodeStr.SetAttribute(_T("КолТов"),      sCountArea );
      nodeStr.SetAttribute(_T("ЦенаТов"),     sPriceNoNDS);
      nodeStr.SetAttribute(_T("СтТовБезНДС"), sSumNoNDS  );
      nodeStr.SetAttribute(_T("НалСт"),       sTaxRate   );
      nodeStr.SetAttribute(_T("СтТовУчНал"),  sSumWithNDS);

      CXmlNode nodeAkciz   = nodeStr.NewChild(_T("Акциз"));
      CXmlNode nodeNoAkciz = nodeAkciz.NewChild(_T("БезАкциз"));

      nodeNoAkciz.SetValue(_T("без акциза"));

      CXmlNode nodeSumNDS  = nodeStr.NewChild(_T("СумНал"));
      CXmlNode nodeSumNDS1 = nodeSumNDS.NewChild(_T("СумНал"));

      nodeSumNDS1.SetValue(sSumNDS);
    }

    sSumNoNDS_Total.  Format(_T("%4.2lf"), dSumNoNDS_Total  );
    sSumWithNDS_Total.Format(_T("%4.2lf"), dSumWithNDS_Total);
    sSumNDS_Total.    Format(_T("%4.2lf"), dSumNDS_Total    );

    CXmlNode nodeSummary = nodeTable.NewChild(_T("ВсегоОпл"));

    nodeSummary.SetAttribute(_T("СтТовБезНДСВсего"),  sSumNoNDS_Total);
    nodeSummary.SetAttribute(_T("СтТовУчНалВсего"),   sSumWithNDS_Total);

    CXmlNode nodeSumNDS  = nodeSummary.NewChild(_T("СумНалВсего"));
    CXmlNode nodeSumNDS1 = nodeSumNDS.NewChild(_T("СумНал"));

    nodeSumNDS1.SetValue(sSumNDS_Total);    
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
  return false;
}

bool PCExportXml_UPD::ComposeFooter()
{
  try
  {
    m_rcData->MoveFirst();

    CString sDateNow        = ConvertString(m_rcData, _T("TodayDateStr")),
            sDateDoc        = ConvertString(m_rcData, _T("InvoiceDateStr")),
            sTaskNum        = ConvertString(m_rcData, _T("TaskNum")),
            sAccountNum     = ConvertString(m_rcData, _T("AccountNum")),
            sClientNum      = ConvertString(m_rcData, _T("ClientNum")),   // Номер заявки клиента
            sTaskDate       = ConvertString(m_rcData, _T("TaskDateStr")),
            sPost           = ConvertString(m_rcData, _T("IOPost")),
            sTTNStr         = ConvertString(m_rcData, _T("TTN_Str")),
            sNumCalcFactAdd = ConvertString(m_rcData, _T("NumCalcFactAdd")),
            sSellerUNN      = ConvertString(m_rcData, _T("SellerUNN")),
            sSellerNameFull = ConvertString(m_rcData, _T("SellerName_Show")),
            sTTN_Cief_F     = ConvertString(m_rcData, _T("TTN_Chief_F")),
            sTTN_Cief_I     = ConvertString(m_rcData, _T("TTN_Chief_I")),
            sTTN_Cief_O     = ConvertString(m_rcData, _T("TTN_Chief_O")),
            sSignF,
            sSignI,
            sSignO,
            sTTN_Tran;
    double  dTotalArea      = ConvertDouble(m_rcData, _T("TotalArea"));

    if ( sClientNum.Trim().GetLength() > 0 )
      sClientNum.Format(_T(" (%s)"), sClientNum);

    sTTN_Tran.Format(_T("Итого отгружено: %.3f м2; %s"), dTotalArea, sTTNStr);

    sSellerUNN.Trim();

    CXmlNode  nodeSvProd = m_nodeDoc.NewChild(_T("СвПродПер"));
    CXmlNode  nodeSvPer  = nodeSvProd.NewChild(_T("СвПер"));

    nodeSvPer.SetAttribute(_T("СодОпер"), _T("Товары переданы"));
    nodeSvPer.SetAttribute(_T("ДатаПер"), sDateDoc);

    CXmlNode nodeOsn = nodeSvPer.NewChild(_T("ОснПер"));

    nodeOsn.SetAttribute(_T("РеквДатаДок"),    sTaskDate);
    nodeOsn.SetAttribute(_T("РеквНомерДок"),   sTaskNum);
    nodeOsn.SetAttribute(_T("РеквНаимДок"),    _T("Счёт"));

    nodeOsn.SetAttribute(_T("РеквДопСведДок"), _T("Задание №") + sAccountNum + sClientNum);

    CXmlNode nodeTrGr = nodeSvPer.NewChild(_T("Тран"));

    nodeTrGr.SetAttribute(_T("СвТран"), sTTN_Tran);

    //---
    CXmlNode nodeAuthority = m_nodeDoc.NewChild(_T("Подписант"));

    nodeAuthority.SetAttribute(_T("СпосПодтПолном"), _T("6"));
    nodeAuthority.SetAttribute(_T("ТипПодпис"),      _T("1"));
    nodeAuthority.SetAttribute(_T("ДопСведПодп"),    _T("Должностные обязанности"));
    
    nodeAuthority.SetAttribute(_T("Должн"),        _T("Генеральный директор"));

    CXmlNode nodeAutFIO = nodeAuthority.NewChild(_T("ФИО"));

    nodeAutFIO.SetAttribute(_T("Фамилия"),  sTTN_Cief_F);
    nodeAutFIO.SetAttribute(_T("Имя"),      sTTN_Cief_I);
    nodeAutFIO.SetAttribute(_T("Отчество"), sTTN_Cief_O);
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
  return false;
}

bool PCExportXml_UPD::SaveFile()
{
  try
  {
    // Подкорректируем имя файла - не любит XML такое
    m_sFileName.Replace(_T(".xls"), _T("#XML"));
    m_sFileName.Replace(_T("."), _T("_"));
    m_sFileName.Replace(_T("#XML"), _T(".xml"));

    m_XML.SaveWithFormatted(m_sFileName, _T("windows-1251"));
    m_XML.Close();
  }
  CATCH_HIDE(__TFILE__, __LINE__, __TFUNCTION__)
  return false;
}