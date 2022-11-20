<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
  
   xmlns="http://schemas.openxmlformats.org/package/2006/relationships"
   
   xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
   xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
   xmlns:o="urn:schemas-microsoft-com:office:office"
   xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
   xmlns:v="urn:schemas-microsoft-com:vml"
   xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
   xmlns:w10="urn:schemas-microsoft-com:office:word"
   xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
   xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
   xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
   xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
   xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
   xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
   xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
   xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
   
   xmlns:tei="http://www.tei-c.org/ns/1.0"
   exclude-result-prefixes="tei"
  >
  <xsl:import href="tei_docx.xsl"/>
  <xsl:template match="/">
    <Relationships>
      <xsl:apply-templates select="//tei:note[not(parent::tei:body | parent::tei:div | parent::tei:div1 | parent::tei:div2 | parent::tei:div3 | parent::tei:div4 | parent::tei:div5 | parent::tei:div6 | parent::tei:div7 | parent::tei:div8 | parent::tei:div9  | ancestor::tei:note | parent::tei:sp)]"/>
    </Relationships>
  </xsl:template>
  <xsl:template match="tei:note">
    <xsl:for-each select=".//tei:ref | .//tei:graphic">
      <xsl:call-template name="rel"/>
    </xsl:for-each>
  </xsl:template>
</xsl:transform>