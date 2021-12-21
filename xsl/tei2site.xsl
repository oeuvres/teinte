<?xml version="1.0" encoding="UTF-8"?>
<!--

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2010 Frederic.Glorieux@fictif.org et École nationale des chartes
© 2012 Frederic.Glorieux@fictif.org 
© 2013 Frederic.Glorieux@fictif.org et LABEX OBVIL


Split a single TEI book in different html chapters

-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <xsl:import href="tei2split.xsl"/>  
  <xsl:import href="html/flow.xsl"/>
  <xsl:import href="html/notes.xsl"/>
  <xsl:import href="html/toc.xsl"/>
  <xsl:output indent="yes" encoding="UTF-8" method="xml" />
  <!-- Still needed for creation of filenames -->
  <xsl:variable name="split" select="true()"/>
  <!-- Where to find static assets like CSS or JS -->
  <xsl:param name="theme">https://oeuvres.github.io/teinte/theme/</xsl:param>
  <!-- extension for generated files and links -->
  <xsl:param name="_ext">.html</xsl:param>

  <!-- Content of document to write -->
  <xsl:template name="cont">
    <xsl:param name="tei"/>
    <xsl:param name="title"/>
    <xsl:variable name="classes">
      <!-- add ancestor rendering -->
      <xsl:for-each select="ancestor::*[@rend]">
        <xsl:text> </xsl:text>
        <xsl:value-of select="normalize-space(@rend)"/>
      </xsl:for-each>
      <xsl:text> tei</xsl:text>
    </xsl:variable>
    
    <html  
      xmlns:dc="http://purl.org/dc/terms/"
      xmlns:dbo="http://dbpedia.org/ontology/"
      xmlns:epub="http://www.idpf.org/2007/ops"
      >
      <xsl:call-template name="att-lang"/>
      <head>
        <meta http-equiv="Content-type" content="text/html; charset=UTF-8" />
        <xsl:call-template name="head">
          <xsl:with-param name="title" select="$title"/>
        </xsl:call-template>
        <link rel="stylesheet" type="text/css" href="{$theme}teinte.css"/>
        <link rel="stylesheet" type="text/css" href="{$theme}layout.css"/>
        <script type="text/javascript" src="{$theme}Tree.js">//</script>
      </head>
      <body class="article {$corpusid}">
        <header>
          <xsl:call-template name="prevnext"/>
          <xsl:call-template name="argument"/>
        </header>
        <article>
          <xsl:attribute name="class">
            
            
          </xsl:attribute>
          <xsl:apply-templates select="$tei">
            <!-- Titles start with <h1> -->
            <xsl:with-param name="level" select="1"/>
          </xsl:apply-templates>
        </article>
      </body>
    </html>
    
    
  </xsl:template>

  <!-- Short summary -->
  <xsl:template name="argument">
    <nav class="argument">
      <xsl:for-each select="tei:div | tei:group | tei:body/tei:div">
        <xsl:if test="position() != 1"> — </xsl:if>
        <xsl:call-template name="a"/>
      </xsl:for-each>
    </nav>
    
  </xsl:template>
  
  <!--  -->
  <xsl:template name="breadcrumb">
    <xsl:param name="base" select="$base"/>
    <nav class="breadcrumb">
      <xsl:for-each select="ancestor::*">
        <xsl:choose>
          <!-- stop before title doc, better formatted upper -->
          <xsl:when test="self::tei:TEI"/>
          <xsl:when test="self::tei:group[parent::tei:text]"/>
          <xsl:when test="self::tei:body"/>
          <xsl:when test="self::tei:front"/>
          <xsl:when test="self::tei:back"/>
          <xsl:otherwise>
            <xsl:call-template name="a-label">
              <xsl:with-param name="base" select="$base"/>
            </xsl:call-template>
            <xsl:text> » </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:call-template name="a-label">
        <xsl:with-param name="base" select="$base"/>
      </xsl:call-template>
    </nav>
  </xsl:template>
  
  <!-- a prev/next navigation -->
  <xsl:template name="prevnext">
    <xsl:param name="valign">middle</xsl:param>
    <nav class="prevnext">
      <table align="center" width="100%" class="prevnext">
        <tr>
          <td  align="left" class="prev" width="50%">
            <!-- like to the element just before, maybe a very far cousin
            for-each seems more efficient than apply-templates
            -->
            <xsl:variable name="prev">
              <!-- SLOW -->
              <xsl:for-each select="preceding::*[key('split', generate-id())][not(self::tei:titlePage)][1]">
                <xsl:call-template name="a-label">
                  <xsl:with-param name="rel">prev</xsl:with-param>
                </xsl:call-template>
              </xsl:for-each>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$prev != ''">
                <xsl:copy-of select="$prev"/>
              </xsl:when>
              <xsl:otherwise>
                <!-- if no before, go back to welcome page ? -->
                <!--
                <xsl:for-each select="ancestor::tei:text[1]">
                  <xsl:call-template name="a-label">
                    <xsl:with-param name="rel">parent</xsl:with-param>
                    <xsl:with-param name="prefix"><abbr>←</abbr><xsl:text> </xsl:text></xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
                -->
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <!--
          <td  align="center" valign="{$valign}" class="up">
            <xsl:for-each select="ancestor-or-self::tei:* ">
              <xsl:choose>
                <xsl:when test="tei:head|tei:titlePage">
                  <div>
                    <xsl:call-template name="a-label">
                      <xsl:with-param name="rel">up</xsl:with-param>
                    </xsl:call-template>
                  </div>
                </xsl:when>
                <xsl:when test="count(.|/*/tei:text) = 1">
                  <div>
                    <xsl:call-template name="a-label">
                      <xsl:with-param name="rel">up</xsl:with-param>
                    </xsl:call-template>
                  </div>
                </xsl:when>
              </xsl:choose>
            </xsl:for-each>
          </td>
          -->
          <td  align="right" class="next" width="50%">
            <!-- first child or descendant ? -->
            <xsl:variable name="child">
              <xsl:for-each select="descendant::*[not(self::tei:titlePage)][key('split', generate-id())][1]">
                <xsl:call-template name="a-label">
                  <xsl:with-param name="rel">next</xsl:with-param>
                </xsl:call-template>
              </xsl:for-each>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$child != ''">
                <xsl:copy-of select="$child"/>
              </xsl:when>
              <xsl:otherwise>
                <!-- Next splitable node, be careful to body without head -->
                <xsl:variable name="next">
                  <xsl:for-each select="following::*[not(self::tei:titlePage)][key('split', generate-id())][1]">
                    <xsl:call-template name="a-label">
                      <xsl:with-param name="rel">next</xsl:with-param>
                    </xsl:call-template>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="$next != ''">
                    <xsl:copy-of select="$next"/>
                  </xsl:when>
                  <!-- seems end, go back to welcome page ? -->
                  <!--
                  <xsl:otherwise>
                    <xsl:for-each select="ancestor::tei:text[1]">
                      <xsl:call-template name="a-label">
                        <xsl:with-param name="rel">parent</xsl:with-param>
                        <xsl:with-param name="suffix"><xsl:text> </xsl:text><abbr>→</abbr></xsl:with-param>
                      </xsl:call-template>
                    </xsl:for-each>
                  </xsl:otherwise>
                  -->
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </table>
    </nav>
  </xsl:template>
  <!-- Plus efficace qu'une xpath lourde.
