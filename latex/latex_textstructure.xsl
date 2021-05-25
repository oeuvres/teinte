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
  <xsl:import href="../xsl/common.xsl"/>
  <xsl:template match="*" mode="innertext">
    <xsl:apply-templates select="."/>
  </xsl:template>
  <xsl:template match="/tei:TEI|/tei:teiCorpus">
    <xsl:call-template name="mainDocument"/>
  </xsl:template>
  <xsl:template match="tei:teiCorpus/tei:TEI">
    <xsl:apply-templates/>
    <xsl:text>&#10;\par\noindent\rule{\textwidth}{2pt}&#10;\par </xsl:text>
  </xsl:template>
  <xsl:template name="mainDocument">

    <xsl:apply-templates/>
    <!-- latexEnd before endnotes ? -->
    <xsl:if test="key('ENDNOTES',1)">
      <xsl:text>&#10;\theendnotes</xsl:text>
    </xsl:if>
    <xsl:text>&#10;\end{document}&#10;</xsl:text>
  </xsl:template>
  <xsl:template name="latexOther">
    <!--
    <xsl:text>\def\TheFullDate{</xsl:text>
    <xsl:text>}&#10;</xsl:text>
    -->
    <xsl:text>\def\TheID{</xsl:text>
    <xsl:value-of select="$docid"/>
    <xsl:text>\makeatother </xsl:text>
    <xsl:text>}&#10;\def\TheDate{</xsl:text>
    <xsl:value-of select="$docdate"/>
    <xsl:text>}&#10;\title{</xsl:text>
    <xsl:value-of select="$doctitle"/>
    <xsl:text>}&#10;\author{</xsl:text>
    <xsl:value-of select="$byline"/>
    <xsl:text>}</xsl:text>
    <xsl:text>\makeatletter </xsl:text>
    <xsl:call-template name="latexBegin"/>
    <xsl:text>\makeatother </xsl:text>
  </xsl:template>
  <xsl:template match="tei:teiHeader"/>
  <xsl:template match="tei:back">
    <xsl:if test="not(preceding::tei:back)">
      <xsl:text>\backmatter </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:body">
    <xsl:if test="not(ancestor::tei:floatingText) and not(preceding::tei:body) and preceding::tei:front">
      <xsl:text>\mainmatter </xsl:text>
    </xsl:if>
    <xsl:if test="count(key('APP',1))&gt;0"> \beginnumbering \def\endstanzaextra{\pstart\centering---------\skipnumbering\pend} </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="count(key('APP',1))&gt;0"> \endnumbering </xsl:if>
  </xsl:template>
  <xsl:template match="tei:body|tei:back|tei:front" mode="innertext">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:closer">
    <xsl:text>&#10;&#10;\begin{quote}</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{quote}&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="tei:dateline">
    <xsl:text>\rightline{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="tei:div|tei:div1|tei:div2|tei:div3|tei:div4|tei:div5">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:divGen[@type='toc']"> \tableofcontents </xsl:template>
  <xsl:template match="tei:divGen[@type='bibliography']">
    <xsl:text>&#10;\begin{thebibliography}{1}&#10;</xsl:text>
    <xsl:call-template name="bibliography"/>
    <xsl:text>&#10;\end{thebibliography}&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="tei:front">
    <xsl:if test="not(preceding::tei:front)">
      <xsl:text>\frontmatter </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:opener">
    <xsl:text>&#10;&#10;\begin{quote}</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{quote}</xsl:text>
  </xsl:template>
  <xsl:template match="tei:text">
    <xsl:choose>
      <xsl:when test="parent::tei:TEI">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="parent::tei:group">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise> \par \hrule \begin{quote} \begin{small} <xsl:apply-templates mode="innertext"/> \end{small} \end{quote} \hrule \par </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:titlePage"> \begin{titlepage} <xsl:apply-templates/> \end{titlepage} \cleardoublepage </xsl:template>
  <xsl:template match="tei:trailer">
    <xsl:text>&#10;&#10;\begin{raggedleft}</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{raggedleft}&#10;</xsl:text>
  </xsl:template>
  <xsl:template name="bibliography">
    <xsl:apply-templates mode="biblio" select="//tei:ref[@type='cite'] | //tei:ptr[@type='cite']"/>
  </xsl:template>

</xsl:transform>
