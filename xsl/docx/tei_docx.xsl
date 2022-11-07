<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:import href="../tei_common.xsl"/>
  <xsl:param name="libreO"/>
  <xsl:param name="templPath"/>
  <!-- indent "no", needed for OOo -->
  <xsl:output encoding="UTF-8" indent="no" method="xml"/>
  <xsl:strip-space elements="tei:TEI tei:TEI.2 tei:body tei:castList tei:div tei:div1 tei:div2  tei:docDate tei:docImprint tei:docTitle tei:fileDesc tei:front tei:group tei:index tei:listWit tei:publicationStmp tei:publicationStmt tei:sourceDesc tei:SourceDesc tei:sources tei:text tei:teiHeader tei:text tei:titleStmt"/>
  <xsl:preserve-space elements="tei:l tei:s tei:p"/>
  <xsl:param name="filename">tei</xsl:param>
  <!-- 1: export <pb/>. Default: 1 -->
  <xsl:param name="pb" select="1"/>
  <xsl:variable name="lf" select="'&#10;'"/>
  <xsl:template match="/">
    <w:document xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" mc:Ignorable="w14 wp14">
      <w:body>
        <xsl:choose>
          <xsl:when test="$templPath != ''">
            <xsl:variable name="templ" select="document($templPath)"/>
            <xsl:apply-templates select="*"/>
            <xsl:copy-of select="$templ/w:document/w:body/w:sectPr"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="*"/>
          </xsl:otherwise>
        </xsl:choose>
      </w:body>
    </w:document>
  </xsl:template>
  <!-- traverser -->
  <xsl:template match="tei:body | tei:front  | tei:sp | tei:TEI | tei:text ">
    <xsl:apply-templates select="*|comment()"/>
  </xsl:template>
  <xsl:template match=" tei:div | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7" priority="0">
    <!-- Poems, insert a continuous section break, will restart numbering -->
    <xsl:if test="@type='poem'">
      <w:p>
        <w:pPr>
          <w:sectPr>
            <w:type w:val="continuous"/>
            <w:lnNumType w:countBy="5" w:restart="newSection"/>
            <!--
               w:rsidR="00C265AC" w:rsidRDefault="00C265AC" w:rsidP="00C265AC"
            <w:headerReference w:type="even" r:id="rId12"/>
            <w:headerReference w:type="default" r:id="rId13"/>
            <w:footerReference w:type="even" r:id="rId14"/>
            <w:footerReference w:type="default" r:id="rId15"/>
            <w:headerReference w:type="first" r:id="rId16"/>
            <w:footerReference w:type="first" r:id="rId17"/>
            <w:pgSz w:w="11906" w:h="16838"/>
            <w:pgMar w:top="1418" w:right="1418" w:bottom="1418" w:left="1418" w:header="0" w:footer="0" w:gutter="0"/>
            <w:lnNumType w:countBy="5" w:restart="newSection"/>
            <w:cols w:space="720"/>
            <w:formProt w:val="0"/>
            <w:docGrid w:linePitch="360" w:charSpace="-6145"/>
            -->
          </w:sectPr>
        </w:pPr>
      </w:p>
    </xsl:if>
    <xsl:if test="local-name(*[not(self::tei:index|self::tei:pb)][1]) != 'head'">
      <w:p>
        <w:pPr>
          <w:pStyle w:val="Titre{count(ancestor-or-self::tei:div)}"/>
        </w:pPr>
        <xsl:call-template name="anchor"/>
        <w:r>
          <w:t>
            <xsl:attribute name="xml:space">preserve</xsl:attribute>
            <xsl:text>[</xsl:text>
            <xsl:choose>
              <xsl:when test="@xml:id">
                <xsl:value-of select="@xml:id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="text">
                  <xsl:apply-templates select="*[not(self::tei:index|self::tei:pb)][1]" mode="text"/>
                </xsl:variable>
                <xsl:value-of select="substring(normalize-space($text), 0, 50)"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text>]</xsl:text>
          </w:t>
        </w:r>
      </w:p>
    </xsl:if>
    <xsl:comment> <xsl:value-of select="@xml:id"/> </xsl:comment>
    <xsl:apply-templates select="*|comment()"/>
  </xsl:template>
  <xsl:template mode="text" match="tei:note"/>
  <!-- Metadata 
   Fields handled by Odette ,author,bibl,created,creation,contributor,copyeditor,creator,date,edition,editor,idno,issued,keyword,licence,license,publie,publisher,secretairederedaction,source,subject,sujet,title,translator,
  -->
  <xsl:template match="tei:teiHeader">
    <xsl:apply-templates select="*|comment()"/>
  </xsl:template>
  <xsl:template match="tei:teiHeader/*"/>
  <xsl:template match="tei:teiHeader/tei:fileDesc">
    <xsl:apply-templates select="*|comment()"/>
  </xsl:template>
  <xsl:template match="tei:fileDesc/*" priority="-1"/>
  <xsl:template match="tei:fileDesc/tei:titleStmt">
    <xsl:apply-templates select="*|comment()"/>
  </xsl:template>
  <xsl:template match="tei:fileDesc/tei:titleStmt/*" priority="-1"/>
  <xsl:template match="tei:fileDesc/tei:titleStmt/tei:title">
    <xsl:call-template name="term">
      <xsl:with-param name="key">title</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:fileDesc/tei:titleStmt/tei:author">
    <xsl:call-template name="term">
      <xsl:with-param name="key">creator</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:fileDesc/tei:titleStmt/tei:editor">
    <xsl:call-template name="term">
      <xsl:with-param name="key">editor</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:editionStmt">
    <xsl:apply-templates select="*|comment()"/>
  </xsl:template>
  <xsl:template match="tei:editionStmt/*" priority="-1"/>
  <xsl:template match="tei:editionStmt/tei:respStmt">
    <xsl:call-template name="term">
      <xsl:with-param name="key">copyeditor</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:publicationStmt">
    <xsl:apply-templates select="*|comment()"/>
  </xsl:template>
  <xsl:template match="tei:publicationStmt/*" priority="-1"/>
  <xsl:template match="tei:publicationStmt/tei:publisher">
    <xsl:call-template name="term">
      <xsl:with-param name="key">publisher</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:call-template name="term">
      <xsl:with-param name="key">issued</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:publicationStmt/tei:idno">
    <xsl:call-template name="term">
      <xsl:with-param name="key">idno</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:availability"/>
  <xsl:template match="tei:sourceDesc">
    <xsl:apply-templates select="*|comment()"/>
  </xsl:template>
  <xsl:template match="tei:sourceDesc/*" priority="-1"/>
  <xsl:template match="tei:sourceDesc/tei:bibl">
    <xsl:call-template name="term">
      <xsl:with-param name="key">source</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:profileDesc">
    <xsl:apply-templates select="*|comment()"/>
  </xsl:template>
  <xsl:template match="tei:profileDesc/*" priority="-1"/>
  <xsl:template match="tei:profileDesc/tei:creation">
    <xsl:apply-templates select="tei:date"/>
  </xsl:template>
  <xsl:template match="tei:profileDesc/tei:creation/tei:date">
    <xsl:call-template name="term">
      <xsl:with-param name="key">created</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:profileDesc/tei:langUsage">
    <xsl:apply-templates select="tei:language"/>
  </xsl:template>
  <xsl:template match="tei:language">
    <xsl:call-template name="term">
      <xsl:with-param name="key">language</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:profileDesc/tei:textClass">
    <xsl:apply-templates select="tei:keywords"/>
  </xsl:template>
  <xsl:template match="tei:profileDesc/tei:textClass/tei:keywords">
    <xsl:apply-templates select="tei:term"/>
  </xsl:template>
  <xsl:template match="tei:textClass/tei:keywords/tei:term">
    <xsl:call-template name="term">
      <xsl:with-param name="key">subject</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template name="term">
    <xsl:param name="key">Key</xsl:param>
    <xsl:value-of select="$lf"/>
    <w:p>
      <w:pPr>
        <xsl:variable name="style">
          <xsl:choose>
            <xsl:when test="$libreO != ''">Term</xsl:when>
            <xsl:otherwise>term</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <w:pStyle w:val="{$style}"/>
      </w:pPr>
      <w:r>
        <w:t xml:space="preserve"><xsl:value-of select="$key"/> : </w:t>
      </w:r>
      <xsl:choose>
        <xsl:when test="@when">
          <w:r>
            <w:t>
              <xsl:value-of select="@when"/>
            </w:t>
          </w:r>
        </xsl:when>
        <xsl:when test="@notAfter|@notBefore">
          <w:r>
            <w:t>
              <xsl:value-of select="@notAfter"/>
              <xsl:text>-</xsl:text>
              <xsl:value-of select="@notBefore"/>
            </w:t>
          </w:r>
        </xsl:when>
        <xsl:when test="@ident">
          <w:r>
            <w:t>
              <xsl:value-of select="@ident"/>
            </w:t>
          </w:r>
        </xsl:when>
        <xsl:when test="@key">
          <w:r>
            <w:t>
              <xsl:value-of select="@key"/>
            </w:t>
          </w:r>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="char"/>
        </xsl:otherwise>
      </xsl:choose>
    </w:p>
  </xsl:template>
  <!-- Pas de mise en forme -->
  <xsl:template match="tei:s">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- Conserver les identifiants -->
  <xsl:template name="anchor">
    <xsl:param name="id" select="@xml:id"/>
    <xsl:choose>
      <xsl:when test="normalize-space($id) != ''">
        <w:bookmarkStart w:name="{$id}">
          <xsl:attribute name="w:id">
            <xsl:number count="node()" level="any"/>
          </xsl:attribute>
        </w:bookmarkStart>
        <w:bookmarkEnd>
          <xsl:attribute name="w:id">
            <xsl:number count="node()" level="any"/>
          </xsl:attribute>
        </w:bookmarkEnd>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:head[@type='kicker']"/>
  <xsl:template match="tei:head" name="head">
    <xsl:variable name="style">
      <xsl:choose>
        <!-- subtitle -->
        <xsl:when test="preceding-sibling::tei:head[not(@type) or @type!='kicker']">Titre</xsl:when>
        <xsl:when test="parent::tei:body | parent::tei:front | parent::tei:back">Titreprincipal</xsl:when>
        <xsl:when test="parent::tei:div1">Titre1</xsl:when>
        <xsl:when test="parent::tei:div2">Titre2</xsl:when>
        <xsl:when test="parent::tei:div3">Titre3</xsl:when>
        <xsl:when test="parent::tei:div">
          <xsl:text>Titre</xsl:text>
          <xsl:value-of select="count(ancestor::tei:div)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <w:p>
      <w:pPr>
        <w:pStyle w:val="{$style}"/>
      </w:pPr>
      <xsl:call-template name="anchor"/>
      <xsl:for-each select="preceding-sibling::tei:head[@type='kicker']">
        <xsl:call-template name="char"/>
        <w:r>
          <w:t>
            <xsl:call-template name="head-pun"/>
          </w:t>
        </w:r>
        <xsl:value-of select="$lf"/>
        <w:r>
          <w:br/>
        </w:r>
      </xsl:for-each>
      <xsl:call-template name="char"/>
    </w:p>
    <!--
    <xsl:if test="../tei:index and not(preceding-sibling::tei:head)">
      <w:p>
        <w:r>
          <xsl:apply-templates select="../tei:index"/>
        </w:r>
      </w:p>
    </xsl:if>
    <xsl:apply-templates select="preceding-sibling::*[self::tei:index|self::tei:pb]"/>
    -->
  </xsl:template>
  <xsl:template match="tei:table">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <w:tbl>
      <w:tblPr>
        <w:tblStyle w:val="Grilledutableau"/>
        <w:tblW w:type="auto" w:w="0"/>
        <w:tblLook w:firstColumn="1" w:firstRow="1" w:lastColumn="0" w:lastRow="0" w:noHBand="0" w:noVBand="1" w:val="04A0"/>
      </w:tblPr>
      <w:tblGrid>
        <xsl:for-each select="tei:row[1]/tei:cell">
          <w:gridCol/>
        </xsl:for-each>
      </w:tblGrid>
      <xsl:apply-templates select="tei:row"/>
    </w:tbl>
  </xsl:template>
  <xsl:template match="tei:row">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <w:tr>
      <xsl:apply-templates select="tei:cell"/>
    </w:tr>
  </xsl:template>
  <xsl:template match="tei:cell">
    <xsl:value-of select="$lf"/>
    <w:tc>
      <xsl:choose>
        <xsl:when test="not(tei:p) and not(tei:list) and not(tei:quote) and not(tei:l)">
          <xsl:call-template name="par"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </w:tc>
  </xsl:template>
  <!-- Éléments regroupants -->
  <xsl:template match="tei:titlePage">
    <w:p/>
    <w:p/>
    <xsl:apply-templates select="*">
      <xsl:with-param name="border" select="true()"/>
    </xsl:apply-templates>
    <w:p/>
    <w:p/>
  </xsl:template>
  <xsl:template match="tei:argument | tei:cit | tei:entryFree[tei:p|tei:sense] | tei:postscript | tei:docTitle">
    <xsl:for-each select="*">
      <xsl:variable name="id">
        <xsl:if test="position() = 1 and @xml:id">
          <xsl:value-of select="@xml:id"/>
        </xsl:if>
      </xsl:variable>
      <xsl:call-template name="par">
        <xsl:with-param name="border" select="true()"/>
        <xsl:with-param name="parent" select="local-name(..)"/>
        <xsl:with-param name="id" select="$id"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="tei:epigraph">
    <!-- pb avec epigraph/cit/quote/p -->
    <xsl:for-each select=".//tei:p | .//tei:bibl">
      <xsl:value-of select="$lf"/>
      <w:p>
        <w:pPr>
          <xsl:variable name="style">
            <xsl:choose>
              <xsl:when test="$libreO != ''">Epigraph</xsl:when>
              <xsl:otherwise>epigraph</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <w:pStyle w:val="{$style}"/>
          <xsl:if test="self::tei:bibl">
            <w:jc w:val="right"/>
          </xsl:if>
        </w:pPr>
        <xsl:call-template name="anchor"/>
        <xsl:call-template name="char"/>
      </w:p>
    </xsl:for-each>
    <xsl:call-template name="vspace"/>
  </xsl:template>
  <xsl:template match="tei:closer | tei:opener | tei:q | tei:quote">
    <xsl:param name="border">
      <xsl:choose>
        <xsl:when test="self::tei:q ">border</xsl:when>
      </xsl:choose>
    </xsl:param>
    <xsl:variable name="inmix" select="../text()[normalize-space(.) != '']|../tei:emph|../tei:hi"/>
    <xsl:choose>
      <!-- conteneur de blocs -->
      <xsl:when test=" tei:byline | tei:closer | tei:dateline | tei:l | tei:label | tei:lg | tei:opener | tei:p | tei:salute | tei:signed  ">
        <xsl:apply-templates select="*">
          <xsl:with-param name="border" select="$border"/>
          <xsl:with-param name="parent" select="local-name(.)"/>
        </xsl:apply-templates>
      </xsl:when>
      <!-- 
