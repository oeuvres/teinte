<?xml version="1.0" encoding="utf-8"?>
<xsl:transform 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
  xmlns:str="http://exslt.org/strings"
  xmlns:exslt="http://exslt.org/common" 
  extension-element-prefixes="str exslt"
  version="1.0"
>
  <xsl:strip-space elements="
    tei:additional tei:adminInfo
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

  <!-- The classical \label is not a precise anchor without the \phantomsection hack
  Use a local macro to always choose best solution
  (hyperrerf/hypertarget with a position upper to the baseline)
  Do not put text in anchor.
  -->
  <xsl:template name="tei:makeHyperTarget">
    <xsl:param name="id" select="@xml:id"/>
    <xsl:if test="$id">\phantomsection\label{<xsl:value-of select="$id"/>}</xsl:if>
  </xsl:template>
  
  <!-- Simple semantic block with a command -->
  <xsl:template name="makeBlock">
    <xsl:param name="style" select="local-name()"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:text>\</xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text>{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template name="makeInline">
    <xsl:param name="before"/>
    <xsl:param name="style"/>
    <xsl:param name="after"/>
    <xsl:variable name="st" select="normalize-space($style)"/>
    <xsl:value-of select="$before"/>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:variable name="decl">
      <xsl:choose>
        <xsl:when test="self::tei:foreign">\emph{</xsl:when>
        <xsl:when test="self::tei:mentioned">\emph{</xsl:when>
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
        <xsl:when test="self::tei:label">
          <xsl:text>\labelchar{</xsl:text>
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
  
  
    
</xsl:transform>
