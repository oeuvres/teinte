<?xml version="1.0" encoding="UTF-8"?>
<!--

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2018 Frederic.Glorieux@fictif.org

-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="tei"
  >
  
  
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" method="xml" indent="yes"/>
  
  <xsl:template match="node()|@*" mode="oe">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="oe"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="/">
    <xsl:apply-templates mode="oe"/>
  </xsl:template>
  <xsl:template match="/processing-instruction()"/>
  <xsl:template match="/tei:TEI" mode="oe">
    <TEI xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.tei-c.org/ns/1.0 ../tei.openedition/xsd/tei.openedition.1.5.2/tei.openedition.1.5.2.xsd"
    >
      <xsl:apply-templates select="@*" mode="oe"/>
      <teiHeader>
        <xsl:apply-templates select="tei:teiHeader/tei:fileDesc" mode="oe"/>
        <encodingDesc>
          <xsl:apply-templates select="tei:teiHeader/tei:encodingDesc/tei:projectDesc" mode="oe"/>
        </encodingDesc>
        <tagsDecl>
          <rendition xml:id="center" scheme="css">text-align: center</rendition>
          <rendition xml:id="i" scheme="css">font-style: italic</rendition>
          <rendition xml:id="italic" scheme="css">font-style: italic</rendition>
          <rendition xml:id="b" scheme="css">font-weight: bold</rendition>
          <rendition xml:id="bold" scheme="css">font-weight: bold</rendition>
          <rendition xml:id="u" scheme="css">text-decoration: underline</rendition>
          <rendition xml:id="underline" scheme="css">text-decoration: underline</rendition>
          <rendition xml:id="sc" scheme="css">font-variant: small-caps</rendition>
          <rendition xml:id="small-caps" scheme="css">font-variant: small-caps</rendition>
          <rendition xml:id="sup" scheme="css">vertical-align: super</rendition>
          <rendition xml:id="super" scheme="css">vertical-align: super</rendition>
          <rendition xml:id="sub" scheme="css">vertical-align: sub</rendition>
          <rendition xml:id="title" scheme="css">font-style: italic</rendition>
        </tagsDecl>
        <profileDesc>
          <xsl:apply-templates select="tei:teiHeader/tei:profileDesc/tei:langUsage" mode="oe"/>
        </profileDesc>
      </teiHeader>
      <xsl:apply-templates select="node()" mode="oe"/>
    </TEI>
  </xsl:template>
  <xsl:template match="/tei:TEI/@n" mode="oe"/>
  <xsl:template match="tei:teiHeader" mode="oe"/>
  <xsl:template match="tei:note/@place" mode="oe">
    <xsl:attribute name="place">
      <xsl:choose>
        <xsl:when test=". = 'end'">end</xsl:when>
        <xsl:when test=". = 'bottom'">foot</xsl:when>
        <xsl:otherwise>foot</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="tei:p/tei:quote | tei:note/tei:quote" mode="oe">
    <hi rendition="#i">
      <xsl:apply-templates mode="oe"/>
    </hi>
  </xsl:template>
  <xsl:template match="tei:quote" mode="oe">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="oe"/>
      <xsl:choose>
        <xsl:when test="text()[normalize-space(.) != '']">
          <seg>
            <xsl:apply-templates select="node()" mode="oe"/>
          </seg>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node()" mode="oe"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:quote/tei:p | tei:quote/tei:l" mode="oe">
    <seg>
      <xsl:apply-templates select="@*" mode="oe"/>
      <xsl:apply-templates select="node()" mode="oe"/>
    </seg>
  </xsl:template>
  <xsl:template match="@rend" mode="oe">
    <xsl:if test="not(../@rendition)">
      <xsl:attribute name="rendition">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="translate(normalize-space(.), ' ', '_')"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:note/@rend | tei:quote/@rend" mode="oe"/>
  <xsl:template match="tei:l/tei:persName | tei:head/tei:persName | tei:note/tei:persName | tei:p/tei:persName | tei:quote/tei:persName" mode="oe">
    <hi rendition="#persName">
      <xsl:apply-templates select="@xml:id|@xml:lang|@full" mode="oe"/>
      <xsl:apply-templates select="node()" mode="oe"/>
    </hi>
  </xsl:template>
  <xsl:template match="tei:head/tei:title | tei:l/tei:title | tei:p/tei:title" mode="oe">
    <hi rendition="#title">
      <xsl:apply-templates select="@xml:id|@xml:lang|@full" mode="oe"/>
      <xsl:apply-templates select="node()" mode="oe"/>
    </hi>
  </xsl:template>
  <xsl:template match="tei:index" mode="oe"/>
  <xsl:template match="tei:pb/@facs" mode="oe">
    <xsl:attribute name="source">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="tei:pb/@n" mode="oe"/>
</xsl:transform>