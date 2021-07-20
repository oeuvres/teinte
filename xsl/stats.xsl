<?xml version="1.0" encoding="UTF-8"?>
<!--

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2013 Frederic.Glorieux@fictif.org et LABEX OBVIL

Extraction du texte d'un corpus TEI pour recherche plein texte ou traitements linguistiques
(ex : suppressions des notes, résolution de l'apparat)
Doit pouvoir fonctionner en import.


-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
  >
  <!-- Importer des dates -->
  <xsl:import href="tei2iramuteq.xsl"/>
  <xsl:output method="text"/>
  
  <xsl:template match="/">
    <xsl:text>text=</xsl:text>
    <xsl:call-template name="text"/>
    <xsl:text>&#10;quotes=</xsl:text>
    <xsl:call-template name="quotes"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:call-template name="p"/>
  </xsl:template>
  
  <xsl:template name="p">
    <xsl:for-each select="/*/tei:text//tei:p">
      <xsl:sort order="descending" data-type="number" select="string-length(normalize-space(.))"/>
      <xsl:if test="position() = 1">
        <xsl:variable name="text" select="normalize-space(.)"/>
        <xsl:text>Biggest &lt;p> </xsl:text>
        <xsl:variable name="chars" select="string-length($text)"/>
        <xsl:text> chars=</xsl:text>
        <xsl:value-of select="$chars"/>
        <xsl:text> lines=</xsl:text>
        <xsl:value-of select="round($chars div 60)"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:value-of select="substring($text, 1, 100)"/>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template name="quotes">
    <xsl:variable name="str">
      <xsl:apply-templates select="/*/tei:text//tei:quote" mode="count"/>
    </xsl:variable>
    <xsl:value-of select="string-length(normalize-space($str))"/>
  </xsl:template>

  <xsl:template name="text">
    <xsl:variable name="str">
      <xsl:apply-templates select="/*/tei:text" mode="count"/>
    </xsl:variable>
    <xsl:value-of select="string-length(normalize-space($str))"/>
  </xsl:template>
  

  <xsl:template match="tei:note" mode="count"/>
  
  <xsl:template name="roles">
    <xsl:for-each select="//tei:role[@xml:id]">
      <xsl:variable name="id" select="@xml:id"/>
      <xsl:variable name="sp" select="key('who', $id)"/>
      <xsl:if test="count($sp) &gt; $minsp">
        <xsl:value-of select="$docid"/>
        <xsl:value-of select="$tab"/>
        <xsl:value-of select="@xml:id"/>
        <xsl:value-of select="$tab"/>
        <xsl:call-template name="gender"/>
        <xsl:value-of select="$tab"/>
        <xsl:call-template name="age"/>
        <xsl:value-of select="$tab"/>
        <xsl:call-template name="status"/>
        <xsl:value-of select="$tab"/>
        <xsl:call-template name="function"/>
        <xsl:value-of select="$tab"/>
        <xsl:variable name="txt">
          <xsl:for-each select="$sp">
            <xsl:value-of select="$lf"/>
            <xsl:apply-templates mode="iramuteq"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-length(normalize-space($txt))"/>
        <xsl:value-of select="$lf"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="scenes">
    <xsl:for-each select="//*[@type = 'scene']">
      <xsl:value-of select="$docid"/>
      <xsl:value-of select="$tab"/>
      <xsl:value-of select="@xml:id"/>
      <xsl:value-of select="$tab"/>
      <xsl:variable name="txt">
        <xsl:apply-templates mode="iramuteq"/>
      </xsl:variable>
      <xsl:value-of select="string-length(normalize-space($txt))"/>
      <xsl:value-of select="$lf"/>
    </xsl:for-each>
  </xsl:template>
  </xsl:transform>