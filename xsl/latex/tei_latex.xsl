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
  <xsl:import href="../tei_common.xsl"/>
  <!--
  <xsl:import href="tei_common.xsl"/>
  -->
  <xsl:import href="common_core.xsl"/>
  <xsl:import href="tei_flow_latex.xsl"/>
  <xsl:import href="tei_misc_latex.xsl"/>
  <xsl:import href="tei_drama_latex.xsl"/>
  <xsl:import href="tei_figure_latex.xsl"/>
  <xsl:import href="tei_linking_latex.xsl"/>
  <xsl:import href="tei_textstructure_latex.xsl"/>
  <xsl:output method="text" encoding="utf8" indent="no"/>
  <xsl:variable name="top" select="/"/>
  <xsl:param name="outputTarget">latex</xsl:param>
  <xsl:param name="spaceCharacter">\hspace*{6pt}</xsl:param>

  <xsl:key name="ENDNOTES" match="tei:note[@place='end']" use="1"/>
  <xsl:key name="FOOTNOTES" match="tei:note[not(@place) or @place='bottom']" use="1"/>
  <xsl:key name="TREES" match="tei:eTree[not(ancestor::tei:eTree)]" use="1"/>
  <xsl:key name="APP" match="tei:app" use="1"/>
  <xsl:key name="CHAPTERS" match="tei:div[@type='chapter' or @type='article' or @type='act']" use="generate-id()"/>
  

  
  <xsl:template match="processing-instruction()[name(.) = 'tex']">
    <!-- TODO desescape ?  -->
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template name="verbatim-lineBreak">
    <xsl:param name="id"/>
    <xsl:text>\mbox{}\newline 
</xsl:text>
  </xsl:template>
  <!-- No Verbatim -->
  <!--
  <xsl:template name="verbatim-createElement">
    <xsl:param name="name"/>
    <xsl:param name="special"/>
    <xsl:text>\textbf{</xsl:text>
    <xsl:value-of select="$name"/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template name="verbatim-newLine"/>
  <xsl:template name="verbatim-Text">
    <xsl:param name="words"/>
    <xsl:choose>
      <xsl:when test="lang('zh-TW') or lang('zh')">
        <xsl:text>{\textChinese </xsl:text>
        <xsl:value-of select="tei:escapeCharsVerbatim($words)"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="lang('ja')">
        <xsl:text>{\textJapanese {</xsl:text>
        <xsl:value-of select="tei:escapeCharsVerbatim($words)"/>
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:when test="lang('ko')">
        <xsl:text>{\textKorean </xsl:text>
        <xsl:value-of select="tei:escapeCharsVerbatim($words)"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="lang('ar') or lang('he') or lang('fa') or lang('ur') or lang('sd')">
        <xsl:text>\hbox{</xsl:text>
        <xsl:value-of select="tei:escapeCharsVerbatim($words)"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="tei:escapeCharsVerbatim($words)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  -->

  <xsl:template name="horizontalRule">
    <xsl:text>\\\rule[0.5ex]{\textwidth}{0.5pt}</xsl:text>
  </xsl:template>

  
  <xsl:template name="makeSection">
    <xsl:param name="level"/>
    <xsl:param name="heading"/>
    <xsl:param name="implicitBlock">false</xsl:param>
    <xsl:text>&#10;</xsl:text>
    <xsl:choose>
      <xsl:when test="$level = 1">\section</xsl:when>
      <xsl:when test="$level = 2">\subsection</xsl:when>
      <xsl:when test="$level = 3">\subsubsection</xsl:when>
      <xsl:when test="$level = 4">\paragraph</xsl:when>
    </xsl:choose>
    <xsl:text>{</xsl:text>
    <xsl:value-of select="$heading"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:choose>
      <xsl:when test="$implicitBlock = 'true'">
        <xsl:text>\par&#10;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>\par&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="*">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\par&#10;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>\par&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="makeWithLabel">
    <xsl:param name="before"/>
    <xsl:text>\textit{</xsl:text>
    <xsl:value-of select="$before"/>
    <xsl:text>}: </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

</xsl:transform>
