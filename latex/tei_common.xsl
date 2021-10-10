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

  <!-- ([%\$#_{}]) -->
  <xsl:template name="texescape">
    <xsl:param name="string" select="."/>
    <xsl:choose>
      <xsl:when test="contains($string, '_')">
        <xsl:call-template name="texescape">
          <xsl:with-param name="string" select="substring-before($string, '_')"/>
        </xsl:call-template>
        <xsl:text>\_</xsl:text>
        <xsl:call-template name="texescape">
          <xsl:with-param name="string" select="substring-after($string, '_')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($string, '%')">
        <xsl:call-template name="texescape">
          <xsl:with-param name="string" select="substring-before($string, '%')"/>
        </xsl:call-template>
        <xsl:text>\%</xsl:text>
        <xsl:call-template name="texescape">
          <xsl:with-param name="string" select="substring-after($string, '%')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($string, '#')">
        <xsl:call-template name="texescape">
          <xsl:with-param name="string" select="substring-before($string, '#')"/>
        </xsl:call-template>
        <xsl:text>\#</xsl:text>
        <xsl:call-template name="texescape">
          <xsl:with-param name="string" select="substring-after($string, '#')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($string, '\')">
        <xsl:call-template name="texescape">
          <xsl:with-param name="string" select="substring-before($string, '\')"/>
        </xsl:call-template>
        <xsl:text>\\</xsl:text>
        <xsl:call-template name="texescape">
          <xsl:with-param name="string" select="substring-after($string, '\')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
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
