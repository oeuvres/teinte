<?xml version="1.0" encoding="UTF-8"?>
<!--

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2016 Frederic.Glorieux@fictif.org 


Split a single TEI book in a multi-pages site

-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:alix="java:com.github.oeuvres.lucene.Alix"
  exclude-result-prefixes="tei alix"
>
  <xsl:import href="tei2html.xsl"/>
  <!-- Name of file, provided by caller -->
  <xsl:param name="filename"/>
  <!-- Options for the html field, be careful if not congruent -->
  <xsl:variable name="text-opts">IdfpoPV</xsl:variable>
  <!-- Options for a pure store field with no search and no effect on docFreq, useful for tocs, index… -->
  <xsl:variable name="html-opts">S</xsl:variable> 
  <!-- Name of this xsl  -->
  <xsl:variable name="this">tei2lucene.xsl</xsl:variable>
  <xsl:output indent="yes" encoding="UTF-8" method="xml" />
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
  <!-- Maybe used for instrospection -->
  <xsl:template match="/*">
    <!-- Table des matières -->
    <xsl:value-of select="alix:docNew()"/>
    <xsl:call-template name="alix:metas"/>
    <xsl:variable name="code" select="'toc'"/>
    <xsl:value-of select="alix:field('href', concat($filename, '/', $code))"/>
    <xsl:value-of select="alix:field('code', $code)"/>
    <xsl:variable name="html">
      <xsl:call-template name="toc"/>
    </xsl:variable>
    <xsl:value-of select="alix:field('html', $html, $html-opts)"/>
    <xsl:value-of select="alix:docWrite()"/>
    <!-- Page de titre -->
    <xsl:value-of select="alix:docNew()"/>
    <xsl:call-template name="alix:metas"/>
    <xsl:variable name="html">
      <xsl:apply-templates select="/*/tei:teiHeader"/>
    </xsl:variable>
    <xsl:variable name="code" select="'titlePage'"/>
    <xsl:value-of select="alix:field('href', concat($filename, '/', $code))"/>
    <xsl:value-of select="alix:field('code', $code)"/>
    <xsl:value-of select="alix:field('html', $html, $html-opts)"/>
    <xsl:value-of select="alix:docWrite()"/>
    <!-- metas -->
    <!-- On parse -->
    <xsl:apply-templates select="*" mode="alix"/>
    
  </xsl:template>
  <xsl:template name="alix:metas">
    <xsl:value-of select="alix:field('title', $doctitle, 'ITS')"/>
    <xsl:value-of select="alix:field('date', $docdate, '#')"/>
    <xsl:value-of select="alix:field('byline', $byline, 'ITS')"/>
    <xsl:variable name="head">
      <xsl:apply-templates select="tei:head[1]" mode="title"/>  
    </xsl:variable>   
    <xsl:value-of select="alix:field('head', $head, 'ITS')"/>
  </xsl:template>
  <xsl:template match="tei:teiHeader" mode="alix"/>
  <xsl:template match="*" mode="alix">
    <xsl:apply-templates select="*" mode="alix"/>
  </xsl:template>
  <xsl:template match="tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7 " mode="alix">
    <xsl:choose>
      <xsl:when test="not(tei:p)">
        <xsl:apply-templates select="*" mode="alix"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="code">
          <xsl:call-template name="id"/>
        </xsl:variable>
        <xsl:value-of select="alix:docNew()"/>
        <xsl:call-template name="alix:metas"/>
        <xsl:value-of select="alix:field('href', concat($filename, '/', $code))"/>
        <xsl:value-of select="alix:field('code', $code)"/>
        <xsl:value-of select="alix:field('type', 'chapter')"/>
        <xsl:variable name="html">
          <xsl:apply-templates select="."/>
        </xsl:variable>   
        <xsl:value-of select="alix:field('html', $html, $html-opts)"/>
        <xsl:value-of select="alix:field('text', $html, $text-opts)"/>
        <xsl:value-of select="alix:docWrite()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
