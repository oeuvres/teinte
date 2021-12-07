<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
  
   xmlns="http://schemas.openxmlformats.org/package/2006/relationships"
   xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
   
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
  <xsl:import href="tei2docx.xsl"/>
  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
  <xsl:template match="/">
    <Relationships>
      <!-- Spécifique version MS.Word utilisée pour le template -->
      <xsl:variable name="templ" select="document($templPath)"/>
      <xsl:comment>
        <xsl:value-of select="$templPath"/>
        
        <xsl:copy-of select="$templ"/>
      </xsl:comment>
      <xsl:copy-of select="$templ/rel:Relationships/rel:Relationship[@Target != ''][not(@TargetMode) or @TargetMode != 'External']"/>
      <!-- do not register targets of links in notes -->
      <xsl:for-each select=".//tei:ref | .//tei:graphic">
        <xsl:choose>
          <xsl:when test="not(ancestor::tei:note)">
            <xsl:call-template name="rel"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="parent" select="local-name(ancestor::tei:note[1]/parent::*)"/>
            <xsl:choose>
              <xsl:when test="contains($parent, 'div') or $parent='lg'  or $parent='quote' or $parent='sp'">
                <xsl:call-template name="rel"/>
              </xsl:when>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </Relationships>
  </xsl:template>

</xsl:transform>