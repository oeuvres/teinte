<?xml version="1.0" encoding="UTF-8"?>
<!--

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2016 Frederic.Glorieux@fictif.org & LABEX OBVIL

Extract teiHeader metadatas for a csv line
-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <!-- TEI common, metadatas -->
  <xsl:import href="common.xsl"/>
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" method="text" indent="yes"/>
  <!-- Permet l'indentation des éléments de structure -->
  <xsl:strip-space elements="tei:TEI tei:TEI.2 tei:body tei:castList  tei:div tei:div1 tei:div2  tei:docDate tei:docImprint tei:docTitle tei:fileDesc tei:front tei:group tei:index tei:listWit tei:publicationStmp tei:publicationStmt tei:sourceDesc tei:SourceDesc tei:sources tei:text tei:teiHeader tei:text tei:titleStmt"/>
  <xsl:preserve-space elements="tei:l tei:p tei:s "/>
  <xsl:variable name="lf">
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  <xsl:variable name="tab">
    <xsl:text>&#9;</xsl:text>
  </xsl:variable>
  <xsl:variable name="apos">'</xsl:variable>
  <xsl:variable name="quot">"</xsl:variable>

  <xsl:template match="tei:TEI">
    <xsl:value-of select="$docid"/>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="$byline"/>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="$docdate"/>
    <xsl:value-of select="$tab"/>
    <xsl:value-of select="$doctitle"/>
    <xsl:value-of select="$lf"/>
  </xsl:template>
</xsl:transform>
