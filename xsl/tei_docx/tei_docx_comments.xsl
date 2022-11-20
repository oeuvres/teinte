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
    <w:comments>
      <xsl:for-each select="//comment()">
        <w:comment w:id="3" w:initials="TEI" w:author="{$filename}">
          <xsl:attribute name="w:id">
            <xsl:call-template name="id"/>
          </xsl:attribute>
          <w:p>
            <w:pPr>
              <w:pStyle w:val="Commentaire"/>
            </w:pPr>
            <w:r>
              <w:t xml:space="preserve"><xsl:value-of select="."/></w:t>
            </w:r>
          </w:p>
        </w:comment>
      </xsl:for-each>
      </w:comments>
  </xsl:template>
</xsl:transform>