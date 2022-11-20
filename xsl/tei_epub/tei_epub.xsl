<?xml version="1.0" encoding="UTF-8"?>
<!-- 

LGPL http://www.gnu.org/licenses/lgpl.html
© 2012–2013 frederic.glorieux@fictif.org
© 2013–2016 Université Paris-Sorbonne pour LABEX OBVIL, frederic.glorieux@fictif.org

Epub pilot for xhtml transformation

Kindle hacks
https://kdp.amazon.com/self-publishing/help?topicId=A1JPUWCSD6F59O
<p> : no @class, but @align
-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:opf="http://www.idpf.org/2007/opf" exclude-result-prefixes="epub html tei opf" extension-element-prefixes="">
  <!-- Use import to allow overriding -->
  <xsl:include href="../html/flow.xsl"/>
  <xsl:include href="../html/notes.xsl"/>
  <xsl:include href="../html/teiHeader.xsl"/>
  <xsl:include href="../html/toc.xsl"/>
  <!-- ensure override on common -->
  <xsl:include href="epub.xsl"/>
  <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
  <!-- Name of this xsl  -->
  <xsl:param name="this">tei2epub.xsl</xsl:param>
  <!-- output type modify behavior of tei_html.xsl -->
  <xsl:param name="format" select="$epub3"/>
  <!-- directory where to generate file, set by caller -->
  <xsl:param name="dstdir"/>
  <!-- link to the opf file to get the css links -->
  <xsl:param name="opf"/>
  <!-- Output some infos for debug -->
  <xsl:param name="debug"/>
  <xsl:template match="/">
    <report>
      <xsl:apply-templates select="/*/tei:text" mode="epub"/>
    </report>
  </xsl:template>
  <!-- default, stop all -->
  <xsl:template match="*" mode="epub"/>
  <!-- cross roots -->
  <xsl:template match="tei:TEI/tei:text | tei:TEI.2/tei:text" mode="epub">
    <xsl:param name="type"/>
    <xsl:if test="$cover">
      <xsl:call-template name="document">
        <!-- epub type -->
        <xsl:with-param name="type">cover</xsl:with-param>
        <xsl:with-param name="css">