preceding::*[ descendant-or-self::*[key('split', generate-id())] ][1]
  -->
  <xsl:template match="*" mode="prev" name="prev-a">
    <xsl:param name="secure"/>
    <xsl:choose>
      <xsl:when test="not($secure)">
        <xsl:apply-templates select="preceding::*[1]" mode="prev">
          <xsl:with-param name="secure" select="true()"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="descendant-or-self::*[key('split', generate-id())]">
        <xsl:call-template name="a-label"/>
      </xsl:when>
      <xsl:when test="not(preceding::*[1])"/>
      <xsl:otherwise>
        <xsl:apply-templates select="preceding::*[1]" mode="prev">
          <xsl:with-param name="secure" select="true()"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- link to a section, shortening too big title -->
  <xsl:template name="a-label">
    <!-- rel attribute -->
    <xsl:param name="rel"/>
    <!-- class attribute -->
    <xsl:param name="class"/>
    <!-- base href prefix foir link -->
    <xsl:param name="base"/>
    <!-- html to put before in the link -->
    <xsl:param name="prefix"/>
    <!-- html to put after in the link -->
    <xsl:param name="suffix"/>
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="href"/>
      </xsl:attribute>
      <xsl:if test="$rel">
        <xsl:attribute name="rel">
          <xsl:value-of select="$rel"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:variable name="classnorm" select="normalize-space(concat($class, ' ', $rel))"/>
      <xsl:if test="$classnorm != ''">
        <xsl:attribute name="class">
          <xsl:value-of select="$classnorm"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:variable name="t">
        <xsl:choose>
          <xsl:when test="concat($prefix , $suffix)!=''">
            <span>
              <xsl:apply-templates select="." mode="title"/>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="." mode="title"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="title" select="normalize-space($t)"/>
      <span>
        <xsl:choose>
          <xsl:when test="$title=''">
            <xsl:copy-of select="$prefix"/>
            <xsl:call-template name="message">
              <xsl:with-param name="id">notitle</xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <!-- Titre trop complet ?
        <xsl:when test="self::tei:text">
          <xsl:copy-of select="$prefix"/>
          <xsl:copy-of select="$t"/>
        </xsl:when>
        -->
          <xsl:when test="string-length($title) &gt; 50">
            <xsl:attribute name="title">
              <xsl:value-of select="$title"/>
            </xsl:attribute>
            <xsl:copy-of select="$prefix"/>
            <xsl:value-of select="substring($title, 1, 30)"/>
            <xsl:value-of select="substring-before(concat(substring($title, 31), ' '), ' ')"/>
            <!-- Quelque chose a été coupé -->
            <xsl:if test="substring-after(substring($title, 30), ' ') != ''">…</xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$prefix"/>
            <xsl:copy-of select="$t"/>
          </xsl:otherwise>
        </xsl:choose>
      </span>
      <xsl:copy-of select="$suffix"/>
    </a>
  </xsl:template>
  
  <xsl:template name="head">
    <xsl:param name="title"/>
    <!-- title of book ? -->
    <xsl:variable name="titlebranch">
      <xsl:call-template name="titlebranch"/>
    </xsl:variable>
    <title>
      <xsl:choose>
        <xsl:when test="$title!=''">
          <xsl:value-of select="normalize-space($title)"/>
        </xsl:when>
        <xsl:when test="normalize-space($titlebranch)!=''">
          <xsl:value-of select="normalize-space($titlebranch)"/>
        </xsl:when>
        <xsl:when test="normalize-space($docid)!=''">
          <xsl:value-of select="normalize-space($docid)"/>
        </xsl:when>
        <!-- TODO localize -->
        <xsl:otherwise>
          <xsl:call-template name="message">
            <xsl:with-param name="id">notitle</xsl:with-param>
          </xsl:call-template>          
        </xsl:otherwise>
      </xsl:choose>
    </title>
    <!-- Short title for item -->
    <!-- mode meta do not work anymore
    <xsl:variable name="label">
      <xsl:if test="ancestor::tei:text[@n]">
        <xsl:value-of select="ancestor::tei:text/@n"/>
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="." mode="label"/>
    </xsl:variable>
    <meta name="label" content="{normalize-space($label)}"/>
    -->
    <!-- Chapter metas when relevant, like author, date, maybe we should go uper if nothing found -->
    <xsl:apply-templates select="." mode="meta"/>
    <!-- Maydo
    <xsl:if test="$seriestitle != ''">
      <link rel="dc:isPartOf" href="." title="{normalize-space($seriestitle)}"/>
    </xsl:if>
    -->
    <!-- Consumer may use this ancestor string to build a breadcrumb -->
    <xsl:for-each select="ancestor::*">
      <xsl:choose>
        <xsl:when test="self::tei:body"/>
        <xsl:when test="self::tei:front"/>
        <xsl:when test="self::tei:back"/>
        <xsl:when test="self::tei:text"/>
        <xsl:when test="self::tei:TEI"/>
        <xsl:otherwise>
          <link rel="dc:isPartOf">
            <xsl:attribute name="href">
              <xsl:call-template name="href"/>
            </xsl:attribute>
            <xsl:attribute name="label">
              <xsl:variable name="label">
                <xsl:apply-templates select="." mode="label"/>
              </xsl:variable>
              <xsl:value-of select="normalize-space($label)"/>
            </xsl:attribute>
          </link>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  
  
  <!-- meta mode maybe used at item level  -->
  <xsl:template match="node()" mode="meta"/>
  <!-- Un exemple de surcharge de ce mode pour ajouter des métas spécifiques à un corpus -->
  <xsl:template match="*[tei:num or tei:head/tei:num]" mode="meta">
    <meta name="num" content="{normalize-space(tei:num|tei:head/tei:num)}" />
  </xsl:template>
  
  
</xsl:transform>
