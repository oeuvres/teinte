<?xml version="1.0" encoding="UTF-8"?>
<!--

Produce a valid xhtml fragment <article>, ready to be included in a page
Just the /TEI/text content (with footnotes) but no /html/head or toc.

BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
© 2019 Frederic.Glorieux@fictif.org & LABEX OBVIL & Optéos
© 2013 Frederic.Glorieux@fictif.org & LABEX OBVIL
© 2012 Frederic.Glorieux@fictif.org
© 2010 Frederic.Glorieux@fictif.org & École nationale des chartes
© 2007 Frederic.Glorieux@fictif.org
© 2005 ajlsm.com (Cybertheses)

XSLT 1.0, compatible browser, PHP, Python, Java…
-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:import href="tei_html/tei_flow_html.xsl"/>
  <xsl:import href="tei_html/tei_notes_html.xsl"/>
  <xsl:import href="tei_html/tei_toc_html.xsl"/>
  <!-- Maybe used as a body class -->
  <xsl:param name="folder"/>
  <!-- method html, safer for empty <div/> -->
  <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="yes"/>
  <!-- Racine -->
  <xsl:template match="/">
    <xsl:apply-templates select="/*/tei:text"/>
  </xsl:template>

  <xsl:template match="tei:text">
    <xsl:param name="level" select="count(ancestor::tei:group)"/>
    
    <xsl:variable name="class">
      <xsl:value-of select="$corpusid"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$folder"/>
      <xsl:text> teinte</xsl:text>
    </xsl:variable>
    
    
    <article>
      <xsl:attribute name="id">
        <xsl:call-template name="id"/>
      </xsl:attribute>
      <xsl:call-template name="atts">
        <xsl:with-param name="class" select="$class"/>
      </xsl:call-template>
      <aside class="toc">
        <xsl:if test="count(.//tei:head) &gt; 2">
          <nav>
            <xsl:call-template name="toc"/>
          </nav>
        </xsl:if>
        <xsl:text> </xsl:text>
      </aside>
      <div class="main">
        <xsl:apply-templates select="*"/>
        <!-- groupes de textes, procéder les notes par textes -->
        <xsl:if test="not(tei:group)">
          <!-- No notes in teiHeader ? -->
          <xsl:call-template name="footnotes"/>
        </xsl:if>
      </div>
    </article>
  </xsl:template>
</xsl:transform>
