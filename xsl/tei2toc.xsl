<?xml version="1.0" encoding="UTF-8"?>
<!--

Produce a valid xhtml fragment <article>, ready to be included in a page
Just the /TEI/text content (with footnotes) but no /html/head or toc.

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2019 Frederic.Glorieux@fictif.org & LABEX OBVIL & Optéos
© 2013 Frederic.Glorieux@fictif.org & LABEX OBVIL
© 2012 Frederic.Glorieux@fictif.org
© 2010 Frederic.Glorieux@fictif.org & École nationale des chartes
© 2007 Frederic.Glorieux@fictif.org
© 2005 ajlsm.com (Cybertheses)

XSLT 1.0 is compatible browser, PHP, Python, Java…
-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:import href="common.xsl"/>
  <xsl:import href="html/toc.xsl"/>
  <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="yes"/>
  <!-- Racine -->
  <xsl:template match="/*">
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
  </xsl:template>
</xsl:transform>
