<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  exclude-result-prefixes="tei"
>
  <!-- 
TEI Styleshest for LaTeX, forked from Sebastian Rahtz
https://github.com/TEIC/Stylesheets/tree/dev/latex
  
1. Distributed under a Creative Commons Attribution-ShareAlike 3.0
   License http://creativecommons.org/licenses/by-sa/3.0/ 
2. http://www.opensource.org/licenses/BSD-2-Clause

A light version for XSLT1, with local improvements.
2021, frederic.glorieux@fictif.org
  -->
  <xsl:template match="tei:anchor">
    <xsl:call-template name="tei:makeHyperTarget"/>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>[latex] <param name="where">where</param> </desc>
  </doc>
  <xsl:template name="generateEndLink">
    <xsl:param name="where"/>
    <xsl:value-of select="$where"/>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>[latex] <param name="ptr">ptr</param> <param name="dest">dest</param> </desc>
  </doc>
  <xsl:template name="makeExternalLink">
    <xsl:param name="ptr" select="false()"/>
    <xsl:param name="dest"/>
    <xsl:param name="title"/>
    <xsl:choose>
      <xsl:when test="$ptr">
        <xsl:text>\url{</xsl:text>
        <!-- Escape maybe needed -->
        <xsl:value-of select="normalize-space($dest)"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\xref{</xsl:text>
        <!-- Escape maybe needed -->
        <xsl:value-of select="normalize-space($dest)"/>
        <xsl:text>}{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>[latex] <param name="target">target</param> <param name="ptr">ptr</param> <param name="dest">dest</param> <param name="body">body</param> </desc>
  </doc>
  <xsl:template name="makeInternalLink">
    <xsl:param name="target"/>
    <xsl:param name="class"/>
    <xsl:param name="ptr" as="xs:boolean" select="false()"/>
    <xsl:param name="dest"/>
    <xsl:param name="body"/>
    <xsl:choose>
      <xsl:when test="$dest=''">
        <xsl:value-of select="$body"/>
      </xsl:when>
      <xsl:when test="id($dest)">
        <xsl:choose>
          <xsl:when test="parent::tei:label">
            <xsl:text>\hyperlink{</xsl:text>
            <xsl:value-of select="$dest"/>
            <xsl:text>}{</xsl:text>
            <xsl:value-of select="$body"/>
            <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:when test="not($body='')">
            <xsl:text>\hyperref[</xsl:text>
            <xsl:value-of select="$dest"/>
            <xsl:text>]{</xsl:text>
            <xsl:value-of select="$body"/>
            <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:when test="$ptr">
            <xsl:for-each select="id($dest)">
              <xsl:choose>
                <xsl:when test="$class='pageref'">
                  <xsl:text>\pageref{</xsl:text>
                  <xsl:value-of select="@xml:id"/>
                  <xsl:text>}</xsl:text>
                </xsl:when>
                <xsl:when test="self::tei:note[@xml:id]">
                  <xsl:text>\ref{</xsl:text>
                  <xsl:value-of select="@xml:id"/>
                  <xsl:text>}</xsl:text>
                </xsl:when>
                <xsl:when test="self::tei:figure[tei:head and @xml:id]">
                  <xsl:text>\ref{</xsl:text>
                  <xsl:value-of select="@xml:id"/>
                  <xsl:text>}</xsl:text>
                </xsl:when>
                <xsl:when test="self::tei:table[tei:head and @xml:id]">
                  <xsl:text>\ref{</xsl:text>
                  <xsl:value-of select="@xml:id"/>
                  <xsl:text>}</xsl:text>
                </xsl:when>
                <!-- Check whether the current ptr is a reference to a bibliographic object 
		          and use \cite rather than \hyperref -->
                <xsl:when test="self::tei:biblStruct[ancestor::tei:div/@xml:id='BIB']">
                  <xsl:text>\cite{</xsl:text>
                  <xsl:value-of select="$dest"/>
                  <xsl:text>}</xsl:text>
                </xsl:when>
                <xsl:when test="starts-with(local-name(.),'div')">
                  <xsl:text>\textit{\hyperref[</xsl:text>
                  <xsl:value-of select="$dest"/>
                  <xsl:text>]{</xsl:text>
                  <xsl:apply-templates mode="xref" select=".">
                    <xsl:with-param name="minimal" select="$minimalCrossRef"/>
                  </xsl:apply-templates>
                  <xsl:text>}}</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>\hyperref[</xsl:text>
                  <xsl:value-of select="$dest"/>
                  <xsl:text>]{</xsl:text>
                  <xsl:value-of select="$body"/>
                  <xsl:apply-templates mode="xref" select=".">
                    <xsl:with-param name="minimal" select="$minimalCrossRef"/>
                  </xsl:apply-templates>
                  <xsl:text>}</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\hyperref[</xsl:text>
            <xsl:value-of select="$dest"/>
            <xsl:text>]{</xsl:text>
            <xsl:value-of select="$body"/>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="not($body='')">
            <xsl:value-of select="$body"/>
          </xsl:when>
          <xsl:when test="$ptr">
            <xsl:value-of select="$dest"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:note" mode="xref">
    <xsl:number level="any"/>
  </xsl:template>
</xsl:transform>
