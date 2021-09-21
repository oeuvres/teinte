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
  <xsl:import href="latex_flow.xsl"/>
  <xsl:output method="text" encoding="utf8" indent="no"/>
  
  
  <xsl:template match="/">
    <xsl:call-template name="meta"/>
  </xsl:template>
  
  <xsl:template name="latexTitle">
    <xsl:for-each select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title">
      <xsl:choose>
        <xsl:when test="not(@type) or @type='main'"><xsl:apply-templates mode="meta"/></xsl:when>
        <xsl:when test="@type='sub'">\emph{<xsl:apply-templates mode="meta"/>}</xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="meta"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="following-sibling::tei:title">
        <xsl:text>\par&#10;</xsl:text>
      </xsl:if>
      <xsl:if test="position() != last()">\medskip&#10;</xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="latexDate">
    <xsl:param name="el" select="(/*/tei:teiHeader/tei:profileDesc/tei:creation/tei:date)[1]"/>
    <!-- XPath error : Invalid type
    <xsl:param name="el">
      <xsl:choose>
        <xsl:when test="/*/tei:teiHeader/tei:profileDesc/tei:creation/tei:date">
          <xsl:copy-of select="(/*/tei:teiHeader/tei:profileDesc/tei:creation/tei:date)[1]"/>
        </xsl:when>
        <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:date">
          <xsl:copy-of select="(/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:date)[1]"/>
        </xsl:when>
      </xsl:choose>
    </xsl:param>
    -->
    <xsl:choose>
      <xsl:when test="$el[@from and @to]">
        <xsl:call-template name="year">
          <xsl:with-param name="string" select="$el/@from"/>
        </xsl:call-template>
        <xsl:text>–</xsl:text>
        <xsl:call-template name="year">
          <xsl:with-param name="string" select="$el/@to"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$el[@when]">
        <xsl:call-template name="year">
          <xsl:with-param name="string" select="$el/@when"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$el"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="latexAuthor">
    <xsl:for-each select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt[1]">
      <xsl:for-each select="tei:author|tei:principal">
        <xsl:choose>
          <xsl:when test="position() = 1"/>
          <xsl:when test="position() = last()"> \&amp; </xsl:when>
          <xsl:otherwise>, </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="normalize-space(.) != ''">
            <xsl:value-of select="normalize-space(.)"/>
          </xsl:when>
          <xsl:when test="contains(@key, '(')">
            <xsl:value-of select="normalize-space(substring-before(@key, '('))"/>
          </xsl:when>
          <xsl:when test="contains(@key, ',')">
            <xsl:value-of select="normalize-space(substring-before(@key, ','))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space(@key)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="latexAuthor1">
    <xsl:for-each select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt[1]">
      <xsl:for-each select="(tei:author|tei:principal)[1]">
        <xsl:apply-templates select="." mode="meta">
          <xsl:with-param name="short" select="true()"/>
        </xsl:apply-templates>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  

  <xsl:template name="meta">
    <xsl:variable name="latexTitle">
      <xsl:call-template name="latexTitle"/>
    </xsl:variable>
    <xsl:text>\title{</xsl:text>
    <xsl:value-of select="$latexTitle"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:variable name="latexDate">
      <xsl:call-template name="latexDate"/>
    </xsl:variable>
    <xsl:text>\date{</xsl:text>
    <xsl:value-of select="$latexDate"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:variable name="latexAuthor">
      <xsl:call-template name="latexAuthor"/>
    </xsl:variable>
    <xsl:text>\author{</xsl:text>
    <xsl:value-of select="$latexAuthor"/>
    <xsl:text>}&#10;</xsl:text>
    
    <!-- Short title for runing head -->
    <xsl:text>\def\elbibl{</xsl:text>
    <xsl:if test="$latexAuthor != ''">
      <xsl:value-of select="$latexAuthor"/>
      <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:if test="$latexDate != ''">
      <xsl:value-of select="$latexDate"/>
      <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:text>\emph{</xsl:text>
    <xsl:apply-templates select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[not(@type) or @type='main'][1]/node()" mode="meta"/>
    <xsl:text>}</xsl:text>
    <xsl:text>}&#10;</xsl:text>
    <!--
    <xsl:variable name="author1">
      <xsl:for-each select="(/*/tei:teiHeader/tei:fileDesc/tei:titleStmt)[1]">
        <xsl:for-each select="(tei:author|tei:principal)[1]">
          <xsl:apply-templates select="." mode="meta">
            <xsl:with-param name="short" select="true()"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    -->
    
    <xsl:if test="/*/tei:teiHeader/tei:profileDesc/tei:abstract">
      <xsl:text>\def\elabstract{%&#10;</xsl:text>
      <xsl:variable name="tex">
        <xsl:for-each select="/*/tei:teiHeader/tei:profileDesc/tei:abstract">
          <xsl:apply-templates/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="$tex"/>
      <xsl:choose>
        <xsl:when test="string-length($tex) &lt; 1500">\vfill&#10;</xsl:when>
        <xsl:otherwise>\newpage&#10;</xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#10;}&#10;</xsl:text>
    </xsl:if>

    <xsl:if test="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl">
      <xsl:text>\def\elsource{</xsl:text>
      <xsl:apply-templates select="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/node()"/>
      <xsl:text>}&#10;</xsl:text>
    </xsl:if>
    

    <xsl:text>\def\eltitlepage{%&#10;</xsl:text>
    <xsl:call-template name="titlePage"/>
    <xsl:text>&#10;}&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template name="titlePage">
    <xsl:text>{\centering\parindent0pt&#10;</xsl:text>
    <xsl:variable name="author">
      <xsl:call-template name="latexAuthor"/>
    </xsl:variable>
    <xsl:if test="$author != ''">
      <xsl:text>  {\LARGE\addfontfeature{LetterSpace=25}\bfseries </xsl:text>
      <xsl:value-of select="$author"/>
      <xsl:text>\par}\bigskip&#10;</xsl:text>
    </xsl:if>
    <xsl:variable name="date">
      <xsl:call-template name="latexDate"/>
    </xsl:variable>
    <xsl:if test="$date != ''">
      <xsl:text>  {\Large </xsl:text>
      <xsl:value-of select="$date"/>
      <xsl:text>\par}\bigskip&#10;</xsl:text>
    </xsl:if>
    <xsl:text>  {\LARGE&#10;</xsl:text>
    <xsl:apply-templates select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
    <xsl:text>&#10;  }&#10;</xsl:text>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>
  
  <!-- no notes in a title page -->
  <xsl:template match="tei:fileDesc/tei:titleStmt/tei:title/tei:note"/>
  
  <xsl:template match="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title">
    <xsl:text>\bigskip</xsl:text>
    <xsl:choose>
      <xsl:when test="not(@type) or @type = 'main'">\textbf{</xsl:when>
      <xsl:when test="@type='sub'">\emph{</xsl:when>
      <xsl:otherwise>{</xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
    <xsl:text>}\par&#10;</xsl:text>
  </xsl:template>

    
  

  <xsl:template match="tei:head[tei:lb]" mode="meta">
    <xsl:for-each select="tei:lb">
      <xsl:variable name="prev">
        <xsl:variable name="tmp">
          <xsl:apply-templates select="preceding-sibling::node()"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($tmp)"/>
      </xsl:variable>
      <xsl:variable name="last" select="substring($prev, string-length($prev))"/>
      <xsl:value-of select="$prev"/>
      <xsl:choose>
        <xsl:when test="contains('?.,;!:', $prev)"/>
        <xsl:otherwise>. </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="position() = last()">
        <xsl:apply-templates select="following-sibling::node()"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:author | tei:principal" mode="meta">
    <xsl:param name="short"/>
    <xsl:choose>
      <xsl:when test="$short and @key">
        <xsl:variable name="key" select="normalize-space(substring-before(concat(@key, '('), '('))"/>
        <xsl:value-of select="substring-before(concat($key, ','), ',')"/>
      </xsl:when>
      <xsl:when test="normalize-space(.) != ''">
        <xsl:apply-templates mode="meta"/>
      </xsl:when>
      <xsl:when test="@key">
        <xsl:variable name="key" select="normalize-space(substring-before(concat(@key, '('), '('))"/>
        <xsl:value-of select="$key"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:date" mode="year">
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
      <xsl:otherwise>
        <xsl:call-template name="year">
          <xsl:with-param name="string" select="$year"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="year">
    <xsl:param name="string" select="@when"/>
    <xsl:choose>
      <xsl:when test="normalize-space($string) = ''"/>
      <xsl:when test="starts-with($string, '-')">
        <xsl:text>-</xsl:text>
        <xsl:value-of select="0 + substring-before(concat(substring($string, 2), '-'), '-')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0 + substring-before(concat($string, '-'), '-')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:surname" mode="meta">
    <!-- Small caps are usually bad in modern TeX -->
    <xsl:apply-templates mode="meta"/>
  </xsl:template>

  <!-- Default, do nothing -->
  <xsl:template match="*" mode="meta">
    <xsl:apply-templates mode="meta"/>
  </xsl:template>
  <!-- No notes in meta -->
  <xsl:template match="tei:note" mode="meta"/>
  <xsl:template match="tei:hi[starts-with(@rend, 'sup')]" mode="meta">
    <xsl:text>\textsuperscript{</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="tei:emph | tei:hi[starts-with(@rend, 'i')] | tei:title" mode="meta">
    <xsl:text>\emph{</xsl:text>
    <xsl:apply-templates mode="meta"/>
    <xsl:text>}</xsl:text>
  </xsl:template>


</xsl:transform>
