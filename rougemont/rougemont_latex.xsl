<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tei="http://www.tei-c.org/ns/1.0"  
  exclude-result-prefixes="tei"
  xmlns:php="http://php.net/xsl"
  extension-element-prefixes="php"
  >
  <xsl:import href="../latex/latex.xsl"/>
  <xsl:import href="../latex/latex_meta.xsl"/>
  <!-- Url ? -->
  <xsl:param name="bookname"/>

  <xsl:key name="split" match="
    tei:*[self::tei:div or self::tei:div1 or self::tei:div2][normalize-space(.) != ''][@type][
    contains(@type, 'article') 
    or contains(@type, 'chapter') 
    or contains(@subtype, 'split') 
    or contains(@type, 'act')  
    or contains(@type, 'poem')
    or contains(@type, 'letter')
    ] 
    | tei:group/tei:text 
    | tei:TEI/tei:text/tei:*/tei:*[self::tei:div or self::tei:div1 or self::tei:group or self::tei:titlePage  or self::tei:castList][normalize-space(.) != '']" 
    use="generate-id(.)"/>
  
  <xsl:variable name="latexDate">
    <xsl:call-template name="latexDate"/>
  </xsl:variable> 
  
  <xsl:variable name="latexTitle">
    <xsl:call-template name="latexTitle"/>
  </xsl:variable> 
  
  <xsl:variable name="latexAuthor">
    <xsl:call-template name="latexAuthor"/>
  </xsl:variable>

  <xsl:variable name="latexAuthor1">
    <xsl:call-template name="latexAuthor1"/>
  </xsl:variable>
  
  <xsl:template match="/" priority="10">
    <xsl:for-each select="//tei:div[@type='chapter']">
      <xsl:call-template name="chapter"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="chapter">
    <!-- Number, used also as url -->
    <xsl:variable name="chapid">
      <xsl:call-template name="id"/>
    </xsl:variable>
    <xsl:variable name="head">
      <xsl:if test="@n">
        <xsl:value-of select="@n"/>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="tei:head" mode="meta"/>
    </xsl:variable>
    <xsl:variable name="meta">
      <xsl:text>\title{</xsl:text>
      <xsl:value-of select="$head"/>
      <xsl:text>}&#10;</xsl:text>
      <xsl:text>\author{</xsl:text>
      <xsl:value-of select="$latexAuthor"/>
      <xsl:text>}&#10;</xsl:text>
      <xsl:text>\date{</xsl:text>
      <xsl:choose>
        <xsl:when test="@when|@from|@to">
          <xsl:call-template name="latexDate">
            <xsl:with-param name="el" select="."/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$latexDate"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}&#10;</xsl:text>
      <xsl:text>\def\elbook{</xsl:text>
      <xsl:value-of select="$latexTitle"/>
      <xsl:text>}&#10;</xsl:text>
      <!-- Short ref for running head -->
      <xsl:text>\def\elbibl{</xsl:text>
      <xsl:value-of select="$latexAuthor1"/>
      <xsl:text>. </xsl:text>
      <xsl:text>\emph{</xsl:text>
      <xsl:value-of select="$latexTitle"/>
      <xsl:text>}</xsl:text>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="$latexDate"/>
      <xsl:text>)</xsl:text>
      <xsl:text>}&#10;</xsl:text>
    </xsl:variable>
    <xsl:variable name="text">
      <xsl:apply-templates select="*[not(self::tei:head)][not(self::tei:epigraph)][not(self::tei:argument)]"/>
    </xsl:variable>
    <!-- -->
    <xsl:value-of select="php:function('Rougemont::xslChapter', $chapid, $meta, $text)"/>
    <!--
    <xsl:variable name="subheads">
      <xsl:for-each select=".//tei:div">
        <xsl:variable name="subhead">
          <xsl:call-template name="title"/>
        </xsl:variable>
        <xsl:call-template name="id"/>
        <xsl:value-of select="$tab"/>
        <xsl:value-of select="normalize-space($subhead)"/>
        <xsl:value-of select="$booktitle"/>
        <xsl:value-of select="$lf"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:variable name="rich">
        <xsl:copy-of select="$doctitle"/>
        <xsl:text> (</xsl:text>
        <xsl:value-of select="$docdate"/>
        <xsl:text>) </xsl:text>
        <xsl:for-each select="ancestor-or-self::*">
          <xsl:sort order="descending" select="position()"/>
          <xsl:choose>
            <xsl:when test="self::tei:TEI"/>
            <xsl:when test="self::tei:text"/>
            <xsl:when test="self::tei:body"/>
            <xsl:otherwise>
              <xsl:if test="position() != 1"> — </xsl:if>
              <xsl:apply-templates mode="title" select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="normalize-space($rich)"/>
    </xsl:variable>
    <xsl:variable name="name">
      <xsl:variable name="rich">
        <xsl:apply-templates select="." mode="title"/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($rich)"/>
    </xsl:variable>
    -->
  </xsl:template>

  <!-- Identifiant local -->
  <xsl:template match="tei:div[@type = 'chapter']" mode="id">
    <xsl:number level="any" count="tei:div[@type = 'chapter']"/>
  </xsl:template>


</xsl:transform>
