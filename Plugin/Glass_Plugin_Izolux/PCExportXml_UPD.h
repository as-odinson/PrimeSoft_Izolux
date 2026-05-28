#pragma once

#include "stdafx.h"
#include "..\..\Design\Glass\GlobVar.h"

#include "..\..\Lib\Common\Xml.h"

using namespace JWXml;

enum eXmlDocType
{
  e_XmlDocType_UPD = 1,  // УПД
  e_XmlDocType_UKD = 2   // корректировка на упд
};

class PCExportXml_UPD
{
public:
  PCExportXml_UPD();
  ~PCExportXml_UPD();

public:
  long           m_nVersion; 
  eXmlDocType    m_eDocType;    // 1 для УПД, 2 для УКД
  long           m_idTask;
  long           m_idUserSign;
  CString        m_sFileName;
  _ConnectionPtr m_Connection;
  _RecordsetPtr  m_rcData;
  CXml           m_XML;
  CXmlNode       m_nodeDoc;

public:
  bool DoExport();
  bool CreateFile();
  bool ComposeHeader();
  bool ComposeTable();
  bool ComposeFooter();
  bool SaveFile();
};
