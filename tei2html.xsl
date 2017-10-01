<?xml version="1.0" encoding="UTF-8"?>
<!--

<h1>TEI » HTML (tei2html.xsl)</h1>

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2005 ajlsm.com (Cybertheses)
© 2007 Frederic.Glorieux@fictif.org
© 2010 Frederic.Glorieux@fictif.org et École nationale des chartes
© 2012 Frederic.Glorieux@fictif.org
© 2013 Frederic.Glorieux@fictif.org et LABEX OBVIL

<p>
Cette transformation XSLT 1.0 (compatible navigateurs, PHP, Python, Java…)
transforme du TEI en HTML5.
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
  <!--
  <xsl:import href="common.xsl"/>
  -->
  <xsl:import href="tei2toc.xsl"/>
  <!-- used as a body class -->
  <xsl:param name="folder"/>
  <!-- included, so that priorities will not be flatten by import chain (ex: from tei2site.html) -->
  <xsl:include href="teiHeader2html.xsl"/>
  <!-- Name of this xsl, change link resolution  -->
  <xsl:variable name="this">tei2html.xsl</xsl:variable>
  <!--
La méthode de sortie est xml, pour faire du html5.
L'utilisation des attributs
est contraignante, difficile à surcharger par les transformations qui veulent une
absence de déclaration de DTD.
-->
  <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="yes"/>
  <!-- Output teiHeader ? -->
  <xsl:param name="teiheader" select="true()"/>
  <!-- notes d'apparat critique ? -->
  <xsl:param name="app" select="boolean(//tei:app)"/>
  <!-- What kind of root element to output ? html, div, article -->
  <xsl:param name="root" select="$html"/>
  <xsl:key name="split" match="/" use="'root'"/>
  <!-- key for notes by page, keep the tricky @use expression in this order, when there are other parallel pages number -->
  <xsl:key name="note-pb" match="tei:note[not(parent::tei:sp)][not(starts-with(local-name(..), 'div'))]" use="generate-id(  preceding::*[self::tei:pb[not(@ed)][@n] ][1]|/ ) "/>
  <!-- test if there are code examples to js prettyprint -->
  <xsl:key name="prettify" match="eg:egXML|tei:tag" use="1"/>
  <!-- mainly in verse -->
  <xsl:variable name="verse" select="count(/*/tei:text/tei:body//tei:l) &gt; count(/*/tei:text/tei:body//tei:p)"/>
  <!-- Racine -->
  <xsl:template match="/*">
    <xsl:apply-templates select="." mode="html"/>
  </xsl:template>
  <xsl:template match="/*" mode="html">
    <xsl:variable name="bodyclass">
      <xsl:value-of select="$corpusid"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$folder"/>
    </xsl:variable>
    <xsl:choose>
      <!-- Just a div element -->
      <xsl:when test="$root= $article">
        <article>
          <xsl:call-template name="att-lang"/>
          <xsl:if test="normalize-space($bodyclass)">
            <xsl:attribute name="class">
              <xsl:value-of select="normalize-space($bodyclass)"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
        </article>
      </xsl:when>
      <!-- Complete doc -->
      <xsl:otherwise>
        <!--  browser will not like doctype -->
        <xsl:if test="$xslbase != $theme">
          <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>
          <xsl:value-of select="$lf"/>
        </xsl:if>
        <html>
          <xsl:call-template name="att-lang"/>
          <head>
            <meta http-equiv="Content-type" content="text/html; charset=UTF-8"/>
            <meta name="modified" content="{$date}"/>
            <!-- déclaration classes css locale (permettre la surcharge si généralisation) -->
            <!-- à travailler
            <xsl:apply-templates select="/*/tei:teiHeader/tei:encodingDesc/tei:tagsDecl"/>
            -->
            <link rel="stylesheet" charset="utf-8" type="text/css" href="{$theme}tei2html.css"/>
            <script type="text/javascript" charset="utf-8" src="{$theme}Tree.js">//</script>
          </head>
          <body>
            <xsl:if test="normalize-space($bodyclass)">
              <xsl:attribute name="class">
                <xsl:value-of select="normalize-space($bodyclass)"/>
              </xsl:attribute>
            </xsl:if>
            <div id="center">
              <div id="main">
                <div id="article">
                  <xsl:apply-templates/>
                </div>
              </div>
              <aside id="aside">
                <nav>
                  <header>
                    <a>
                      <xsl:attribute name="href">
                        <xsl:for-each select="/*/tei:text">
                          <xsl:call-template name="href"/>
                        </xsl:for-each>
                      </xsl:attribute>
                      <xsl:if test="$byline">
                        <xsl:copy-of select="$byline"/>
                        <xsl:text> </xsl:text>
                      </xsl:if>
                      <xsl:if test="$docdate != ''">
                        <span class="docDate">
                          <xsl:text> (</xsl:text>
                          <xsl:value-of select="$docdate"/>
                          <xsl:text>)</xsl:text>
                        </span>
                      </xsl:if>
                      <br/>
                      <xsl:copy-of select="$doctitle"/>
                    </a>
                  </header>
                  <xsl:call-template name="toc"/>
                </nav>
              </aside>
            </div>
            <xsl:if test="count(key('prettify', 1))">
              <script src="https://google-code-prettify.googlecode.com/svn/loader/run_prettify.js">//</script>
            </xsl:if>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Go through -->
  <xsl:template match="tei:TEI|tei:TEI.2">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- Bloc de métadonnées -->
  <xsl:template match="tei:teiHeader">
    <!-- Parametrize ? -->
    <xsl:choose>
      <xsl:when test="not($teiheader)"/>
      <xsl:when test="../tei:text/tei:front/tei:titlePage"/>
      <xsl:otherwise>
        <xsl:apply-templates select="tei:fileDesc"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
 <h2>Blocs</h2>
  -->
  <!--
<h3>Sections</h3>

<p>
Les sorties en plusieurs fichiers se distribuent généralement selon les sections.
Des comportement peuvent varier.
</p>

<p>
<strong>Niveau de titre</strong> — &lt;h1> en tête de fichier,
et -1 pour chaque niveau ensuite, d'où le paramètre $level qui peut
être modifié par l'appeleur.
</p>

<p>
<strong>Notes</strong> — Les notes peuvent être sorties en bas de chaque fichier
(une section ou tout le texte), rassemblées dans un fichier à part, sorties par texte
(group/text)
</p>
  -->
  <xsl:template match="tei:elementSpec">
    <article>
      <xsl:attribute name="id">
        <xsl:call-template name="id"/>
      </xsl:attribute>
      <xsl:call-template name="atts"/>
      <h1>
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="@ident"/>
        <xsl:text>&gt;</xsl:text>
      </h1>
      <xsl:apply-templates select="*"/>
    </article>
  </xsl:template>
  <xsl:template match="tei:text">
    <xsl:param name="level" select="count(ancestor::tei:group)"/>
    <article>
      <xsl:attribute name="id">
        <xsl:call-template name="id"/>
      </xsl:attribute>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates select="*">
        <xsl:with-param name="level" select="$level +1"/>
      </xsl:apply-templates>
      <!-- groupes de textes, procéder les notes par textes -->
      <xsl:if test="not(tei:group)">
        <!-- No notes in teiHeader ? -->
        <xsl:call-template name="footnotes"/>
      </xsl:if>
    </article>
  </xsl:template>
  <xsl:template match="tei:front">
    <xsl:param name="level" select="count(ancestor::tei:group)"/>
    <xsl:variable name="element">
      <xsl:choose>
        <xsl:when test="$format = $epub2">div</xsl:when>
        <xsl:otherwise>section</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$element}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:if test="$format = $epub3">
        <xsl:attribute name="epub:type">frontmatter</xsl:attribute>
      </xsl:if>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates select="*">
        <xsl:with-param name="level" select="$level"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:back">
    <xsl:param name="notes" select="not(ancestor::tei:group)"/>
    <xsl:param name="level" select="count(ancestor::tei:group)"/>
    <xsl:choose>
      <xsl:when test="normalize-space(.) = ''"/>
      <xsl:otherwise>
        <xsl:variable name="element">
          <xsl:choose>
            <xsl:when test="$format = $epub2">div</xsl:when>
            <xsl:otherwise>section</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$element}" namespace="http://www.w3.org/1999/xhtml">
          <xsl:if test="$format = $epub3">
            <xsl:attribute name="epub:type">backmatter</xsl:attribute>
          </xsl:if>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates select="*">
            <xsl:with-param name="level" select="$level "/>
          </xsl:apply-templates>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:body">
    <xsl:param name="level" select="count(ancestor::tei:group)"/>
    <xsl:variable name="element">
      <xsl:choose>
        <xsl:when test="$format = $epub2">div</xsl:when>
        <xsl:otherwise>section</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$element}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:if test="$format = $epub3">
        <xsl:attribute name="epub:type">bodymatter</xsl:attribute>
      </xsl:if>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates select="*">
        <xsl:with-param name="level" select="$level "/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  <!--
    TODO ? notes dans les groupes ?
  <xsl:template match="tei:text/tei:group">
    <xsl:param name="el">
      <xsl:choose>
        <xsl:when test="$format = 'html5'">section</xsl:when>
        <xsl:otherwise>div</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="atts"/>
      <xsl:comment>
        <xsl:call-template name="path"/>
      </xsl:comment>
      <xsl:apply-templates/>
      <xsl:call-template name="notes">
        <xsl:with-param name="texte" select=".//*[not()]"/>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>
  -->
  <!-- Sections -->
  <xsl:template match="tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7 | tei:epilogue | tei:preface | tei:group | tei:prologue">
    <xsl:param name="level" select="count(ancestor::*) - 2"/>
    <xsl:param name="el">
      <xsl:choose>
        <xsl:when test="self::tei:group">div</xsl:when>
        <xsl:when test="$format = $epub2">div</xsl:when>
        <xsl:otherwise>section</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="id">
        <xsl:call-template name="id"/>
      </xsl:attribute>
      <xsl:call-template name="atts">
        <xsl:with-param name="class">level<xsl:value-of select="$level + 1"/></xsl:with-param>
      </xsl:call-template>
      <!-- attributs epub3 -->
      <xsl:choose>
        <xsl:when test="$format != $epub3"/>
        <xsl:when test="@type = 'bibliography'">
          <xsl:attribute name="epub:type">bibliography</xsl:attribute>
        </xsl:when>
        <xsl:when test="@type = 'glossary'">
          <xsl:attribute name="epub:type">glossary</xsl:attribute>
        </xsl:when>
        <xsl:when test="@type = 'index'">
          <xsl:attribute name="epub:type">index</xsl:attribute>
        </xsl:when>
        <xsl:when test="@type = 'chapter' or @type = 'act' or @type='article'">
          <xsl:attribute name="epub:type">chapter</xsl:attribute>
        </xsl:when>
        <xsl:when test="ancestor::tei:div[@type = 'chapter' or @type = 'act' or @type='article']">
          <xsl:attribute name="epub:type">subchapter</xsl:attribute>
        </xsl:when>
        <xsl:when test=".//tei:div[@type = 'chapter' or @type = 'act' or @type='article']">
          <xsl:attribute name="epub:type">part</xsl:attribute>
        </xsl:when>
        <!-- dangerous ? -->
        <xsl:when test="self::*[key('split', generate-id())]">
          <xsl:attribute name="epub:type">chapter</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <!-- First element is an empty(?) page break, may come from numerisation or text-processor -->
      <xsl:variable name="name" select="local-name()"/>
      <xsl:choose>
        <xsl:when test="$format != $epub2 and $format != $epub3"/>
        <!-- first section with close to the parent title, no page break -->
        <xsl:when test="not(preceding-sibling::*[$name = local-name()]) and not(preceding-sibling::tei:p|preceding-sibling::tei:quote)"/>
        <!-- start of a file  -->
        <xsl:when test="$level &lt; 2"/>
        <!-- deep level, do nothing -->
        <xsl:when test="$level &gt; 3"/>
        <!-- hard page break ? -->
        <xsl:otherwise/>
      </xsl:choose>
      <xsl:apply-templates select="*">
        <xsl:with-param name="level" select="$level + 1"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  <!-- Floating division -->
  <xsl:template match="tei:floatingText">
    <xsl:param name="el">
      <xsl:choose>
        <xsl:when test="$format = 'html5'">aside</xsl:when>
        <xsl:otherwise>div</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <!-- Cartouche d'entête d'acte -->
  <xsl:template match="tei:group/tei:text/tei:front ">
    <xsl:param name="el">
      <xsl:choose>
        <xsl:when test="$format = 'html5'">header</xsl:when>
        <xsl:otherwise>div</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="atts"/>
      <!--
          <xsl:choose>
            <xsl:when test="../@n">
              <xsl:value-of select="../@n"/>
            </xsl:when>
            <xsl:when test="tei:titlePart[starts-with(@type, 'num')]">
              <xsl:value-of select="tei:titlePart[starts-with(@type, 'num')]"/>
            </xsl:when>
          </xsl:choose>
        -->
      <xsl:apply-templates/>
      <!-- VJ : inscire la mention "D'après témoin" -->
      <xsl:apply-templates select=".//tei:witness[@ana='edited']" mode="according"/>
    </xsl:element>
  </xsl:template>
  <!-- Éléments coupés de la sortie, ou à implémenter -->
  <xsl:template match="tei:divGen "/>
  <!--
