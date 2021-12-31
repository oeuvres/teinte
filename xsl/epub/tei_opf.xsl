<?xml version="1.0" encoding="UTF-8"?>
<!--
<h1>TEI » HTML (tei_html.xsl)</h1>


LGPL http://www.gnu.org/licenses/lgpl.html
© 2012–2013 frederic.glorieux@fictif.org
© 2013–2015 frederic.glorieux@fictif.org et LABEX OBVIL

TODO Adobe page-map (map page number to paper edition)
http://wiki.mobileread.com/wiki/Adobe_Digital_Editions#Page-map
-->
<xsl:transform version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.idpf.org/2007/opf" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei opf">
  <xsl:import href="../tei_common.xsl"/>
  <!-- ensure override on common -->
  <xsl:include href="epub.xsl"/>
  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
  <xsl:param name="format" select="$epub3"/>
  <!-- process an opf template -->
  <xsl:param name="opf"/>
  
  <!-- The root TEI element -->
  <xsl:variable name="TEI" select="/*"/>
  
  
  <!-- process opf template, copy all and sometimes intercept -->
  <xsl:template match="tei:TEI | tei:TEI.2">
    <xsl:apply-templates select="document($opf)/*" mode="opf:template"/>
  </xsl:template>
  <xsl:template match="node()|@*" mode="opf:template">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="opf:template"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="opf:package/text() | opf:metadata/text() | opf:manifest/text() | opf:spine/text()" mode="opf:template"/>
  <xsl:template match="comment()" mode="opf:template"/>
  <xsl:template match="processing-instruction()" mode="opf:template"/>
  <xsl:template match="opf:package" mode="opf:template">
    <package unique-identifier="dcidid" version="3.0" prefix="rendition: http://www.idpf.org/vocab/rendition/#">
      <xsl:choose>
        <xsl:when test="$format = $epub2">
          <xsl:attribute name="version">2.0</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates mode="opf:template"/>
    </package>
  </xsl:template>
  <xsl:template match="opf:metadata" mode="opf:template">
    <metadata>
      <dc:format>application/epub+zip</dc:format>
      <xsl:apply-templates mode="opf:template"/>
      <dc:identifier id="dcidid">
        <xsl:value-of select="$identifier"/>
      </dc:identifier>
      <dc:title>
        <xsl:value-of select="normalize-space($doctitle)"/>
      </dc:title>
      <dc:language>
        <xsl:value-of select="$lang"/>
      </dc:language>
      <xsl:choose>
        <xsl:when test="dc:publisher"/>
        <xsl:when test="$TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:publisher">
          <dc:publisher>
            <xsl:value-of select="normalize-space($TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:publisher)"/>
          </dc:publisher>
        </xsl:when>
        <!-- ?? fallback value ? -->
      </xsl:choose>
      <!-- A good date -->
      <xsl:if test="$docdate != ''">
        <dc:date>
          <xsl:value-of select="$docdate"/>
        </dc:date>
      </xsl:if>
      <xsl:if test="$byline != ''">
        <dc:creator>
          <xsl:value-of select="$byline"/>
        </dc:creator>
      </xsl:if>
      <meta property="rendition:layout">reflowable</meta>
      <meta property="rendition:orientation">auto</meta>
      <meta property="dcterms:modified">
        <xsl:value-of select="$date"/>
        <xsl:text>Z</xsl:text>
      </meta>
    </metadata>
  </xsl:template>
  <xsl:template match="opf:manifest" mode="opf:template">
    <manifest>
      <!-- copy style resources -->
      <xsl:apply-templates mode="opf:template"/>
      <!-- @id reconnus par la plupart des bibliothèques epub -->
      <xsl:if test="$cover != ''">
        <item href="cover{$_html}" id="coverhtml" media-type="application/xhtml+xml"/>
        <xsl:choose>
          <xsl:when test="contains($cover, '.png')">
            <item href="{$cover}" id="cover-image" media-type="image/png" properties="cover-image"/>
          </xsl:when>
          <xsl:otherwise>
            <item href="{$cover}" id="cover-image" media-type="image/jpeg" properties="cover-image"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <item id="titlePage" media-type="application/xhtml+xml" href="titlePage{$_html}"/>
      <item id="toc" media-type="application/xhtml+xml" href="toc{$_html}" properties="nav"/>
      <xsl:if test="$fnpage != ''">
        <item id="{$fnpage}" media-type="application/xhtml+xml" href="{$fnpage}{$_html}"/>
      </xsl:if>
      <!-- Section files -->
      <xsl:apply-templates select="$TEI/*" mode="opf">
        <xsl:with-param name="type">manifest</xsl:with-param>
      </xsl:apply-templates>
      <!-- images to declare -->
      <xsl:for-each select="//tei:graphic">
        <item>
          <xsl:attribute name="id">
            <xsl:call-template name="id"/>
          </xsl:attribute>
          <xsl:attribute name="href">
            <xsl:value-of select="@url"/>
          </xsl:attribute>
          <xsl:attribute name="media-type">
            <xsl:choose>
              <xsl:when test="contains(@url, '.png')">image/png</xsl:when>
              <xsl:when test="contains(@url, '.jpg')">image/jpeg</xsl:when>
              <xsl:otherwise>image/jpeg</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </item>
      </xsl:for-each>
      <item id="ncx" media-type="application/x-dtbncx+xml" href="toc.ncx"/>
    </manifest>
  </xsl:template>
  <xsl:template match="opf:spine" mode="opf:template">
    <spine toc="ncx">
      <xsl:if test="$cover != ''">
        <itemref idref="coverhtml"/>
      </xsl:if>
      <itemref idref="titlePage"/>
      <xsl:apply-templates select="$TEI/*" mode="opf">
        <xsl:with-param name="type">spine</xsl:with-param>
      </xsl:apply-templates>
      <xsl:if test="$fnpage != ''">
        <itemref idref="{$fnpage}"/>
      </xsl:if>
      <itemref idref="toc"/>
      <xsl:apply-templates mode="opf:template"/>
    </spine>
  </xsl:template>
  <!-- par défaut tout arrêter -->
  <xsl:template match="*" mode="opf"/>
  <!-- traverser les racines -->
  <xsl:template match="/*/tei:text" mode="opf">
    <xsl:param name="type"/>
    <xsl:apply-templates select="tei:front | tei:group | tei:body | tei:back " mode="opf">
      <xsl:with-param name="type" select="$type"/>
    </xsl:apply-templates>
  </xsl:template>
  <!-- An entry for titlePage, will be created if not found -->
  <xsl:template match="/*/tei:text/tei:front/tei:titlePage" mode="opf"/>
  <!-- Paratext entries -->
  <xsl:template match="
    /*/tei:text/tei:front/*[self::tei:argument | self::tei:castList | self::tei:epilogue | self::tei:performance | self::tei:prologue | self::tei:set]
  | /*/tei:text/tei:back/*[self::tei:argument | self::tei:castList | self::tei:epilogue | self::tei:performance | self::tei:prologue | self::tei:set]
    " mode="opf">
    <xsl:param name="type"/>
    <xsl:call-template name="item">
      <xsl:with-param name="type" select="$type"/>
    </xsl:call-template>
  </xsl:template>
  <!-- section container -->
  <xsl:template match="tei:back | tei:body | tei:front" mode="opf">
    <xsl:param name="type"/>
    <xsl:choose>
      <!-- simple content -->
      <xsl:when test="tei:p | tei:l | tei:list | tei:argument | tei:table | tei:docTitle | tei:docAuthor">
        <xsl:call-template name="item">
          <xsl:with-param name="type" select="$type"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Sections, blocks will be lost -->
      <xsl:when test="descendant::*[key('split', generate-id())]">
        <xsl:apply-templates select="tei:argument  | tei:div | tei:div0 | tei:div1 |  tei:castList | tei:epilogue | tei:performance | tei:prologue | tei:set | tei:titlePage" mode="opf">
          <xsl:with-param name="type" select="$type"/>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- Sections, split candidates -->
  <xsl:template match="tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7 | tei:group" mode="opf">
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="self::tei:front and not(tei:div|tei:div1)"/>
      <xsl:when test="self::tei:back and not(tei:div|tei:div1)"/>
      <!-- TO synchronize with tei_ncx.xsl -->
      <xsl:when test="descendant::*[key('split', generate-id())]">
        <!-- Is there something signficative before the first div ? -->
        <xsl:variable name="before" select="generate-id(tei:group|tei:div|tei:div1|tei:div2|tei:div3|tei:div4|tei:div5|tei:div6)"/>
        <xsl:variable name="cont" select="tei:*[following-sibling::*[generate-id(.)=$before]]"/>
        <xsl:choose>
          <xsl:when test="(self::tei:front|self::tei:body|self::tei:back) and not(tei:p|tei:l|tei:list|tei:argument|tei:table)"/>
          <xsl:when test="$cont">
            <xsl:call-template name="item">
              <xsl:with-param name="type" select="$type"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
        <!-- Process other children -->
        <xsl:apply-templates select="*" mode="opf">
          <xsl:with-param name="type" select="$type"/>
        </xsl:apply-templates>
      </xsl:when>
      <!-- Should be last level to split -->
      <xsl:otherwise>
        <xsl:if test="not(key('split', generate-id()))">
          <xsl:message>tei_opf.xsl, <xsl:value-of select="$type"/>, split problem for: <xsl:call-template name="id"/>, <xsl:call-template name="title"/></xsl:message>
        </xsl:if>
        <xsl:call-template name="item">
          <xsl:with-param name="type" select="$type"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="item">
    <xsl:param name="type"/>
    <xsl:param name="id">
      <xsl:call-template name="id"/>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="$type = 'manifest'">
        <item id="{$id}" media-type="application/xhtml+xml">
          <xsl:attribute name="href">
            <xsl:call-template name="href"/>
          </xsl:attribute>
        </item>
      </xsl:when>
      <xsl:when test="$type = 'spine'">
        <itemref idref="{$id}"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>tei_opf.xsl, <xsl:call-template name="id"/>, type imprévu : <xsl:value-of select="$type"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Retenir les meta obigatoires déjà renseignées -->
  <xsl:template match="tei:sourceDesc/tei:bibl/tei:title " mode="dc"/>
  <!-- default, no output for unknow elements -->
  <xsl:template match="*" mode="dc">
    <xsl:apply-templates mode="dc"/>
  </xsl:template>
  <xsl:template match="tei:teiHeader" mode="dc">
    <xsl:apply-templates select="tei:fileDesc" mode="dc"/>
  </xsl:template>
  <xsl:template match="tei:fileDesc" mode="dc">
    <xsl:apply-templates select="tei:sourceDesc" mode="dc"/>
  </xsl:template>
  <xsl:template match="tei:sourceDesc" mode="dc">
    <xsl:choose>
      <xsl:when test="tei:bibl[@type='struct']">
        <xsl:apply-templates select="tei:bibl[@type='struct']" mode="dc"/>
      </xsl:when>
      <xsl:when test="count(*) != 1">
        <xsl:apply-templates select="*[1]" mode="dc"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*" mode="dc"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:bibl" mode="dc">
    <xsl:apply-templates select="*" mode="dc"/>
  </xsl:template>
  <xsl:template match="tei:title" mode="dc">
    <dc:title>
      <xsl:apply-templates mode="dc"/>
    </dc:title>
  </xsl:template>
  <xsl:template match="tei:date" mode="dc">
    <dc:date>
      <xsl:call-template name="year"/>
    </dc:date>
  </xsl:template>
  <xsl:template match="tei:author | tei:editor" mode="dc">
    <!-- ?? not used in epub apps
    <xsl:attribute name="opf:file-as">
    </xsl:attribute>
    -->
    <xsl:variable name="el">
      <xsl:choose>
        <xsl:when test="local-name() = 'author'">dc:creator</xsl:when>
        <xsl:otherwise>dc:contributor</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$el}" namespace="http://purl.org/dc/elements/1.1/">
      <xsl:apply-templates select="@role" mode="dc"/>
      <xsl:choose>
        <!-- Put a sortable normalize name of author if available -->
        <xsl:when test="@key">
          <xsl:value-of select="@key"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  <xsl:template match="@role" mode="dc">
    <xsl:attribute name="opf:role">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="tei:ref[@type='source']" mode="dc">
    <dc:source>
      <xsl:value-of select="@target"/>
    </dc:source>
  </xsl:template>
  <xsl:template match="tei:argument | tei:desc" mode="dc">
    <dc:description>
      <xsl:apply-templates mode="dc"/>
    </dc:description>
  </xsl:template>
</xsl:transform>
