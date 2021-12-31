<?xml version="1.0" encoding="UTF-8"?>
<!--

<h1>TEI » HTML (tei2html.xsl)</h1>

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2021 Frederic.Glorieux@fictif.org & hutlus.fr & Optéos
© 2019 Frederic.Glorieux@fictif.org & LABEX OBVIL & Optéos
© 2013 Frederic.Glorieux@fictif.org & LABEX OBVIL
© 2012 Frederic.Glorieux@fictif.org
© 2010 Frederic.Glorieux@fictif.org & École nationale des chartes
© 2007 Frederic.Glorieux@fictif.org
© 2005 ajlsm.com (Cybertheses)

XSLT 1.0 is compatible browser, PHP, Python, Java…
-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:include href="flow.xsl"/>
  <xsl:include href="notes.xsl"/>
  <!--  -->
  <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="yes"/>
  <!-- Racine -->
  <xsl:template match="/">
    <xsl:apply-templates select="/*/tei:teiHeader/tei:profileDesc/tei:abstract"/>
  </xsl:template>
  <xsl:template match="tei:abstract">
    <xsl:text>&#10;&#10;&#10;</xsl:text>
    <article>
      <xsl:apply-templates/>
      <xsl:call-template name="footnotes"/>
    </article>
  </xsl:template>
  <xsl:template match="tei:ref[starts-with(@target, '#')]">
    <xsl:apply-templates/>
  </xsl:template>
</xsl:transform>
