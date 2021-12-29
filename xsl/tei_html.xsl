<?xml version="1.0" encoding="UTF-8"?>
<!--
Part of Teinte https://github.com/oeuvres/teinte
BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
© 2019 Frederic.Glorieux@fictif.org & LABEX OBVIL & Optéos
© 2013 Frederic.Glorieux@fictif.org & LABEX OBVIL
© 2012 Frederic.Glorieux@fictif.org
© 2010 Frederic.Glorieux@fictif.org & École nationale des chartes
© 2007 Frederic.Glorieux@fictif.org
© 2005 ajlsm.com (Cybertheses)

XSLT 1.0 is compatible browser, PHP, Python, Java…
-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:include href="html/tei_flow_html.xsl"/>
  <xsl:include href="html/tei_notes_html.xsl"/>
  <xsl:include href="html/tei_header_html.xsl"/>
  <xsl:include href="html/tei_toc_html.xsl"/>
  <!-- Where to find static assets like CSS or JS -->
  <xsl:param name="theme">https://oeuvres.github.io/teinte/theme/</xsl:param>
  <!-- used as a body class -->
  <xsl:param name="folder"/>
  <!--  -->
  <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="yes"/>
  <!-- Output teiHeader ? -->
  <xsl:param name="teiheader" select="true()"/>
  <!-- Racine -->
  <xsl:template match="/*">
    <xsl:apply-templates select="." mode="html"/>
  </xsl:template>
  <xsl:template match="/*" mode="html">
    <xsl:variable name="bodyclass">
      <xsl:value-of select="$corpusid"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$folder"/>
    </xsl:variable>
    <html>
      <xsl:call-template name="att-lang"/>
      <head>
        <meta charset="UTF-8"/>
        <meta name="modified" content="{$date}"/>
        <!-- déclaration classes css locale (permettre la surcharge si généralisation) -->
        <!-- à travailler
        <xsl:apply-templates select="/*/tei:teiHeader/tei:encodingDesc/tei:tagsDecl"/>
        -->
        <link rel="stylesheet" type="text/css" href="{$theme}teinte.css"/>
        <link rel="stylesheet" type="text/css" href="{$theme}teinte.layout.css"/>
        <link rel="stylesheet" type="text/css" href="{$theme}teinte.tree.css"/>
        <style>
.name {background: rgba(192, 192, 192, 0.5)}
.persName {background: rgba(255, 255, 0, 0.5)}
.placeName {background: rgba(0, 0, 128, 0.3)}
        </style>
      </head>
      <body>
        <xsl:if test="normalize-space($bodyclass)">
          <xsl:attribute name="class">
            <xsl:value-of select="normalize-space($bodyclass)"/>
          </xsl:attribute>
        </xsl:if>
        <div class="container" id="viewport">
          <div id="text" class="text">
            <xsl:apply-templates/>
          </div>
          <aside id="sidebar">
            <nav>
              <header>
                <a>
                  <xsl:attribute name="href">
                    <xsl:for-each select="/*/tei:text">
                      <xsl:call-template name="href"/>
                    </xsl:for-each>
                  </xsl:attribute>
                  <xsl:if test="$byline">
                    <xsl:copy-of select="$byline"/>
                    <xsl:text> </xsl:text>
                  </xsl:if>
                  <xsl:if test="$docdate != ''">
                    <span class="docDate">
                      <xsl:text> (</xsl:text>
                      <xsl:value-of select="$docdate"/>
                      <xsl:text>)</xsl:text>
                    </span>
                  </xsl:if>
                  <br/>
                  <xsl:copy-of select="$doctitle"/>
                </a>
              </header>
              <xsl:call-template name="toc"/>
            </nav>
          </aside>
        </div>
        <script type="text/javascript" charset="utf-8" src="{$theme}teinte.tree.js">//</script>
      </body>
    </html>
  </xsl:template>
  <!-- Metadata maybe controlled with this view -->
  <xsl:template match="tei:index">
    <div class="index">
      <xsl:for-each select="*">
        <div>
          <xsl:call-template name="class"/>
          <xsl:choose>
            <xsl:when test="@type">
              <small>
                <xsl:value-of select="@type"/>
                <xsl:text>: </xsl:text>
              </small>
            </xsl:when>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="@key">
              <xsl:value-of select="@key"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>
  <!-- Bloc de métadonnées -->
  <xsl:template match="tei:teiHeader">
    <header id="teiHeader">
      <xsl:choose>
        <xsl:when test="not($teiheader)"/>
        <xsl:when test="../tei:text/tei:front/tei:titlePage"/>
        <xsl:otherwise>
          <xsl:apply-templates select="tei:fileDesc"/>
          <xsl:apply-templates select="tei:profileDesc/tei:abstract"/>
        </xsl:otherwise>
      </xsl:choose>
    </header>
  </xsl:template>
  <xsl:template match="tei:text">
    <xsl:param name="level" select="count(ancestor::tei:group)"/>
    <article>
      <xsl:attribute name="id">
        <xsl:call-template name="id"/>
      </xsl:attribute>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates select="*">
        <xsl:with-param name="level" select="$level +1"/>
      </xsl:apply-templates>
      <!-- groupes de textes, procéder les notes par textes -->
      <xsl:if test="not(tei:group)">
        <!-- No notes in teiHeader ? -->
        <xsl:call-template name="footnotes"/>
      </xsl:if>
    </article>
  </xsl:template>
  <xsl:template match="*" priority="-1">
    <xsl:choose>
      <xsl:when test="namespace-uri(/*) = namespace-uri()">
        <xsl:element name="{local-name()}">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
