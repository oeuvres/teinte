<?xml version="1.0" encoding="UTF-8"?>
<!--

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2016 Frederic.Glorieux@fictif.org et LABEX OBVIL


Théâtre, répliques par genre
-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" method="text" indent="yes"/>
  <xsl:param name="genre">male</xsl:param>
  <xsl:include href="tei2naked.xsl"/>
  <xsl:key name="role" match="tei:role" use="@xml:id"/>
  <xsl:template match="/">
    <xsl:apply-templates mode="naked"/>
  </xsl:template>
  <xsl:template match="tei:sp" mode="naked">
    <xsl:variable name="role" select="key('role', @who)"/>
    <xsl:if test="contains( concat(' ', $role/@rend, ' '), concat(' ', $genre, ' ') )">
      <xsl:apply-templates mode="naked"/>
    </xsl:if>
  </xsl:template>
</xsl:transform>
