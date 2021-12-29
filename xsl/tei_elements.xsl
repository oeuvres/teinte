<?xml version="1.0" encoding="UTF-8"?>
<!--

Part of Teinte https://github.com/oeuvres/teinte
BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
Copyright (c) 2020 frederic.glorieux@fictif.org


Split a single TEI book in different elements
-->
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <xsl:import href="tei_split.xsl"/>  
  <xsl:import href="html/tei_flow_html.xsl"/>
  <xsl:import href="html/tei_notes_html.xsl"/>
  <xsl:import href="html/tei_toc_html.xsl"/>
  <xsl:output indent="yes" encoding="UTF-8" method="xml" />
  <!-- Still needed for creation of filenames -->
  <xsl:variable name="split" select="true()"/>
  <!-- No extension for generated links -->
  <xsl:param name="_ext"/>

  <xsl:template name="document">
    <xsl:param name="tei" select="."/>
    <xsl:variable name="href">
      <xsl:value-of select="$dst_dir"/>
      <xsl:call-template name="href"/>
      <!-- Shall we need a suffix here ? -->
    </xsl:variable>
    <xsl:document 
      href="{$href}.html" 
      omit-xml-declaration="yes" 
      encoding="UTF-8" 
      indent="yes"
      >
      <article>
        <xsl:apply-templates select="$tei">
          <!-- Titles start with <h1> -->
          <xsl:with-param name="level" select="1"/>
        </xsl:apply-templates>
      </article>
    </xsl:document>
    <!-- Json metadata ? -->
  </xsl:template>
  
  
</xsl:transform>
