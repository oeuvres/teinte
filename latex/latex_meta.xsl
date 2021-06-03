<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <!-- 
Latex from TEI, metadata for preamble

2021, frederic.glorieux@fictif.org
  -->
  <xsl:output method="text" encoding="utf8"/>
  <xsl:template match="/">
    <xsl:variable name="title">
      <xsl:apply-templates select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[not(@type) or @type='main'][1]"/>
    </xsl:variable>
    <xsl:text>\title{</xsl:text>
    <xsl:value-of select="$title"/>
    <xsl:text>}&#10;</xsl:text>
    <!-- Book date = year -->
    <xsl:variable name="year">
      <xsl:choose>
        <xsl:when test="/*/tei:teiHeader/tei:profileDesc/tei:creation/tei:date">
          <xsl:apply-templates mode="year" select="/*/tei:teiHeader/tei:profileDesc/tei:creation[1]/tei:date[1]"/>
        </xsl:when>
        <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:date">
          <xsl:apply-templates mode="year" select="(/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:date)[1]"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>\date{</xsl:text>
    <xsl:value-of select="$year"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:text>\author{</xsl:text>
    <xsl:for-each select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt[1]">
      <xsl:for-each select="tei:author|tei:principal">
        <xsl:choose>
          <xsl:when test="position() = 1"/>
          <xsl:when test="position() = last()"> \&amp; </xsl:when>
          <xsl:otherwise>, </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select=".">
          <xsl:with-param name="short" select="true()"/>
        </xsl:apply-templates>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:text>}&#10;</xsl:text>
    <!-- Short ref for running head -->
    <xsl:text>\def\shortref{</xsl:text>
    <xsl:variable name="author1">
      <xsl:for-each select="(/*/tei:teiHeader/tei:fileDesc/tei:titleStmt)[1]">
        <xsl:for-each select="(tei:author|tei:principal)[1]">
          <xsl:apply-templates select=".">
            <xsl:with-param name="short" select="true()"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="$author1 != ''">
      <xsl:value-of select="$author1"/>
      <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:if test="$year != ''">
      <xsl:value-of select="$year"/>
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:text>\emph{</xsl:text>
    <xsl:value-of select="$title"/>
    <xsl:text>}</xsl:text>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:author | tei:principal">
    <xsl:param name="short"/>
    <xsl:choose>
      <xsl:when test="normalize-space(.) != ''">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="@key">
        <xsl:variable name="key" select="normalize-space(substring-before(concat(@key, '('), '('))"/>
        <xsl:choose>
          <xsl:when test="$short != ''">
            <xsl:value-of select="substring-before(concat($key, ','), ',')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$key"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:date" mode="year" name="year">
    <xsl:variable name="year">
      <xsl:choose>
        <xsl:when test="normalize-space(@when) != ''">
          <xsl:value-of select="normalize-space(@when)"/>
        </xsl:when>
        <xsl:when test="normalize-space(@to) != ''">
          <xsl:value-of select="normalize-space(@to)"/>
        </xsl:when>
        <xsl:when test="normalize-space(@notAfter) != ''">
          <xsl:value-of select="normalize-space(@notAfter)"/>
        </xsl:when>
        <xsl:when test="normalize-space(@from) != ''">
          <xsl:value-of select="normalize-space(@from)"/>
        </xsl:when>
        <xsl:when test="normalize-space(@notBefore) != ''">
          <xsl:value-of select="normalize-space(@notBefore)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$year = ''">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:when>
      <xsl:when test="starts-with($year, '-')">
        <xsl:text>-</xsl:text>
        <xsl:value-of select="0 + substring-before(concat(substring($year, 2), '-'), '-')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0 + substring-before(concat($year, '-'), '-')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:surname">
    <!-- Small caps are usually bad in modern TeX -->
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Default, do nothing -->
  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- No notes in meta -->
  <xsl:template match="tei:note"/>
  <xsl:template match="tei:hi[starts-with(@rend, 'sup')]">
    <xsl:text>\textsuperscript{</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="tei:emph | tei:hi[starts-with(@rend, 'i')]">
    <xsl:text>\textit{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>


</xsl:transform>