@page{ margin:0;}
        </xsl:with-param>
        <xsl:with-param name="id">cover</xsl:with-param>
        <xsl:with-param name="title">
          <xsl:call-template name="message">
            <xsl:with-param name="id">cover</xsl:with-param>
          </xsl:call-template>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$doctitle"/>
        </xsl:with-param>
        <xsl:with-param name="content">
          <div id="cover" style="text-align: center; page-break-after: always;">
            <img src="{$cover}" alt="{$doctitle}" style="height: 100%; max-width: 100%;"/>
          </div>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <!-- Create a default titlePage, may be rewritten if another found -->
    <xsl:call-template name="document">
      <xsl:with-param name="id">
        <xsl:text>titlePage</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="title">
        <xsl:value-of select="$doctitle"/>
        <xsl:text> (</xsl:text>
        <xsl:call-template name="message">
          <xsl:with-param name="id">titlePage</xsl:with-param>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="content">
        <xsl:variable name="html">
          <xsl:choose>
            <xsl:when test="tei:front/tei:titlePage[normalize-space(.) != '']">
              <xsl:apply-templates select="tei:front/tei:titlePage"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="/*/tei:teiHeader"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$format = $epub2">
            <div class="titlePage">
              <xsl:copy-of select="$html"/>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <section epub:type="titlepage" class="titlePage">
              <xsl:copy-of select="$html"/>
            </section>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
    <!-- Create a toc -->
    <xsl:call-template name="document">
      <xsl:with-param name="id">
        <xsl:text>toc</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="title">
        <xsl:call-template name="message">
          <xsl:with-param name="id">toc</xsl:with-param>
        </xsl:call-template>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$doctitle"/>
      </xsl:with-param>
      <xsl:with-param name="content">
        <xsl:choose>
          <xsl:when test="$format = $epub2">
            <h1>
              <xsl:call-template name="message">
                <xsl:with-param name="id">toc</xsl:with-param>
              </xsl:call-template>
            </h1>
            <xsl:call-template name="toc"/>
          </xsl:when>
          <xsl:otherwise>
            <nav>
              <xsl:attribute name="epub:type">toc</xsl:attribute>
              <xsl:attribute name="id">toc</xsl:attribute>
              <h1>
                <xsl:call-template name="message">
                  <xsl:with-param name="id">toc</xsl:with-param>
                </xsl:call-template>
              </h1>
              <ol class="tree">
                <xsl:if test="$cover">
                  <li>
                    <a href="cover{$_html}">
                      <xsl:call-template name="message">
                        <xsl:with-param name="id">cover</xsl:with-param>
                      </xsl:call-template>
                    </a>
                  </li>
                </xsl:if>
                <li>
                  <a href="titlePage{$_html}">
                    <xsl:call-template name="message">
                      <xsl:with-param name="id">titlePage</xsl:with-param>
                    </xsl:call-template>
                  </a>
                </li>
                <xsl:apply-templates select="/*/tei:text/tei:front" mode="li"/>
                <xsl:apply-templates select="/*/tei:text/tei:body" mode="li"/>
                <xsl:apply-templates select="/*/tei:text/tei:group" mode="li"/>
                <xsl:apply-templates select="/*/tei:text/tei:back" mode="li"/>
                <xsl:if test="$fnpage != ''">
                  <li>
                    <a href="{$fnpage}{$_html}">Notes</a>
                  </li>
                </xsl:if>
                <!-- Loop on <spine> template ? -->
                <xsl:if test="$opf != ''">
                  <xsl:for-each select="document($opf)/opf:package/opf:spine/opf:itemref">
                    <li>
                      <a>
                        <xsl:attribute name="href">
                          <xsl:value-of select="key('opfid', @idref)/@href"/>
                        </xsl:attribute>
                        <xsl:choose>
                          <xsl:when test="processing-instruction('title')">
                            <xsl:value-of select="processing-instruction('title')"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="translate(@idref, '_', ' ')"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </a>
                    </li>
                  </xsl:for-each>
                </xsl:if>
              </ol>
            </nav>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="$fnpage != ''">
      <xsl:variable name="label">
        <xsl:call-template name="message">
          <xsl:with-param name="id">notes</xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:call-template name="document">
        <xsl:with-param name="id" select="$fnpage"/>
        <xsl:with-param name="title">
          <xsl:value-of select="$label"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$doctitle"/>
        </xsl:with-param>
        <xsl:with-param name="content">
          <h1>
            <xsl:copy-of select="$label"/>
          </h1>
          <xsl:call-template name="footnotes"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="tei:front | tei:group | tei:body | tei:back " mode="epub"/>
  </xsl:template>
  <!-- For some books, the front is short, no realt <div> -->
  
  <!-- title page and blurb entry -->
  <xsl:template mode="epub" match="
    /tei:TEI/tei:text/*[self::tei:front | self::tei:back]/*[self::tei:argument | self::tei:castList | self::tei:epilogue | self::tei:performance | self::tei:prologue | self::tei:set | self::tei:titlePage]">
    <xsl:if test="normalize-space(.) != ''">
      <xsl:call-template name="document"/>
    </xsl:if>
  </xsl:template>
  <!-- hierarchical titles <h[1-6]> with hierarchical context -->
  <xsl:template match="tei:head">
    <xsl:param name="level" select="count(ancestor::tei:*) - 2"/>
    <xsl:variable name="parent" select="translate(local-name(parent::*), '1234567890', '')"/>
    <xsl:choose>
      <!-- title of a block element, let imported stylesheet works -->
      <xsl:when test="$parent!='div' and $parent != 'group'">
        <xsl:apply-imports/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="name">
          <xsl:choose>
            <xsl:when test="parent::tei:front | parent::tei:text | parent::tei:back ">h1</xsl:when>
            <xsl:when test="$level &lt; 2">h1</xsl:when>
            <xsl:when test="$level &gt; 7">h6</xsl:when>
            <xsl:otherwise>h<xsl:value-of select="$level - 1"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="prev" select="preceding-sibling::tei:head"/>
        <!-- ancestors links, perf problems, not clear in interfaces
        <xsl:variable name="no">
          <xsl:number/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$prev"/>
          <xsl:when test="string-length(..) &lt; 4000"/>
          <xsl:when test="$no=1"/>
          <xsl:when test="count(ancestor::tei:*[tei:head]) &gt; 2">
            <ul class="menu ancestors">
              <xsl:for-each select="ancestor::tei:*[tei:head]">
                <li>
                  <xsl:call-template name="a"/>
                </li>
              </xsl:for-each>
            </ul>
          </xsl:when>
        </xsl:choose>
        -->
        <xsl:apply-templates select="tei:pb"/>
        <xsl:element name="{$name}" namespace="http://www.w3.org/1999/xhtml">
          <xsl:call-template name="atts"/>
          <xsl:apply-templates select="node()[local-name() != 'pb']"/>
        </xsl:element>
        <xsl:if test="not(following-sibling::tei:head)">
          <xsl:for-each select="parent::*[1]">
            <xsl:variable name="count" select="count(tei:group|tei:div|tei:div1|tei:div2|tei:div3|tei:div4|tei:div5|tei:div6)"/>
            <xsl:if test="$count &gt; 1 and $count &lt; 11">
              <div class="argument">
                <xsl:for-each select="tei:group|tei:div|tei:div1|tei:div2|tei:div3|tei:div4|tei:div5|tei:div6">
                  <xsl:if test="position() != 1"> — </xsl:if>
                  <xsl:call-template name="a"/>
                </xsl:for-each>
              </div>
            </xsl:if>
          </xsl:for-each>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- section container -->
  <xsl:template match="tei:back | tei:body | tei:front" mode="epub">
    <xsl:choose>
      <!-- simple content -->
      <xsl:when test="tei:p|tei:l|tei:list|tei:argument|tei:table|tei:docTitle|tei:docAuthor">
        <xsl:call-template name="document"/>
      </xsl:when>
      <!-- Sections, blocks will be lost -->
      <xsl:when test="descendant::*[key('split', generate-id())]">
        <xsl:apply-templates select="tei:argument  | tei:div | tei:div0 | tei:div1 |  tei:castList | tei:epilogue | tei:performance | tei:prologue | tei:set | tei:titlePage" mode="epub"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template> 
  <!-- Sections, candidates for split -->
  <xsl:template match=" tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7 | tei:group" mode="epub">
    <xsl:param name="type"/>
    <xsl:choose>
      <!-- there are children to split, so we should do something special with what is before (and also after)
          Is it a great idea to open a file/page for such division which could contain no more than a title ?      
      -->
      <xsl:when test="descendant::*[key('split', generate-id())]">
        <!-- take content before sections -->
        <xsl:variable name="before" select="generate-id(tei:group|tei:div|tei:div0|tei:div1|tei:div2|tei:div3|tei:div4|tei:div5|tei:div6)"/>
        <xsl:variable name="cont" select="tei:*[following-sibling::*[generate-id(.)=$before]]"/>
        <!-- TO synchronize with tei2opf.xsl -->
        <xsl:choose>
          <xsl:when test="(self::tei:front|self::tei:body|self::tei:back) and not(tei:p|tei:l|tei:list|tei:argument|tei:table)"/>
          <xsl:when test="$cont">
            <xsl:call-template name="document">
              <xsl:with-param name="content">
                <div>
                  <xsl:call-template name="atts"/>
                  <xsl:apply-templates select="$cont">
                    <xsl:with-param name="level" select="1"/>
                  </xsl:apply-templates>
                  <!-- TODO, notes by <pb> -->
                  <xsl:if test="$fnpage = ''">
                    <xsl:call-template name="footnotes">
                      <xsl:with-param name="cont" select="$cont"/>
                      <xsl:with-param name="pb"/>
                    </xsl:call-template>
                  </xsl:if>
                </div>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
        <xsl:apply-templates select=" tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7 " mode="epub"/>
        <!-- What about content after last section ? -->
      </xsl:when>
      <!-- Should be a leave with no children to split -->
      <xsl:otherwise>
        <xsl:if test="not(key('split', generate-id()))">
          <xsl:message>tei2epub.xsl, split problem for: <xsl:call-template name="id"/>, <xsl:call-template name="title"/></xsl:message>
        </xsl:if>
        <xsl:call-template name="document"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- 
file creation
param id allow to override the default mecanism for file name
  -->
  <xsl:template name="document">
    <xsl:param name="id"/>
    <xsl:param name="href">
      <xsl:value-of select="$dstdir"/>
      <xsl:choose>
        <xsl:when test="$id != ''">
          <xsl:value-of select="$id"/>
          <xsl:value-of select="$_html"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="href"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="title">
      <xsl:call-template name="titlebranch"/>
    </xsl:param>
    <xsl:param name="type">
      <xsl:choose>
        <xsl:when test="ancestor-or-self::tei:front">frontmatter</xsl:when>
        <xsl:when test="ancestor-or-self::tei:back">backmatter</xsl:when>
        <xsl:otherwise>bodymatter</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <!-- Un contenu généré par ailleurs -->
    <xsl:param name="content"/>
    <!-- Some css -->
    <xsl:param name="css"/>
    <xsl:variable name="message">
      <xsl:value-of select="$href"/>
      <xsl:text> : </xsl:text>
      <xsl:call-template name="idpath"/>
    </xsl:variable>
    <xsl:if test="$debug != ''">
      <xsl:message terminate="no">
        <xsl:value-of select="$message"/>
      </xsl:message>
    </xsl:if>
    <xsl:document href="{$href}" omit-xml-declaration="no" encoding="UTF-8" indent="yes">
      <xsl:choose>
        <xsl:when test="$format = $epub3">
          <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"></xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$lf"/>
      <html xml:lang="{$lang}" lang="{$lang}" xmlns:epub="http://www.idpf.org/2007/ops">
        <head>
          <meta charset="utf-8"/>
          <title>
            <xsl:value-of select="normalize-space($title)"/>
          </title>
          <xsl:choose>
            <xsl:when test="$opf != ''">
              <xsl:for-each select="document($opf)/opf:package/opf:manifest/opf:item[@media-type='text/css']">
                <link rel="stylesheet" type="text/css" href="{@href}"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <link rel="stylesheet" type="text/css" href="Styles/epub.css"/>
            </xsl:otherwise>
          </xsl:choose>
          <!-- ne marche plus dans les dernières Kobo
          <link rel="stylesheet" type="application/vnd.adobe-page-template+xml" href="style/ade.xpgt"/>
          TODO, de la css locale
          <xsl:if test="$corpusid != ''">
            <link rel="stylesheet" type="text/css" href="{$corpusid}.css"/>
          </xsl:if>
          -->
          <xsl:if test="$css != ''">
            <style type="text/css">
              <xsl:text> </xsl:text>
              <xsl:copy-of select="$css"/>
            </style>
          </xsl:if>
        </head>
        <body>
          <xsl:if test="$corpusid != ''">
            <xsl:attribute name="class">
              <xsl:value-of select="$corpusid"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="$content">
              <xsl:copy-of select="$content"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="."/>
              <xsl:if test="$fnpage = ''">
                <xsl:call-template name="footnotes"/>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </body>
      </html>
    </xsl:document>
  </xsl:template>
  <!-- No small-caps in ereader, for roman numbers like centuries -->
  <xsl:template match="tei:num/text()">
    <xsl:variable name="roman">ivxlcdm.- </xsl:variable>
    <xsl:choose>
      <xsl:when test="translate(., $roman, '')=''">
        <xsl:value-of select="translate(., $roman, 'IVXLCDM.- ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:speaker/text()">
    <xsl:value-of select="translate(., $lc, $uc)"/>
  </xsl:template>
  <!-- epub supposed to be read, no facs things like runing titles -->
  <xsl:template match="tei:fw"/>
  <xsl:template match="tei:g">
    <xsl:apply-templates/>
  </xsl:template>
</xsl:transform>
