<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns="http://www.tei-c.org/ns/1.0" 
  xmlns:epub="http://www.idpf.org/2007/ops"
  
  xmlns:html="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="html epub"
  xmlns:exslt="http://exslt.org/common"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:php="http://php.net/xsl"
  extension-element-prefixes="date exslt php"
  >
  <xsl:output indent="yes" encoding="UTF-8" method="xml" omit-xml-declaration="yes"/>
  <xsl:variable name="lf" select="'&#10;'"/>
  <!-- 1234567890 -->
  <xsl:variable name="ÂBC">ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÄÆÇÉÈÊËÎÏÑÔÖŒÙÛÜ _-,</xsl:variable>
  <xsl:variable name="âbc">abcdefghijklmnopqrstuvwxyzàâäæçéèêëîïñôöœùûü</xsl:variable>
  <xsl:variable name="abc">abcdefghijklmnopqrstuvwxyzaaaeceeeeiinooeuuu</xsl:variable>
  <xsl:variable name="sheet" select="document('styles.xml', document(''))"/>
  

  <xsl:template match="html:*">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="node() | @*"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="node()">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template match="html:link | html:script | html:style"/>
  <xsl:template match="html:meta[@http-equiv]"/>
<!--
STRUCTURE
-->
  <xsl:template match="html:html">
    <xsl:processing-instruction name="xml-model"> href="http://oeuvres.github.io/Teinte/teinte.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
    <xsl:if test="function-available('date:date-time')">
      <xsl:value-of select="$lf"/>
      <xsl:comment>
        <xsl:text>Html2tei: </xsl:text>
        <xsl:value-of select="date:date-time()"/>
      </xsl:comment>
    </xsl:if>
    
    <TEI>
      <xsl:apply-templates select="node() | @*"/>
    </TEI>
  </xsl:template>
  <xsl:template match="html:head">
    <teiHeader>
      <xsl:apply-templates select="node() | @*"/>
    </teiHeader>
  </xsl:template>
  <xsl:template match="html:body">
    <text>
      <xsl:apply-templates select="@*"/>
      <body>
        <div>
          <xsl:apply-templates/>
        </div>
      </body>
    </text>
  </xsl:template>
  <xsl:template match="html:section | html:article">
    <div type="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="html:img">
    <graphic>
      <xsl:copy-of select="@*"/>
    </graphic>
  </xsl:template>
  <!-- no hierachical grouping ? -->
  <xsl:template match="html:div">
    <xsl:variable name="class" select="translate(@class, $ÂBC, $abc)"/>
    <xsl:variable name="id" select="translate(@id, $ÂBC, $abc)"/>
    <xsl:variable name="mapping" select="$sheet/*/*[@name=$class or @id=$id][not(@html) or @html='div'][1]"/>
    <xsl:variable name="mixed">
      <xsl:for-each select="text()">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space(.) = ''"/>
      <xsl:when test="$mixed = '' and not(*[local-name() != 'img'])"/>
      <xsl:when test="$mapping">
        <xsl:call-template name="mapping">
          <xsl:with-param name="mapping" select="$mapping"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$mixed = '' and count(*) = 1 and *[@class='pagenum']">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$class = 'strophe' or $class = 'strophec' or $class = 'lg' or $class = 'stanza'">
        <lg>
          <xsl:apply-templates select="@*[name() != 'class']"/>
          <xsl:apply-templates/>
        </lg>
      </xsl:when>
      <xsl:when test="$class = 'quote' or $class = 'quotec' ">
        <quote>
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates/>
        </quote>
      </xsl:when>
      <xsl:otherwise>
        <div>
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Wikisource -->
  <xsl:template match="
    html:div[@class='tableItem']
    ">
    <!-- strip -->
  </xsl:template>
  <xsl:template match="html:ol[@class='references']">
    <div type="notes">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="html:ol[@class='references']/html:li">
    <note>
      <xsl:attribute name="xml:id">
        <xsl:choose>
          <xsl:when test="starts-with(@id, 'cite_note-')">
            <xsl:text>fn</xsl:text>
            <xsl:value-of select="substring-after(@id, 'cite_note-')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@id"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </note>
  </xsl:template>
<!--
BLOCKS
-->
  <!-- Hierarchical headers is not sure -->
  <xsl:template match="html:h1 | html:h2 | html:h3 | html:h4 | html:h5 | html:h6">
    <!--
    <xsl:text disable-output-escaping="yes">