<h3>Titres</h3>

  -->
  <!-- Titre en entête -->
  <xsl:template match="tei:titleStmt/tei:title">
    <h1>
      <xsl:choose>
        <xsl:when test="@type">
          <xsl:attribute name="class">
            <xsl:value-of select="@type"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="../tei:title[@type='main']">
          <xsl:attribute name="class">notmain</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
    </h1>
  </xsl:template>
  <!-- Page de titre -->
  <xsl:template match="tei:titlePage">
    <xsl:param name="el">
      <xsl:choose>
        <xsl:when test="$format = 'html5'">section</xsl:when>
        <xsl:otherwise>div</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:if test="$format = $epub3">
        <xsl:attribute name="epub:type">titlepage</xsl:attribute>
      </xsl:if>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:titlePage/tei:performance"/>
  <!-- <h[1-6]> titres avec niveaux hiérarchiques génériques selon le nombre d'ancêtres, il est possible de paramétrer le niveau, pour commencer à 1 en haut de document généré -->
  <xsl:template match="tei:head">
    <xsl:param name="level" select="count(ancestor::tei:*) - 2"/>
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="normalize-space(.) = ''"/>
        <xsl:when test="parent::tei:front | parent::tei:text | parent::tei:back ">h1</xsl:when>
        <xsl:when test="$level &lt; 1">h1</xsl:when>
        <xsl:when test="$level &gt; 7">h6</xsl:when>
        <xsl:otherwise>h<xsl:value-of select="$level"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$name != ''">
      <xsl:apply-templates select="tei:pb"/>
      <xsl:element name="{$name}" namespace="http://www.w3.org/1999/xhtml">
        <xsl:call-template name="atts">
          <xsl:with-param name="class">
            <xsl:value-of select="../@type"/>
            <xsl:if test="$verse"> verse</xsl:if>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="node()[local-name()!='pb']"/>
        <xsl:if test="not(following-sibling::*[1][self::tei:head]) and $format != $epub2 and $format != $epub3">
          <a class="bookmark">
            <xsl:attribute name="href">
              <xsl:for-each select="ancestor::tei:div[1]">
                <xsl:call-template name="href"/>
              </xsl:for-each>
            </xsl:attribute>
            <xsl:text> §</xsl:text>
          </a>
        </xsl:if>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  <!-- Autres titres -->
  <xsl:template match="tei:titlePart">
    <div>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!--
<h3>Paragraphs</h3>
  -->
  <!--  -->
  <!-- Quotation (may contain paragraphs) -->
  <xsl:template match="tei:epigraph | tei:exemplum | tei:remarks">
    <blockquote>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </blockquote>
  </xsl:template>
  <!-- labelled paragraphe container -->
  <xsl:template match="tei:classes | tei:content">
    <fieldset>
      <xsl:call-template name="atts"/>
      <legend>
        <xsl:call-template name="message">
          <xsl:with-param name="id" select="local-name()"/>
        </xsl:call-template>
      </legend>
      <xsl:apply-templates/>
    </fieldset>
  </xsl:template>
  <!-- Contains blocks, but are no sections -->
  <xsl:template match="tei:argument | tei:closer | tei:def | tei:docTitle | tei:entry | tei:form | tei:postscript  | tei:entry/tei:xr | tei:opener">
    <xsl:if test=". != ''">
      <div>
        <xsl:call-template name="atts"/>
        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>
  <!-- To think, rendering ? -->
  <xsl:template match="tei:sp">
    <div>
      <xsl:attribute name="id">
        <xsl:call-template name="id"/>
      </xsl:attribute>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- Paragraph blocs (paragraphs are not allowed in it) -->
  <xsl:template match="tei:p">
    <p>
      <xsl:variable name="prev" select="preceding-sibling::*[not(self::tei:pb)][1]"/>
      <xsl:variable name="char1" select="substring( normalize-space(.), 1, 1)"/>
      <xsl:variable name="class">
        <xsl:choose>
          <xsl:when test="contains( '-–—0123456789', $char1 )"/>
          <xsl:when test="contains(concat(' ', @rend, ' '), ' indent ')"/>
          <!--
          <xsl:when test="$prev and contains('-–—', substring(normalize-space($prev), 1, 1))"/>
          -->
          <xsl:when test="local-name($prev) ='p' and translate($prev, '*∾  ','')!=''"/>
          <xsl:otherwise>autofirst</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>     
      <xsl:call-template name="atts">
        <xsl:with-param name="class" select="$class"/>
      </xsl:call-template>
      <xsl:if test="@n">
        <small class="n">
          <xsl:text>[</xsl:text>
          <xsl:value-of select="@n"/>
          <xsl:text>]</xsl:text>
        </small>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if test=".=''"> </xsl:if>
    </p>
  </xsl:template>
  <xsl:template match="tei:acheveImprime | tei:approbation | tei:byline | tei:caption | tei:dateline | tei:desc | tei:docEdition | tei:docImprint | tei:imprimatur | tei:performance | tei:premiere | tei:printer | tei:privilege | tei:signed | tei:salute | tei:set | tei:trailer
    ">
    <xsl:variable name="el">
      <xsl:choose>
        <xsl:when test="self::tei:trailer">p</xsl:when>
        <xsl:when test="self::tei:docImprint">div</xsl:when>
        <xsl:when test="parent::tei:titlePage">p</xsl:when>
        <xsl:otherwise>div</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="normalize-space(.) != '' ">
      <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
        <xsl:call-template name="atts"/>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:address">
    <address>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </address>
  </xsl:template>
  <!-- Ne pas sortir les saut de ligne dans du texte préformaté -->
  <xsl:template match="tei:eg/tei:lb"/>
  <!-- Couillards et autres culs de lampe -->
  <xsl:template match="tei:ab">
    <xsl:choose>
      <xsl:when test="@type='hr'">
        <hr align="center" width="30%"/>
      </xsl:when>
      <xsl:when test="normalize-space(.) = ''">
        <div>
          <xsl:call-template name="atts"/>
          <xsl:text> </xsl:text>
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div>
          <xsl:call-template name="atts">
            <xsl:with-param name="class">
              <xsl:if test="substring(normalize-space(.), 1, 1) = '*'">star</xsl:if>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Preformated text -->
  <xsl:template match="tei:eg">
    <pre>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </pre>
  </xsl:template>
  <!--
<h3>Listes</h3>



-->
  <!-- Différentes listes, avec prise en charge xhtml correcte des titres (inclus dans un blockquote)  -->
  <xsl:template match="tei:list | tei:listWit | tei:listBibl | tei:recordHist">
    <xsl:variable name="el">
      <xsl:choose>
        <xsl:when test="not(@rend)">ul</xsl:when>
        <xsl:when test="contains(' ordered ol Décimale ', concat(' ', @type, ' ')) ">ol</xsl:when>
        <xsl:when test="contains(' a) a. decimal Décimal decimal-leading-zero 1. 1° 1) I I. lower-alpha lower-latin ol upper-alpha upper-latin upper-roman  ', concat(' ', @rend, ' ')) ">ol</xsl:when>
        <xsl:otherwise>ul</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- test if items as already items -->
    <xsl:variable name="first" select="substring(normalize-space(tei:item), 1, 1)"/>
    <xsl:variable name="none" select="contains('-–—•1', $first)"/>
    <xsl:choose>
      <!-- liste titrée à mettre dans un conteneur-->
      <xsl:when test="tei:head">
        <div class="{local-name()}">
          <xsl:apply-templates select="tei:head"/>
          <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:call-template name="atts">
              <xsl:with-param name="class">
                <xsl:if test="$none">none</xsl:if>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="*[local-name() != 'head']"/>
          </xsl:element>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
          <xsl:call-template name="atts">
            <xsl:with-param name="class">
              <xsl:if test="$none">none</xsl:if>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Pour l’instant ne pas afficher les configurations -->
  <xsl:template match="tei:listPerson">
    <span>
      <xsl:attribute name="id">
        <xsl:call-template name="id"/>
      </xsl:attribute>
    </span>
  </xsl:template>
  <!-- Pseudo-listes  -->
  <xsl:template match="tei:respStmt">
    <xsl:variable name="name" select="name()"/>
    <!-- Plus de 2 item du même nom, voir s'il y a un titre dans le fichier de messages -->
    <xsl:if test="../*[name() = $name][2] and count(../*[name() = $name][1]|.) = 1">
      <xsl:variable name="message">
        <xsl:call-template name="message"/>
      </xsl:variable>
      <xsl:if test="string($message) != ''">
        <p class="{local-name()}">
          <xsl:value-of select="$message"/>
        </p>
      </xsl:if>
    </xsl:if>
    <div>
      <xsl:call-template name="atts"/>
      <xsl:if test="*/@from|*/@to">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="*/@from"/>
        <xsl:text> — </xsl:text>
        <xsl:value-of select="*/@to"/>
        <xsl:text>) </xsl:text>
      </xsl:if>
      <xsl:for-each select="*">
        <xsl:apply-templates select="."/>
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:call-template name="dot"/>
          </xsl:when>
          <xsl:when test="position()=1 and following-sibling::*"> : </xsl:when>
          <xsl:otherwise> ; </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </div>
  </xsl:template>
  <xsl:template match="tei:resp">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- Liste de type index -->
  <xsl:template match="tei:list[@type='index']">
    <div>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates select="tei:head"/>
      <!-- s'il n'y a pas de division spéciale, barre de lettres -->
      <!--
      <xsl:choose>
        <xsl:when test="not(tei:list)">
          <div class="alpha">
            <xsl:call-template name="alpha_href"/>
          </div>
        </xsl:when>
      </xsl:choose>
      -->
      <ul class="index">
        <xsl:apply-templates select="*[local-name() != 'head']"/>
      </ul>
    </div>
  </xsl:template>
  <!-- Barre de lettres, supposée appelée dans le contexte d'un index à plat -->
  <xsl:template name="alpha_href">
    <!-- Préfixe de l'identifiant -->
    <xsl:param name="prefix" select="concat(@xml:id, '.')"/>
    <xsl:param name="alpha">abcdefghijklmnopqrstuvwxyz</xsl:param>
    <xsl:choose>
      <!-- ne pas oublier de stopper à temps -->
      <xsl:when test="$alpha =''"/>
      <xsl:otherwise>
        <xsl:variable name="lettre" select="substring($alpha, 1, 1)"/>
        <!-- tester si la lettre existe avant de l'écrire -->
        <xsl:if test="*[translate(substring(., 1, 1), $idfrom, $idto) = $lettre]">
          <xsl:if test="$lettre != 'a'"> </xsl:if>
          <!-- pas d'espace insécable -->
          <a href="#{$prefix}{$lettre}" target="_self">
            <xsl:value-of select="translate ( $lettre, $lc, $uc)"/>
          </a>
        </xsl:if>
        <xsl:call-template name="alpha_href">
          <xsl:with-param name="alpha" select="substring($alpha, 2)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Titre d'une liste -->
  <xsl:template match="tei:list/tei:head">
    <p class="list">
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <!-- <item>, item de liste -->
  <xsl:template match="tei:item">
    <li>
      <xsl:call-template name="atts"/>
      <!-- unplug, maybe expensive -->
      <!--
      <xsl:if test="../@type='index' and not(../tei:list)">
        <xsl:variable name="lettre" select="translate(substring(., 1, 1), $iso, $min)"/>
        <xsl:if test="translate(substring(preceding-sibling::tei:item[1], 1, 1), $iso, $min) != $lettre">
          <a id="{../@xml:id}.{$lettre}">&#x200c;</a>
        </xsl:if>
      </xsl:if>
      -->
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  <!-- term list -->
  <xsl:template match="tei:list[@type='gloss' or tei:label]">
    <xsl:choose>
      <!-- liste titrée à mettre dans un conteneur-->
      <xsl:when test="tei:head">
        <div class="{local-name()}">
          <xsl:apply-templates select="tei:head"/>
          <dl class="dl">
            <xsl:call-template name="atts"/>
            <xsl:apply-templates select="*[local-name() != 'head']"/>
          </dl>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <dl>
          <xsl:call-template name="atts">
            <xsl:with-param name="class">dl</xsl:with-param>
          </xsl:call-template>
          <xsl:apply-templates/>
        </dl>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:list[@type='gloss' or tei:label]/tei:label">
    <dt>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </dt>
  </xsl:template>
  <xsl:template match="tei:list[@type='gloss' or tei:label]/tei:item">
    <dd>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </dd>
  </xsl:template>
  <xsl:template match="tei:castList">
    <div>
      <xsl:attribute name="id">
        <xsl:call-template name="id"/>
      </xsl:attribute>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates select="tei:head | tei:p"/>
      <ul class="castList">
        <xsl:for-each select="*[not(self::tei:head) and not(self::tei:p)]">
          <li>
            <xsl:call-template name="atts"/>
            <xsl:apply-templates select="."/>
          </li>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>
  <xsl:template match="tei:castItem">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:castGroup">
    <xsl:apply-templates select="tei:head | tei:note | tei:roleDesc"/>
    <ul class="castGroup">
      <xsl:for-each select="*">
        <li>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates select="."/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>
  <xsl:template match="tei:castGroup/tei:head">
    <xsl:call-template name="span"/>
  </xsl:template>
  <xsl:template match="tei:actor | tei:role | tei:roleDesc">
    <xsl:call-template name="span"/>
  </xsl:template>
  <!-- Glossary like dictionary entry -->
  <xsl:template match="tei:entryFree">
    <div>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="tei:xr">
    <div>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- Le calendrier des modifications et passer dans dans une page credits -->
  <xsl:template match="tei:revisionDesc">
    <table>
      <xsl:call-template name="atts">
        <xsl:with-param name="class">data</xsl:with-param>
      </xsl:call-template>
      <caption>
        <xsl:call-template name="message"/>
      </caption>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  <!-- Liste spéciale, journal des modifications  -->
  <xsl:template match="tei:change">
    <tr>
      <xsl:call-template name="atts"/>
      <td>
        <xsl:value-of select="@when"/>
      </td>
      <td>
        <xsl:call-template name="anchors">
          <xsl:with-param name="att">who</xsl:with-param>
        </xsl:call-template>
      </td>
      <td>
        <xsl:apply-templates/>
      </td>
    </tr>
  </xsl:template>
  <!--
