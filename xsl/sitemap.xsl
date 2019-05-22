<?xml version="1.0" encoding="UTF-8"?>
<!--

© 2017 Frederic.Glorieux@fictif.org et Consortium CAHIER

-->
<xsl:transform exclude-result-prefixes="site" extension-element-prefixes="exslt" version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:exslt="http://exslt.org/common" xmlns:site="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="common.xsl"/>
  <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="yes"/>
  <xsl:template match="/*">
    <!--  browser will not like doctype -->
    <xsl:if test="$xslbase != $theme">
      <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>
      <xsl:value-of select="$lf"/>
    </xsl:if>
    <html>
      <xsl:call-template name="att-lang"/>
      <head>
        <meta content="text/html; charset=UTF-8" http-equiv="Content-type"/>
        <link charset="utf-8" href="{$theme}tei2html.css" rel="stylesheet" type="text/css"/>
      </head>
      <body>
        
        <main id="center">
          <article id="article">
            <h1><a href="https://github.com/dramacode/moliere">Molière</a> en XML/TEI sur Github</h1>
            <table class="sortable">
              <tr><th>Fichier</th></tr>
              <xsl:apply-templates select="site:url"/>
            </table>
          </article>
        </main>
        <script charset="utf-8" src="{$theme}Sortable.js" type="text/javascript">//</script>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="site:url">
    <tr>
      <td>
        <a href="{site:loc}">
          <xsl:value-of select="site:loc"/>
        </a>
      </td>
    </tr>
  </xsl:template>
</xsl:transform>