&lt;/div>
&lt;div>
</xsl:text>
-->
    <head>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="type">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </head>
  </xsl:template>
  <!--
  <xsl:template match="html:h1//text() | html:h2//text() | html:h3//text() | html:h4//text() | html:h5//text() | html:h6//text()">
    <xsl:value-of select="translate(., $ABC, $abc)"/>
  </xsl:template>
  -->
  <xsl:template match="html:ul | html:ol">
    <list>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="type">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </list>
  </xsl:template>
  <xsl:template match="html:li">
    <item>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </item>
  </xsl:template>
  <xsl:template match="html:blockquote">
    <quote>
      <xsl:apply-templates select="node() | @*"/>
    </quote>
  </xsl:template>
  <xsl:template match="html:p">
    <xsl:variable name="class" select="translate(@class, $ÂBC, $abc)"/>
    <xsl:variable name="id" select="translate(@id, $ÂBC, $abc)"/>
    <xsl:variable name="mapping" select="$sheet/*/*[@name=$class or @id=$id][not(@html) or @html='p'][1]"/>
    <xsl:variable name="mixed">
      <xsl:for-each select="text()">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:for-each>
    </xsl:variable>
    <!-- vu où ? -->
    <xsl:if test="contains(@class, 'p2')">
      <p/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="normalize-space(.) = '' and not(*[local-name != 'img'])">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$mixed = '' and count(*) = 1 and *[@class='pagenum']">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$mapping">
        <xsl:call-template name="mapping">
          <xsl:with-param name="mapping" select="$mapping"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="ancestor::html:div[@class='poetry' or @class='stanza' or @class='poem' or @class='strophe' or @class='strophec'] ">
        <l>
          <xsl:apply-templates select="node()|@*"/>
        </l>
      </xsl:when>
      <xsl:when test=" $class = 'hsub' or $class = 'hsubc'">
        <head type="sub">
          <xsl:apply-templates select="@*[name() != 'class'] | node()"/>
        </head>
      </xsl:when>
      <xsl:when test=" $class = 'sig' or $class = 'signed' ">
        <signed>
          <xsl:apply-templates select="@* | node()"/>
        </signed>
      </xsl:when>
      <xsl:when test=" $class = 'titre' ">
        <label>
          <xsl:apply-templates select="@* | node()"/>
        </label>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:apply-templates select="@*"/>
          <xsl:choose>
            <xsl:when test="@class = 'p2'"/>
            <xsl:when test="$class=''"/>
            <xsl:otherwise>
              <xsl:attribute name="rend">
                <xsl:value-of select="$class"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
<!-- 
PHRASES
  -->
  <!-- typographic phrasing -->
  <xsl:template match="html:b | html:small | html:strong | html:sub | html:u">
    <hi>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="rend">
        <xsl:value-of select="local-name(.)"/>
        <xsl:if test="@class != ''">
          <xsl:text> </xsl:text>
          <xsl:value-of select="normalize-space(@class)"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates/>
    </hi>
  </xsl:template>
  <xsl:template match="html:i">
    <emph>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </emph>
  </xsl:template>
  <!-- -->
  <xsl:template match="html:sup">
    <xsl:choose>
      <xsl:when test="@class='reference'">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <hi rend="sup">
          <xsl:apply-templates/>
        </hi>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- specific to Gutenberg ? -->
  <xsl:template match="html:cite">
    <title>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </title>
  </xsl:template>
  <xsl:template match="html:br">
    <xsl:value-of select="$lf"/>
    <lb/>
  </xsl:template>
  <xsl:template match="html:span">
    <xsl:variable name="class" select="translate(@class, $ÂBC, $abc)"/>
    <xsl:variable name="id" select="translate(@id, $ÂBC, $abc)"/>
    <xsl:variable name="mapping" select="$sheet/*/*[@name=$class or @id=$id][not(@html) or @html='span'][1]"/>
    <xsl:choose>
      <!-- span class="i3 smcap" -->
      <xsl:when test="contains(@class, 'smcap') and ancestor::*[@class='quote']">
        <author>
          <xsl:apply-templates/>
        </author>
      </xsl:when>
      <xsl:when test="contains(@class, 'pagenum')">
        <pb n="{@id}"/>
      </xsl:when>
      <xsl:when test="$mapping">
        <xsl:call-template name="mapping">
          <xsl:with-param name="mapping" select="$mapping"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test=". = ''">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="@lang | @xml:lang">
        <foreign>
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates/>
        </foreign>
      </xsl:when>
      <xsl:when test="$class='sc'">
        <hi rend="sc">
          <xsl:apply-templates/>
        </hi>
      </xsl:when>
      <xsl:when test="@class='add2em'">
        <seg type="tab">    </seg>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="@class='add4em'">
        <seg type="tab">    </seg>
        <seg type="tab">    </seg>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="@class='add6em'">
        <seg type="tab">    </seg>
        <seg type="tab">    </seg>
        <seg type="tab">    </seg>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="@class='add8em'">
        <seg type="tab">    </seg>
        <seg type="tab">    </seg>
        <seg type="tab">    </seg>
        <seg type="tab">    </seg>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <seg>
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates/>
        </seg>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="html:hr"/>
  <xsl:template match="html:em">
    <emph>
      <xsl:apply-templates select="@* | node()"/>
    </emph>
  </xsl:template>
  <!-- Links -->
  <xsl:template match="html:a">
    <xsl:choose>
      <!-- Useful anchor ? -->
      <xsl:when test=". = ''"/>
      <!-- 
