<?xml version="1.0" encoding="utf-8"?>
<xsl:transform xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="tei:caesura">
    <xsl:text>\quad{}</xsl:text>
  </xsl:template>
  <xsl:template match="tei:facsimile"/>
  
  
  <xsl:template match="tei:affiliation|tei:email">
    <xsl:text>\mbox{}\\ </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  
  <xsl:template match="tei:affiliation|tei:email">
    <xsl:text>\mbox{}\\ </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:eTree|tei:eLeaf">
    <xsl:if test="not(ancestor::tei:eTree)">
      \renewcommand{\psedge}{\ncangle}
      \psset{levelsep=72pt,angleA=-90,angleB=90}
      <xsl:variable name="maxleaves"
        select="count(tei:eTree|tei:eLeaf)"/>
      <xsl:text></xsl:text>
      <xsl:message><xsl:value-of select="$maxleaves"/> leaves</xsl:message>
    </xsl:if>
    <xsl:text>&#10;\pstree{\Tr{\psframebox[linestyle=none]{\parbox{.1\textwidth}{\raggedright\footnotesize </xsl:text>
    <xsl:apply-templates select="tei:label"/>
    <xsl:text>}}}}{</xsl:text>
    <xsl:apply-templates select="tei:eTree|tei:eLeaf"/>
    <xsl:text>}</xsl:text>
  </xsl:template>  
  
  
  <!--
  <xsl:template name="makeAppEntry">
    <xsl:param name="lemma"/>
    <xsl:text>\edtext{</xsl:text>
    <xsl:value-of select="$lemma"/>
    <xsl:text>}{\Afootnote{</xsl:text>
    <xsl:call-template name="appReadings"/>
    <xsl:text>}}</xsl:text>
  </xsl:template>
  -->
  
</xsl:transform>
