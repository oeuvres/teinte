<?xml version='1.0' encoding='UTF-8'?>
<xsl:transform exclude-result-prefixes="bml" version="1.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:bml="http://efele.net/2010/ns/bml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
  <xsl:key match="*[@id]" name="id" use="@id"/>
  <xsl:variable name="caps">ABCDEFGHIJKLMNOPQRSTUVWXYZÆŒÇÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝ</xsl:variable>
  <xsl:variable name="mins">abcdefghijklmnopqrstuvwxyzæœçàáâãäåèéêëìíîïòóôõöùúûüý</xsl:variable>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@id">
    <xsl:attribute name="xml:id">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="bml:l/@cont">
    <xsl:attribute name="part">
      <xsl:choose>
        <xsl:when test=". = 'true'">F</xsl:when>
        <xsl:otherwise>Y</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="bml:bml">
    <xsl:text disable-output-escaping="yes"><![CDATA[<?xml-stylesheet type="text/xsl" href="../teinte/tei2html.xsl"?>
<?xml-model href="http://oeuvres.github.io/teinte/teinte.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>
]]></xsl:text>
    <TEI xml:lang="fr">
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title>
              <xsl:apply-templates select="/bml:bml/bml:metadata/bml:electronique/bml:titre/node()"/>
            </title>
            <author>
              <xsl:attribute name="key">
                <xsl:value-of select="/bml:bml/bml:metadata/bml:monographie/bml:auteur/bml:nom-bibliographie"/>
                <xsl:text> (</xsl:text>
                <xsl:value-of select="/bml:bml/bml:metadata/bml:monographie/bml:auteur/bml:dates"/>
                <xsl:text>)</xsl:text>
              </xsl:attribute>
              <xsl:value-of select="/bml:bml/bml:metadata/bml:monographie/bml:auteur/bml:nom-couverture"/>
            </author>
          </titleStmt>
          <publicationStmt>
            <publisher>hurlus.fr</publisher>
          </publicationStmt>
          <sourceDesc>
            <bibl>
              <xsl:for-each select="/bml:bml/bml:metadata/bml:volume/bml:facsimile[@href]">
                <xsl:if test="position() != 1"><lb/></xsl:if>
                <ref>
                  <xsl:attribute name="target">
                    <xsl:value-of select="@href"/>
                  </xsl:attribute>
                  <xsl:value-of select="@href"/>
                </ref>
              </xsl:for-each>
            </bibl>
            <bibl>
              <ref>
                <xsl:attribute name="target">
                  <xsl:value-of select="/bml:bml/bml:metadata/bml:electronique/@identificateur"/>
                </xsl:attribute>
                <xsl:value-of select="/bml:bml/bml:metadata/bml:electronique/@identificateur"/>
              </ref>
            </bibl>
          </sourceDesc>
        </fileDesc>
        <profileDesc>
          <creation>
            <date>
              <xsl:attribute name="when">
                <xsl:value-of select="/bml:bml/bml:metadata/bml:monographie/bml:date"/>
              </xsl:attribute>
              <xsl:value-of select="/bml:bml/bml:metadata/bml:monographie/bml:date"/>
              </date>
          </creation>
          <langUsage>
            <language ident="fr"/>
          </langUsage>
        </profileDesc>
      </teiHeader>
      <text>
        <xsl:apply-templates select="bml:page-sequences"/>
      </text>
    </TEI>
  </xsl:template>
  <!-- <vsep xmlns="http://efele.net/2010/ns/bml" rend="threestars"/>
  
       | "emptyline" 
       | "fewlines"
       
       | "onestar" 
       | "threestars" 
       | "threestarsrow"
       
       | "dots" 
       | "rule"
       | "fullwidth-rule"
       | "tilderule"
       | "doublerule"
  -->
  <xsl:template match="bml:vsep">
    <xsl:choose>
      <xsl:when test="contains(@class, 'line')">
        <lb>
          <xsl:attribute name="type">line</xsl:attribute>
          <xsl:if test="@class != 'line' and @class != 'emptyline'">
            <xsl:attribute name="rend">
              <xsl:value-of select="@class"/>
            </xsl:attribute>
          </xsl:if>
        </lb>
      </xsl:when>
      <xsl:otherwise>
        <ab>
          <xsl:choose>
            <xsl:when test="@class = 'onestar'">
              <xsl:attribute name="type">dinkus</xsl:attribute>
              <xsl:text>*</xsl:text>
            </xsl:when>
            <xsl:when test="@class = 'threestars'">
              <xsl:attribute name="type">dinkus</xsl:attribute>
              <xsl:text>*</xsl:text>
              <lb/>
              <xsl:text>* *</xsl:text>
            </xsl:when>
            <xsl:when test="@class = 'threestarsrow'">
              <xsl:attribute name="type">dinkus</xsl:attribute>
              <xsl:text>* * *</xsl:text>
            </xsl:when>
            <xsl:when test="@class='rule' or @class = 'dots' or @class='doublerule' or @class='fullwidth-rule' or @class='tilderule'">
              <xsl:attribute name="type">rule</xsl:attribute>
              <xsl:attribute name="rend">
                <xsl:value-of select="@class"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="rend">center</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </ab>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="bml:page-sequences">
    <body>
      <xsl:apply-templates select="node()|@*"/>
    </body>
  </xsl:template>
  <xsl:template match="bml:page-sequence">
    <xsl:choose>
      <xsl:when test="count(bml:div) = 1">
        <xsl:apply-templates select="node()|@*"/>
      </xsl:when>
      <xsl:otherwise>
        <div>
          <xsl:apply-templates select="node()|@*"/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="bml:p">
    <p>
      <xsl:apply-templates select="node()|@*"/>
    </p>
  </xsl:template>
  <xsl:template match="bml:div">
    <div>
      <xsl:apply-templates select="node()|@*"/>
    </div>
  </xsl:template>
  <xsl:template match="bml:h1 | bml:h2  | bml:h3">
    <head>
      <xsl:apply-templates select="node()|@*"/>
    </head>
  </xsl:template>
  <xsl:template match="bml:h1/bml:b | bml:h2/bml:b  | bml:h3/bml:b | bml:h1/bml:s | bml:h2/bml:s  | bml:h3/bml:s ">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="bml:p/@class">
    <xsl:attribute name="rend">
      <xsl:choose>
        <xsl:when test=". = 'c'">center</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="bml:p/@class">
    <xsl:choose>
      <xsl:when test=". = 'c'">
        <xsl:attribute name="rend">center</xsl:attribute>
      </xsl:when>
      <xsl:when test=". = 'cont'">
        <xsl:attribute name="part">F</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="rend">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="bml:i">
    <emph>
      <xsl:apply-templates select="node()|@*"/>
    </emph>
  </xsl:template>
  <xsl:template match="bml:i/bml:r">
    <emph>
      <xsl:apply-templates select="node()|@*"/>
    </emph>
  </xsl:template>
  <xsl:template match="bml:sup">
    <hi rend="sup">
      <xsl:apply-templates select="node()|@*"/>
    </hi>
  </xsl:template>
  <xsl:template match="bml:s">
    <hi rend="sc">
      <xsl:apply-templates select="node()|@*"/>
    </hi>
  </xsl:template>
  <xsl:template match="bml:s/text()">
    <xsl:value-of select="translate(., $caps, $mins)"/>
  </xsl:template>
  <xsl:template match="bml:signature">
    <signed>
      <xsl:apply-templates select="node()|@*"/>
    </signed>
  </xsl:template>
  <xsl:template match="bml:epigraphe">
    <epigraph>
      <xsl:apply-templates select="node()|@*"/>
    </epigraph>
  </xsl:template>
  <xsl:template match="bml:salutation">
    <salute>
      <xsl:apply-templates select="node()|@*"/>
    </salute>
  </xsl:template>
  <xsl:template match="bml:date">
    <dateline>
      <xsl:apply-templates select="node()|@*"/>
    </dateline>
  </xsl:template>
  <xsl:template match="bml:letter">
    <figure>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="type">letter</xsl:attribute>
      <xsl:apply-templates/>
    </figure>
  </xsl:template>
  <xsl:template match="bml:letter/bml:h3">
    <head>
      <xsl:apply-templates select="node()|@*"/>
    </head>
  </xsl:template>
  <xsl:template match="bml:blockquote">
    <quote>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="bml:poem">
          <xsl:attribute name="type">poem</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
    </quote>
  </xsl:template>
  <xsl:template match="bml:poem">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="@class">
    <xsl:variable name="rend">
      <xsl:choose>
        <xsl:when test=". = 'smaller'"/>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$rend != ''">
      <xsl:attribute name="rend">
        <xsl:value-of select="$rend"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  <xsl:template match="bml:blockquote/bml:h3 | bml:poem/bml:h3">
    <label>
      <xsl:apply-templates select="node()|@*"/>
    </label>
  </xsl:template>
  <xsl:template match="bml:hstage">
    <label>
      <xsl:choose>
        <xsl:when test="bml:speaker">
          <xsl:attribute name="type">speaker</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="node()|@*"/>
    </label>
  </xsl:template>
  <xsl:template match="bml:speaker">
    <name>
      <xsl:apply-templates select="node()|@*"/>
    </name>
  </xsl:template>
  <xsl:template match="bml:pstage | bml:stage">
    <stage>
      <xsl:apply-templates select="node()|@*"/>
    </stage>
  </xsl:template>
  <xsl:template match="bml:l">
    <l>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="@indent = 1">
          <xsl:attribute name="rend">lmarg1</xsl:attribute>
        </xsl:when>
        <xsl:when test="@indent = 2">
          <xsl:attribute name="rend">lmarg2</xsl:attribute>
        </xsl:when>
        <xsl:when test="@indent = 3">
          <xsl:attribute name="rend">lmarg3</xsl:attribute>
        </xsl:when>
        <xsl:when test="@indent = 4">
          <xsl:attribute name="rend">lmarg4</xsl:attribute>
        </xsl:when>
        <xsl:when test="@indent">
          <space extent="{@indent} tabs">
            <xsl:value-of select="substring('                                                              ', 1, 4 * @indent)"/>
          </space>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
    </l>
  </xsl:template>
  <xsl:template match="bml:img">
    <figure>
      <graphic url="{@src}">
        <desc>
          <xsl:value-of select="@alt"/>
        </desc>
      </graphic>
    </figure>
  </xsl:template>
  <xsl:template match="bml:l/@indent"/>
  <xsl:template match="bml:lg">
    <lg>
      <xsl:apply-templates select="node()|@*"/>
    </lg>
  </xsl:template>
  <xsl:template match="bml:pagenum">
    <xsl:apply-templates/>
    <pb n="{@num}"/>
  </xsl:template>
  <xsl:template match="bml:correction">
    <!--
    <corr>
      <xsl:apply-templates select="node()|@*"/>
    </corr>
    -->
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="bml:correction/@original">
    <xsl:attribute name="n">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="bml:table">
    <table>
      <xsl:apply-templates select="node()|@*"/>
    </table>
  </xsl:template>
  <xsl:template match="bml:tbody">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="bml:tr">
    <row>
      <xsl:apply-templates select="node()|@*"/>
    </row>
  </xsl:template>
  <xsl:template match="bml:td">
    <cell>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="rend" select="normalize-space(concat(@text-align, ' ', @vertical-align))"/>
      <xsl:if test="$rend != ''">
        <xsl:attribute name="rend">
          <xsl:value-of select="$rend"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </cell>
  </xsl:template>
  <xsl:template match="@text-align | @vertical-align"/>
  <xsl:template match="@colspan">
    <xsl:attribute name="cols">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@rowspan">
    <xsl:attribute name="rows">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="bml:notes"/>
  <xsl:template match="bml:noteref">
    <note>
      <xsl:apply-templates select="key('id', @noteid)/node()"/>
    </note>
  </xsl:template>
</xsl:transform>
