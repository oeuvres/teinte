<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <!-- 
TEI Styleshest for LaTeX, forked from Sebastian Rahtz
https://github.com/TEIC/Stylesheets/tree/dev/latex
  
1. Distributed under a Creative Commons Attribution-ShareAlike 3.0
   License http://creativecommons.org/licenses/by-sa/3.0/ 
2. http://www.opensource.org/licenses/BSD-2-Clause

A light version for XSLT1, with local improvements.
2021, frederic.glorieux@fictif.org
  -->
  <!-- Deprecated, should be handle at LaTeX level -->
  <xsl:param name="documentclass">book</xsl:param>


  <xsl:template match="*" mode="innertext">
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="/tei:TEI|/tei:teiCorpus">
    <xsl:param name="message"/>
    <xsl:call-template name="mainDocument"/>
  </xsl:template>

  <xsl:template match="tei:teiCorpus/tei:TEI">
    <xsl:param name="message"/>
    <xsl:apply-templates/>
    <xsl:text>\noindent\rule{\textwidth}{2pt}&#10;\par&#10;</xsl:text>
  </xsl:template>

  <xsl:template name="mainDocument">
    <xsl:param name="message"/>
    <xsl:apply-templates/>
    <!-- latexEnd before endnotes ? -->
    <xsl:if test="key('ENDNOTES',1)">
      <xsl:text>&#10;\theendnotes</xsl:text>
    </xsl:if>
  </xsl:template>



  <xsl:template match="tei:back">
    <xsl:param name="message"/>
    <xsl:if test="not(preceding::tei:back)">
      <xsl:text>\backmatter </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:body">
    <xsl:param name="message"/>
    <xsl:if test="not(ancestor::tei:floatingText) and not(preceding::tei:body) and preceding::tei:front">
      <xsl:text>&#10;\mainmatter&#10;&#10;</xsl:text>
    </xsl:if>
    <xsl:if test="count(key('APP',1))&gt;0"> \beginnumbering \def\endstanzaextra{\pstart\centering---------\skipnumbering\pend} </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="count(key('APP',1))&gt;0"> \endnumbering </xsl:if>
  </xsl:template>

  <xsl:template match="tei:body|tei:back|tei:front" mode="innertext">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:closer">
    <xsl:param name="message"/>
    <xsl:text>&#10;&#10;\begin{quote}</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{quote}&#10;</xsl:text>
  </xsl:template>

  <!-- Hierarchies -->
  <xsl:template match="tei:div">
    <xsl:param name="message"/>
    
    <xsl:variable name="level">
      <xsl:call-template name="level"/>
    </xsl:variable>
    <!-- first content element -->
    <xsl:variable name="first" select="
      (*[not(self::tei:argument)]
      [not(self::tei:byline)]
      [not(self::tei:cb)]
      [not(self::tei:dateline)]
      [not(self::tei:docAuthor)]
      [not(self::tei:docDate)]
      [not(self::tei:epigraph)]
      [not(self::tei:head)]
      [not(self::tei:opener)]
      [not(self::tei:pb)]
      [not(self::tei:salute)]
      [not(self::tei:signed)])[1]
      "/>



    <xsl:choose>
      <!--  restart columns -->
      <xsl:when test="$documentclass = 'book' and $level &lt;= 0">
        <xsl:text>&#10;\chapteropen&#10;</xsl:text>
        <xsl:choose>
          <xsl:when test="$first">
            <xsl:apply-templates select="$first/preceding-sibling::*"/>
            <xsl:text>&#10;\chaptercont&#10;</xsl:text>
            <xsl:apply-templates select="$first | $first/following-sibling::*"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>&#10;\chaptercont&#10;</xsl:text>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>\chapterclose&#10;&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- Not yet support -->
  <xsl:template match="tei:div1|tei:div2|tei:div3|tei:div4|tei:div5">
    <xsl:param name="message"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:divGen[@type='toc']"> \tableofcontents </xsl:template>

  <xsl:template match="tei:divGen[@type='bibliography']">
    <xsl:param name="message"/>
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

  <xsl:template match="
      tei:back/tei:head
    | tei:body/tei:head
    | tei:div/tei:head
    | tei:div1/tei:head
    | tei:div2/tei:head
    | tei:div3/tei:head
    | tei:div4/tei:head
    | tei:div5/tei:head
    | tei:div6/tei:head
    | tei:front/tei:head
    ">
    <xsl:param name="message"/>
    <xsl:variable name="level">
      <xsl:call-template name="level"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@type='kicker' and following-sibling::tei:head"/>
      <!-- Title not for toc -->
      <xsl:when test="preceding-sibling::tei:head[not(@type='kicker')]">
        <xsl:text>\begin{center}</xsl:text>
        <xsl:choose>
          <xsl:when test="@type = 'sub'">
            <xsl:text>\emph{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>\end{center}&#10;</xsl:text>
      </xsl:when>
      <!-- Open sectionning for LaTeX -->
      <xsl:otherwise>
        <xsl:text>&#10;\</xsl:text>
        <xsl:choose>
          <xsl:when test="$documentclass = 'book'">
            <xsl:choose>
              <xsl:when test="$level &lt; 0">part</xsl:when>
              <xsl:when test="$level = 0">chapter</xsl:when>
              <xsl:when test="$level = 1">section</xsl:when>
              <xsl:when test="$level = 2">subsection</xsl:when>
              <xsl:when test="$level = 3">subsubsection</xsl:when>
              <xsl:when test="$level = 4">paragraph</xsl:when>
              <xsl:when test="$level = 5">subparagraph</xsl:when>
              <xsl:when test="$level &gt; 5">subparagraph</xsl:when>
              <xsl:otherwise>section</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$level &lt; 0">part</xsl:when>
              <xsl:when test="$level = 0">section</xsl:when>
              <xsl:when test="$level = 1">subsection</xsl:when>
              <xsl:when test="$level = 2">subsubsection</xsl:when>
              <xsl:when test="$level = 3">paragraph</xsl:when>
              <xsl:when test="$level = 4">subparagraph</xsl:when>
              <xsl:when test="$level &gt; 4">subparagraph</xsl:when>
              <xsl:otherwise>section</xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <!-- 
Old logic of numbering, let Latex consumer choose, but get 
parent::tei:body or ancestor::tei:floatingText
or (ancestor::tei:back and $numberBackHeadings = '')
or (not($numberHeadings = 'true') and ancestor::tei:body)
or (ancestor::tei:front and $numberFrontHeadings = '')
or parent::tei:div[contains(@rend, 'nonumber')]

\chapter[{toc-title text only}]{title with maybe notes}

[{a title may contain [brackets]}]
        -->
        <xsl:variable name="kicker">
          <xsl:variable name="raw">
            <xsl:apply-templates select="preceding-sibling::tei:head[@type='kicker']" mode="title"/>
          </xsl:variable>
          <xsl:value-of select="normalize-space($raw)"/>
        </xsl:variable>
        <xsl:variable name="title">
          <xsl:apply-templates select="." mode="title"/>
        </xsl:variable>
        <xsl:variable name="kicker-sep">
          <xsl:if test="$kicker != ''">
            <xsl:call-template name="head-pun">
              <xsl:with-param name="prev" select="$kicker"/>
              <xsl:with-param name="next" select="$title"/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:variable>
        <xsl:text>[{</xsl:text>
        <xsl:variable name="raw">
          <xsl:value-of select="$kicker"/>
          <xsl:value-of select="$kicker-sep"/>
          <xsl:value-of select="$title"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($raw)"/>
        <xsl:text>}]</xsl:text>
        <xsl:text>{</xsl:text>
        <xsl:apply-templates select="preceding-sibling::tei:head[@type='kicker']/node()"/>
        <xsl:value-of select="$kicker-sep"/>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
        <!-- Update letf mark manual. We want some typo but no notes -->
        <xsl:if test="../parent::tei:front | ../parent::tei:body | ../parent::tei:back">
          <xsl:text>&#10;\renewcommand{\leftmark}{</xsl:text>
          <xsl:value-of select="$kicker"/>
          <xsl:value-of select="$kicker-sep"/>
          <xsl:apply-templates>
            <xsl:with-param name="message">nonote</xsl:with-param>
          </xsl:apply-templates>
          <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:if test="../@xml:id">
          <!-- Keep it there fo bookmarks (tested) -->
          <xsl:call-template name="tei:makeHyperTarget">
            <xsl:with-param name="id" select="../@xml:id"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:text>&#10;&#10;</xsl:text>
        <xsl:for-each select=".//tei:note">
          <xsl:if test="true()">\footnotetext{<xsl:apply-templates/>}&#10;</xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    
    
  </xsl:template>






  <xsl:template match="tei:opener">
    <xsl:param name="message"/>
    <xsl:text>&#10;&#10;\begin{quote}</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{quote}</xsl:text>
  </xsl:template>

  <xsl:template match="tei:teiHeader">
    <xsl:param name="message"/>
  </xsl:template>

  <xsl:template match="tei:text">
    <xsl:param name="message"/>
    <xsl:choose>
      <xsl:when test="parent::tei:TEI">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="parent::tei:group">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>\hrule \begin{quote} \begin{small} <xsl:apply-templates mode="innertext"/> \end{small} \end{quote} \hrule \par&#10;</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:titlePage">
    <xsl:param name="message"/>
    <xsl:text>&#10;\begin{titlePage}&#10;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#10;\end{titlePage}&#10;</xsl:text>
  </xsl:template>

  <xsl:template name="bibliography">
    <xsl:apply-templates mode="biblio" select="//tei:ref[@type='cite'] | //tei:ptr[@type='cite']"/>
  </xsl:template>


  <!-- Calculate a level 
-1 	\part{part}
0 	\chapter{chapter}
1 	\section{section}
2 	\subsection{subsection}
3 	\subsubsection{subsubsection}
4 	\paragraph{paragraph}
5 	\subparagraph{subparagraph}
  -->
  <xsl:template name="level">
    <xsl:variable name="chapter" select="ancestor-or-self::*[key('CHAPTERS',generate-id(.))][1]"/>
    <xsl:choose>
      <xsl:when test="$chapter">
        <xsl:value-of select="count(ancestor-or-self::tei:div[ancestor::*[count(.|$chapter) = 1]])"/>
      </xsl:when>
      <xsl:when test="ancestor-or-self::tei:div[1]/descendant::*[key('CHAPTERS',generate-id(.))]">-1</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count(ancestor-or-self::tei:div)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



</xsl:transform>
