<?xml version="1.0" encoding="UTF-8"?>
<!--

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2016 Frederic.Glorieux@fictif.org et LABEX OBVIL

XML TEI allégé, par exemple pièce de théâtre sans didascalies, ou critique sans citations
-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <!-- TEI common, metadatas -->
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" method="xml" indent="yes"/>

  <xsl:template match="node()|@*" mode="txm">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="txm"/>
    </xsl:copy>
  </xsl:template>
  <!-- éléments à traverser -->
  <xsl:template match="/">
    <xsl:apply-templates mode="txm"/>
  </xsl:template>
  <!-- éléments à arrêter -->
  <xsl:template match="
      tei:back
    | tei:bibl
    | tei:byline
    | tei:cit
    | tei:castList
    | tei:castItem
    | tei:dateline
    | tei:docAuthor 
    | tei:docDate 
    | tei:docImprint
    | tei:event
    | tei:figure
    | tei:front
    | tei:label
    | tei:listBibl
    | tei:note
    | tei:person
    | tei:place
    | tei:ref[not(node())] 
    | tei:salute 
    | tei:signed
    | tei:speaker
    | tei:stage
    | tei:titlePart 
    | tei:trailer
    | tei:titlePage
    | tei:titlePart
    
    " mode="txm"/>
  <!--
    | tei:quote
    | tei:head
    -->

  <!-- Rétablissement de césure -->
  <xsl:template match="tei:caes" mode="txm">
    <xsl:choose>
      <xsl:when test="@whole">
        <xsl:value-of select="@whole"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Mot ajouté -->
  <xsl:template match="tei:supplied" mode="txm">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates mode="txm"/>
    <xsl:text>]</xsl:text>
  </xsl:template>


  <!-- alternative critique -->
  <xsl:template match="tei:app" mode="txm">
    <xsl:apply-templates select="tei:lem" mode="txm"/>
  </xsl:template>
  <xsl:template match="tei:choice" mode="txm">
    <xsl:choose>
      <xsl:when test="tei:corr">
        <xsl:apply-templates select="tei:corr" mode="txm"/>
      </xsl:when>
      <xsl:when test="tei:expan">
        <xsl:apply-templates select="tei:expan" mode="txm"/>
      </xsl:when>
      <xsl:when test="tei:reg">
        <xsl:apply-templates select="tei:reg" mode="txm"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[1]" mode="txm"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:name[@type='authority'] | tei:persName[@type='authority']" mode="txm">
    <authority>
      <xsl:apply-templates mode="txm"/>
    </authority>
  </xsl:template>

  <xsl:template match="tei:quote[tei:lg] | tei:p[tei:quote][normalize-space(text()) = ''] | tei:quote[tei:l]"/>

</xsl:transform>
