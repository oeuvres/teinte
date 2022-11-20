<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns="http://www.w3.org/1999/xhtml" 
  xmlns:html="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="html"
  >
  <xsl:output indent="yes" encoding="UTF-8" method="xml" omit-xml-declaration="yes"/>
  <xsl:variable name="lf" select="'&#10;'"/>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="
      html:div[@class='tableItem']
    | html:span[@class='mw-cite-backlink']
    | html:div[@id='mw-navigation']
    ">
    <!-- strip -->
  </xsl:template>
  <xsl:template match="
    html:ol[@class='references']
    ">
    <xsl:apply-templates/>
    <!-- cross -->
  </xsl:template>
  <!-- 
  
  <li id="cite_note-p132-17"> => <div id="sdfootnote17">
  
  -->
  <xsl:template match="html:li[starts-with(@id, 'cite_note')]">
    <xsl:variable name="num">
      <xsl:variable name="tmp" select="substring-after(@id, '-')"/>
      <xsl:choose>
        <xsl:when test="contains($tmp, '-')">
          <xsl:value-of select="substring-after($tmp, '-')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$tmp"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div id="sdfootnote{$num}">
      <!--
      <p>
        <a name="sdfootnote{$num}sym" href="#sdfootnote{$num}anc" class="sdfootnotesym-western">
          <xsl:value-of select="$num"/>
        </a>
        <xsl:apply-templates select="node()[not(self::html:p)]"/>
      </p>
      <xsl:apply-templates select="html:p"/>
      -->
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="html:span[@class='reference-text']">
    <xsl:choose>
      <xsl:when test="ancestor::html:p">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:text>   </xsl:text>
          <xsl:apply-templates/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
    <!--
    <xsl:apply-templates/>
    -->
  </xsl:template>
  <!--
    <a href="#cite_note-1"> =>
    <a class="sdfootnoteanc" name="sdfootnote1anc" href="#sdfootnote1sym">
    -->
  <xsl:template match="html:a[starts-with(@href, '#cite_note')]">
    <xsl:variable name="num">
      <xsl:variable name="tmp" select="substring-after(@href, '-')"/>
      <xsl:choose>
        <xsl:when test="contains($tmp, '-')">
          <xsl:value-of select="substring-after($tmp, '-')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$tmp"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>   
    <a name="sdfootnote{$num}anc" class="sdfootnoteanc" href="#sdfootnote{$num}sym">
      <xsl:apply-templates/>
    </a>
  </xsl:template>
</xsl:transform>