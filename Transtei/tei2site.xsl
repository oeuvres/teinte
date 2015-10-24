<?xml version="1.0" encoding="UTF-8"?>
<!--
<h1>TEI » document (tei_split.xsl)</h1>

© 2012, <a href="http://www.algone.net/">Algone</a>, <a href="http://www.cecill.info/licences/Licence_CeCILL-C_V1-fr.html">licence CeCILL-C</a> (LGPL compatible droit français)

<ul>
  <li>[VJ] <a onclick="this.href='mailto'+'\x3A'+'jolivet'+'\x40'+'algone.net?subject=[tei_split.xsl] '">Vincent Jolivet</a></li>
  <li>[FG] <a onclick="this.href='mailto'+'\x3A'+'glorieux'+'\x40'+'algone.net?subject=[tei_split.xsl] '">Frédéric Glorieux</a></li>
</ul>


Teipot, factorisation d'outils utiles pour la division d'un fichier XML
en plusieurs fichiers HTML

Attention, cette transformation n'a d'intérêt qu'importée par un pilote
qui importera aussi une transformation vers HTML



-->
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <xsl:import href="tei2html.xsl"/>
  <xsl:output indent="yes" encoding="UTF-8" method="xml"/>
  <xsl:key name="split" match="
tei:*[self::tei:div or self::tei:div1 or self::tei:div2][@type][
  contains(@type, 'article') 
    or contains(@type, 'chapter') 
    or contains(@subtype, 'split') 
    or contains(@type, 'act')  
    or contains(@type, 'poem')
    or contains(@type, 'letter')
] 
| tei:group/tei:text 
| tei:TEI/tei:text/tei:*/tei:*[self::tei:div or self::tei:div1 or self::tei:group]" use="generate-id(.)"/>
  <!-- dossier de projection des fichiers générés, paramétrable de l'extérieur -->
  <xsl:param name="dstdir">html/</xsl:param>
  <!-- Dossier où retrouver des ressources de thème -->
  <xsl:param name="style">style/</xsl:param>
  <!-- paramètre permettant de tester d'où fonctionne un template -->
  <xsl:param name="this">tei2site.xsl</xsl:param>
  <!-- Racine -->
  <xsl:template match="/">
    <!-- Generate a global navigation -->
    <xsl:call-template name="document">
      <xsl:with-param name="id">
        <xsl:if test="$docid != ''">
          <xsl:value-of select="$docid"/>
          <xsl:text>_</xsl:text>
        </xsl:if>
        <xsl:text>nav</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="title">
        <xsl:value-of select="normalize-space($doctitle)"/>
        <xsl:text>, </xsl:text>
        <xsl:call-template name="message">
          <xsl:with-param name="id">navigation</xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="body">
        <nav class="toc">
          <header>
            <a>
              <xsl:attribute name="href">
                <xsl:for-each select="/*/tei:text">
                  <xsl:call-template name="href"/>
                </xsl:for-each>
              </xsl:attribute>
              <xsl:copy-of select="$byline"/>
              <xsl:copy-of select="$doctitle"/>
              <xsl:if test="$docdate">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="$docdate"/>
                <xsl:text>)</xsl:text>
              </xsl:if>
            </a>
          </header>
          <xsl:call-template name="toc"/>
        </nav>
      </xsl:with-param>
    </xsl:call-template>
    <!-- Traverser le document pour voir les documents à créer -->
    <xsl:apply-templates select="*" mode="site"/>
    <date>
      <xsl:value-of select="$date"/>
    </date>
    <!-- le corpus en une seule page ne peut pas être généré ici car le contexte de résolution des liens est différent -->
  </xsl:template>
  
  <!-- Par défaut, traverser -->
  <xsl:template match="*" mode="site">
    <xsl:apply-templates mode="site"/>
  </xsl:template>
  <!-- Arrêter le texte -->
  <xsl:template match="text()" mode="site"/>
  <!-- Licence -->
  <xsl:template match="tei:publicationStmt" mode="site">
    <xsl:call-template name="document">
      <xsl:with-param name="id">
        <xsl:if test="$docid != ''">
          <xsl:value-of select="$docid"/>
          <xsl:text>_</xsl:text>
        </xsl:if>
        <xsl:text>licence</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <!-- métadonnées, do something ? -->
  <xsl:template match="tei:teiHeader" mode="site"/>
  <!-- Welcome page, title page and abstract -->
  <xsl:template match="tei:TEI/tei:text" mode="site">
    <xsl:call-template name="document">
      <xsl:with-param name="title" select="normalize-space($doctitle)"/>
      <xsl:with-param name="body">
        <!-- bug here
        <xsl:call-template name="prevnext"/>
        -->
        <article>
          <xsl:call-template name="att-lang"/>
          <xsl:attribute name="class">
            <xsl:value-of select="local-name()"/>
            <xsl:for-each select="ancestor-or-self::*[@rend]">
              <xsl:text> </xsl:text>
              <xsl:value-of select="normalize-space(@rend)"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="tei:front/tei:titlePage">
              <xsl:apply-templates select="tei:front/tei:titlePage"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="/*/tei:teiHeader"/>
            </xsl:otherwise>
            <!--
            <xsl:when test="tei:front/tei:head">
              <xsl:apply-templates select="tei:front/tei:head"/>
            </xsl:when>
            <xsl:when test="tei:body/tei:head">
              <xsl:apply-templates select="tei:body/tei:head"/>
            </xsl:when>
            <xsl:otherwise>
              <h1>
                <xsl:copy-of select="$doctitle"/>
              </h1>
            </xsl:otherwise>
            -->
          </xsl:choose>
          <xsl:apply-templates select="tei:front/tei:argument[1]"/>
          <xsl:choose>
            <xsl:when test="tei:body/tei:div | tei:body/tei:div1 | tei:group">
              <!-- Local toc  -->
              <nav class="argument">
                <xsl:if test="tei:front/tei:div | tei:front/tei:div1">
                  <div>
                    <xsl:if test="tei:front/tei:head">
                      <strong>
                        <xsl:apply-templates select="tei:front" mode="a"/>
                      </strong>
                      <xsl:text> — </xsl:text>
                    </xsl:if>
                    <xsl:for-each select="tei:front/tei:div | tei:front/tei:div1">
                      <xsl:if test="position() != 1"> — </xsl:if>
                      <xsl:call-template name="a"/>
                    </xsl:for-each>
                  </div>
                </xsl:if>
                <div>
                  <xsl:for-each select="tei:body/tei:div | tei:body/tei:div1 | tei:group/*">
                    <xsl:if test="position() != 1"> — </xsl:if>
                    <xsl:call-template name="a"/>
                  </xsl:for-each>
                </div>
                <xsl:if test="tei:back/tei:div | tei:back/tei:div1">
                  <div>
                    <xsl:if test="tei:back/tei:head">
                      <strong>
                        <xsl:apply-templates select="tei:back" mode="a"/>
                      </strong>
                      <xsl:text> — </xsl:text>
                    </xsl:if>
                    <xsl:for-each select="tei:back/tei:div | tei:back/tei:div">
                      <xsl:if test="position() != 1"> — </xsl:if>
                      <xsl:call-template name="a"/>
                    </xsl:for-each>
                  </div>
                </xsl:if>
              </nav>
              <!-- Notes on front page -->
              <xsl:choose>
                <xsl:when test="tei:front/tei:titlePage">
                  <xsl:for-each select="tei:front/tei:titlePage">
                    <xsl:call-template name="footnotes"/>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each select="/*/tei:teiHeader">
                    <xsl:call-template name="footnotes"/>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:for-each select="tei:front/tei:argument[1]">
                <xsl:call-template name="footnotes"/>
              </xsl:for-each>
            </xsl:when>
            <!-- Simple article with no parts -->
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </article>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates select="*" mode="site"/>
  </xsl:template>
  <!-- Crédits -->
  <xsl:template match="tei:titleStmt" mode="site">
    <xsl:call-template name="document">
      <xsl:with-param name="id">
        <xsl:if test="$docid != ''">
          <xsl:value-of select="$docid"/>
          <xsl:text>_</xsl:text>
        </xsl:if>
        <xsl:text>credits</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template mode="site" match="
    tei:group/tei:text | tei:group |
    tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7 
    "
   >
    <xsl:variable name="body">
      <xsl:choose>
        <!-- avec des enfants à spliter, entête + nav -->
        <xsl:when test="descendant::*[key('split', generate-id())]">
          <!-- take content before sections -->
          <xsl:variable name="before" select="generate-id(tei:group|tei:div|tei:div1|tei:div2|tei:div3|tei:div4|tei:div5|tei:div6)"/>
          <xsl:variable name="cont" select="tei:*[following-sibling::*[generate-id(.)=$before]]"/>
          <article>
            <xsl:call-template name="att-lang"/>
            <xsl:call-template name="atts">
              <xsl:with-param name="class">
                <xsl:for-each select="ancestor::*[@rend]">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="normalize-space(@rend)"/>
                </xsl:for-each>
              </xsl:with-param>
            </xsl:call-template>
            <!-- if a page break just before, catch it -->
            <xsl:if test="preceding-sibling::*[1][self::tei:pb]">
              <xsl:apply-templates select="preceding-sibling::*[1]"/>
            </xsl:if>
            <!-- sortir les enfants qui ne sont pas des feuilles de split -->
            <xsl:apply-templates select="$cont">
              <xsl:with-param name="level" select="1"/>
            </xsl:apply-templates>
            <!-- les notes, passer les noeud sur lesquels générer -->
            <xsl:call-template name="footnotes">
              <xsl:with-param name="cont" select="$cont"/>
              <xsl:with-param name="pb"/>
            </xsl:call-template>
          </article>
          <!-- Local toc  -->
          <nav class="argument">
            <xsl:for-each select="tei:div | tei:group | tei:body/tei:div">
              <xsl:if test="position() != 1"> — </xsl:if>
              <xsl:call-template name="a"/>
            </xsl:for-each>
          </nav>
        </xsl:when>
        <!-- split leave, no nav -->
        <xsl:otherwise>
          <xsl:if test="self::*[not(key('split', generate-id()))]">
          <xsl:message>tei2site.xsl, split problem : <xsl:call-template name="id"/>, <xsl:call-template name="title"></xsl:call-template></xsl:message>
          </xsl:if>
          <article>
            <xsl:call-template name="att-lang"/>
            <xsl:call-template name="atts">
              <xsl:with-param name="class">
                <xsl:for-each select="ancestor::*[@rend]">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="normalize-space(@rend)"/>
                </xsl:for-each>
              </xsl:with-param>
            </xsl:call-template>
            <!-- Récupérer le saut de page qui précède pour avoir la référence de la section