Tables
 - - -
  -->
  <!-- table  -->
  <xsl:template match="tei:table">
    <table>
      <xsl:call-template name="atts">
        <xsl:with-param name="class">table</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  <xsl:template match="tei:table/tei:head">
    <caption>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </caption>
  </xsl:template>
  <!-- ligne -->
  <xsl:template match="tei:row">
    <tr>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  <!-- Cellule  -->
  <xsl:template match="tei:cell">
    <xsl:variable name="el">
      <xsl:choose>
        <xsl:when test="@role='label'">th</xsl:when>
        <xsl:when test="../@role='label'">th</xsl:when>
        <xsl:otherwise>td</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="atts"/>
      <xsl:if test="@rows &gt; 1">
        <xsl:attribute name="rowspan">
          <xsl:value-of select="@rows"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@cols &gt; 1">
        <xsl:attribute name="colspan">
          <xsl:value-of select="@cols"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <!-- vers, strophe -->

  <xsl:template match="tei:lg">
    <div>
      <xsl:call-template name="atts">
        <xsl:with-param name="class">
          <xsl:if test="@part">
            <xsl:text>part-</xsl:text>
            <xsl:value-of select="translate(@part, 'fimy', 'FIMY')"/>
          </xsl:if>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template name="l-n">
    <xsl:choose>
      <xsl:when test="@n">
        <xsl:value-of select="@n"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- ligne (ex : vers) -->
  <xsl:template match="tei:l">
    <xsl:variable name="n">
      <xsl:call-template name="l-n"/>
    </xsl:variable>
    <!-- or $prev/@n = $n SLOW
    <xsl:variable name="prev" select="preceding::tei:l[1]"/>
    -->
    <xsl:choose>
      <!-- probablement vers vide pour espacement -->
      <xsl:when test="normalize-space(.) =''">
        <br/>
      </xsl:when>
      <xsl:otherwise>
        <div>
          <xsl:variable name="pos">
            <xsl:number/>
          </xsl:variable>
          <xsl:call-template name="atts">
            <xsl:with-param name="class">
              <xsl:if test="@part">
                <xsl:text>part-</xsl:text>
                <xsl:value-of select="translate(@part, 'fimy', 'FIMY')"/>
              </xsl:if>
              <xsl:if test="@met">
                <xsl:text> </xsl:text>
                <xsl:value-of select="@met"/>
              </xsl:if>
              <!-- first verse in stanza -->
              <xsl:choose>
                <!-- Not in a stanza -->
                <xsl:when test="not(parent::tei:lg)"/>
                <!-- Is it a broken verse to align ? -->
                <xsl:when test="@part and @part != 'I'">
                  <!-- search if previous verse should be aligned -->
                  <xsl:for-each select="preceding::tei:l[@part='I'][1]">
                    <xsl:variable name="first">
                      <xsl:number/>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="$first != 1"/>
                      <xsl:when test="not(parent::tei:lg)"/>
                      <xsl:when test="not(parent::tei:lg/@part) or parent::tei:lg/@part = 'I'"> first</xsl:when>
                    </xsl:choose>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="$pos != 1"/>
                <!-- first but in a stanza fragment-->
                <xsl:when test="parent::tei:lg/@part and parent::tei:lg/@part != 'I'"/>
                <!-- first verse in a stanza -->
                <xsl:when test="$pos = 1">
                  <xsl:text> first</xsl:text>
                </xsl:when>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:choose>
            <xsl:when test="not(number($n))"/>
            <xsl:when test="$n &lt; 1"/>
            <!-- previous verse has same number, usually a rupted verse -->
            <xsl:when test="@part='M' or @part='F'"/>
            <!-- line number could be multiple in a file, do not check repeated number in broken verses  -->
            <xsl:when test="ancestor::tei:quote"/>
            <xsl:when test="($n mod 5) = 0">
              <small class="l-n">
                <xsl:value-of select="$n"/>
                <xsl:text> </xsl:text>
              </small>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="@part = 'M' or @part = 'm' or @part = 'F' or @part = 'f'  or @part = 'y'  or @part = 'Y'">
            <!-- Rupted verse, get the exact spacer from previous verse -->
            <xsl:variable name="txt">
              <xsl:apply-templates select="preceding::tei:l[1]" mode="lspacer"/>
            </xsl:variable>
            <xsl:if test="normalize-space($txt) != ''">
              <span class="spacer" style="visibility: hidden;">
                <xsl:value-of select="$txt"/>
              </span>
            </xsl:if>
          </xsl:if>
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:l" mode="lspacer">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="title"/>
    </xsl:variable>
    <xsl:choose>
      <!-- ??? -->
      <xsl:when test="not(ancestor::tei:body)"/>
      <!-- encoding error -->
      <xsl:when test="not(@part)"/>
      <!-- encoding error -->
      <xsl:when test="@part = 'F'">
        <xsl:apply-templates select="preceding::tei:l[1]" mode="lspacer"/>
        <xsl:value-of select="$txt"/>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="@part = 'M'">
        <xsl:apply-templates select="preceding::tei:l[1]" mode="lspacer"/>
        <xsl:value-of select="$txt"/>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="@part = 'Y'">
        <xsl:apply-templates select="preceding::tei:l[1]" mode="lspacer"/>
        <xsl:value-of select="$txt"/>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="@part = 'I'">
        <xsl:value-of select="$txt"/>
        <xsl:text> </xsl:text>
      </xsl:when>
      <!-- No part="I" ? -->
      <xsl:otherwise>
        <xsl:value-of select="$txt"/>
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
<h2>Caractères</h2>

<p>Balises de niveau mot, à l'intérieur d'un paragraphe.</p>

