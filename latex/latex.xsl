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
  
  <xsl:import href="common1.xsl"/>
  <xsl:import href="common_core.xsl"/>
  <xsl:import href="latex_core.xsl"/>
  <xsl:import href="latex_misc.xsl"/>
  <xsl:import href="latex_drama.xsl"/>
  <xsl:import href="latex_figures.xsl"/>
  <xsl:import href="latex_linking.xsl"/>
  <xsl:import href="latex_textstructure.xsl"/>
  <xsl:import href="latex_param.xsl"/>
  <xsl:output method="text" encoding="utf8"/>
  <xsl:variable name="top" select="/"/>
  <xsl:param name="outputTarget">latex</xsl:param>
  <xsl:param name="documentclass">book</xsl:param>
  <xsl:param name="spaceCharacter">\hspace*{6pt}</xsl:param>


  <xsl:strip-space elements="tei:additional tei:adminInfo
    tei:altGrp tei:altIdentifier tei:analytic
    tei:app tei:appInfo tei:application
    tei:arc tei:argument tei:attDef
    tei:attList tei:availability tei:back
    tei:biblFull tei:biblStruct tei:bicond
    tei:binding tei:bindingDesc tei:body
    tei:broadcast tei:cRefPattern tei:calendar
    tei:calendarDesc tei:castGroup
    tei:castList tei:category tei:certainty
    tei:char tei:charDecl tei:charProp
    tei:choice tei:cit tei:classDecl
    tei:classSpec tei:classes tei:climate
    tei:cond tei:constraintSpec tei:correction
    tei:custodialHist tei:decoDesc
    tei:dimensions tei:div tei:div1 tei:div2
    tei:div3 tei:div4 tei:div5 tei:div6
    tei:div7 tei:divGen tei:docTitle tei:eLeaf
    tei:eTree tei:editionStmt
    tei:editorialDecl tei:elementSpec
    tei:encodingDesc tei:entry tei:epigraph
    tei:epilogue tei:equipment tei:event
    tei:exemplum tei:fDecl tei:fLib
    tei:facsimile tei:figure tei:fileDesc
    tei:floatingText tei:forest tei:front
    tei:fs tei:fsConstraints tei:fsDecl
    tei:fsdDecl tei:fvLib tei:gap tei:glyph
    tei:graph tei:graphic tei:media tei:group
    tei:handDesc tei:handNotes tei:history
    tei:hom tei:hyphenation tei:iNode tei:if
    tei:imprint tei:incident tei:index
    tei:interpGrp tei:interpretation tei:join
    tei:joinGrp tei:keywords tei:kinesic
    tei:langKnowledge tei:langUsage
    tei:layoutDesc tei:leaf tei:lg tei:linkGrp
    tei:list tei:listBibl tei:listChange
    tei:listEvent tei:listForest tei:listNym
    tei:listOrg tei:listPerson tei:listPlace
    tei:listRef tei:listRelation
    tei:listTranspose tei:listWit tei:location
    tei:locusGrp tei:macroSpec tei:metDecl
    tei:moduleRef tei:moduleSpec tei:monogr
    tei:msContents tei:msDesc tei:msIdentifier
    tei:msItem tei:msItemStruct tei:msPart
    tei:namespace tei:node tei:normalization
    tei:notatedMusic tei:notesStmt tei:nym
    tei:objectDesc tei:org tei:particDesc
    tei:performance tei:person tei:personGrp
    tei:physDesc tei:place tei:population
    tei:postscript tei:precision
    tei:profileDesc tei:projectDesc
    tei:prologue tei:publicationStmt
    tei:quotation tei:rdgGrp tei:recordHist
    tei:recording tei:recordingStmt
    tei:refsDecl tei:relatedItem tei:relation
    tei:relationGrp tei:remarks tei:respStmt
    tei:respons tei:revisionDesc tei:root
    tei:row tei:samplingDecl tei:schemaSpec
    tei:scriptDesc tei:scriptStmt tei:seal
    tei:sealDesc tei:segmentation
    tei:seriesStmt tei:set tei:setting
    tei:settingDesc tei:sourceDesc
    tei:sourceDoc tei:sp tei:spGrp tei:space
    tei:spanGrp tei:specGrp tei:specList
    tei:state tei:stdVals tei:subst
    tei:substJoin tei:superEntry
    tei:supportDesc tei:surface tei:surfaceGrp
    tei:table tei:tagsDecl tei:taxonomy
    tei:teiCorpus tei:teiHeader tei:terrain
    tei:text tei:textClass tei:textDesc
    tei:timeline tei:titlePage tei:titleStmt
    tei:trait tei:transpose tei:tree
    tei:triangle tei:typeDesc tei:vAlt
    tei:vColl tei:vDefault tei:vLabel
    tei:vMerge tei:vNot tei:vRange tei:valItem
    tei:valList tei:vocal
    "/>
  


  <xsl:template match="processing-instruction()[name(.) = 'tex']">
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

  <xsl:template name="emphasize">
    <xsl:param name="class"/>
    <xsl:param name="content"/>
    <xsl:variable name="lang">
      <xsl:call-template name="tei:findLanguage"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($class, 'titlem') and starts-with($lang, 'ja')">
        <xsl:text>{\textJapanese {</xsl:text>
        <xsl:copy-of select="$content"/>
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:when test="contains($class, 'titlem') and starts-with($lang, 'ko')">
        <xsl:text>{\textKorean {</xsl:text>
        <xsl:copy-of select="$content"/>
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:when test="contains($class, 'titlem') and starts-with($lang, 'zh')">
        <xsl:text>{\textChinese {</xsl:text>
        <xsl:copy-of select="$content"/>
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:when test="contains($class, 'titlem')">
        <xsl:text>\emph{</xsl:text>
        <xsl:copy-of select="$content"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="contains($class, 'titlej')">
        <xsl:text>\emph{</xsl:text>
        <xsl:copy-of select="$content"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="contains($class, 'titlea')">
        <xsl:text>‘</xsl:text>
        <xsl:copy-of select="$content"/>
        <xsl:text>’</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>




  <xsl:template name="makeInline">
    <xsl:param name="before"/>
    <xsl:param name="style"/>
    <xsl:param name="after"/>
    <xsl:variable name="lang">
      <xsl:call-template name="tei:findLanguage"/>
    </xsl:variable>
    <xsl:variable name="st" select="normalize-space($style)"/>
    <xsl:value-of select="$before"/>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:variable name="decl">
      <xsl:choose>
        <xsl:when test="contains(' add unclear bibl docAuthor titlem italic mentioned term foreign ', concat(' ',$st,' '))">
          <xsl:choose>
            <xsl:when test="starts-with($lang, 'ja')">{\textJapanese </xsl:when>
            <xsl:when test="starts-with($lang, 'ko')">{\textKorean </xsl:when>
            <xsl:when test="starts-with($lang, 'zh')">{\textChinese </xsl:when>
            <xsl:otherwise>\emph{</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$st = 'supplied'">
          <xsl:text/>
        </xsl:when>
        <xsl:when test="$st = 'bold'">
          <xsl:text>\textbf{</xsl:text>
        </xsl:when>
        <xsl:when test="$st = 'strikethrough'">
          <xsl:text>\sout{</xsl:text>
        </xsl:when>
        <xsl:when test="$st = 'sup'">
          <xsl:text>\textsuperscript{</xsl:text>
        </xsl:when>
        <xsl:when test="$st = 'sub'">
          <xsl:text>\textsubscript{</xsl:text>
        </xsl:when>
        <xsl:when test="local-name() = 'label'">
          <xsl:text>\textbf{</xsl:text>
        </xsl:when>
        <xsl:when test="$st = ''">
          <xsl:value-of select="concat('{\', local-name(), ' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('{\', substring-before(concat($st, ' '), ' '), ' ')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$decl"/>
    <xsl:apply-templates/>
    <xsl:if test="$decl != ''">}</xsl:if>
    <xsl:value-of select="$after"/>
  </xsl:template>

  <xsl:template name="horizontalRule">
    <xsl:text>\\\rule[0.5ex]{\textwidth}{0.5pt}</xsl:text>
  </xsl:template>

  <!-- ?? -->
  <xsl:template name="makeBlock">
    <xsl:param name="style"/>
    <xsl:value-of select="concat('\begin{', $style, '}')"/>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:apply-templates/>
    <xsl:value-of select="concat('\end{', $style, '}')"/>
  </xsl:template>
  
  <xsl:template name="makeItem">
    <xsl:text>&#10;\item</xsl:text>
    <xsl:if test="@n">[<xsl:value-of select="@n"/>]</xsl:if>
    <xsl:text> </xsl:text>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:call-template name="rendering"/>
  </xsl:template>
  <xsl:template name="makeLabelItem">
    <xsl:text>&#10;\item</xsl:text>
    <xsl:if test="@n">[<xsl:value-of select="@n"/>]</xsl:if>
    <xsl:text> </xsl:text>
    <xsl:call-template name="rendering"/>
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
  <xsl:template name="tei:makeHyperTarget">
    <xsl:param name="id" select="@xml:id"/>
    <xsl:if test="$id">\label{<xsl:value-of select="$id"/>}</xsl:if>
  </xsl:template>
</xsl:transform>
