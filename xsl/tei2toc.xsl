<?xml version="1.0" encoding="UTF-8"?>
<!--
  
<h1>TEI » HTML (tei2html.xsl)</h1>

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2013 Frederic.Glorieux@fictif.org et LABEX OBVIL
© 2012 Frederic.Glorieux@fictif.org 
© 2010 Frederic.Glorieux@fictif.org et École nationale des chartes
© 2007 Frederic.Glorieux@fictif.org
© 2005 ajlsm.com et Cybertheses

<p>
Cette transformation XSLT 1.0 (compatible navigateurs, PHP, Python, Java…) 
transforme du TEI en HTML5.
Les auteurs ne s'engagent pas à supporter les 600 éléments TEI.
Cette feuille prend en charge <a href="http://www.tei-c.org/Guidelines/Customization/Lite/">TEI lite</a>
et les éléments TEI documentés dans les <a href="./../schema/">schémas</a> de cette installation.
</p>
<p>
Alternative : les transformations de Sebastian Rahtz <a href="http://www.tei-c.org/Tools/Stylesheets/">tei-c.org/Tools/Stylesheets/</a>
sont officiellement ditribuées par le consortium TEI, cependant ce développement est en XSLT 2.0 (java requis).
</p>
-->
<xsl:transform version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns="http://www.w3.org/1999/xhtml" 
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:eg="http://www.tei-c.org/ns/Examples"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:html="http://www.w3.org/1999/xhtml" 
  xmlns:epub="http://www.idpf.org/2007/ops" 
  exclude-result-prefixes="eg html rng tei epub" 
  xmlns:exslt="http://exslt.org/common" 
  extension-element-prefixes="exslt"
  >
  <xsl:import href="toc.xsl"/>
  <xsl:param name="root"/>
  <!-- No XML declaration for html fragments -->
  <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="yes"/>
  <!-- Racine -->
  <xsl:template match="/*">
    <xsl:choose>
      <xsl:when test="$root=$front">
        <xsl:call-template name="toc-front"/>
      </xsl:when>      
      <xsl:when test="$root=$back">
        <xsl:call-template name="toc-back"/>
      </xsl:when>
      <!-- HTML fragment -->
      <xsl:when test="$root=$ul or $root=$ol">
        <xsl:call-template name="toc"/>
      </xsl:when>
      <!-- HTML fragment -->
      <xsl:when test="$root=$nav">
        <nav class="toc">
          <xsl:call-template name="att-lang"/>
          <xsl:call-template name="toc-header"/>
          <xsl:call-template name="toc"/>
        </nav>
      </xsl:when>
      <!-- Complete doc -->
      <xsl:otherwise>
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>
        <xsl:value-of select="$lf"/>
        <html>
          <xsl:call-template name="att-lang"/>
          <head>
            <meta http-equiv="Content-type" content="text/html; charset=UTF-8"/>
            <meta name="modified" content="{$date}"/>
            <!-- déclaration classes css locale (permettre la surcharge si généralisation) -->
            <!-- à travailler
            <xsl:apply-templates select="/*/tei:teiHeader/tei:encodingDesc/tei:tagsDecl"/>
            -->
            <link rel="stylesheet" type="text/css" href="{$theme}tei2html.css"/>
            <script type="text/javascript" src="{$theme}Tree.js">//</script>
          </head>
          <body class="{$corpusid}">
            <nav>
              <xsl:call-template name="toc-header"/>
              <xsl:call-template name="toc"/>
            </nav>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
