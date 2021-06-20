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
  <!-- 
  some S. Rahtz TEI common templates ported to xslt 1
  -->
  
  <xsl:template name="tei:findLanguage">
    <xsl:param name="context" select="."/>
    <xsl:if test="$context">
      <xsl:for-each select="$context">
        <xsl:value-of select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="tei:i18n">
    <xsl:param name="code"/>
    <xsl:choose>
      <xsl:when test="$code = 'p.'">p. </xsl:when>
      <xsl:when test="$code = 'page'">p. </xsl:when>
      <xsl:when test="$code = 'note'">Note </xsl:when>
      <xsl:when test="$code = 'note'">Note : </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="tei:resolveURI">
    <xsl:param name="context" select="."/>
    <xsl:param name="target"/>
    <!-- Could be better here -->
    <xsl:value-of select="normalize-space($target)"/>
  </xsl:template>
  
  <xsl:template name="str:tokenize">
    <xsl:param name="string" select="''" />
    <xsl:param name="delimiters" select="' &#x9;&#xA;'" />
    <xsl:choose>
      <xsl:when test="not($string)" />
      <xsl:when test="not($delimiters)">
        <xsl:call-template name="str:_tokenize-characters">
          <xsl:with-param name="string" select="$string" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="str:_tokenize-delimiters">
          <xsl:with-param name="string" select="$string" />
          <xsl:with-param name="delimiters" select="$delimiters" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="str:_tokenize-characters">
    <xsl:param name="string" />
    <xsl:if test="$string">
      <token><xsl:value-of select="substring($string, 1, 1)" /></token>
      <xsl:call-template name="str:_tokenize-characters">
        <xsl:with-param name="string" select="substring($string, 2)" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="str:_tokenize-delimiters">
    <xsl:param name="string" />
    <xsl:param name="delimiters" />
    <xsl:variable name="delimiter" select="substring($delimiters, 1, 1)" />
    <xsl:choose>
      <xsl:when test="not($delimiter)">
        <token><xsl:value-of select="$string" /></token>
      </xsl:when>
      <xsl:when test="contains($string, $delimiter)">
        <xsl:if test="not(starts-with($string, $delimiter))">
          <xsl:call-template name="str:_tokenize-delimiters">
            <xsl:with-param name="string" select="substring-before($string, $delimiter)" />
            <xsl:with-param name="delimiters" select="substring($delimiters, 2)" />
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="str:_tokenize-delimiters">
          <xsl:with-param name="string" select="substring-after($string, $delimiter)" />
          <xsl:with-param name="delimiters" select="$delimiters" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="str:_tokenize-delimiters">
          <xsl:with-param name="string" select="$string" />
          <xsl:with-param name="delimiters" select="substring($delimiters, 2)" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

  <!-- 
    Is given an element and defines whether or not this element is to be rendered inline. 
    XSLT1 can only return string (no booleans)
    
    $inline != '' => is inline
    $inline = '' => is block
    
    BAD tests 
    ($inline = true()) => always true
    not($inline) => always false

  -->
  <xsl:template name="tei:isInline">
    <xsl:param name="element" select="."/>
    <xsl:choose>
      <xsl:when test="count($element) = 0">true</xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$element">
          <xsl:choose>
            <!-- Children of <div>, block -->
            <xsl:when test="parent::tei:div"/>
            <!-- Brother of a block, block -->
            <xsl:when test="../tei:p|../tei:l|../tei:lg|../tei:list|../tei:table"/>
            <xsl:when test="parent::tei:titlePage"/>
            <xsl:when test="parent::tei:body"/>
            <xsl:when test="parent::tei:front"/>
            <xsl:when test="parent::tei:back"/>
            <xsl:when test="parent::tei:list"/>
            <xsl:when test="parent::tei:figure"/>
            <xsl:when test="self::tei:body"/>
            <xsl:when test="self::tei:front"/>
            <xsl:when test="self::tei:back"/>
            <xsl:when test="not(self::*)">true</xsl:when>
            <xsl:when test="parent::tei:bibl/parent::tei:q">true</xsl:when>
            <xsl:when test="contains(@rend,'inline') and not(tei:p or tei:l)">true</xsl:when>
            <xsl:when test="self::tei:note[@place='display']"/>
            <xsl:when test="self::tei:note[@place='block']"/>
            <xsl:when test="self::tei:note">true</xsl:when>
            <xsl:when test="contains(@rend,'display') or contains(@rend,'block')"/>
            <xsl:when test="@type='display' or @type='block'"/>
            <xsl:when test="tei:table or tei:figure or tei:list or tei:lg    or tei:q/tei:l or tei:l or tei:p or tei:biblStruct or tei:sp or tei:floatingText"/>
            <xsl:when test="self::tei:cit[not(@rend)]">true</xsl:when>
            <xsl:when test="parent::tei:cit[contains(@rend,'display')]"/>
            <xsl:when test="parent::tei:cit and (tei:p or tei:l)"/>
            <xsl:when test="parent::tei:cit and parent::cit/tei:bibl"/>
            <xsl:when test="self::tei:docAuthor and parent::tei:byline">true</xsl:when>
            <xsl:when test="self::tei:note[tei:cit/tei:bibl]"/>
            <xsl:when test="self::tei:note[parent::tei:biblStruct]">true</xsl:when>
            <xsl:when test="self::tei:note[parent::tei:bibl]">true</xsl:when>
            <xsl:when test="self::tei:note">true</xsl:when>
            <xsl:when test="self::tei:abbr">true</xsl:when>
            <xsl:when test="self::tei:affiliation">true</xsl:when>
            <xsl:when test="self::tei:altIdentifier">true</xsl:when>
            <xsl:when test="self::tei:analytic">true</xsl:when>
            <xsl:when test="self::tei:add">true</xsl:when>
            <xsl:when test="self::tei:am">true</xsl:when>
            <xsl:when test="self::tei:att">true</xsl:when>
            <xsl:when test="self::tei:author">true</xsl:when>
            <xsl:when test="self::tei:bibl and not(parent::tei:listBibl)">true</xsl:when>
            <xsl:when test="self::tei:biblScope">true</xsl:when>
            <xsl:when test="self::tei:br">true</xsl:when>
            <xsl:when test="self::tei:byline">true</xsl:when>
            <xsl:when test="self::tei:c">true</xsl:when>
            <xsl:when test="self::tei:caesura">true</xsl:when>
            <xsl:when test="self::tei:choice">true</xsl:when>
            <xsl:when test="self::tei:code">true</xsl:when>
            <xsl:when test="self::tei:collection">true</xsl:when>
            <xsl:when test="self::tei:country">true</xsl:when>
            <xsl:when test="self::tei:damage">true</xsl:when>
            <xsl:when test="self::tei:date">true</xsl:when>
            <xsl:when test="self::tei:del">true</xsl:when>
            <xsl:when test="self::tei:depth">true</xsl:when>
            <xsl:when test="self::tei:dim">true</xsl:when>
            <xsl:when test="self::tei:dimensions">true</xsl:when>
            <xsl:when test="self::tei:editor">true</xsl:when>
            <xsl:when test="self::tei:editionStmt">true</xsl:when>
            <xsl:when test="self::tei:emph">true</xsl:when>
            <xsl:when test="self::tei:ex">true</xsl:when>
            <xsl:when test="self::tei:expan">true</xsl:when>
            <xsl:when test="self::tei:figure[@place='inline']">true</xsl:when>
            <xsl:when test="self::tei:figure"/>
            <xsl:when test="self::tei:floatingText"/>
            <xsl:when test="self::tei:foreign">true</xsl:when>
            <xsl:when test="self::tei:forename">true</xsl:when>
            <xsl:when test="self::tei:g">true</xsl:when>
            <xsl:when test="self::tei:gap">true</xsl:when>
            <xsl:when test="self::tei:genName">true</xsl:when>
            <xsl:when test="self::tei:geogName">true</xsl:when>
            <xsl:when test="self::tei:gi">true</xsl:when>
            <xsl:when test="self::tei:gloss">true</xsl:when>
            <xsl:when test="self::tei:graphic">true</xsl:when>
            <xsl:when test="self::tei:media">true</xsl:when>
            <xsl:when test="self::tei:height">true</xsl:when>
            <xsl:when test="self::tei:ident">true</xsl:when>
            <xsl:when test="self::tei:idno">true</xsl:when>
            <xsl:when test="self::tei:imprint">true</xsl:when>
            <xsl:when test="self::tei:institution">true</xsl:when>
            <xsl:when test="self::tei:label[parent::tei:list]"/>
            <xsl:when test="self::tei:label">true</xsl:when>
            <xsl:when test="self::tei:locus">true</xsl:when>
            <xsl:when test="self::tei:mentioned">true</xsl:when>
            <xsl:when test="self::tei:monogr">true</xsl:when>
            <xsl:when test="self::tei:series">true</xsl:when>
            <xsl:when test="self::tei:msName">true</xsl:when>
            <xsl:when test="self::tei:name">true</xsl:when>
            <xsl:when test="self::tei:num">true</xsl:when>
            <xsl:when test="self::tei:orgName">true</xsl:when>
            <xsl:when test="self::tei:orig">true</xsl:when>
            <xsl:when test="self::tei:origDate">true</xsl:when>
            <xsl:when test="self::tei:origPlace">true</xsl:when>
            <xsl:when test="self::tei:pc">true</xsl:when>
            <xsl:when test="self::tei:persName">true</xsl:when>
            <xsl:when test="self::tei:placeName">true</xsl:when>
            <xsl:when test="self::tei:ptr">true</xsl:when>
            <xsl:when test="self::tei:publisher">true</xsl:when>
            <xsl:when test="self::tei:pubPlace">true</xsl:when>
            <xsl:when test="self::tei:lb or self::pb">true</xsl:when>
            <xsl:when test="self::tei:quote and tei:lb"/>
            <xsl:when test="self::tei:q">true</xsl:when>
            <xsl:when test="self::tei:quote">true</xsl:when>
            <xsl:when test="self::tei:ref">true</xsl:when>
            <xsl:when test="self::tei:region">true</xsl:when>
            <xsl:when test="self::tei:repository">true</xsl:when>
            <xsl:when test="self::tei:roleName">true</xsl:when>
            <xsl:when test="self::tei:rubric">true</xsl:when>
            <xsl:when test="self::tei:rs">true</xsl:when>
            <xsl:when test="self::tei:said">true</xsl:when>
            <xsl:when test="self::tei:seg">true</xsl:when>
            <xsl:when test="self::tei:sic">true</xsl:when>
            <xsl:when test="self::tei:settlement">true</xsl:when>
            <xsl:when test="self::tei:soCalled">true</xsl:when>
            <xsl:when test="self::tei:summary">true</xsl:when>
            <xsl:when test="self::tei:supplied">true</xsl:when>
            <xsl:when test="self::tei:surname">true</xsl:when>
            <xsl:when test="self::tei:tag">true</xsl:when>
            <xsl:when test="self::tei:term">true</xsl:when>
            <xsl:when test="self::tei:textLang">true</xsl:when>
            <xsl:when test="self::tei:title">true</xsl:when>
            <xsl:when test="self::tei:unclear">true</xsl:when>
            <xsl:when test="self::tei:val">true</xsl:when>
            <xsl:when test="self::tei:width">true</xsl:when>
            <xsl:when test="self::tei:dynamicContent">true</xsl:when>
            <!-- 
          <xsl:when test="parent::tei:note[tei:isEndNote(.)]"/>
          -->
            <xsl:when test="not(self::tei:p)">
              <xsl:call-template name="tei:isInline">
                <xsl:with-param name="element" select=".."/>
              </xsl:call-template>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

  <!-- Title, author and date is taken from the
      &lt;teiHeader&gt; rather than looked for in the front matter -->
  
  <xsl:param name="useHeaderFrontMatter">false</xsl:param>
  
  <xsl:template name="tei:generateSimpleTitle">
    <xsl:param name="context" select="."/>
    <xsl:for-each select="$context">
      <xsl:choose>
        <xsl:when test="$useHeaderFrontMatter='true' and ancestor-or-self::tei:TEI/tei:text/tei:front//tei:docTitle">
          <xsl:apply-templates select="ancestor-or-self::tei:TEI/tei:text/tei:front//tei:docTitle" mode="simple"/>
        </xsl:when>
        <xsl:when test="ancestor-or-self::tei:teiCorpus">
          <xsl:apply-templates select="ancestor-or-self::tei:teiCorpus/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[not(@type='subordinate')]" mode="simple"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="ancestor-or-self::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt">
            <xsl:choose>
              <xsl:when test="tei:title[@type='main']">
                <xsl:apply-templates select="tei:title[@type='main']" mode="simple"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="tei:title[1]" mode="simple"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  
  <!-- title  -->
  <xsl:template match="tei:title" mode="simple">
    <xsl:apply-templates select="text()"/>
  </xsl:template>
  

  <!-- TOD, take from teinte/common.xsl -->
  <xsl:template name="tei:generateAuthor">
    <xsl:param name="context" select="."/>
    <xsl:variable name="result">
      <xsl:for-each select="$context">
        <xsl:choose>
          <xsl:when test="$useHeaderFrontMatter='true' and
            ancestor-or-self::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author">
            <xsl:apply-templates mode="author" select="ancestor-or-self::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author"/>
          </xsl:when>
          <xsl:when
            test="ancestor-or-self::tei:TEI/tei:text/tei:front//tei:docAuthor">
            <xsl:apply-templates mode="author"
              select="ancestor-or-self::tei:TEI/tei:text/tei:front//tei:docAuthor"/>
          </xsl:when>
          <xsl:when
            test="ancestor-or-self::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author">
            <xsl:apply-templates mode="author" select="ancestor-or-self::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author"/>
          </xsl:when>
          <xsl:when
            test="ancestor-or-self::tei:teiCorpus/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author">
            <xsl:apply-templates mode="author" select="ancestor-or-self::tei:teiCorpus/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author"/>
          </xsl:when>
          <xsl:when
            test="ancestor-or-self::tei:TEI/tei:teiHeader/tei:revisionDesc/tei:change/tei:respStmt[tei:resp='author']">
            <xsl:apply-templates select="ancestor-or-self::tei:TEI/tei:teiHeader/tei:revisionDesc/tei:change/tei:respStmt[tei:resp='author'][1]/tei:name"/>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:copy-of select="$result"/>
  </xsl:template>
  
    
</xsl:transform>
