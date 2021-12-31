<?xml version="1.0" encoding="UTF-8"?>
<!-- 
<h1>TEI » epub : toc.ncx (tei_ncx.xsl)</h1>

© 2012, <a href="http://www.algone.net/">Algone</a>, licence  <a href="http://www.cecill.info/licences/Licence_CeCILL-C_V1-fr.html">CeCILL-C</a>/<a href="http://www.gnu.org/licenses/lgpl.html">LGPL</a>
<ul>
  <li>[FG] <a href="#" onmouseover="this.href='mailto'+'\x3A'+'glorieux'+'\x40'+'algone.net'">Frédéric Glorieux</a></li>
  <li>[VJ] <a href="#" onmouseover="this.href='mailto'+'\x3A'+'jolivet'+'\x40'+'algone.net'">Vincent Jolivet</a></li>
</ul>

-->
<xsl:transform 
  exclude-result-prefixes="tei ncx opf" 
  extension-element-prefixes="exslt" version="1.1" 
  xmlns="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:exslt="http://exslt.org/common" 
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  >
  <xsl:import href="../tei_common.xsl"/>
  <!-- ensure override on common -->
  <xsl:include href="epub.xsl"/>
  <xsl:output encoding="UTF-8" format-public="-//NISO//DTD ncx 2005-1//EN" format-system="http://www.daisy.org/z3986/2005/ncx-2005-1.dtd" indent="yes"/>
  <!-- Opf template, may contain spine items to add to the toc -->
  <xsl:param name="opf"/>
  <!-- This xsl -->
  <xsl:variable name="this">tei2ncx.xsl</xsl:variable>
  <xsl:template match="/">
    <ncx version="2005-1">
      <head>
        <meta content="{$identifier}" name="dtb:uid"/>
        <!--
        <meta name="dtb:depth" content="{$depth}"/>
        <xsl:param name="depth">
    <xsl:choose>
      <xsl:when test="/*/tei:teiHeader/tei:encodingDesc/tei:tagsDecl/tei:rendition[@xml:id='toc-depth']">
        <xsl:value-of select="/*/tei:teiHeader/tei:encodingDesc/tei:tagsDecl/tei:rendition[@xml:id='toc-depth']/@n"/>
      </xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:div1/tei:div2/tei:div3">3</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:div1/tei:div2">2</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:div1">1</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:div/tei:div/tei:div/tei:div/tei:div/tei:div">6</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:div/tei:div/tei:div/tei:div/tei:div">5</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:div/tei:div/tei:div/tei:div">4</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:div/tei:div/tei:div">3</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:div/tei:div">2</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:div">1</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:group/tei:group/tei:group/tei:group/tei:group/tei:group">6</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:group/tei:group/tei:group/tei:group/tei:group">5</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:group/tei:group/tei:group/tei:group">4</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:group/tei:group/tei:group">3</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:group/tei:group">2</xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:group">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
        -->
        <meta content="0" name="dtb:totalPageCount"/>
        <meta content="0" name="dtb:maxPageNumber"/>
      </head>
      <docTitle>
        <text>
          <xsl:value-of select="$doctitle"/>
        </text>
      </docTitle>
      <xsl:variable name="navMap">
        <navMap>
          <!-- Cover ? -->
          <xsl:choose>
            <xsl:when test="$cover">
              <navPoint id="cover" playOrder="1">
                <navLabel>
                  <text>
                    <xsl:call-template name="message">
                      <xsl:with-param name="id">cover</xsl:with-param>
                    </xsl:call-template>
                  </text>
                </navLabel>
                <content src="cover{$_html}"/>
              </navPoint>
              <navPoint id="titlePage" playOrder="2">
                <navLabel>
                  <text>
                    <xsl:call-template name="message">
                      <xsl:with-param name="id">titlePage</xsl:with-param>
                    </xsl:call-template>
                  </text>
                </navLabel>
                <content src="titlePage{$_html}"/>
              </navPoint>
            </xsl:when>
            <xsl:otherwise>
              <navPoint id="titlePage" playOrder="1">
                <navLabel>
                  <text>
                    <xsl:call-template name="message">
                      <xsl:with-param name="id">titlePage</xsl:with-param>
                    </xsl:call-template>
                  </text>
                </navLabel>
                <content src="titlePage{$_html}"/>
              </navPoint>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates mode="ncx" select="/*/tei:text/*">
            <xsl:with-param name="depth" select="3"/>
          </xsl:apply-templates>
          <xsl:if test="$fnpage != ''">
            <navPoint id="{$fnpage}">
              <navLabel>
                <text>
                  <xsl:call-template name="message">
                    <xsl:with-param name="id">notes</xsl:with-param>
                  </xsl:call-template>
                </text>
              </navLabel>
              <content src="{$fnpage}{$_html}"/>
            </navPoint>
          </xsl:if>
          <navPoint id="toc">
            <navLabel>
              <text>
                <xsl:call-template name="message">
                  <xsl:with-param name="id">toc</xsl:with-param>
                </xsl:call-template>
              </text>
            </navLabel>
            <content src="toc{$_html}"/>
          </navPoint>
          <!-- Loop on <spine> template to add to entry ? -->
          <xsl:if test="$opf != ''">
            <xsl:for-each select="document($opf)/opf:package/opf:spine/opf:itemref">
              <navPoint id="{@id|@idref}">
                <navLabel>
                  <text>
                    <xsl:choose>
                      <xsl:when test="processing-instruction('title')">
                        <xsl:value-of select="processing-instruction('title')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="translate(@idref, '_', ' ')"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </text>
                </navLabel>
                <content>
                  <xsl:attribute name="src">
                    <xsl:value-of select="key('opfid', @idref)/@href"/>
                  </xsl:attribute>
                </content>
              </navPoint>
            </xsl:for-each>
          </xsl:if>
        </navMap>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="function-available('exslt:node-set')">
          <!-- renumber navPoint -->
          <xsl:apply-templates mode="playOrder" select="exslt:node-set($navMap)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$navMap"/>
        </xsl:otherwise>
      </xsl:choose>
    </ncx>
  </xsl:template>
  <!-- Mode entré dans la nav, par défaut, arrêter -->
  <xsl:template match="*" mode="ncx"/>
  <xsl:template match="tei:TEICorpus" mode="ncx">
    <xsl:param name="depth"/>
    <xsl:apply-templates mode="ncx" select="*">
      <xsl:with-param name="depth" select="$depth"/>
    </xsl:apply-templates>
  </xsl:template>
  <xsl:template match="tei:TEI | tei:TEI.2" mode="ncx">
    <xsl:param name="depth"/>
    <xsl:apply-templates mode="ncx" select="tei:text">
      <xsl:with-param name="depth" select="$depth"/>
    </xsl:apply-templates>
  </xsl:template>
  <!-- traverser -->
  <xsl:template match="/*/tei:text" mode="ncx">
    <xsl:param name="depth"/>
    <xsl:apply-templates mode="ncx" select="*">
      <xsl:with-param name="depth" select="$depth"/>
    </xsl:apply-templates>
  </xsl:template>
  <!-- entry is always created  -->
  <xsl:template match="/*/tei:text/tei:front/tei:titlePage" mode="ncx"/>
  <xsl:template match="
    /*/tei:text/tei:front/*[self::tei:argument | self::tei:castList | self::tei:epilogue | self::tei:performance | self::tei:prologue | self::tei:set]
  | /*/tei:text/tei:back/*[self::tei:argument | self::tei:castList | self::tei:epilogue | self::tei:performance | self::tei:prologue | self::tei:set]
    " mode="ncx">
    <xsl:param name="depth"/>
    <xsl:call-template name="navPoint">
      <xsl:with-param name="depth" select="$depth - 1"/>
    </xsl:call-template>
  </xsl:template>
  <!-- section container -->
  <!--
  <xsl:template match="tei:back | tei:body | tei:front" mode="opf">
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="tei:p | tei:l | tei:list | tei:argument | tei:table | tei:docTitle | tei:docAuthor">
        <xsl:call-template name="item">
          <xsl:with-param name="type" select="$type"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="descendant::*[key('split', generate-id())]">
        <xsl:apply-templates select="tei:argument  | tei:div | tei:div0 | tei:div1 |  tei:castList | tei:epilogue | tei:performance | tei:prologue | tei:set | tei:titlePage" mode="opf">
          <xsl:with-param name="type" select="$type"/>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  -->
  <xsl:template match="tei:back | tei:body | tei:front" mode="ncx">
    <xsl:param name="depth"/>
    <xsl:variable name="children" select="(tei:div | tei:div0 | tei:div1 |  tei:castList | tei:epilogue | tei:performance | tei:prologue | tei:set )[normalize-space(.) != '']"/>
    <xsl:choose>
      <!-- No sections -->
      <xsl:when test="count($children) &lt; 1 and self::tei:body">
        <xsl:call-template name="navPoint"/>
      </xsl:when>
      <xsl:when test="normalize-space(.) = ''"/>
      <!-- La Vendetta -->
      <xsl:when test="count($children) = 1">
        <!-- take the root title if not found in child ? -->
        <xsl:variable name="title">
          <xsl:call-template name="title"/>
        </xsl:variable>
        <xsl:for-each select="$children">
          <xsl:choose>
            <xsl:when test="tei:head">
              <xsl:call-template name="navPoint">
                <xsl:with-param name="depth" select="0"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="navPoint">
                <xsl:with-param name="title" select="$title"/>
                <xsl:with-param name="depth" select="0"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>     
      <!-- simple content ? -->
      <xsl:when test="tei:p | tei:l | tei:list | tei:argument | tei:table | tei:docTitle | tei:docAuthor">
        <xsl:call-template name="navPoint">
          <xsl:with-param name="depth" select="0"/>
          <xsl:with-param name="title">
            <xsl:call-template name="title"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <!-- div content -->
      <xsl:when test="descendant::*[key('split', generate-id())]">
        <xsl:apply-templates select="tei:argument  | tei:div | tei:div0 | tei:div1 |  tei:castList | tei:epilogue | tei:performance | tei:prologue | tei:set | tei:titlePage[normalize-space(.) != '']" mode="ncx">
          <xsl:with-param name="depth" select="$depth - 1"/>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- Sections, split candidates -->
  <xsl:template match="
    tei:group |
    tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7 
" mode="ncx">
    <xsl:param name="depth" select="2"/>
    <xsl:call-template name="navPoint">
      <xsl:with-param name="depth" select="$depth - 1"/>
    </xsl:call-template>
  </xsl:template>
  <!-- Créer un point de nav -->
  <xsl:template name="navPoint">
    <xsl:param name="depth"/>
    <xsl:param name="id">
      <xsl:call-template name="id"/>
    </xsl:param>
    <xsl:param name="title">
      <xsl:call-template name="title"/>
    </xsl:param>
    <xsl:param name="href">
      <xsl:call-template name="href"/>
    </xsl:param>
    <navPoint>
      <xsl:attribute name="id">
        <xsl:value-of select="$id"/>
      </xsl:attribute>
      <xsl:attribute name="playOrder">
        <xsl:variable name="playOrder">
          <xsl:number count="tei:group | tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7 | /*/tei:text/tei:front/tei:argument " level="any"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$cover">
            <xsl:value-of select="$playOrder + 2"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- +1 for auto titlePage -->
            <xsl:value-of select="$playOrder + 1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <navLabel>
        <text>
          <xsl:value-of select="normalize-space($title)"/>
        </text>
      </navLabel>
      <content>
        <xsl:attribute name="src">
          <xsl:value-of select="$href"/>
        </xsl:attribute>
      </content>
      <xsl:if test="$depth &gt; 0">
        <xsl:apply-templates mode="ncx" select="tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7 | tei:argument[parent::tei:front]">
          <xsl:with-param name="depth" select="$depth"/>
        </xsl:apply-templates>
      </xsl:if>
    </navPoint>
  </xsl:template>
  <!-- Renuméroter la navigation -->
  <xsl:template match="node() | @*" mode="playOrder">
    <xsl:copy>
      <xsl:apply-templates mode="playOrder" select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  <!-- Always compute a sequential value for playOrder -->
  <xsl:template match="ncx:navPoint" mode="playOrder">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="playOrder">
        <xsl:number count="ncx:navPoint" level="any"/>
      </xsl:attribute>
      <xsl:apply-templates mode="playOrder"/>
    </xsl:copy>
  </xsl:template>
</xsl:transform>
