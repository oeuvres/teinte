<?xml version="1.0" encoding="UTF-8"?>
<!--
To index TEI files in lucene with Alix

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2019 Frederic.Glorieux@fictif.org & Opteos & 


 
-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:alix="http://alix.casa"
  exclude-result-prefixes="tei"
>
  <xsl:import href="flow.xsl"/>
  <xsl:import href="notes.xsl"/>
  <xsl:import href="toc.xsl"/>
  <xsl:output indent="yes" encoding="UTF-8" method="xml" />
  <!-- chapter split policy -->
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
  <!-- Name of file, provided by caller -->
  <xsl:param name="filename"/>
  <!-- Get metas as a global var to insert fields in all chapters -->
  <xsl:variable name="info">
    <alix:field name="title" type="string" value="{$doctitle}"/>
    <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt">
      <xsl:for-each select="tei:author|tei:principal">
        <xsl:variable name="value">
          <xsl:apply-templates select="." mode="key"/>
        </xsl:variable>
        <alix:field name="author" type="facet" value="{$value}"/>
      </xsl:for-each>
    </xsl:for-each>
    <alix:field name="year" type="int">
      <xsl:variable name="value" select="substring($docdate, 1, 4)"/>
      <xsl:if test="$value &lt;= 0">
        <xsl:message terminate="yes">
          <xsl:value-of select="$value"/>
          <xsl:text> bad DATE in </xsl:text>
          <xsl:value-of select="$filename"/>
        </xsl:message>
      </xsl:if>
      <xsl:attribute name="value">
        <xsl:value-of select="$value"/>
      </xsl:attribute>
    </alix:field>
  </xsl:variable> 
  <xsl:template match="/*">
    <!-- XML book is handled as nested lucene documents (chapters) -->
    <alix:book>
      <xsl:copy-of select="$info"/>
      <alix:field name="type" value="book" type="string"/>
      <alix:field name="toc" type="store">
        <xsl:call-template name="toc"/>
      </alix:field>
      <!-- process chapters -->
      <xsl:apply-templates mode="alix"/>
      <alix:chapter>
        <xsl:copy-of select="$info"/>
        <alix:field name="type" value="notes" type="string"/>
        <alix:field name="text" type="text">
          <xsl:call-template name="footnotes"/>
        </alix:field>
      </alix:chapter>
    </alix:book>
  </xsl:template>
  
  <!-- Default mode alix -->
  <xsl:template match="tei:teiHeader" mode="alix"/>
  <xsl:template match="*" mode="alix">
    <xsl:apply-templates select="*" mode="alix"/>
  </xsl:template>
  
  
  <xsl:template mode="alix" match="
    tei:group/tei:text | tei:group |
    tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7 
    "
    >
    <xsl:choose>
      <!-- blocks of text, open a chapter leaf -->
      <xsl:when test="tei:p|tei:l|tei:list|tei:argument|tei:table">
        <xsl:call-template name="chapter"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="alix"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="chapter">
    <alix:chapter>
      <alix:field name="type" value="chapter" type="string"/>
      <xsl:copy-of select="$info"/>
      <alix:field name="breadcrumb" type="text">
        <xsl:call-template name="breadcrumb"/>
      </alix:field>
      <!-- if nested sections, record nested titles, should modify score -->
      <xsl:if test="tei:div">
        <alix:field name="argument" type="text">
          <xsl:for-each select=".//tei:div">
          <xsl:if test="position() != 1">
            <xsl:text> — </xsl:text>
          </xsl:if>
          <xsl:apply-templates select="." mode="title"/>
        </xsl:for-each>
        </alix:field>
      </xsl:if>
      <alix:field name="text" type="text">
        <article>
          <xsl:apply-templates/>
        </article>
      </alix:field>
    </alix:chapter>
  </xsl:template>
  <xsl:template name="breadcrumb">
    <xsl:copy-of select="$doctitle"/>
    <xsl:for-each select="ancestor-or-self::*">
      <!--
      <xsl:sort order="descending" select="position()"/>
      -->
      <xsl:choose>
        <xsl:when test="self::tei:TEI"/>
        <xsl:when test="self::tei:text"/>
        <xsl:when test="self::tei:body"/>
        <xsl:otherwise>
          <xsl:text> » </xsl:text>
          <xsl:apply-templates select="." mode="title"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  
</xsl:transform>