<a href="#footnote11" title="Go to footnote 11"><span class="smaller">[11]</span></a>
      -->
      <xsl:otherwise>
        <ref>
          <xsl:apply-templates select="@*"/>
          <xsl:attribute name="target">
            <xsl:choose>
              <xsl:when test="starts-with(@href, '#cite_note-')">
                <xsl:text>#fn</xsl:text>
                <xsl:value-of select="substring-after(@href, '#cite_note-')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@href"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates/>
        </ref>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="html:table">
    <table>
      <xsl:apply-templates select="node()|@*"/>
    </table>
  </xsl:template>
  <xsl:template match="html:tr">
    <row>
      <xsl:apply-templates select="node()|@*"/>
    </row>
  </xsl:template>
  <xsl:template match="html:td">
    <cell>
      <xsl:apply-templates select="node()|@*"/>
    </cell>
  </xsl:template>
  <xsl:template match="html:th">
    <cell role="label">
      <xsl:apply-templates select="node()|@*"/>
    </cell>
  </xsl:template>
  
  <!-- Gutenberg notices -->
  <xsl:template match="html:pre">
    <xsl:choose>
      <xsl:when test="contains(., 'Gutenberg')"/>
      <xsl:otherwise>
        <eg>
          <xsl:apply-templates select="node() | @*"/>
        </eg>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- Maping logic -->
  <xsl:template name="mapping">
    <xsl:param name="mapping"/>
    <xsl:choose>
      <!-- error ? -->
      <xsl:when test="not($mapping)"/>
      <xsl:when test="not($mapping/@tei)"/>
      <!-- Filter element by class -->
      <xsl:when test="$mapping/@tei = ''">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{$mapping/@tei}">
          <xsl:apply-templates select="@*[name() != 'class']"/>
          <xsl:if test="$mapping/@rend">
            <xsl:attribute name="rend">
              <xsl:value-of select="$mapping/@tei"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="$mapping/@type">
            <xsl:attribute name="type">
              <xsl:value-of select="$mapping/@type"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="@*[name() != 'class']"/>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- 
 ATTRIBUTES
  -->
  <xsl:template match="html:*/@*" priority="0"/>
  
  <xsl:template match="@n | @rend | @xml:lang">
    <xsl:copy>
      <xsl:value-of select="."/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@class">
    <xsl:attribute name="rend">
      <xsl:value-of select="translate(., $ÂBC, $abc)"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="@lang">
    <xsl:attribute name="xml:lang">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="@name">
    <xsl:attribute name="xml:id">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@id">
    <xsl:attribute name="xml:id">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="@title">
    <xsl:variable name="title" select="normalize-space(.)"/>
    <xsl:if test="$title != ''">
      <xsl:attribute name="n">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
    <!-- A counting template to produce inlines -->
  <xsl:template name="divClose">
    <xsl:param name="n"/>
    <xsl:choose>
      <xsl:when test="$n &gt; 0">
        <xsl:processing-instruction name="div">/</xsl:processing-instruction>
        <xsl:call-template name="divClose">
          <xsl:with-param name="n" select="$n - 1"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="divOpen">
    <xsl:param name="n"/>
    <xsl:choose>
      <xsl:when test="$n &gt; 0">
        <xsl:processing-instruction name="div"/>
        <xsl:call-template name="divOpen">
          <xsl:with-param name="n" select="$n - 1"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="debug">
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:text>/</xsl:text>
      <xsl:variable name="name" select="name()"/>
      <xsl:value-of select="$name"/>
      <xsl:if test="count(../*[name()=$name]) &gt; 1">
        <xsl:text>[</xsl:text>
          <xsl:number/>
        <xsl:text>]</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:transform>