<h3>HTML</h3>

  -->
  <!-- <hi>, mise en forme typo générique -->
  <xsl:template match="tei:hi">
    <xsl:variable name="rend" select="translate(@rend, $idfrom, $idto)"/>
    <xsl:choose>
      <xsl:when test=". =''"/>
      <!-- si @rend est un nom d'élément HTML -->
      <xsl:when test="contains( ' b big em i s small strike strong sub sup tt u ', concat(' ', $rend, ' '))">
        <xsl:element name="{$rend}" namespace="http://www.w3.org/1999/xhtml">
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$rend = ''">
        <em>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </em>
      </xsl:when>
      <xsl:when test="starts-with($rend, 'it')">
        <i>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </i>
      </xsl:when>
      <xsl:when test="starts-with($rend, 'it')">
        <i>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </i>
      </xsl:when>
      <xsl:when test="contains($rend, 'bold') or contains($rend, 'gras')">
        <b>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </b>
      </xsl:when>
      <xsl:when test="starts-with($rend, 'ind')">
        <sub>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </sub>
      </xsl:when>
      <xsl:when test="starts-with($rend, 'exp')">
        <sup>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </sup>
      </xsl:when>
      <!-- surlignages venus de la transformation ODT -->
      <xsl:when test="$rend='bg' or $rend='mark'">
        <span class="bg" style="background-color:#{@n};">
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="$rend='col' or $rend='color'">
        <span class="col" style="color:#{@n};">
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <!-- sinon appeler le span général -->
      <xsl:otherwise>
        <span>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- <code>, code en police à chasse fixe -->
  <xsl:template match="tei:code">
    <xsl:call-template name="span">
      <xsl:with-param name="el">code</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:u">
    <xsl:call-template name="span"/>
  </xsl:template>
  <!-- <eg>, exemple en ligne -->
  <!--
  <xsl:template match="tei:p/tei:eg">
    <xsl:call-template name="span">
      <xsl:with-param name="el">samp</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  -->
  <!-- <gi>, nom d’un élément -->
  <!-- ajout de < et > pas assez robuste en CSS pour utiliser template span -->
  <xsl:template match="tei:gi">
    <code>
      <xsl:text>&lt;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&gt;</xsl:text>
    </code>
  </xsl:template>
  <!-- XML sample -->
  <xsl:template match="eg:egXML">
    <xsl:choose>
      <xsl:when test="*">
        <div class="xml">
          <xsl:apply-templates mode="xml2html"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <pre class="prettyprint linenums">
          <code class="language-xml">
            <xsl:apply-templates/>
          </code>
        </pre>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
    use the @scheme for a link ? TEI, Docbook…

    -->
  <xsl:template match="tei:tag">
    <code class="language-xml prettyprint">
      <xsl:choose>
        <xsl:when test="@type='start'">&lt;</xsl:when>
        <xsl:when test="@type='end'">&lt;/</xsl:when>
        <xsl:when test="@type='empty'">&lt;</xsl:when>
        <xsl:when test="@type='pi'">&lt;?</xsl:when>
        <xsl:when test="@type='comment'">&lt;!--</xsl:when>
        <xsl:when test="@type='pi'">&lt;[CDATA[</xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
      <xsl:choose>
        <xsl:when test="@type='start'">&gt;</xsl:when>
        <xsl:when test="@type='end'">&gt;</xsl:when>
        <xsl:when test="@type='empty'">/&gt;</xsl:when>
        <xsl:when test="@type='pi'">?&gt;</xsl:when>
        <xsl:when test="@type='comment'">--&gt;</xsl:when>
        <xsl:when test="@type='pi'">]]&gt;</xsl:when>
      </xsl:choose>
    </code>
  </xsl:template>
  <!-- ODD -->
  <xsl:template match="tei:memberOf">
    <xsl:value-of select="@key"/>
  </xsl:template>
  <xsl:template match="tei:memberOf">
    <xsl:value-of select="@key"/>
  </xsl:template>
  <!--
  zeroOrMore xmlns="http://relaxng.org/ns/structure/1.0">
      <choice
  -->
  <xsl:template match="rng:zeroOrMore">
    <xsl:text>( </xsl:text>
    <xsl:apply-templates select="*"/>
    <xsl:text> )*</xsl:text>
  </xsl:template>
  <xsl:template match="rng:choice">
    <xsl:if test="not(parent::rng:zeroOrMore)">( </xsl:if>
    <xsl:for-each select="*">
      <xsl:if test="position() != 1"> | </xsl:if>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    <xsl:if test="not(parent::rng:zeroOrMore)"> )</xsl:if>
  </xsl:template>
  <xsl:template match="rng:ref | rng:element | rng:attribute">
    <xsl:value-of select="@name"/>
  </xsl:template>
  <xsl:template match="rng:text">
    <xsl:text>text()</xsl:text>
  </xsl:template>
  <!-- <att>, nom d’un attribut -->
  <xsl:template match="tei:att">
    <code>
      <xsl:apply-templates/>
    </code>
  </xsl:template>
  <!-- <num>, nombres, utile pour les chiffres romains -->
  <xsl:template match="tei:num">
    <xsl:call-template name="span"/>
  </xsl:template>
  <!-- Césure, html5 <wbr> ? -->
  <xsl:template match="tei:caes">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- Page break in titlePage, something to do, don't know what for now -->
  <xsl:template match="tei:titlePage/tei:pb"/>
  <!-- Page break, add a space, hyphenation supposed to be resolved -->
  <xsl:template match="tei:pb" name="pb">
    <xsl:variable name="norm" select="normalize-space(@n)"/>
    <xsl:variable name="text">
      <xsl:choose>
        <xsl:when test="starts-with(@ed, 'frantext')"/>
        <xsl:when test="$norm = ''"/>
        <xsl:when test="contains('[({', substring($norm, 1,1))">
          <xsl:value-of select="$norm"/>
        </xsl:when>
        <xsl:when test="@ana">[<xsl:value-of select="@ana"/>]</xsl:when>
        <xsl:when test="@ed">[<xsl:value-of select="@n"/>]</xsl:when>
        <!-- number display as a page -->
        <xsl:when test="@n != ''  and contains('0123456789IVXDCM', substring(@n,1,1))">{p. <xsl:value-of select="@n"/>}</xsl:when>
        <xsl:otherwise>[<xsl:value-of select="@n"/>]</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="class">
      <xsl:text>pb</xsl:text>
      <xsl:if test="@ed">
        <xsl:text> ed </xsl:text>
        <xsl:value-of select="@ed"/>
      </xsl:if>
      <xsl:if test="@facs">
        <xsl:text> facs</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="id">
      <xsl:call-template name="id"/>
    </xsl:variable>
    <!-- test if inside mixed content, before adding a space, to keep automatic indent  -->
    <xsl:variable name="mixed" select="../text()[normalize-space(.) != '']"/>
    <xsl:choose>
      <xsl:when test="normalize-space(@n) = ''"/>
      <xsl:when test="$text =''"/>
      <xsl:when test="$format = $epub2">
        <xsl:if test="$mixed != ''">
          <xsl:text> </xsl:text>
        </xsl:if>
        <sub>
          <xsl:if test="$id != ''">
            <xsl:attribute name="id">
              <xsl:value-of select="$id"/>
            </xsl:attribute>
          </xsl:if>
        </sub>
        <xsl:if test="$mixed != ''">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$mixed != ''">
          <xsl:text> </xsl:text>
        </xsl:if>
        <a class="{normalize-space($class)}">
          <xsl:choose>
            <!-- @xml:base ? -->
            <xsl:when test="@facs">
              <xsl:attribute name="href">
                <xsl:if test="not(starts-with(@facs, 'http')) and /*/@xml:base">
                  <xsl:value-of select="/*/@xml:base"/>
                </xsl:if>
                <xsl:value-of select="@facs"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="$id != ''">
              <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$id"/>
              </xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="$id != ''">
            <xsl:attribute name="id">
              <xsl:value-of select="$id"/>
            </xsl:attribute>
          </xsl:if>
          <!-- TODO by js
          <xsl:if test="not(@ed)">
            <xsl:attribute name="onclick">if(window.pb) pb(this, '<xsl:value-of select="$docid"/>', '<xsl:value-of select="@n"/>');</xsl:attribute>
          </xsl:if>
          -->
          <xsl:value-of select="$text"/>
        </a>
        <xsl:if test="@ed">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- colomn break -->
  <xsl:template match="tei:cb" name="cb">
    <!--
    <xsl:if test="@n and @n != ''">
      <i class="cb"> (<xsl:value-of select="@n"/>) </i>
    </xsl:if>
    -->
  </xsl:template>
  <!-- line breaks -->
  <xsl:template match="tei:lb">
    <xsl:choose>
      <xsl:when test="@n and ancestor::tei:p">
        <xsl:text> </xsl:text>
        <small class="l">[l. <xsl:value-of select="@n"/>]</small>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="@n">
        <small class="lb">
          <xsl:text>
  </xsl:text>
          <br/>
          <xsl:value-of select="@n"/>
          <xsl:text> </xsl:text>
        </small>
      </xsl:when>
      <xsl:otherwise>
        <br>
          <xsl:call-template name="atts"/>
        </br>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- folios, or rules -->
  <xsl:template match="tei:milestone">
    <xsl:choose>
      <xsl:when test="@unit='hr' or @unit='rule'">
        <hr>
          <xsl:call-template name="atts"/>
        </hr>
      </xsl:when>
      <xsl:when test="@unit='folio'">
        <small class="pb folio">
          <xsl:text>f. </xsl:text>
          <xsl:value-of select="@n"/>
        </small>
      </xsl:when>
      <xsl:otherwise>
        <span>
          <xsl:call-template name="atts"/>
          <xsl:value-of select="@n"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- bloc hors flux -->
  <xsl:template match="tei:fw">
    <xsl:call-template name="span">
      <xsl:with-param name="el">small</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <!-- HTML5, “identifiant” -->
  <xsl:template match="tei:ident">
    <xsl:call-template name="span">
      <xsl:with-param name="el">b</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <!-- Create an html5 inline element, differents tests done to ensure quality of output -->
  <xsl:template match="tei:institution | tei:heraldry | tei:locus | tei:metamark | tei:nameLink | tei:biblFull/tei:publicationStmt/tei:date | tei:biblFull/tei:publicationStmt/tei:pubPlace | tei:repository | tei:settlement " name="span">
    <xsl:param name="el">span</xsl:param>
    <xsl:choose>
      <xsl:when test=".=''"/>
      <!-- bad tag, with spaces only, tested, not too expensive -->
      <xsl:when test="translate(.,'  ,:;.','')=''">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- generic inline catch a lot, to put some  -->
  <xsl:template match="tei:distinct | tei:emph | tei:mentioned | tei:sic | tei:soCalled ">
    <xsl:call-template name="span">
      <xsl:with-param name="el">em</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <!-- <span class="..."/>, segment générique sans mise en forme particulière -->
  <xsl:template match="tei:phr ">
    <xsl:call-template name="span"/>
  </xsl:template>
  <!-- Go throw with no html effect -->
  <xsl:template match="tei:seg | tei:imprint |  tei:pubPlace | tei:glyph ">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:seg[@rend] | tei:seg[@type]">
    <span>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <!-- dates -->
  <xsl:template match="tei:date | tei:publicationStmt/tei:date | tei:docDate | tei:origDate">
    <xsl:variable name="el">
      <xsl:choose>
        <xsl:when test="parent::tei:div">div</xsl:when>
        <xsl:when test="parent::tei:titlePage">p</xsl:when>
        <xsl:when test="parent::tei:front">p</xsl:when>
        <!-- bug in LibreOffice
        <xsl:when test="$format=$html5">time</xsl:when>
        -->
        <xsl:otherwise>span</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="att">
      <xsl:choose>
        <xsl:when test="$format=$html5">datetime</xsl:when>
        <xsl:otherwise>title</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="value">
      <xsl:if test="@cert">~</xsl:if>
      <xsl:if test="@scope">~</xsl:if>
      <xsl:variable name="notBefore">
        <xsl:value-of select="number(substring(@notBefore, 1, 4))"/>
      </xsl:variable>
      <xsl:variable name="notAfter">
        <xsl:value-of select="number(substring(@notAfter, 1, 4))"/>
      </xsl:variable>
      <xsl:variable name="when">
        <xsl:value-of select="number(substring(@when, 1, 4))"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$when != 'NaN'">
          <xsl:value-of select="$when"/>
        </xsl:when>
        <xsl:when test="$notAfter = $notBefore and $notAfter != 'NaN'">
          <xsl:value-of select="$notAfter"/>
        </xsl:when>
        <xsl:when test="$notBefore != 'NaN' and $notAfter != 'NaN'">
          <xsl:value-of select="$notBefore"/>
          <xsl:text>/</xsl:text>
          <xsl:value-of select="$notAfter"/>
        </xsl:when>
        <xsl:when test="$notBefore != 'NaN'">
          <xsl:value-of select="$notBefore"/>
          <xsl:text>/…</xsl:text>
        </xsl:when>
        <xsl:when test="$notAfter != 'NaN'">
          <xsl:text>…–</xsl:text>
          <xsl:value-of select="$notAfter"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test=". = '' and $value = ''"/>
      <xsl:when test=". = '' and $value != ''">
        <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
          <xsl:call-template name="atts"/>
          <xsl:attribute name="{$att}">
            <xsl:value-of select="$value"/>
          </xsl:attribute>
          <xsl:value-of select="$value"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
          <xsl:call-template name="atts"/>
          <xsl:if test="$value != ''">
            <xsl:attribute name="{$att}">
              <xsl:value-of select="$value"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- caractère particulier, par exemple lettrine, peut nécessiter une police particulière -->
  <xsl:template match="tei:c">
    <span>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <!--
<h3>Liens</h3>
  -->
  <!-- Template to override  -->
  <xsl:template match="tei:ref">
    <a>
      <xsl:call-template name="atts"/>
      <xsl:if test="@subtype">
        <xsl:attribute name="target">
          <xsl:value-of select="@subtype"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:variable name="html">
        <xsl:apply-templates/>
      </xsl:variable>     
      <xsl:choose>
        <xsl:when test="string($html) != ''">
          <xsl:copy-of select="$html"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="anchors">
            <xsl:with-param name="anchors" select="@target"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>
  <!-- Ancre -->
  <xsl:template match="tei:anchor">
    <!-- empty char, hack for some readers -->
    <a id="{@xml:id}">&#x200c;</a>
  </xsl:template>
  <!-- email -->
  <xsl:template match="tei:email">
    <xsl:choose>
      <xsl:when test="$format=$epub2">
        <a href="mailto:{normalize-space(.)}">
          <xsl:value-of select="normalize-space(.)"/>
        </a>
      </xsl:when>
      <!-- hide email for publication on web -->
      <xsl:otherwise>
        <xsl:variable name="string">
          <xsl:value-of select="substring-before(., '@')"/>
          <xsl:text>'+'\x40'+'</xsl:text>
          <xsl:value-of select="substring-after(., '@')"/>
        </xsl:variable>
        <xsl:text>&lt;</xsl:text>
        <a>
          <xsl:call-template name="atts"/>
          <xsl:attribute name="href">#</xsl:attribute>
          <xsl:attribute name="onmouseover">if(this.ok) return; this.href='mailto:<xsl:value-of select="$string"/>'; this.ok=true; </xsl:attribute>
          <xsl:text>&#x200c;</xsl:text>
          <xsl:value-of select="substring-before(., '@')"/>
          <xsl:text>&#x200c;</xsl:text>
          <xsl:text>＠</xsl:text>
          <xsl:text>&#x200c;</xsl:text>
          <xsl:value-of select="substring-after(., '@')"/>
          <xsl:text>&#x200c;</xsl:text>
        </a>
        <xsl:text>&gt;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Pointeur sans label -->
  <xsl:template match="tei:ptr">
    <a>
      <xsl:call-template name="atts"/>
      <xsl:attribute name="href">
        <xsl:value-of select="@target"/>
      </xsl:attribute>
      <xsl:value-of select="@target"/>
    </a>
  </xsl:template>
  <!-- Quelque chose à faire ?

<figure>
  <graphic url="../../../../elec/conferences/src/knoch-mund/olgiati.png"/>
  <head>© Mirta Olgiati</head>
</figure>

<figure class="right">
  <a href="ferri/grande/Ill_2_Grillando.jpg"><img src="ferri/petite/Ill_2_Grillando.jpg" height="155" width="250"></a>
  <figcaption style="width: 250px;">
    <a href="ferri/grande/Ill_2_Grillando.jpg"><img src="theme/img/agrandir.png" title="agrandir"></a>
    [ill. 1] Paolo Grillando, Tractat[um] de hereticis et sortilegijs…, Lyon, 1536 [page de titre]. Cornell Library, Division of Rare Books and Manuscripts, Witchcraft BF1565 G85 1536.
    </figcaption>
</figure>

  -->
  <xsl:template match="tei:figure | tei:facsimile">
    <xsl:param name="el">
      <xsl:choose>
        <xsl:when test="$format = 'html5'">figure</xsl:when>
        <xsl:otherwise>div</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="id">
        <xsl:call-template name="id"/>
      </xsl:attribute>
      <xsl:call-template name="atts"/>
      <!-- ?
      <a class="bookmark">
        <xsl:attribute name="href">
          <xsl:call-template name="href"/>
        </xsl:attribute>
        <xsl:text> §</xsl:text>
      </a>
      -->
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:figure/tei:figDesc | tei:figure/tei:desc | tei:figure/tei:head">
    <xsl:choose>
      <xsl:when test=".=''"/>
      <xsl:when test="$format = 'html5'">
        <figcaption>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </figcaption>
      </xsl:when>
      <xsl:otherwise>
        <div>
          <xsl:call-template name="atts">
            <xsl:with-param name="class">figcaption</xsl:with-param>
          </xsl:call-template>
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Images, TODO @alt -->
  <xsl:template match="tei:graphic">
    <xsl:variable name="id">
      <xsl:call-template name="id"/>
    </xsl:variable>
    <img src="{$images}{@url}" alt="{normalize-space(.)}" id="{$id}">
      <xsl:if test="@rend">
        <xsl:attribute name="align">
          <xsl:copy-of select="@rend"/>
        </xsl:attribute>
      </xsl:if>
    </img>
  </xsl:template>
  <!-- Sentence -->
  <xsl:template match="tei:s">
    <xsl:text>