Tester si saut de page en milieu de texte pour récupérer le précédent.
Attention, pas .//tei:pb[1] (= tous les pb ainés) ni ./following:: (= saut de page après la section)
si du texte avant le premier saut de page, prendre le précédent
            -->
              <!-- 
When  a split section shall we get back the previous page number?
Tricky, <pb> could be hidden, forget.
                
<div type="chapter">
  <index indexName="shorttoc">
     <term>PRINCIPALES ABRÉVIATIONS UTILISÉES</term>
  </index>
  <head rendition="#chaptertitle"><pb n="87" facs="pages/9782600009232_p0087.tif"/>PRINCIPALES ABRÉVIATIONS UTILISÉES </head>
            <xsl:if test=".//tei:pb and local-name(*[1])!='pb'">
              <xsl:variable name="pb" select="node()[1]/following::tei:pb[1]"/>
              <xsl:variable name="text">
                <xsl:for-each select=".//text()[count($pb|following::tei:pb[1])=1]">
                  <xsl:choose>
                    <xsl:when test="ancestor::tei:index"/>
                    <xsl:otherwise>
                      <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </xsl:variable>
              <xsl:if test="$text != ''">
                <xsl:apply-templates select="preceding::tei:pb[1]"/>
              </xsl:if>
            </xsl:if>
              -->
            <!-- if a page break just before, catch it -->
            <xsl:if test="preceding-sibling::*[1][self::tei:pb]">
              <xsl:apply-templates select="preceding-sibling::*[1]"/>
            </xsl:if>
            <xsl:apply-templates select="*">
              <xsl:with-param name="level" select="1"/>
            </xsl:apply-templates>
            <xsl:call-template name="footnotes"/>
          </article>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="document">
      <xsl:with-param name="body" select="$body"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="descendant::*[key('split', generate-id())]">
        <xsl:apply-templates mode="site"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- No more childre to process, isnt'it ? -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Pour section à spliter -->
  <xsl:template name="document">
    <!-- Content generated -->
    <xsl:param name="body"/>
    <!-- Allow title override -->
    <xsl:param name="title"/>
    <!-- Allow id override -->
    <xsl:param name="id">
      <xsl:call-template name="id"/>
    </xsl:param>
    <xsl:param name="href">
      <xsl:value-of select="$destdir"/>
      <xsl:call-template name="href">
        <xsl:with-param name="id" select="$id"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:message>
      <xsl:value-of select="$href"/>
      <xsl:text> : </xsl:text>
      <xsl:call-template name="idpath"/>
    </xsl:message>
    <xsl:document 
      href="{$href}" 
      omit-xml-declaration="no" 
      encoding="UTF-8" 
      indent="yes"
      format-system=""
    >
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
          <script type="text/javascript" src="{$style}Tree.js">//</script>
          <!-- lien à une CSS pour les fichiers statiques -->
          <link rel="stylesheet" type="text/css" href="{$style}html.css"/>
          <xsl:if test="$corpusid != ''">
            <link rel="stylesheet" type="text/css" href="{$style}{$corpusid}.css"/>
          </xsl:if>
        </head>
        <body class="article {$corpusid}">
          <xsl:call-template name="prevnext"/>
          <xsl:copy-of select="$body"/>
        </body>
      </html>
    </xsl:document>
    <!-- Ne pas procéder la suite à partir d'ici, l'aisser faire l'appelleur -->
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
    <xsl:if test="$seriestitle != ''">
      <link rel="dc:isPartOf" href="." title="{normalize-space($seriestitle)}"/>
    </xsl:if>
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

  <!-- génération d'une navigation précédent/suivant -->
  <xsl:template name="prevnext">
    <xsl:param name="valign">top</xsl:param>
    <nav class="prevnext">
      <table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">
        <tr>
          <td  align="left" valign="{$valign}" class="prev" width="30%">
            <!-- like to the element just before, maybe a very far cousin
            for-each seems more efficient than apply-templates
            -->
            <xsl:variable name="prev">
              <xsl:for-each select="preceding::*[key('split', generate-id())][not(self::tei:titlePage)][1]">
                <xsl:call-template name="a-label">
                  <xsl:with-param name="rel">prev</xsl:with-param>
                  <xsl:with-param name="prefix"><abbr>←</abbr><xsl:text> </xsl:text></xsl:with-param>
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
          <td  align="center" valign="{$valign}" class="up">
            <xsl:for-each select="ancestor-or-self::tei:* ">
              <xsl:if test="tei:head|tei:titlePage">
                <div>
                  <xsl:call-template name="a-label">
                    <xsl:with-param name="rel">up</xsl:with-param>
                  </xsl:call-template>
                </div>
              </xsl:if>
            </xsl:for-each>
          </td>
          <td  align="right" valign="{$valign}" class="next" width="30%">
            <!-- first child or descendant ? -->
            <xsl:variable name="child">
              <xsl:for-each select="descendant::*[not(self::tei:titlePage)][key('split', generate-id())][1]">
                <xsl:call-template name="a-label">
                  <xsl:with-param name="rel">next</xsl:with-param>
                  <xsl:with-param name="prefix"><abbr>→</abbr><xsl:text> </xsl:text></xsl:with-param>
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
                      <xsl:with-param name="prefix"><abbr>→</abbr><xsl:text> </xsl:text></xsl:with-param>
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
    <xsl:param name="rel"/>
    <xsl:param name="base"/>
    <!-- html to put before in the link -->
    <xsl:param name="prefix"/>
    <!-- html to put after in the link -->
    <xsl:param name="suffix"/>
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="$base"/>
        <xsl:call-template name="href"/>
      </xsl:attribute>
      <xsl:if test="$rel">
        <xsl:attribute name="rel">
          <xsl:value-of select="$rel"/>
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
      <xsl:copy-of select="$suffix"/>
    </a>
  </xsl:template>
  

</xsl:transform>
