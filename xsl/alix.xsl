<?xml version="1.0" encoding="UTF-8"?>
<!--
To index TEI files in lucene

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2019 Frederic.Glorieux@fictif.org & Opteos & 



-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:alix="http://alix.casa"
  exclude-result-prefixes="tei"
>
  <xsl:import href="flow.xsl"/>
  <xsl:import href="notes.xsl"/>
  <xsl:import href="toc.xsl"/>
  <!-- Name of file, provided by caller -->
  <xsl:param name="filename"/>
  <xsl:output indent="yes" encoding="UTF-8" method="xml" />
  <xsl:template match="/*">
    <alix:document>
      <alix:field name="title" type="facet">
        <xsl:value-of select="$doctitle"/>
      </alix:field>
      <alix:field name="date" type="facet">
        <xsl:value-of select="$docdate"/>
      </alix:field>
      <alix:field name="article" type="xml">
        <article>
          <xsl:apply-templates select="tei:text"/>
        </article>
      </alix:field>
      <alix:field name="toc" type="xml">
        <xsl:call-template name="toc"/>
      </alix:field>
    </alix:document>
  </xsl:template>
</xsl:transform>