ancestor::tei:p or ancestor::tei:l or parent::tei:cell
      -->
      <!-- bloc -->
      <xsl:when test="parent::tei:back | parent::tei:body | parent::tei:cell | parent::tei:div | parent::tei:div1 | parent::tei:div2 | parent::tei:div3 | parent::tei:div4 | parent::tei:div5 | parent::tei:div6 | parent::tei:div7 | parent::tei:div8 | parent::tei:div9 | parent::tei:front">
        <xsl:call-template name="par"/>
      </xsl:when>
      <!-- inline -->
      <xsl:otherwise>
        <xsl:call-template name="char">
          <xsl:with-param name="style">
            <xsl:choose>
              <xsl:when test="self::tei:quote">quote-c</xsl:when>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Elements known as pure block/para -->
  <xsl:template match=" tei:ab | tei:back/* | tei:body/* | tei:byline | tei:dateline | tei:div/* | tei:div1/* | tei:div2/* | tei:div3/* | tei:div4/* | tei:front/* | tei:label | tei:p  | tei:salute | tei:signed | tei:sp/* | tei:titlePage/* | tei:titlePart" name="par" priority="-1">
    <xsl:param name="parent"/>
    <xsl:param name="border"/>
    <xsl:param name="fill"/>
    <xsl:param name="style">
      <xsl:choose>
        <xsl:when test="$libreO">
          <xsl:choose>
            <xsl:when test="self::tei:p and parent::tei:note">Notedebasdepage</xsl:when>
            <xsl:when test="self::tei:p and parent::tei:quote">Quote</xsl:when>
            <xsl:when test="self::tei:p and parent::tei:sp">Sp</xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="translate(substring(local-name(), 1, 1), $lc, $uc)"/>
              <xsl:value-of select="substring(local-name(), 2)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="self::tei:p and parent::tei:note">Notedebasdepage</xsl:when>
            <xsl:when test="self::tei:p and parent::tei:quote">quote</xsl:when>
            <xsl:when test="self::tei:p and parent::tei:sp">sp</xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="local-name()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="rend"/>
    <xsl:value-of select="$lf"/>
    <w:p>
      <w:pPr>
        <xsl:if test="$style != ''">
          <w:pStyle w:val="{$style}"/>
        </xsl:if>
        <xsl:if test="$border != ''">
          <w:pBdr>
            <w:top w:color="auto" w:space="6" w:sz="2" w:val="single"/>
            <w:left w:color="auto" w:space="6" w:sz="2" w:val="single"/>
            <w:bottom w:color="auto" w:space="6" w:sz="2" w:val="single"/>
            <w:right w:color="auto" w:space="6" w:sz="2" w:val="single"/>
          </w:pBdr>
        </xsl:if>
        <xsl:if test="$fill != ''">
          <w:pBdr>
            <w:top w:color="auto" w:space="5" w:sz="2" w:val="none"/>
            <w:left w:color="auto" w:space="5" w:sz="2" w:val="none"/>
            <w:bottom w:color="auto" w:space="5" w:sz="2" w:val="none"/>
            <w:right w:color="auto" w:space="5" w:sz="2" w:val="none"/>
          </w:pBdr>
          <w:shd w:color="auto" w:fill="{$fill}" w:val="clear"/>
        </xsl:if>
        <xsl:call-template name="rend-p">
          <xsl:with-param name="rend" select="normalize-space(concat($rend, ' ', @rend))"/>
        </xsl:call-template>
      </w:pPr>
      <xsl:call-template name="anchor"/>
      <xsl:if test="parent::tei:note and not(preceding-sibling::*)">
        <w:r>
          <w:rPr>
            <w:rStyle w:val="Appelnotedebasdep"/>
          </w:rPr>
          <w:footnoteRef/>
          <w:tab/>
        </w:r>
      </xsl:if>
      <xsl:call-template name="char">
        <xsl:with-param name="rend" select="normalize-space(concat($rend, ' ', @rend))"/>
      </xsl:call-template>
    </w:p>
  </xsl:template>
  <xsl:template match="tei:l" name="l">
    <xsl:param name="rend"/>
    <xsl:value-of select="$lf"/>
    <xsl:choose>
      <!-- if empty verse, probably line group separator -->
      <xsl:when test=". = ''">
        <w:p/>
      </xsl:when>
      <xsl:otherwise>
        <w:p>
          <w:pPr>
            <w:pStyle>
              <xsl:attribute name="w:val">
                <xsl:choose>
                  <xsl:when test="$libreO != '' and ancestor::tei:quote">Quotel</xsl:when>
                  <xsl:when test="ancestor::tei:quote">quotel</xsl:when>
                  <xsl:when test="$libreO != ''">L</xsl:when>
                  <xsl:otherwise>l</xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </w:pStyle>
            <xsl:call-template name="rend-p">
              <xsl:with-param name="rend" select="concat(@rend, ' ', $rend)"/>
            </xsl:call-template>
          </w:pPr>
          <xsl:call-template name="anchor"/>
          <xsl:call-template name="char">
            <xsl:with-param name="rend" select="concat(@rend, ' ', $rend)"/>
          </xsl:call-template>
        </w:p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:lg">
    <xsl:param name="rend"/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates>
      <xsl:with-param name="rend" select="normalize-space(concat($rend, ' ', @rend))"/>
    </xsl:apply-templates>
    <!-- Line group separator, empty para, not in style <l> for verse numbering -->
    <xsl:if test="following-sibling::*[1][self::tei:lg]">
      <xsl:value-of select="$lf"/>
      <w:p/>
    </xsl:if>
  </xsl:template>
  <!-- Index mark, TODO -->
  <xsl:template match="tei:index">
    <w:fldChar w:fldCharType="begin"/>
    <w:instrText>
      <xsl:attribute name="xml:space">preserve</xsl:attribute>
      <xsl:text>XE "</xsl:text>
      <xsl:if test="@indexName">
        <xsl:value-of select="@indexName"/>
        <xsl:text>:</xsl:text>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@n">
          <xsl:value-of select="@n"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>"</xsl:text>
    </w:instrText>
    <w:fldChar w:fldCharType="end"/>
  </xsl:template>
  <xsl:template match="tei:note">
    <xsl:choose>
      <!-- Note de niveau caractère -->
      <xsl:when test="not(parent::tei:body | parent::tei:div | parent::tei:div1 | parent::tei:div2 | parent::tei:div3 | parent::tei:div4 | parent::tei:div5 | parent::tei:div6 | parent::tei:div7 | parent::tei:div8 | parent::tei:div9 | parent::tei:sp)">
        <w:r>
          <w:rPr>
            <w:rStyle w:val="Appelnotedebasdep"/>
          </w:rPr>
          <w:footnoteReference w:id="1">
            <xsl:attribute name="w:id">
              <xsl:call-template name="id"/>
            </xsl:attribute>
          </w:footnoteReference>
        </w:r>
      </xsl:when>
      <!-- note de niveau paragraphe -->
      <xsl:when test="text()[normalize-space(.) != '']|tei:emph|tei:hi">
        <xsl:value-of select="$lf"/>
        <w:p>
          <w:pPr>
            <xsl:variable name="style">
              <xsl:choose>
                <xsl:when test="$libreO != ''">Note</xsl:when>
                <xsl:otherwise>note</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <w:pStyle w:val="{$style}"/>
          </w:pPr>
          <xsl:call-template name="anchor"/>
          <!--
          <w:r>
            <w:br/>
          </w:r>
          <w:r>
            <w:rPr>
              <w:rStyle w:val="alert"/>
            </w:rPr>
            <w:t>
              <xsl:text>[</xsl:text>
              <xsl:value-of select="@n|@xml:id"/>
              <xsl:text>]</xsl:text>
            </w:t>
          </w:r>
          <w:r>
            <w:tab/>
          </w:r>
          -->
          <xsl:call-template name="char"/>
        </w:p>
      </xsl:when>
      <!-- note regroupant des blocs -->
      <xsl:otherwise>
        <xsl:apply-templates select="comment()"/>
        <xsl:for-each select="*">
          <xsl:choose>
            <xsl:when test="self::tei:quote | self::tei:l | self::tei:lg">
              <xsl:apply-templates select="."/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$lf"/>
              <w:p>
                <w:pPr>
                  <xsl:variable name="style">
                    <xsl:choose>
                      <xsl:when test="$libreO != '' and self::tei:p">Note</xsl:when>
                      <xsl:when test="self::tei:p">note</xsl:when>
                      <xsl:when test="$libreO != ''">
                        <xsl:value-of select="translate(substring(local-name(), 1, 1), $lc, $uc)"/>
                        <xsl:value-of select="substring(local-name(), 2)"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="local-name()"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <w:pStyle w:val="{$style}"/>
                </w:pPr>
                <xsl:call-template name="anchor"/>
                <xsl:call-template name="char"/>
              </w:p>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Style sémantique de niveau bloc ou caractère -->
  <xsl:template match="tei:bibl | tei:stage">
    <xsl:value-of select="$lf"/>
    <xsl:choose>
      <!-- niveau bloc -->
      <xsl:when test="parent::*[self::tei:quote|self::tei:cell|self::tei:note][tei:p|tei:l]">
        <w:p>
          <w:pPr>
            <xsl:variable name="style">
              <xsl:choose>
                <xsl:when test="$libreO != ''">
                  <xsl:value-of select="translate(substring(local-name(), 1, 1), $lc, $uc)"/>
                  <xsl:value-of select="substring(local-name(), 2)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="local-name()"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <w:pStyle w:val="{$style}"/>
            <xsl:call-template name="rend-p"/>
          </w:pPr>
          <xsl:call-template name="anchor"/>
          <xsl:call-template name="char"/>
        </w:p>
      </xsl:when>
      <!-- niveau caractère -->
      <xsl:when test="ancestor::tei:p  or ancestor::tei:note or parent::tei:quote or parent::tei:cell or  ../text()[normalize-space(.) != '']">
        <xsl:call-template name="char">
          <xsl:with-param name="style">
            <xsl:choose>
              <xsl:when test="self::tei:bibl">bibl-c</xsl:when>
              <xsl:when test="self::tei:stage">stage-c</xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="local-name(.)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <!-- niveau bloc -->
      <xsl:otherwise>
        <w:p>
          <w:pPr>
            <xsl:variable name="style">
              <xsl:choose>
                <xsl:when test="$libreO != ''">
                  <xsl:value-of select="translate(substring(local-name(), 1, 1), $lc, $uc)"/>
                  <xsl:value-of select="substring(local-name(), 2)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="local-name()"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <w:pStyle w:val="{$style}"/>
            <xsl:call-template name="rend-p"/>
          </w:pPr>
          <xsl:call-template name="anchor"/>
          <xsl:call-template name="char"/>
        </w:p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:speaker">
    <xsl:value-of select="$lf"/>
    <w:p>
      <w:pPr>
        <xsl:variable name="style">
          <xsl:choose>
            <xsl:when test="$libreO != ''">Speaker</xsl:when>
            <xsl:otherwise>speaker</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <w:pStyle w:val="{$style}"/>
      </w:pPr>
      <xsl:call-template name="anchor"/>
      <xsl:call-template name="char"/>
    </w:p>
  </xsl:template>
  <xsl:template match="tei:lb">
    <!-- tabulation en cas de justification -->
    <xsl:choose>
      <xsl:when test="parent::tei:body | parent::tei:cit | parent::tei:div | parent::tei:div1 | parent::tei:div2 | parent::tei:div3 | parent::tei:div4 | parent::tei:div5 | parent::tei:div6 | parent::tei:div7 | parent::tei:div8 | parent::tei:div9 | parent::tei:sp"/>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="ancestor::tei:ab"/>
          <xsl:when test="ancestor::tei:label"/>
          <xsl:when test="ancestor::tei:head"/>
          <xsl:when test="parent::*/@rend[contains(., 'center')]"/>
        </xsl:choose>
        <xsl:value-of select="$lf"/>
        <w:r>
          <w:br/>
        </w:r>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- saut de page -->
  <!-- 
    <xsl:variable name="target" select="(@target|@url|@ref)[1]"/>
    <w:hyperlink>
      <xsl:choose>
        <xsl:when test="starts-with($target, '#')">
          <xsl:attribute name="w:anchor">
            <xsl:value-of select="substring($target, 2)"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="r:id">
            <xsl:call-template name="id"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test=".=''">
          <w:r>
            <w:rPr>
              <w:rStyle w:val="LienInternet"/>
            </w:rPr>
            <w:t>
              <xsl:value-of select="$target"/>
            </w:t>
          </w:r>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="char">
            <xsl:with-param name="style">LienInternet</xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </w:hyperlink>
    -->
  <xsl:template match="tei:pb">
    <xsl:variable name="text">
      <xsl:call-template name="anchor"/>
      <w:r>
        <w:rPr>
          <w:rStyle w:val="{local-name()}"/>
        </w:rPr>
        <w:t>
          <xsl:text>[</xsl:text>
          <xsl:choose>
            <xsl:when test="@n and @n != ''">
              <xsl:text>p. </xsl:text>
              <xsl:value-of select="@n"/>
            </xsl:when>
            <xsl:when test="@xml:id">
              <xsl:value-of select="@xml:id"/>
            </xsl:when>
            <xsl:otherwise>p. ???</xsl:otherwise>
          </xsl:choose>
          <xsl:text>]</xsl:text>
        </w:t>
      </w:r>
    </xsl:variable>
    <xsl:variable name="link">
      <xsl:choose>
        <xsl:when test="(@corresp|@facs) != ''">
          <w:hyperlink>
            <xsl:attribute name="r:id">
              <xsl:call-template name="id"/>
            </xsl:attribute>
            <xsl:copy-of select="$text"/>
          </w:hyperlink>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$text"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- <pb> not desired -->
      <xsl:when test="$pb = ''"/>
      <!-- <pb> as para -->
      <xsl:when test="parent::tei:body | parent::tei:cit | parent::tei:div | parent::tei:div1 | parent::tei:div2 | parent::tei:div3 | parent::tei:div4 | parent::tei:div5 | parent::tei:div6 | parent::tei:div7 | parent::tei:div8 | parent::tei:div9 | parent::tei:list | parent::tei:listBibl | parent::tei:quote[tei:l|tei:lg|tei:p] | parent::tei:sp">
        <xsl:value-of select="$lf"/>
        <w:p>
          <xsl:copy-of select="$link"/>
        </w:p>
      </xsl:when>
      <!-- <pb> inline, help with line breaks around -->
      <xsl:otherwise>
        <xsl:value-of select="$lf"/>
        <w:r>
          <w:br/>
        </w:r>
          <xsl:copy-of select="$link"/>
        <xsl:value-of select="$lf"/>
        <w:r>
          <w:br/>
        </w:r>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Listes -->
  <xsl:template match="tei:list | tei:listBibl | tei:castList">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:item">
    <w:p>
      <w:pPr>
        <w:pStyle w:val="Paragraphedeliste"/>
        <w:numPr>
          <w:ilvl w:val="0"/>
          <w:numId w:val="3"/>
        </w:numPr>
      </w:pPr>
      <xsl:call-template name="anchor"/>
      <xsl:call-template name="char"/>
    </w:p>
  </xsl:template>
  <xsl:template match="tei:castItem">
    <w:p>
      <xsl:call-template name="anchor"/>
      <xsl:call-template name="char"/>
    </w:p>
  </xsl:template>
  <!-- rendering para -->
  <xsl:template name="rend-p">
    <xsl:param name="rend" select="@rend"/>
    <xsl:variable name="string" select="concat(' ', normalize-space($rend), ' ')"/>
    <xsl:choose>
      <xsl:when test="contains($string, ' margin ')">
        <w:ind w:left="2000"/>
      </xsl:when>
      <xsl:when test="contains($string, ' center ')">
        <w:ind w:firstLine="0" w:left="0" w:right="0"/>
        <w:jc w:val="center"/>
      </xsl:when>
      <xsl:when test="contains($string, ' right ')">
        <w:jc w:val="right"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- global inline -->
  <xsl:template match="tei:l//* | tei:p//* | tei:head//*" priority="0">
    <xsl:call-template name="char"/>
  </xsl:template>
  <!-- Char level -->
  <xsl:template match="tei:emph | tei:hi | tei:name | tei:num | tei:persName | tei:resp | tei:surname | tei:title" name="char">
    <!-- inherits a char style -->
    <xsl:param name="style">
      <xsl:choose>
        <xsl:when test="tei:hi"/>
        <xsl:otherwise>
          <xsl:value-of select="local-name()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <!-- rend inherits -->
    <xsl:param name="rend"/>
    <xsl:for-each select="node()|text()">
      <xsl:variable name="format">
        <xsl:text> </xsl:text>
        <xsl:value-of select="normalize-space(@rend)"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="normalize-space($rend)"/>
        <xsl:text> </xsl:text>
        <xsl:if test="self::tei:surname">sc </xsl:if>
        <xsl:if test="self::tei:num">sc </xsl:if>
        <xsl:if test="self::tei:title">i </xsl:if>
        <xsl:if test="self::tei:hi[not(@rend)]">i </xsl:if>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="self::tei:hi and contains($format, ' sup ') ">
          <w:r>
            <w:rPr>
              <w:vertAlign w:val="superscript"/>
            </w:rPr>
            <w:t>
              <xsl:value-of select="normalize-space(.)"/>
            </w:t>
          </w:r>
        </xsl:when>
        <xsl:when test="self::tei:hi and contains($format, ' sub ')">
          <w:r>
            <w:rPr>
              <w:vertAlign w:val="subscript"/>
            </w:rPr>
            <w:t>
              <xsl:value-of select="normalize-space(.)"/>
            </w:t>
          </w:r>
        </xsl:when>
        <xsl:when test="self::tei:note | self::tei:lb">
          <xsl:apply-templates select="."/>
        </xsl:when>
        <!-- for each element, recall -->
        <xsl:when test="*">
          <xsl:call-template name="char">
            <xsl:with-param name="rend" select="$format"/>
          </xsl:call-template>
        </xsl:when>
        <!-- text node or simple  -->
        <xsl:otherwise>
          <xsl:variable name="rPr">
            <xsl:choose>
              <!-- force italic ? -->
              <xsl:when test="contains($format, ' i ') or contains($format, ' ital') or contains($format, ' it ')">
                <xsl:choose>
                  <!-- TODO, better control of italic balancing -->
                  <xsl:when test="ancestor-or-self::tei:emph"/>
                  <xsl:otherwise>
                    <w:i/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
            </xsl:choose>
            <xsl:if test="contains($format, ' u ') or contains($format, ' under') ">
              <w:u w:val="single"/>
            </xsl:if>
            <xsl:if test="contains($format, ' sc ') or contains($format, ' small-caps ') or contains($format, ' smallcaps ')  or contains($format, ' pc ') ">
              <w:smallCaps/>
            </xsl:if>
            <!--
            <xsl:if test="contains(concat(' ', ../@rend, ' '), 'small')">
              <w:highlight w:val="yellow"/>
            </xsl:if>
            -->
            <!-- inline style -->
            <xsl:choose>
              <xsl:when test="self::tei:hi"/>
              <xsl:when test="local-name() != ''">
                <w:rStyle w:val="{local-name()}"/>
              </xsl:when>
            </xsl:choose>
            <xsl:if test="@xml:lang">
              <w:lang w:val="{@xml:lang}"/>
            </xsl:if>
          </xsl:variable>
          <!-- impossible to test variable with no string -->
          <w:r>
            <w:rPr>
              <xsl:copy-of select="$rPr"/>
            </w:rPr>
            <w:t>
              <xsl:attribute name="xml:space">preserve</xsl:attribute>
              <xsl:value-of select="."/>
            </w:t>
          </w:r>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="vspace">
    <w:p>
      <w:r/>
    </w:p>
  </xsl:template>
  <xsl:template match="tei:space">
    <xsl:variable name="inline">
      <xsl:call-template name="tei:isInline"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$inline = ''">
        <w:p/>
      </xsl:when>
      <xsl:when test="@quantity">
        <w:r>
          <w:t>
            <xsl:attribute name="xml:space">preserve</xsl:attribute>
            <xsl:value-of select="substring('                                                   ', 1, @quantity)"/>
          </w:t>
        </w:r>
      </xsl:when>
      <xsl:otherwise>
        <w:r>
          <w:tab/>
        </w:r>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- | *[@target] | *[@ref] -->
  <xsl:template match="tei:ref | tei:graphic[@url]">
    <!-- target is created with tei2docx-rels.xsl -->
    <xsl:variable name="target" select="(@target|@url|@ref)[1]"/>
    <w:hyperlink>
      <xsl:choose>
        <xsl:when test="starts-with($target, '#')">
          <xsl:attribute name="w:anchor">
            <xsl:value-of select="substring($target, 2)"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="r:id">
            <xsl:call-template name="id"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test=".=''">
          <w:r>
            <w:rPr>
              <w:rStyle w:val="LienInternet"/>
            </w:rPr>
            <w:t>
              <xsl:value-of select="$target"/>
            </w:t>
          </w:r>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="char">
            <xsl:with-param name="style">LienInternet</xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </w:hyperlink>
  </xsl:template>
  <xsl:template name="id">
    <xsl:choose>
      <xsl:when test="self::comment()">
        <!-- Bug number, ne prend pas comment -->
        <xsl:number count="node()" level="any"/>
      </xsl:when>
      <xsl:when test="self::tei:ref">
        <xsl:text>ref</xsl:text>
        <xsl:number count="//tei:ref" level="any"/>
      </xsl:when>
      <xsl:when test="self::tei:note">
        <xsl:number count="tei:note" level="any"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="generate-id()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Used for links in *rels.xsl -->
  <xsl:template name="rel">
    <xsl:variable name="target">
      <!-- select="(@target|@ref|@corresp|@facs)[1]" -->
      <xsl:choose>
        <xsl:when test="@target != ''">
          <xsl:value-of select="normalize-space(@target)"/>
        </xsl:when>
        <xsl:when test="@ref != ''">
          <xsl:value-of select="normalize-space(@ref)"/>
        </xsl:when>
        <xsl:when test="@corresp != ''">
          <xsl:value-of select="normalize-space(@corresp)"/>
        </xsl:when>
        <xsl:when test="@facs != ''">
          <xsl:value-of select="normalize-space(@facs)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- Les ancres sont ailleurs -->
      <xsl:when test="starts-with($target, '#')"/>
      <!-- No target -->
      <xsl:when test="$target = ''"/>
      <xsl:otherwise>
        <Relationship Target="{$target}" TargetMode="External" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <xsl:attribute name="Id">
            <xsl:call-template name="id"/>
          </xsl:attribute>
        </Relationship>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Utile ou parasite ? -->
  <xsl:template match="comment()">
    <xsl:comment>
      <xsl:value-of select="."/>
    </xsl:comment>
    <xsl:choose>
      <xsl:when test="ancestor::*[text()[normalize-space(.) != '']]">
        <w:r>
          <w:rPr>
            <w:rStyle w:val="Marquedecommentaire"/>
          </w:rPr>
          <w:commentReference>
            <xsl:attribute name="w:id">
              <xsl:call-template name="id"/>
            </xsl:attribute>
          </w:commentReference>
        </w:r>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$lf"/>
        <w:p>
          <w:pPr>
            <w:pStyle w:val="Marquedecommentaire"/>
          </w:pPr>
          <w:r>
            <w:commentReference>
              <xsl:attribute name="w:id">
                <xsl:call-template name="id"/>
              </xsl:attribute>
            </w:commentReference>
          </w:r>
        </w:p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