</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- <w>, word, avec possible définition -->
  <xsl:template match="tei:w">
    <xsl:variable name="def" select="key('id', substring(@lemmaRef, 2))"/>
    <xsl:variable name="lastW" select="preceding-sibling::tei:w[1]"/>
    <xsl:variable name="lastChar" select="substring($lastW, string-length($lastW))"/>
    <xsl:choose>
      <!--  Particulier à MontFerrand, à sortir ? -->
      <xsl:when test="$def">
        <a>
          <xsl:call-template name="atts"/>
          <xsl:attribute name="title">
            <xsl:for-each select="$def/ancestor-or-self::tei:entry[1]//tei:def">
              <xsl:value-of select="normalize-space(.)"/>
              <xsl:choose>
                <xsl:when test="position() != last()"> ; </xsl:when>
                <xsl:otherwise>.</xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <!-- french PUNCT ? -->
      <xsl:when test="string-length(.)=1 and contains(';:?!»', .)">
        <xsl:text> </xsl:text>
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:when test="string-length(.)=1 and contains('),.', .)">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:when test="string-length(.)=1 and contains('),.', .)">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="pos">
          <xsl:number/>
        </xsl:variable>
        <xsl:if test="$pos!=1 and $lastChar!='’' and $lastChar!=$apos">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Do something on punctuation ? -->
  <xsl:template match="tei:pc | tei:g">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- behaviors on text nodes between words  -->
  <!--
  <xsl:template match="text()">
    <xsl:choose>
      <xsl:when test="normalize-space(.)='' and ../tei:w"/>
      <xsl:when test="$format = $epub2 and not(../tei:w)">
        <xsl:value-of select="translate(., '‘’★‑∾ ', concat($apos, $apos,'*-~ '))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  -->
  <!-- Poetic information, rendering? -->
  <xsl:template match="tei:caesura">
    <xsl:text> </xsl:text>
  </xsl:template>
  <!-- Cross without a trace? -->
  <xsl:template match="tei:corr">
    <xsl:choose>
      <xsl:when test="not(../tei:w)"/>
      <xsl:when test="preceding-sibling::*[1][self::tei:w]">
        <xsl:text> </xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:template>
  <!--
<h3>Bibliographie</h3>

  -->
  <xsl:template match="tei:biblFull | tei:biblStruct | tei:msDesc | tei:msPart | tei:witness">
    <xsl:variable name="el">
      <xsl:choose>
        <!-- Référence bibliographique affichée comme bloc -->
        <xsl:when test="parent::tei:accMat or parent::tei:cit or parent::tei:div or parent::tei:div0 or parent::tei:div1 or parent::tei:div2 or parent::tei:div3 or parent::tei:div4 or parent::tei:div5 or parent::tei:div6 or parent::tei:div7 or parent::tei:epigraph">p</xsl:when>
        <xsl:when test="parent::tei:listWit or parent::tei:listBibl">li</xsl:when>
        <xsl:otherwise>span</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="atts"/>
      <xsl:if test="@n">
        <small class="n">
          <xsl:value-of select="@n"/>
        </small>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:if test="@xml:id">
        <i>
          <xsl:call-template name="witid"/>
        </i>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="self::tei:biblStruct">
          <xsl:for-each select="*">
            <xsl:apply-templates select="."/>
            <xsl:choose>
              <xsl:when test="position()=last()">.</xsl:when>
              <xsl:otherwise>. </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  <!-- Traverser sans trace -->
  <xsl:template match="tei:monogr | tei:analytic">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- Manuscript ou imprimé, notamment appelé comme témoin -->
  <xsl:template match="tei:msDesc | tei:bibl" mode="a">
    <a class="{local-name()}">
      <xsl:attribute name="href">
        <xsl:call-template name="href"/>
      </xsl:attribute>
      <xsl:variable name="title">
        <xsl:apply-templates/>
      </xsl:variable>
      <xsl:attribute name="title">
        <xsl:value-of select="normalize-space($title)"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="@xml:id">
          <xsl:call-template name="witid"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="message"/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>
  <!-- Présentation d'identifiants de témoins -->
  <xsl:template name="witid">
    <xsl:param name="s" select="@xml:id"/>
    <xsl:choose>
      <xsl:when test="normalize-space($s)=''"/>
      <xsl:when test="contains($s, '_') or contains($s, '.')">
        <xsl:value-of select="."/>
      </xsl:when>
      <!-- Si patron normalisé d'identifiant pour édition -->
      <xsl:when test="starts-with($s, 'ed') and translate(substring($s,3), '0123456789 ', '')=''">
        <xsl:text>éd. </xsl:text>
        <xsl:value-of select="normalize-space(substring($s,3))"/>
      </xsl:when>
      <xsl:when test="translate(substring($s, 1, 1), 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', '') =''">
        <xsl:value-of select="substring($s, 1, 1)"/>
        <xsl:call-template name="witid">
          <xsl:with-param name="s" select="substring($s, 2)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <sup>
          <xsl:value-of select="$s"/>
        </sup>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:title">
    <xsl:choose>
      <xsl:when test="@ref">
        <!-- ?? resolve links ? -->
        <a href="{@ref}">
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <cite>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </cite>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- titre avec une URI pas loin -->
  <xsl:template match="tei:title[../tei:idno[@type='URI']]">
    <a href="{../tei:idno[@type='URI']}">
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  <!-- na pas sortir l'URI -->
  <xsl:template match="tei:idno[@type='URI'][../tei:title]" priority="5"/>
  <!-- identifiant bibliographique -->
  <xsl:template match="tei:idno | tei:altIdentifier">
    <xsl:choose>
      <xsl:when test="starts-with(normalize-space(.), 'http')">
        <a>
          <xsl:call-template name="atts"/>
          <xsl:attribute name="href">
            <xsl:value-of select="normalize-space(.)"/>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="@type and @type != 'URI'">
              <xsl:value-of select="@type"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:biblScope | tei:collation | tei:collection | tei:dim | tei:docAuthor | tei:editor | tei:edition | tei:extent | tei:funder | tei:publisher | tei:stamp | tei:biblFull/tei:titleStmt/tei:title">
    <xsl:variable name="element">
      <xsl:choose>
        <xsl:when test="parent::tei:titlePage">p</xsl:when>
        <xsl:when test="parent::tei:front">p</xsl:when>
        <xsl:when test="parent::tei:div">p</xsl:when>
        <xsl:otherwise>span</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$element}">
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <!-- generic div -->
  <xsl:template match="tei:accMat | tei:additional | tei:additions | tei:addrLine | tei:adminInfo | tei:binding | tei:bindingDesc | tei:closer | tei:condition | tei:equiv | tei:history | tei:licence | tei:listRef | tei:objectDesc | tei:origin | tei:provenance | tei:physDesc | tei:biblFull/tei:publicationStmt | tei:source | tei:speaker | tei:support | tei:supportDesc | tei:surrogates | tei:biblFull/tei:titleStmt" name="div">
    <xsl:param name="el">
      <xsl:choose>
        <xsl:when test="self::tei:speaker">p</xsl:when>
        <xsl:otherwise>div</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:if test="normalize-space(.) != ''">
      <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
        <xsl:call-template name="atts"/>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:handDesc">
    <ul>
      <xsl:for-each select="*">
        <li>
          <xsl:call-template name="atts"/>
          <xsl:if test="@xml:id">
            <small class="id">[<xsl:value-of select="@xml:id"/>]</small>
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:apply-templates/>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>
  <xsl:template match="tei:dimensions">
    <span>
      <xsl:call-template name="atts"/>
      <xsl:variable name="message">
        <xsl:call-template name="message">
          <xsl:with-param name="id">
            <xsl:value-of select="@type"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="$message != ''">
        <xsl:value-of select="translate(substring($message, 1, 1), $lc, $uc)"/>
        <xsl:value-of select="substring($message, 2)"/>
        <xsl:text> : </xsl:text>
      </xsl:if>
      <xsl:for-each select="*">
        <xsl:apply-templates select="."/>
        <xsl:choose>
          <xsl:when test="position() =last()"/>
          <xsl:otherwise> x </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:if test="@unit">
        <xsl:text> </xsl:text>
        <xsl:value-of select="@unit"/>
      </xsl:if>
      <xsl:text>.</xsl:text>
    </span>
  </xsl:template>
  <xsl:template match="tei:layout">
    <div>
      <xsl:call-template name="atts"/>
      <xsl:choose>
        <xsl:when test="@columns and number(@columns) &gt; 1"> &lt;TODO&gt; </xsl:when>
        <xsl:when test="@ruledLines">
          <xsl:value-of select="@ruledLines"/>
          <xsl:text> </xsl:text>
          <xsl:call-template name="message">
            <xsl:with-param name="id">ruledLines</xsl:with-param>
          </xsl:call-template>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="@writtenLines"/>
          <xsl:call-template name="message">
            <xsl:with-param name="id">writtenLines</xsl:with-param>
          </xsl:call-template>
          <xsl:text>, </xsl:text>
        </xsl:when>
        <xsl:when test="@writtenLines">
          <xsl:value-of select="@writtenLines"/>
          <xsl:text> </xsl:text>
          <xsl:call-template name="message">
            <xsl:with-param name="id">lines</xsl:with-param>
          </xsl:call-template>
          <xsl:text>, </xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:variable name="text">
        <xsl:apply-templates/>
      </xsl:variable>
      <xsl:copy-of select="$text"/>
      <xsl:if test="translate(substring(normalize-space($text), string-length(normalize-space($text))), '.?!', '') != ''">.</xsl:if>
    </div>
  </xsl:template>
  <!-- Go throw -->
  <xsl:template match="tei:height | tei:width | tei:layoutDesc ">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:msIdentifier">
    <span>
      <xsl:call-template name="atts"/>
      <xsl:for-each select="*">
        <xsl:apply-templates select="."/>
        <xsl:choose>
          <xsl:when test="position() = last()">. </xsl:when>
          <xsl:otherwise>
            <xsl:text>, </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </span>
  </xsl:template>
  <!-- Indication du témoin édité (mention "D'après...") -->
  <xsl:template match="tei:witness[@ana='edited']" mode="according">
    <div class="according">
      <xsl:text>D'après </xsl:text>
      <xsl:value-of select="@n"/>
      <xsl:text>.</xsl:text>
    </div>
  </xsl:template>
  <!-- Affichage de n° de témoin -->
  <xsl:template match="tei:witness" mode="a">
    <a class="wit">
      <xsl:attribute name="href">
        <xsl:call-template name="href"/>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="tei:label">
          <xsl:apply-templates select="tei:label/node()"/>
        </xsl:when>
        <xsl:when test="@n">
          <xsl:value-of select="@n"/>
        </xsl:when>
        <xsl:when test="@xml:id">
          <xsl:value-of select="@xml:id"/>
        </xsl:when>
      </xsl:choose>
    </a>
  </xsl:template>
  <!-- Lien vers un groupe de témoins -->
  <xsl:template match="tei:listWit" mode="a">
    <a class="wit">
      <xsl:attribute name="href">
        <xsl:call-template name="href"/>
      </xsl:attribute>
      <xsl:for-each select="tei:witness">
        <xsl:variable name="label">
          <xsl:apply-templates select="."/>
        </xsl:variable>
        <xsl:value-of select="$label"/>
        <xsl:choose>
          <xsl:when test="position() = last()">.</xsl:when>
          <xsl:otherwise>, </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </a>
  </xsl:template>
  <!--
Elements block or inline level
   -->
  <xsl:template match="tei:listBibl/tei:bibl">
    <li>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  <xsl:template match="tei:bibl | tei:gloss | tei:label | tei:q | tei:quote | tei:said | tei:stage">
    <xsl:variable name="mixed" select="../text()[normalize-space(.) != '']"/>
    <xsl:choose>
      <xsl:when test="normalize-space(.) = ''">
        <xsl:apply-templates/>
      </xsl:when>
      <!-- inside mixed content, or line formatted text (? or tei:lb or ../tei:lb), should be inline -->
      <xsl:when test="$mixed or parent::tei:p or parent::tei:s  or parent::tei:label">
        <xsl:call-template name="span">
          <xsl:with-param name="el">
            <xsl:choose>
              <xsl:when test="self::tei:gloss">dfn</xsl:when>
              <xsl:when test="self::tei:label">b</xsl:when>
              <xsl:when test="self::tei:stage">em</xsl:when>
              <xsl:when test="self::tei:q">q</xsl:when>
              <xsl:when test="self::tei:quote">q</xsl:when>
              <xsl:when test="self::tei:said">q</xsl:when>
              <xsl:otherwise>span</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@corresp and contains(@type, 'embed') and $format != $epub2">
        <figure>
          <xsl:call-template name="atts">
            <xsl:with-param name="class">corresp</xsl:with-param>
          </xsl:call-template>
          <figcaption>
            <xsl:call-template name="atts"/>
            <xsl:attribute name="xml:base">
              <xsl:value-of select="@corresp"/>
            </xsl:attribute>
            <xsl:apply-templates/>
          </figcaption>
        </figure>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="el">
          <xsl:choose>
            <xsl:when test="self::tei:label and parent::tei:figure">div</xsl:when>
            <xsl:when test="self::tei:label">p</xsl:when>
            <xsl:when test="self::tei:quote">blockquote</xsl:when>
            <xsl:otherwise>div</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
          <xsl:call-template name="atts">
            <xsl:with-param name="class">
              <xsl:value-of select="local-name()"/>
              <!-- modify rendering when contain verses -->
              <xsl:if test="tei:l"> l</xsl:if>
              <xsl:if test="tei:lg"> lg</xsl:if>
              <xsl:if test="@corresp"> corresp</xsl:if>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:cit">
    <xsl:variable name="mixed" select="../text()[normalize-space(.) != '']"/>
    <xsl:choose>
      <xsl:when test="$mixed">
        <span>
          <xsl:call-template name="atts"/>
          <xsl:for-each select="*">
            <xsl:if test="position() != 1">
              <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="div"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
<h3>Indexables</h3>
  -->
  <!-- kindle support @id & @title only on <em> (but no class !!)  -->
  <xsl:template match="tei:term">
    <xsl:choose>
      <xsl:when test=". = ''"/>
      <xsl:otherwise>
        <dfn>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </dfn>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Default, content from <index> is supposed to not be displayed -->
  <xsl:template match="tei:index"/>
  <!-- Termes with possible normal form -->
  <xsl:template match="tei:addName | tei:affiliation | tei:author | tei:authority | tei:country | tei:foreign | tei:forename | tei:genName | tei:geogFeat | tei:geogName | tei:name | tei:origPlace | tei:orgName | tei:persName | tei:placeName | tei:repository | tei:roleName | tei:rs | tei:settlement | tei:surname">
    <xsl:choose>
      <xsl:when test="@rend = 'margin'">
        <aside class="marginalia">
          <xsl:if test=". = '' and @key">
            <xsl:if test="@role != ''">
              <xsl:call-template name="message">
                <xsl:with-param name="id" select="@role"/>
              </xsl:call-template>
              <xsl:text> : </xsl:text>
            </xsl:if>
            <xsl:value-of select="@key"/>
          </xsl:if>
          <xsl:apply-templates/>
        </aside>
      </xsl:when>
      <xsl:when test="normalize-space(.) = ''">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="@ref or @xml:base">
        <a>
          <!-- linking policy will be resolved from the "linking" template, matched by @ref attribute -->
          <xsl:call-template name="atts"/>
          <!-- Make an exception here for @xml:base ? -->
          <xsl:choose>
            <xsl:when test="self::tei:persName">
              <xsl:attribute name="property">dbo:person</xsl:attribute>
            </xsl:when>
            <xsl:when test="self::tei:placeName">
              <xsl:attribute name="property">dbo:place</xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
<h2>Notes</h2>


<h3Footnotes</h3>

-->
  <!--
Call that in
  -->
  <xsl:template name="footnotes">
    <!-- children from which find notes -->
    <xsl:param name="cont" select="*"/>
    <!-- for notes by pages -->
    <xsl:param name="pb" select="$cont//tei:pb[@n][not(@ed)]"/>
    <!-- Handle on current node -->
    <xsl:variable name="current" select="."/>
    <xsl:variable name="notes">
      <xsl:if test="$app">
        <xsl:variable name="apparatus">
          <xsl:choose>
            <xsl:when test="$cont">
              <xsl:for-each select="$cont // tei:app">
                <xsl:call-template name="note-inline"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="$cont // tei:app">
                <xsl:call-template name="note-inline"/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="$apparatus != ''">
          <p class="apparatus">
            <xsl:copy-of select="$apparatus"/>
          </p>
        </xsl:if>
      </xsl:if>
      <!--
      <xsl:for-each select="$cont //tei:*[@rend='note']">
        <xsl:sort select="local-name()"/>
        <xsl:call-template name="fn"/>
      </xsl:for-each>
      -->
      <xsl:choose>
        <!-- Trop long ? $pb -->
        <xsl:when test=" $pb ">
          <!-- first notes before the first pb, a preceding:: axis was very slow  -->
          <xsl:variable name="notes1" select="key('note-pb', generate-id(/))"/>
          <xsl:if test="$notes1">
            <div class="page">
              <xsl:for-each select="$notes1[@resp = 'author'][not(@place = 'margin')]">
                <xsl:call-template name="note"/>
              </xsl:for-each>
              <xsl:for-each select="$notes1[@resp = 'editor'][not(@place = 'margin')]">
                <xsl:call-template name="note"/>
              </xsl:for-each>
              <xsl:for-each select="$notes1[not(@resp) or (@resp != 'editor' and @resp != 'author')][not(@place = 'margin')]">
                <xsl:call-template name="note"/>
              </xsl:for-each>
            </div>
          </xsl:if>
          <xsl:for-each select="$pb">
            <xsl:variable name="notes4page">
              <!-- notes abc ? @n and translate(@n, 'abcdefghijklmnopqrstuvwxyz-.', '') -->
              <xsl:for-each select="key('note-pb', generate-id())[@resp = 'author'][not(@place = 'margin')]">
                <!-- do not output notes for a page, outside from the <div> scope  -->
                <xsl:if test="ancestor::*[count(.|$current)=1]">
                  <xsl:call-template name="note"/>
                </xsl:if>
              </xsl:for-each>
              <xsl:for-each select="key('note-pb', generate-id())[@resp = 'editor'][not(@place = 'margin')]">
                <xsl:if test="ancestor::*[count(.|$current)=1]">
                  <xsl:call-template name="note"/>
                </xsl:if>
              </xsl:for-each>
              <xsl:for-each select="key('note-pb', generate-id())[not(@resp) or (@resp != 'editor' and @resp != 'author')][not(@place = 'margin')]">
                <xsl:if test="ancestor::*[count(.|$current)=1]">
                  <xsl:call-template name="note"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:if test="$notes4page != ''">
              <div class="page">
                <div class="b note-page">
                  <xsl:call-template name="a"/>
                </div>
                <xsl:copy-of select="$notes4page"/>
              </div>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <!-- handle notes by split sections ? -->
        <xsl:when test="$cont and function-available('exslt:node-set')">
          <xsl:apply-templates select="exslt:node-set($cont)" mode="fn">
            <xsl:with-param name="resp">author</xsl:with-param>
          </xsl:apply-templates>
          <xsl:apply-templates select="exslt:node-set($cont)" mode="fn">
            <xsl:with-param name="resp">editor</xsl:with-param>
          </xsl:apply-templates>
          <xsl:apply-templates select="exslt:node-set($cont)" mode="fn"/>
        </xsl:when>
        <!-- !! especially not efficient -->
        <xsl:when test="$cont">
          <xsl:for-each select="$cont //tei:note">
            <xsl:sort select="@place|@resp"/>
            <xsl:call-template name="fn"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="key('id', 'note-footseq')">
          <xsl:apply-templates select="*" mode="fn"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*" mode="fn">
            <xsl:with-param name="resp">author</xsl:with-param>
          </xsl:apply-templates>
          <xsl:apply-templates select="*" mode="fn">
            <xsl:with-param name="resp">editor</xsl:with-param>
          </xsl:apply-templates>
          <xsl:apply-templates select="*" mode="fn"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$notes != ''">
      <xsl:variable name="el">
        <xsl:choose>
          <xsl:when test="$format=$epub2">div</xsl:when>
          <xsl:otherwise>section</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
        <xsl:if test="$format = $epub3">
          <xsl:attribute name="epub:type">footnotes</xsl:attribute>
        </xsl:if>
        <xsl:attribute name="class">footnotes</xsl:attribute>
        <!--
        <hr class="footnotes" width="30%"/>
        -->
        <xsl:copy-of select="$notes"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  <!-- Inline view for apparatus note -->
  <xsl:template name="note-inline">
    <!-- identifiant de la note -->
    <xsl:variable name="id">
      <xsl:call-template name="id"/>
    </xsl:variable>
    <xsl:variable name="text">
      <xsl:for-each select="text()">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="html">
      <xsl:choose>
        <xsl:when test="$text='' and count(*)=1 and tei:p">
          <span class="note" id="{$id}">
            <xsl:if test="$format = $epub3">
              <xsl:attribute name="epub:type">note</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="noteback">
              <xsl:with-param name="class"/>
            </xsl:call-template>
            <xsl:text>, </xsl:text>
            <xsl:apply-templates select="*/node()"/>
          </span>
        </xsl:when>
        <xsl:when test="$text='' and *[1][self::tei:p]">
          <div class="note" id="{$id}">
            <p class="noindent">
              <xsl:call-template name="noteback"/>
              <xsl:apply-templates select="*[1]/node()"/>
            </p>
            <xsl:apply-templates select="*[position() &gt; 1]"/>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <span class="note" id="{$id}">
            <xsl:call-template name="noteback">
              <xsl:with-param name="class"/>
            </xsl:call-template>
            <xsl:apply-templates/>
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$html != ''">
      <xsl:copy-of select="$html"/>
      <!-- regarder si la ligne est déjà ponctuée avant d'ajouter un point -->
      <xsl:variable name="norm" select="normalize-space($html)"/>
      <xsl:variable name="last" select="substring($norm, string-length($norm))"/>
      <xsl:choose>
        <!-- block -->
        <xsl:when test="count(*) &gt; 1 and $text='' "/>
        <!-- Déja ponctué -->
        <xsl:when test="$last=',' or $last=';' or $last='.'">
          <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:otherwise>. </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  <!-- section de notes déjà inscrite dans la source -->
  <xsl:template match="tei:div[@type='notes' or @type='footnotes']">
    <xsl:variable name="el">
      <xsl:choose>
        <xsl:when test="$format=$epub2">div</xsl:when>
        <xsl:otherwise>section</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="class">footnotes</xsl:attribute>
      <xsl:attribute name="id">
        <xsl:call-template name="id"/>
      </xsl:attribute>
      <xsl:if test="$format = $epub3">
        <xsl:attribute name="epub:type">footnotes</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <!-- Note, ancre courante (sauf si enfant direct d'un div) -->
  <xsl:template match="tei:note | tei:*[@rend='note']">
    <xsl:choose>
      <xsl:when test="@place = 'margin'">
        <aside>
          <xsl:call-template name="atts"/>
          <xsl:attribute name="class">marginalia</xsl:attribute>
          <xsl:apply-templates/>
        </aside>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="noteref"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Note, appel sous forme de lien -->
  <xsl:template match="tei:ref[@type='note']">
    <xsl:call-template name="noteref"/>
  </xsl:template>
  <!-- Note, appel et lien vers le texte -->
  <xsl:template name="noteref">
    <xsl:param name="class">noteref</xsl:param>
    <xsl:variable name="id">
      <xsl:call-template name="id"/>
    </xsl:variable>
    <xsl:choose>
      <!-- In that case, links are already provided in the source -->
      <xsl:when test="parent::tei:seg[contains(@rendition, '#interval')]">
        <a id="{$id}_">&#x200c;</a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="n">
          <xsl:call-template name="note-n"/>
        </xsl:variable>
        <!-- TODO, multi cibles -->
        <xsl:variable name="target">
          <xsl:choose>
            <xsl:when test="@target">
              <xsl:value-of select="substring-before(concat(@target, ' '), ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="href">
                <xsl:with-param name="class" select="$class"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- FBRreader -->
        <a class="{$class}" href="{$target}" id="{$id}_">
          <xsl:if test="$format = $epub3">
            <xsl:attribute name="epub:type">noteref</xsl:attribute>
          </xsl:if>
          <sup>
            <xsl:value-of select="$n"/>
          </sup>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Display note number -->
  <xsl:template name="note-n">
    <xsl:variable name="resp" select="@resp"/>
    <xsl:variable name="hasformat" select="@rend != '' and boolean(translate(substring-before(concat(@rend, ' '), ' '), '1AaIi', '') = '')"/>
    <xsl:choose>
      <xsl:when test="@n">
        <xsl:value-of select="@n"/>
      </xsl:when>
      <!-- Renvoi à une note -->
      <xsl:when test="self::tei:ref[@type='note']">
        <xsl:for-each select="key('id', substring-after(@target, '#'))[1]">
          <xsl:call-template name="n"/>
        </xsl:for-each>
      </xsl:when>
      <!--
      <xsl:when test="self::tei:app">
        <xsl:number count="tei:app" format="a" level="any" from="*[key('split', generate-id())]"/>
      </xsl:when>
      note number by book, not by chapter
      <xsl:when test="$hasformat and ancestor::*[key('split', generate-id())] and $fnpage = ''">
        <xsl:number count="tei:note[@rend=$hasformat]" level="any" from="*[key('split', generate-id())]" format="{@rend}"/>
      </xsl:when>
      -->
      <xsl:when test="$hasformat">
        <xsl:number count="tei:note[@rend=$hasformat]" format="{@rend}" level="any" from="/"/>
      </xsl:when>
      <xsl:when test="@type='app'">
        <xsl:number count="tei:note[@type='app']" format="a" level="any" from="/"/>
      </xsl:when>
      <xsl:when test="@resp='editor'">
        <xsl:number count="tei:note[@resp=$resp]" format="I" level="any" from="/"/>
      </xsl:when>
      <xsl:when test="@resp">
        <xsl:number count="tei:note[@resp=$resp]" level="any" from="/"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:number count="tei:note[not(@resp) and not(@rend) and not(@place='margin') and not(parent::tei:div) and not(parent::tei:notesStmt)]" level="any" from="/"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Note, link to return to anchor -->
  <xsl:template name="noteback">
    <xsl:param name="class">noteback</xsl:param>
    <xsl:variable name="id">
      <xsl:call-template name="id"/>
    </xsl:variable>
    <a class="{$class}">
      <xsl:attribute name="href">
        <xsl:choose>
          <xsl:when test="@target">
            <xsl:value-of select="substring-before(concat(@target, ' '), ' ')"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Call a centralized note href template, for epub deported notes -->
            <xsl:call-template name="href">
              <xsl:with-param name="class">
                <xsl:value-of select="$class"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:text>_</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:call-template name="note-n"/>
      <xsl:if test="$class = 'noteback'">
        <xsl:text>. </xsl:text>
      </xsl:if>
    </a>
  </xsl:template>
  <!-- Note, texte, fonctionne pour note courante ou déportée -->
  <xsl:template name="note">
    <!-- identifiant de la note -->
    <xsl:variable name="id">
      <xsl:call-template name="id"/>
    </xsl:variable>
    <xsl:variable name="text">
      <xsl:for-each select="text()">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="element">
      <xsl:choose>
        <xsl:when test="$format = $epub2">div</xsl:when>
        <xsl:otherwise>aside</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$element}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="class">
        <xsl:value-of select="normalize-space(concat(@rend, ' ', @resp, ' ', @type, ' ', @place, ' note'))"/>
      </xsl:attribute>
      <xsl:attribute name="id">
        <xsl:value-of select="$id"/>
      </xsl:attribute>
      <xsl:if test="$format = $epub3">
        <xsl:attribute name="epub:type">note</xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$text='' and count(*)=1 and tei:p">
          <xsl:call-template name="noteback"/>
          <xsl:apply-templates select="*/node()"/>
        </xsl:when>
        <xsl:when test="$text='' and *[1][self::tei:p]">
          <p class="noindent">
            <xsl:call-template name="noteback"/>
            <xsl:apply-templates select="*[1]/node()"/>
          </p>
          <xsl:apply-templates select="*[position() &gt; 1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="noteback"/>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <!-- TOTEST
      <xsl:choose>
        <xsl:when test="@ana">
          <xsl:text> </xsl:text>
          <i>
            <xsl:value-of select="@ana"/>
          </i>
          <xsl:text>. </xsl:text>
        </xsl:when>
      </xsl:choose>
      -->
  </xsl:template>
  <!-- Mode app -->
  <xsl:template match="node()" mode="app" name="app">
    <xsl:choose>
      <xsl:when test="self::tei:app[@rend='table']"/>
      <!-- Variante, en note de bas de page -->
      <xsl:when test="self::tei:app">
        <span>
          <xsl:call-template name="atts"/>
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="tei:rdg | tei:note | tei:witDetail"/>
        </span>
      </xsl:when>
      <!-- Note normalisée pour ajout -->
      <xsl:when test="self::tei:supplied">
        <!-- Pas besoin de rappel pour note en contexte
        <xsl:choose>
          <xsl:when test="local-name(..)='w'">
            <xsl:apply-templates select=".." mode="title"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="title"/>
          </xsl:otherwise>
        </xsl:choose>
        -->
        <xsl:if test="@source">
          <xsl:text> </xsl:text>
          <i>
            <xsl:call-template name="anchors">
              <xsl:with-param name="anchors" select="@source"/>
            </xsl:call-template>
          </i>
        </xsl:if>
        <xsl:if test="@reason">
          <xsl:text> </xsl:text>
          <i>
            <xsl:call-template name="message">
              <xsl:with-param name="id" select="@reason"/>
            </xsl:call-template>
          </i>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="local-name(..)='w'">
            <xsl:text> [ </xsl:text>
            <xsl:apply-templates/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- Note normalisée pour correction -->
      <xsl:when test="self::tei:choice">
        <!-- pas de rappel de la forme corrigée
        <xsl:apply-templates select="tei:corr/node() | tei:expan/node() | tei:reg/node()"/>
        <xsl:text> </xsl:text>
        -->
        <xsl:choose>
          <xsl:when test="tei:corr/@source">
            <i>
              <xsl:call-template name="anchors">
                <xsl:with-param name="anchors" select="tei:corr/@source"/>
              </xsl:call-template>
            </i>
            <xsl:text> [ </xsl:text>
          </xsl:when>
          <xsl:otherwise> [ </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="tei:sic/node() | tei:abbr/node() | tei:orig/node()"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- Le template principal affichant des notes hors flux -->
  <xsl:template match="node()" mode="fn" name="fn">
    <xsl:param name="resp"/>
    <xsl:choose>
      <!-- not a note, go in  -->
      <xsl:when test="not(self::tei:note)">
        <xsl:apply-templates select="*" mode="fn">
          <xsl:with-param name="resp" select="$resp"/>
        </xsl:apply-templates>
      </xsl:when>
      <!-- do not output block notes -->
      <xsl:when test="parent::tei:app or parent::tei:back or parent::tei:div or parent::tei:div1 or parent::tei:div2 or parent::tei:div3 or parent::tei:front or parent::tei:notesStmt or parent::tei:sp"/>
      <xsl:when test="$resp= '' and not(@resp)">
        <xsl:call-template name="note"/>
      </xsl:when>
      <xsl:when test="@resp and @resp=$resp">
        <xsl:call-template name="note"/>
      </xsl:when>
      <!-- note other than author or editor -->
      <xsl:when test="$resp ='' and @resp and @resp != 'author'  and @resp != 'editor'">
        <xsl:call-template name="note"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- Citations numérotées, la référence apparaît en note de bas de page, une animation permet de la mettre en valeur -->
  <xsl:template match="tei:p//tei:cit[@n]">
    <span>
      <xsl:call-template name="atts">
        <xsl:with-param name="class">cit_n</xsl:with-param>
      </xsl:call-template>
      <xsl:for-each select="*">
        <xsl:choose>
          <xsl:when test="self::tei:bibl"/>
          <xsl:otherwise>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:variable name="id">
        <xsl:call-template name="id"/>
      </xsl:variable>
      <!-- FBRreader -->
      <sup>
        <a class="noteref" href="#{$id}" name="_{$id}">
          <xsl:if test="$format = $epub3">
            <xsl:attribute name="epub:type">noteref</xsl:attribute>
          </xsl:if>
          <!-- xsl:attribute name="onclick">if(this.cloc) {this.parentNode.className='cit_n'; this.cloc=null; } else { this.cloc=true;  this.parentNode.className='cit_n_bibl'}; return true;</xsl:attribute -->
          <xsl:attribute name="onmouseover">this.parentNode.className='cit_n_bibl'</xsl:attribute>
          <xsl:attribute name="onmouseout">this.parentNode.className='cit_n'</xsl:attribute>
          <xsl:value-of select="@n"/>
        </a>
      </sup>
      <span class="listBibl">
        <xsl:apply-templates select="tei:bibl"/>
      </span>
    </span>
  </xsl:template>
  <!-- Note sans appel -->
  <xsl:template match="tei:back/tei:note | tei:div/tei:note | tei:div0/tei:note | tei:div1/tei:note | tei:div2/tei:note | tei:div3/tei:note | tei:div4/tei:note | tei:front/tei:note | tei:sp/tei:note">
    <xsl:choose>
      <xsl:when test="not(tei:p|tei:div)">
        <p>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <div>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Note, texte, pour les notes déportée -->
  <xsl:template match="tei:div[@type='notes']/tei:note" priority="5">
    <xsl:call-template name="note"/>
  </xsl:template>
  <!--
<h3>Apparat critique</h3>
  -->
  <!-- Variante normale, traitement dynamique -->
  <xsl:template match="tei:app">
    <xsl:variable name="el">
      <xsl:choose>
        <xsl:when test="tei:p">div</xsl:when>
        <xsl:otherwise>span</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$el}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="id">
        <xsl:call-template name="id">
          <xsl:with-param name="suffix">_</xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:attribute name="class">app</xsl:attribute>
      <xsl:attribute name="onmouseover">this.className='apprdg'</xsl:attribute>
      <xsl:attribute name="onmouseout">if(!this.cloc) this.className='app'</xsl:attribute>
      <xsl:attribute name="onclick">if(this.cloc) {this.className='app'; this.cloc=null; } else { this.cloc=true; this.className='apprdg'}; return true;</xsl:attribute>
      <!-- ajouts et omissions -->
      <xsl:apply-templates select="tei:lem"/>
      <xsl:call-template name="noteref"/>
      <span class="rdgList">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="tei:rdg | tei:witDetail | tei:note"/>
        <xsl:text> </xsl:text>
      </span>
    </xsl:element>
  </xsl:template>
  <!-- version de base de la variante -->
  <xsl:template match="tei:lem">
    <xsl:variable name="prev" select="normalize-space(../preceding-sibling::node()[1])"/>
    <!-- généralement, un espace avant, sauf si apostrophe -->
    <xsl:if test="translate (substring($prev, string-length($prev)), concat($apos, '’'), '') != ''">
      <xsl:text> </xsl:text>
    </xsl:if>
    <span>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <!-- Autre leçon -->
  <xsl:template match="tei:rdg | tei:witDetail">
    <xsl:choose>
      <!-- même leçon que le précédent -->
      <xsl:when test=" . = preceding-sibling::tei:rdg">, </xsl:when>
      <xsl:when test="preceding-sibling::tei:rdg"> ; </xsl:when>
    </xsl:choose>
    <span>
      <xsl:call-template name="atts"/>
      <!-- si même leçon que la précédente, pas la pein de la copier -->
      <xsl:choose>
        <xsl:when test=". = preceding-sibling::tei:rdg"/>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="anchors"/>
      <xsl:choose>
        <!-- Mot clé, chercher un intitulé -->
        <xsl:when test="@cause and normalize-space(@cause) != ''">
          <xsl:text> </xsl:text>
          <i>
            <xsl:call-template name="message">
              <xsl:with-param name="id" select="@cause"/>
            </xsl:call-template>
          </i>
        </xsl:when>
        <!-- texte libre -->
        <xsl:when test="@hand|@place and normalize-space(@hand|@place) != ''">
          <xsl:text> </xsl:text>
          <i>
            <xsl:value-of select="@hand|@place"/>
          </i>
        </xsl:when>
        <!-- suivant identique, lui laisser l'intitulé automatique -->
        <xsl:when test=" . = following-sibling::tei:rdg"/>
        <!-- Rien en principal, c'est une addition -->
        <xsl:when test="../lem = ''">
          <xsl:text> </xsl:text>
          <i>
            <xsl:call-template name="message">
              <xsl:with-param name="id">add</xsl:with-param>
            </xsl:call-template>
          </i>
        </xsl:when>
        <!-- Rien à ajouter, c'est une omission -->
        <xsl:when test=". = ''">
          <xsl:text> </xsl:text>
          <i>
            <xsl:call-template name="message">
              <xsl:with-param name="id">omit</xsl:with-param>
            </xsl:call-template>
          </i>
        </xsl:when>
      </xsl:choose>
    </span>
  </xsl:template>
  <!-- abbréviation, avec possible forme normale -->
  <xsl:template match="tei:abbr">
    <abbr>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </abbr>
  </xsl:template>
  <!-- expansion signalée en cours de texte -->
  <xsl:template match="tei:expan">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  <!-- développement silencieux d’abréviation -->
  <xsl:template match="tei:ex">
    <ins>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </ins>
  </xsl:template>
  <!-- Texte ajouté -->
  <xsl:template match="tei:choice/tei:supplied">
    <ins>
      <xsl:choose>
        <xsl:when test="@source">
          <xsl:call-template name="atts">
            <xsl:with-param name="class">tipshow</xsl:with-param>
          </xsl:call-template>
          <!-- ??
          <small class="tip">
            <xsl:call-template name="fn"/>
          </small>
          -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="atts"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
    </ins>
  </xsl:template>
  <xsl:template match="tei:supplied">
    <xsl:choose>
      <xsl:when test="not(../tei:w)"/>
      <xsl:when test="preceding-sibling::*[1][self::tei:w]">
        <xsl:text> </xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:text>[</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  <!-- Specific BFM -->
  <xsl:template match="tei:surplus">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:template>
  <!-- @source pour attribut title -->
  <xsl:template match="@source" mode="title">
    <xsl:text> : </xsl:text>
    <xsl:call-template name="anchors">
      <xsl:with-param name="anchors" select="."/>
    </xsl:call-template>
  </xsl:template>
  <!-- @reason pour attribut title -->
  <xsl:template match="@reason" mode="title">
    <xsl:text>, </xsl:text>
    <xsl:value-of select="."/>
  </xsl:template>
  <!-- Insertions -->
  <xsl:template match="tei:add">
    <ins>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </ins>
  </xsl:template>
  <!-- Suppressions -->
  <xsl:template match="tei:del">
    <del>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
      <xsl:if test="@ana">
        <xsl:text> [</xsl:text>
        <xsl:call-template name="message">
          <xsl:with-param name="id" select="@ana"/>
        </xsl:call-template>
        <xsl:text>]</xsl:text>
      </xsl:if>
    </del>
  </xsl:template>
  <!-- Alternative, conserver les espacements (faut-il un conteneur ?) -->
  <xsl:template match="tei:choice|tei:subst">
    <xsl:choose>
      <xsl:when test="false()">
        <span>
          <xsl:call-template name="atts">
            <xsl:with-param name="class">tipshow</xsl:with-param>
          </xsl:call-template>
          <!-- ??
          <small class="tip">
            <xsl:call-template name="fn"/>
          </small>
          -->
          <xsl:apply-templates select="*"/>
        </span>
      </xsl:when>
      <xsl:when test="tei:orig and tei:reg">
        <span>
          <xsl:call-template name="atts"/>
          <xsl:attribute name="title">
            <xsl:if test="*/@source">
              <xsl:value-of select="*/@source"/>
              <xsl:text> : </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="tei:orig" mode="title"/>
          </xsl:attribute>
          <xsl:apply-templates select="tei:reg/node()"/>
        </span>
      </xsl:when>
      <xsl:when test="tei:sic and tei:corr">
        <span>
          <xsl:call-template name="atts"/>
          <xsl:attribute name="title">
            <xsl:if test="*/@source">
              <xsl:value-of select="*/@source"/>
              <xsl:text> : </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="tei:sic" mode="title"/>
          </xsl:attribute>
          <xsl:apply-templates select="tei:corr/node()"/>
        </span>
      </xsl:when>
      <xsl:when test="tei:add and tei:del">
        <span>
          <xsl:call-template name="atts"/>
          <xsl:attribute name="title">
            <xsl:if test="*/@source">
              <xsl:value-of select="*/@source"/>
              <xsl:text> : </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="tei:del" mode="title"/>
          </xsl:attribute>
          <xsl:apply-templates select="tei:add/node()"/>
        </span>
      </xsl:when>
      <xsl:when test="tei:abbr and tei:expan">
        <span>
          <xsl:call-template name="atts"/>
          <xsl:attribute name="title">
            <xsl:if test="*/@source">
              <xsl:value-of select="*/@source"/>
              <xsl:text> : </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="tei:abbr" mode="title"/>
          </xsl:attribute>
          <xsl:apply-templates select="tei:expan/node()"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span>
          <xsl:call-template name="atts"/>
          <xsl:apply-templates select="*"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Correction -->
  <xsl:template match="tei:choice/tei:corr | tei:reg | tei:choice[tei:abbr]/tei:expan">
    <ins>
      <xsl:call-template name="atts"/>
      <xsl:if test="preceding-sibling::*">
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
    </ins>
  </xsl:template>
  <xsl:template match="tei:choice/tei:sic | tei:choice/tei:abbr | tei:orig">
    <del>
      <xsl:call-template name="atts"/>
      <!-- Espace avant un mot ? attention si l'alternative est au milieu d'un mot -->
      <xsl:apply-templates/>
    </del>
  </xsl:template>
  <!-- (?) -->
  <xsl:template match="tei:interp">
    <span>
      <xsl:call-template name="atts"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="tei:unclear">
    <xsl:apply-templates/>
    <xsl:text> [?] </xsl:text>
  </xsl:template>
  <xsl:template match="tei:gap">
    <span class="gap">
      <xsl:attribute name="title">
        <xsl:call-template name="message">
          <xsl:with-param name="id">gap</xsl:with-param>
        </xsl:call-template>
        <xsl:if test="@extent">
          <xsl:text> : </xsl:text>
          <xsl:value-of select="@extent"/>
          <xsl:text> </xsl:text>
          <xsl:call-template name="message">
            <xsl:with-param name="id">chars</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="not(../tei:w)"/>
        <xsl:when test="preceding-sibling::*[1][self::tei:w]">
          <xsl:text> </xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:text>[</xsl:text>
      <xsl:choose>
        <xsl:when test="@extent and not(text())">
          <xsl:value-of select="substring('........................................................................................................', 1, @extent)"/>
        </xsl:when>
        <xsl:when test="@reason">
          <xsl:call-template name="message">
            <xsl:with-param name="id" select="@reason"/>
          </xsl:call-template>
          <xsl:if test="@unit">
            <xsl:text> </xsl:text>
            <xsl:value-of select="@unit"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test=". != ''">
          <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>…</xsl:otherwise>
      </xsl:choose>
      <xsl:text>]</xsl:text>
    </span>
  </xsl:template>
  <!-- Commentaire libre dans une note d'apparat critique. -->
  <xsl:template match="tei:app/tei:note">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- Dommage -->
  <xsl:template match="tei:damage">
    <span>
      <xsl:call-template name="atts"/>
      <xsl:text>[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
    </span>
  </xsl:template>
  <!-- Supposant que cela contient des espaces insécables -->
  <xsl:template match="tei:space">
    <xsl:choose>
      <xsl:when test="text() != ''">
        <span>
          <xsl:call-template name="atts"/>
          <xsl:value-of select="substring('                                 ', 1, string-length(.))"/>
        </span>
      </xsl:when>
      <xsl:when test="@extent">
        <span class="space" style="{@extent}"/>
      </xsl:when>
      <xsl:otherwise>
        <span style="width:2em;" class="space">    </span>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- Conteneur de variantes importantes -->
  <xsl:template match="tei:app[@rend='table']">
    <table>
      <xsl:call-template name="atts"/>
      <!-- afficher l'intitulé de witness -->
      <xsl:for-each select="*[. != '']">
        <xsl:variable name="pos">
          <xsl:number/>
        </xsl:variable>
        <th width="{floor(100 div count(../tei:rdg|../tei:lem))} %">
          <xsl:call-template name="anchors">
            <xsl:with-param name="att">wit</xsl:with-param>
          </xsl:call-template>
        </th>
      </xsl:for-each>
      <tr>
        <xsl:for-each select="*[. != '']">
          <td valign="top">
            <xsl:choose>
              <xsl:when test="position()=1">
                <xsl:call-template name="atts">
                  <xsl:with-param name="class">first</xsl:with-param>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="atts">
                  <xsl:with-param name="class">more</xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
          </td>
        </xsl:for-each>
      </tr>
    </table>
  </xsl:template>
  <!-- Boucler sur une liste d'ancre en attribut afin d'en afficher quelque chose -->
  <xsl:template name="anchors">
    <!-- nom de l'attribut sur lequel boucler (permet aussi d'adapter le comportement) -->
    <xsl:param name="att">wit</xsl:param>
    <!-- valeur initiale d'attribut à reprendre -->
    <xsl:param name="anchors" select="normalize-space(@*[name()=$att])"/>
    <xsl:variable name="id" select="
      substring-before(
          concat($anchors, ' ') , ' '
      )"/>
    <!-- le n° de témoin -->
    <xsl:choose>
      <!-- plus rien à afficher -->
      <xsl:when test="normalize-space($anchors) = ''"/>
      <!-- code qui n'est pas une ancre (serait-ce un lien ?) -->
      <xsl:when test="not(starts-with($anchors, '#'))">
        <xsl:text> </xsl:text>
        <i class="{$att}">
          <xsl:value-of select="$id"/>
        </i>
      </xsl:when>
      <!-- l'ancre répond, faire afficher un lien -->
      <xsl:when test="key('id', substring-after($id, '#'))">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="key('id', substring-after($id, '#'))" mode="a"/>
      </xsl:when>
      <!-- ancre absente dans le document -->
      <xsl:otherwise>
        <xsl:text> </xsl:text>
        <i class="{$att}">
          <xsl:value-of select="substring-after($id, '#')"/>
        </i>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:variable name="suivant" select="substring-after($anchors, ' ')"/>
    <xsl:if test="$suivant != ''">
      <xsl:text> </xsl:text>
      <xsl:call-template name="anchors">
        <xsl:with-param name="anchors" select="$suivant"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <!--
<h2>Modes</h2>

<p>
Un mode permet de parcourir l'arbre du document source afin d'en extraire
d'autres informations que le parcours par défaut. Dans le traitement de documents écrits,
les modes sont souvent utilisés pour extraire une table des matières, des index,
ou les notes qui courrent dans le texte. Nous utilisons aussi les modes pour des vues alternatives sur certains
noeuds, par exemple un identifiant, un titre court (label), ou un lien. Cette syntaxe permet
d'employer toute la souplesse de l'héritage et la surcharge en XSLT.
Il est apparu que certains processeurs XSLT (essentiellemen xsltproc) ont pu être peu performants
sur ces écritures, il en reste parfois des “modes” implémentés sous forme de templates nommés,
qui énumère des conditions sous forme d'une chaîne d'alternatives (choose/when+).
</p>
  -->
  <!--
Attributes

Centralize some html attribute policy, especially for id, and class
  -->
  <xsl:template name="atts">
    <!-- Add some html classes to the automatic ones -->
    <xsl:param name="class"/>
    <!-- Ddelegate class attribution to another template -->
    <xsl:call-template name="class">
      <xsl:with-param name="class" select="$class"/>
    </xsl:call-template>
    <!-- Shall we identify element ? -->
    <xsl:choose>
      <!--
      <xsl:when test="normalize-space(@id) != ''">
        <xsl:attribute name="id">
          <xsl:value-of select="translate(normalize-space(@id), ' ', '')"/>
        </xsl:attribute>
      </xsl:when>
      -->
      <xsl:when test="normalize-space(@xml:id) != ''">
        <xsl:attribute name="id">
          <xsl:value-of select="translate(normalize-space(@xml:id), ' ', '')"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="generate-id(..) = generate-id(/*/tei:text)">
        <xsl:attribute name="id">
          <xsl:call-template name="id"/>
        </xsl:attribute>
      </xsl:when>
    </xsl:choose>
    <!-- Process other know attributes -->
    <xsl:apply-templates select="@*"/>
  </xsl:template>
  <!-- Provide automatic classes from TEI names -->
  <xsl:template name="class">
    <xsl:param name="class"/>
    <!-- @rend may be used as a free text attribute, be careful -->
    <xsl:variable name="value">
      <!-- Name of the element (except from a list where TEI info will be redundant with HTML name) -->
      <xsl:if test="not(contains( ' abbr add cell code del eg emph hi item list q ref row seg table ' , concat(' ', local-name(), ' ')))">
        <xsl:value-of select="local-name()"/>
      </xsl:if>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@type"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@subtype"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@role"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@ana"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@evidence"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@place"/>
      <xsl:text> </xsl:text>
      <!-- lang is a useful class for some rendering (ex: greek fonts) -->
      <xsl:value-of select="@xml:lang"/>
      <xsl:text> </xsl:text>
      <!-- parameter value -->
      <xsl:value-of select="$class"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@rend"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="translate(@rendition, '#', '')"/>
    </xsl:variable>
    <xsl:variable name="norm" select="normalize-space($value)"/>
    <xsl:if test="$norm != ''">
      <xsl:attribute name="class">
        <xsl:value-of select="$norm"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  <!-- by default, do nothing on attribute -->
  <xsl:template match="tei:*/@*" priority="-2"/>
  <!-- Genererate html attributes from  à target attribute -->
  <xsl:template match="@ref | @target | @lemmaRef" name="linking">
    <xsl:param name="path" select="."/>
    <xsl:choose>
      <!-- Que faire avec witDetail/@target ? -->
      <xsl:when test="../@wit"/>
      <!-- Hide mail adress -->
      <xsl:when test="contains($path, '@')">
        <xsl:attribute name="href">#</xsl:attribute>
        <xsl:attribute name="onmouseover">
          <xsl:text>this.href='mailto:</xsl:text>
          <xsl:value-of select="substring-before($path, '@')"/>
          <xsl:text>'+'\x40'+'</xsl:text>
          <xsl:value-of select="substring-after($path, '@')"/>
          <xsl:text>'</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <!-- internal link, should point an existing element (maybe not) -->
      <xsl:when test="starts-with($path, '#') and key('id', substring($path, 2))">
        <xsl:for-each select="key('id', substring($path, 2))[1]">
          <xsl:attribute name="href">
            <xsl:call-template name="href"/>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:call-template name="href"/>
          </xsl:attribute>
        </xsl:for-each>
        <!-- perf mode href ? -->
      </xsl:when>
      <!-- internal link with no # -->
      <xsl:when test="key('id', $path)">
        <!-- perf mode href ? -->
        <xsl:for-each select="key('id', $path)[1]">
          <xsl:attribute name="href">
            <xsl:call-template name="href"/>
          </xsl:attribute>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="href">
          <xsl:value-of select="$path"/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- @id, @lang, réécriture de certains attributs standard pour xhtml -->
  <xsl:template match="@xml:lang | @xml:id">
    <xsl:variable name="id0"> '":,; </xsl:variable>
    <xsl:attribute name="{local-name(.)}">
      <xsl:value-of select="translate(., $id0, '')"/>
    </xsl:attribute>
  </xsl:template>
  <!-- @xml:*, attributs à recopier à l'identique -->
  <xsl:template match="@xml:base">
    <xsl:copy-of select="."/>
  </xsl:template>
  <!-- @html:*, copier les attributs xhtml -->
  <xsl:template match="@*[ namespace-uri(.) = 'http://www.w3.org/1999/xhtml']">
    <xsl:attribute name="{local-name(.)}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <!-- <html:*> Recopier tout ce qui est html -->
  <xsl:template match="html:*">
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
</xsl:transform>
