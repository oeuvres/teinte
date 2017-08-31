<?xml version="1.0" encoding="UTF-8"?>
<!--

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2005 ajlsm.com (Cybertheses)
© 2007 Frederic.Glorieux@fictif.org
© 2010 Frederic.Glorieux@fictif.org et École nationale des chartes
© 2012 Frederic.Glorieux@fictif.org 
© 2013 Frederic.Glorieux@fictif.org et LABEX OBVIL


Different templates shared among the callers
 * metadata
 * internal identifiers (<template name="href">)
 * cross linkink in same file (<template name="id">)
 * mode for links

-->
<xsl:transform  version="1.0"
  xmlns="http://www.w3.org/1999/xhtml" 
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:exslt="http://exslt.org/common"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
  xmlns:saxon="http://icl.com/saxon" 
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  
  exclude-result-prefixes="rdf rdfs tei" 
  extension-element-prefixes="exslt saxon date" 
  >
  <!-- 
Gobal TEI parameters and variables are divided in different categories
 * parameters set exclusively by the caller, impossible to guess from TEI file
 * parameters with prefered values from TEI file but possible to override when calling
 * constant variables
    -->
  <!-- base href for generated links -->
  <xsl:param name="base"/>
  <!-- Allow to change the extension of generated links -->
  <xsl:param name="_html">.html</xsl:param>
  <!-- Corpus name passed by caller, used as a body class -->
  <xsl:param name="corpusid"/>
  <!-- Maybe set by a parent transformation, used here for link resolution -->
  <xsl:param name="mode"/>
  <!-- Path from XML file to xsl applied, useful for browser transformation -->
  <xsl:param name="xslbase">
    <xsl:call-template name="xslbase"/>
  </xsl:param>
  <!-- Allow caller to override protocol for theme (https) -->
  <xsl:param name="http">http://</xsl:param>
  <xsl:param name="theme">
    <xsl:choose>
      <xsl:when test="$xslbase != ''">
        <xsl:value-of select="$xslbase"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$http"/>oeuvres.github.io/Teinte/</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- generation date, maybe modified by caller -->
  <xsl:param name="date">
    <xsl:choose>
      <xsl:when test="function-available('date:date-time')">
        <xsl:variable name="date">
          <xsl:value-of select="date:date-time()"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains($date, '+')">
            <xsl:value-of select="substring-before($date, '+')"/>
          </xsl:when>
          <xsl:when test="contains($date, '-')">
            <xsl:value-of select="substring-before($date, '-')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$date"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>2016</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- Type de sortie : html5, xhtml, …? -->
  <xsl:param name="format">html5</xsl:param>
  <!-- give name of file from the caller -->
  <xsl:param name="filename"/>
  <!-- doc name -->
  <xsl:param name="docid">
    <xsl:choose>
      <!-- filename -->
      <xsl:when test="$filename != ''">
        <xsl:value-of select="$filename"/>
      </xsl:when>
      <xsl:when test="/*/@xml:id != ''">
        <xsl:value-of select="/*/@xml:id"/>
      </xsl:when>
      <xsl:when test="/*/@xml:base != ''">
        <xsl:value-of select="/*/@xml:base"/>
      </xsl:when>
      <xsl:when test="/*/@n != '' and /*/@n != '0'">
        <xsl:value-of select="/*/@n"/>
      </xsl:when>
      <!-- try to generate a significant code from author title -->
      <xsl:otherwise>
        <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[1]">
          <xsl:variable name="author">
            <xsl:choose>
              <xsl:when test="@key != ''">
                <xsl:value-of select="substring-before(concat(substring-before(concat(@key,','), ','), '('), '(')"/>
              </xsl:when>
              <xsl:when test="contains(., ' ')">
                <xsl:value-of select="substring-before(., ' ')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:value-of select="translate(normalize-space($author), $idfrom, $idto)"/>
          <xsl:text>_</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]">
          <xsl:variable name="mot1">
            <xsl:value-of select="translate(normalize-space(substring-before(concat(.,' '), ' ')), $idfrom, $idto)"/>
          </xsl:variable>
          <xsl:variable name="mot2">
            <xsl:value-of select="
              translate(
                normalize-space(
                  substring-before(
                    concat(substring-after(., ' '),' '), 
                  ' ')
                ), 
              $idfrom, $idto)"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="contains(' le la les un une des de ', concat(' ',$mot1,' '))">
              <xsl:value-of select="$mot2"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$mot1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- Reference title, which order ? -->
  <xsl:param name="doctitle">
    <xsl:choose>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title">
        <xsl:for-each select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[not(@type) or @type='main' or @type='sub']">
          <xsl:if test="position()!=1">. </xsl:if>
          <xsl:apply-templates mode="title"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:title">
        <xsl:apply-templates mode="title" select="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:title[1]/node()"/>
      </xsl:when>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:title">
        <xsl:apply-templates mode="title" select="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:title[1]/node()"/>
      </xsl:when>
      <xsl:when test="/*/tei:text/tei:group/tei:head">
        <xsl:apply-templates mode="title" select="/*/tei:text/tei:group/tei:head[1]/node()"/>
      </xsl:when>
      <xsl:when test="/*/tei:text/tei:body/tei:head">
        <xsl:apply-templates mode="title" select="/*/tei:text/tei:body/tei:head[1]/node()"/>
      </xsl:when>
      <xsl:when test="$docid != ''">
        <xsl:copy-of select="$docid"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="message">
          <xsl:with-param name="id">notitle</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- A build byline from  -->
  <xsl:param name="byline">
    <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt[1]">
      <xsl:choose>
        <xsl:when test="not(tei:author)"/>
        <xsl:when test="count(tei:author) &gt; 3">
          <span class="byline">
            <xsl:for-each select="tei:author[1]">
              <xsl:call-template name="key"/>
            </xsl:for-each>
            <xsl:text> </xsl:text>
            <i>et al.</i>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <span class="byline">
            <xsl:for-each select="tei:author">
              <xsl:if test="position() &gt; 1"> ; </xsl:if>
              <xsl:variable name="html">
                <xsl:call-template name="key"/>
              </xsl:variable>
              <xsl:copy-of select="$html"/>
              <xsl:variable name="norm" select="normalize-space($html)"/>
              <xsl:variable name="last" select="substring($norm, string-length($norm))"/>
              <xsl:if test="position() = last() and position() &gt; 1 and $last != '.'">.</xsl:if>
            </xsl:for-each>
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:param>
  <!-- Referenced date -->
  <xsl:param name="docdate">
    <xsl:choose>
      <xsl:when test="/*/tei:teiHeader/tei:profileDesc/tei:creation/tei:date[concat(.,@when,@notBefore,@notAfter)!='']">
        <xsl:apply-templates mode="year" select="/*/tei:teiHeader/tei:profileDesc/tei:creation[1]/tei:date[1]"/>
      </xsl:when>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:date">
        <xsl:apply-templates mode="year" select="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull[1]/tei:publicationStmt[1]/tei:date[1]"/>
      </xsl:when>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@type='struct']/tei:date">
        <xsl:apply-templates mode="year" select="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@type='struct'][1]/tei:date[1]"/>
      </xsl:when>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:date">
        <xsl:apply-templates mode="year" select="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[1]/tei:date[1]"/>
      </xsl:when>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date">
        <xsl:apply-templates mode="year" select="/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date[1]"/>
      </xsl:when>
    </xsl:choose>
  </xsl:param>
  <!-- Publication date, especially useful to date preface and so on  -->
  <xsl:variable name="issued">
    <xsl:choose>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull/tei:publicationStmt/tei:date">
        <xsl:apply-templates mode="year" select="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblFull[1]/tei:publicationStmt[1]/tei:date[1]"/>
      </xsl:when>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@type='struct']/tei:date">
        <xsl:apply-templates mode="year" select="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@type='struct'][1]/tei:date[1]"/>
      </xsl:when>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:date">
        <xsl:apply-templates mode="year" select="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[1]/tei:date[1]"/>
      </xsl:when>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date">
        <xsl:apply-templates mode="year" select="/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt[1]/tei:date[1]"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <!-- la chaîne identifiante (ISBN, URI…) -->
  <xsl:param name="identifier">
    <xsl:choose>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno">
        <xsl:value-of select="/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno"/>
      </xsl:when>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@type='struct']/tei:idno">
        <xsl:value-of select="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@type='struct']/tei:idno"/>
      </xsl:when>
      <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/*/tei:idno">
        <xsl:value-of select="/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/*/tei:idno"/>
      </xsl:when>
      <xsl:when test="$docid">
        <xsl:value-of select="$docid"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Identifier ?</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- Langue du document, sert aussi pour les messages générés -->
  <xsl:param name="lang">
    <xsl:choose>
      <xsl:when test="/*/@xml:lang">
        <xsl:value-of select="/*/@xml:lang"/>
      </xsl:when>
      <xsl:when test="/*/tei:teiHeader/tei:profileDesc/tei:langUsage/@xml:lang">
        <xsl:value-of select="/*/tei:teiHeader/tei:profileDesc/tei:langUsage/@xml:lang"/>
      </xsl:when>
      <xsl:when test="/*/tei:teiHeader/tei:profileDesc/tei:langUsage/tei:language/@ident">
        <xsl:value-of select="/*/tei:teiHeader/tei:profileDesc/tei:langUsage/tei:language/@ident"/>
      </xsl:when>
      <xsl:otherwise>fr</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- File for generated messages -->
  <xsl:param name="messages">tei.rdfs</xsl:param>
  <!--  charger le fichier de messages, document('') permet de résoudre les chemin relativement à ce fichier  -->
  <xsl:variable name="rdf:Property" select="document($messages, document(''))/*/rdf:Property"/>
  <!-- Useful in Teinte package -->
  <xsl:variable name="this"/>
  <!-- A separate page for footnotes ? -->
  <xsl:param name="fnpage"/>
  <!-- A dest folder for graphics -->
  <xsl:param name="images"/>
  <!-- key to know which element to split -->
  <!-- Éléments uniques dans un fichier, identifiés par leur nom, liste séparée d'espaces. -->
  <xsl:variable name="els-unique"> editorialDecl licence projectDesc revisionDesc samplingDecl sourceDesc TEI teiHeader </xsl:variable>
  <!-- Une barre d'espaces insécables, utilisable pour de l'indentation automatique -->
  <xsl:variable name="nbsp">                                                                                         </xsl:variable>
  <xsl:variable name="lf">
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  <xsl:variable name="tab">
    <xsl:text>&#9;</xsl:text>
  </xsl:variable>
  <!-- Some constants -->
  <xsl:variable name="epub2">epub2</xsl:variable>
  <xsl:variable name="epub3">epub3</xsl:variable>
  <xsl:variable name="html5">html5</xsl:variable>
  <xsl:variable name="html">html</xsl:variable>
  <xsl:variable name="article">article</xsl:variable>
  <xsl:variable name="nav">nav</xsl:variable>
  <xsl:variable name="ul">ul</xsl:variable>
  <xsl:variable name="ol">ol</xsl:variable>
  <xsl:variable name="front">front</xsl:variable>
  <xsl:variable name="back">back</xsl:variable>
  <!-- Upper case letters with diactitics, for translate() -->
  <xsl:variable name="uc">ABCDEFGHIJKLMNOPQRSTUVWXYZÆŒÇÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÝ</xsl:variable>
  <!-- Lower case letters with diacritic, for translate() -->
  <xsl:variable name="lc">abcdefghijklmnopqrstuvwxyzæœçàáâãäåèéêëìíîïòóôõöùúûüý</xsl:variable>
  <!-- To produce a normalised id -->
  <xsl:variable name="idfrom">ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÄÉÈÊÏÎÔÖÛÜÇàâäéèêëïîöôüû ,.</xsl:variable>
  <xsl:variable name="idto">abcdefghijklmnopqrstuvwxyzaaaeeeiioouucaaaeeeeiioouu-</xsl:variable>
  <xsl:variable name="apos">'</xsl:variable>
  <xsl:variable name="quote">"</xsl:variable>
  <!-- a key for identified elements -->
  <xsl:key match="*" name="id" use="@xml:id"/>
  <!-- A key to count elements by name -->
  <xsl:key match="*" name="qname" use="local-name()"/>
  <!-- Put a lang attribute  -->
  <xsl:template name="att-lang">
    <xsl:variable name="lang-loc" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
    <xsl:choose>
      <xsl:when test="$lang-loc != ''">
        <xsl:attribute name="lang">
          <xsl:value-of select="$lang-loc"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="$lang != ''">
        <xsl:attribute name="lang">
          <xsl:value-of select="$lang"/>
        </xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- Get a year from a date tag with different possible attributes -->
  <xsl:template match="*" mode="year" name="year">
    <xsl:choose>
      <xsl:when test="@when">
        <xsl:value-of select="substring(@when, 1, 4)"/>
      </xsl:when>
      <xsl:when test="@notAfter">
        <xsl:value-of select="substring(@notAfter, 1, 4)"/>
      </xsl:when>
      <xsl:when test="@notBefore">
        <xsl:value-of select="substring(@notBefore, 1, 4)"/>
      </xsl:when>
      <xsl:when test="@n">
        <xsl:value-of select="substring(@n, 1, 4)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="text" select="normalize-space(string(.))"/>
        <!-- try to find a year -->
        <xsl:variable name="XXXX" select="translate($text,'0123456789', '##########')"/>
        <xsl:choose>
          <xsl:when test="contains($XXXX, '####')">
            <xsl:variable name="pos" select="string-length(substring-before($XXXX,'####')) + 1"/>
            <xsl:value-of select="substring($text, $pos, 4)"/>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="key">
    <xsl:choose>
      <xsl:when test="@key and contains(@key, '(')">
        <xsl:value-of select="normalize-space(substring-before(@key, '('))"/>
      </xsl:when>
      <xsl:when test="@key != ''">
        <xsl:value-of select="@key"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="title"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Create a titlePage from teiHeader -->
  <xsl:template name="titlePage">
    <xsl:apply-templates select="/*/tei:teiHeader"/>
    <!--
    <div class="titlePage">
      <xsl:choose>
        <xsl:when test="not(/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author)"/>
        <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[. != '']">
          <xsl:apply-templates select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[. != '']"/>
        </xsl:when>
        <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[@key != '']">
          <xsl:for-each select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[@key != '']">
            <div class="author">
              <xsl:choose>
                <xsl:when test="contains(@key, '(')">
                  <xsl:value-of select="normalize-space(substring-before(@key, '('))"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="@key"/>
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="/*/tei:teiHeader/tei:profileDesc/tei:creation/tei:date[1]"/>
      <xsl:apply-templates select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[not(@type) or @type='main' or @type='sub' or @type='alt' or @type='short' or @type='desc']"/>
      <xsl:apply-templates select="/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt"/>
    </div>
    -->
  </xsl:template>
  <!-- Créer un titre hiérarchique pour /html/head/title d'une section -->
  <xsl:template name="titlebranch">
    <xsl:variable name="titlebranch">
      <xsl:for-each select="ancestor-or-self::*">
        <xsl:sort order="descending" select="position()"/>
        <xsl:variable name="branch">
          <xsl:apply-templates mode="title" select="."/>
        </xsl:variable>
        <xsl:variable name="branchNorm" select="normalize-space($branch)"/>
        <xsl:choose>
          <!-- ramasser le teiHeader (?) -->
          <xsl:when test="self::tei:TEI"/>
          <xsl:when test="self::tei:text">
            <xsl:if test="position() != 1"> — </xsl:if>
            <xsl:copy-of select="$doctitle"/>
          </xsl:when>
          <xsl:when test="self::tei:body"/>
          <!-- forged title, do not use ? why ? -->
          <!--
          <xsl:when test="starts-with($branchNorm, '[')"/>
          -->
          <!-- end -->
          <xsl:otherwise>
            <xsl:if test="position() != 1"> — </xsl:if>
            <xsl:if test="position() = 1 and not(starts-with($branchNorm, '['))">« </xsl:if>
            <xsl:copy-of select="$branch"/>
            <xsl:if test="position() = 1 and not(starts-with($branchNorm, '['))"> »</xsl:if>
            <!--
            <xsl:choose>
              <xsl:when test="contains(';.,', substring($branchNorm, string-length($branchNorm)) )"> </xsl:when>
              <xsl:when test="position() = last()">.</xsl:when>
              <xsl:otherwise>. </xsl:otherwise>
            </xsl:choose>
            -->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <!-- ???
    <xsl:choose>
      <xsl:when test="normalize-space($titlebranch) = ''">
        <xsl:value-of select="$corpusTitle"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($titlebranch)"/>
      </xsl:otherwise>
    </xsl:choose>
    -->
    <xsl:value-of select="normalize-space($titlebranch)"/>
  </xsl:template>
  <!--
<h3>mode="id" (identifiant)</h3>

<p>
Mode permettant d'associer un identifiant unique dans le contexte d'un document,
notamment pour établir cible et source de liens.
</p>
-->
  <xsl:template match="*" mode="id" name="id">
    <xsl:param name="prefix"/>
    <xsl:param name="suffix"/>
    <xsl:variable name="id0"> '":,; /\</xsl:variable>
    <xsl:value-of select="$prefix"/>
    <xsl:choose>
      <xsl:when test="@xml:id">
        <xsl:value-of select="translate(@xml:id, $id0, '')"/>
      </xsl:when>
      <xsl:when test="@id">
        <xsl:value-of select="translate(@id, $id0, '')"/>
      </xsl:when>
      <xsl:when test="/tei:TEI/tei:text/tei:front and count(.|/tei:TEI/tei:text/tei:front)=1">front</xsl:when>
      <xsl:when test="@type = 'act'">
        <xsl:number format="I" count="tei:*[@type='act']"/>
      </xsl:when>
      <xsl:when test="@type = 'scene'">
        <xsl:for-each select="parent::*[1]">
          <xsl:call-template name="id"/>
        </xsl:for-each>
        <xsl:number format="01"/>
      </xsl:when>
      <xsl:when test="self::tei:sp">
        <xsl:for-each select="parent::*[1]">
          <xsl:call-template name="id"/>
        </xsl:for-each>
        <xsl:text>-</xsl:text>
        <xsl:number format="1"/>
      </xsl:when>
      <xsl:when test="parent::*/@type = 'act'">
        <xsl:for-each select="parent::*[1]">
          <xsl:call-template name="id"/>
        </xsl:for-each>
        <xsl:number format="01"/>
      </xsl:when>
      <xsl:when test="self::tei:listPerson and @type = 'configuration'">
        <xsl:text>conf</xsl:text>
        <xsl:number count="tei:listPerson[@type='configuration']" level="any"/>
      </xsl:when>
      <xsl:when test="not(ancestor::tei:group) and (self::tei:div or starts-with(local-name(), 'div'))">
        <!-- should I put file id as div id prefix ? -->
        <!--
        <xsl:if test="$docid != ''">
          <xsl:value-of select="translate($docid, $id0, $id1)"/>
          <xsl:text>_</xsl:text>        
        </xsl:if>
        -->
        <xsl:choose>
          <xsl:when test="ancestor::tei:body">body-</xsl:when>
          <xsl:when test="ancestor::tei:front">front-</xsl:when>
          <xsl:when test="ancestor::tei:back">back-</xsl:when>
        </xsl:choose>
        <xsl:number count="tei:div|tei:div1|tei:div2|tei:div3|tei:div4" format="1-1" level="multiple"/>
      </xsl:when>
      <!-- hiérarchie simple de div  -->
      <xsl:when test="self::tei:div and not(ancestor::tei:group)">
        <!-- should I put file id as div id prefix ? -->
        <!--
        <xsl:if test="$docid != ''">
          <xsl:value-of select="translate($docid, $id0, $id1)"/>
          <xsl:text>_</xsl:text>        
        </xsl:if>
        -->
        <xsl:number count="tei:div" format="1-1" level="multiple"/>
      </xsl:when>
      <!-- find index -->
      <xsl:when test="/tei:TEI/tei:text and count(.|/tei:TEI/tei:text)=1">index</xsl:when>
      <!-- éléments hauts -->
      <xsl:when test="count(.. | /*) = 1">
        <!-- should I put file id as div id prefix ? -->
        <!--
        <xsl:if test="$docid != ''">
          <xsl:value-of select="translate($docid, $id0, $id1)"/>
          <xsl:text>_</xsl:text>        
        </xsl:if>
        -->
        <xsl:value-of select="local-name()"/>
      </xsl:when>
      <!-- groupe de textes -->
      <xsl:when test="self::tei:group">
        <!-- should I put file id as div id prefix ? -->
        <!--
        <xsl:if test="$docid != ''">
          <xsl:value-of select="translate($docid, $id0, $id1)"/>
          <xsl:text>_</xsl:text>        
        </xsl:if>
        -->
        <xsl:value-of select="local-name()"/>
        <xsl:number format="-1-1" from="/*/tei:text/tei:group" level="multiple"/>
      </xsl:when>
      <!-- éléments uniques identifiables par leur nom -->
      <xsl:when test="contains($els-unique, concat(' ', local-name(), ' '))">
        <!-- should I put file id as div id prefix ? -->
        <!--
        <xsl:if test="$docid != ''">
          <xsl:value-of select="translate($docid, $id0, $id1)"/>
          <xsl:text>_</xsl:text>        
        </xsl:if>
        -->
        <xsl:value-of select="local-name()"/>
      </xsl:when>
      <xsl:when test="self::tei:pb">
        <xsl:choose>
          <xsl:when test="contains('0123456789IVXDCM', substring(@n,1,1))">
            <xsl:text>pb</xsl:text>
            <xsl:value-of select="normalize-space(translate(@n, $id0, ''))"/>
          </xsl:when>
          <xsl:when test="@n != ''">
            <xsl:value-of select="normalize-space(translate(@n, $id0, ''))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>p</xsl:text>
            <xsl:number level="any"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="self::tei:figure">
        <xsl:text>fig</xsl:text>
        <xsl:number level="any"/>
      </xsl:when>
      <xsl:when test="self::tei:graphic">
        <xsl:text>img</xsl:text>
        <xsl:number level="any"/>
      </xsl:when>
      <!-- Défaut -->
      <xsl:when test="true()">
        <!-- should I put file id as div id prefix ? -->
        <!--
        <xsl:if test="$docid != ''">
          <xsl:value-of select="translate($docid, $id0, $id1)"/>
          <xsl:text>_</xsl:text>
        </xsl:if>
        -->
        <xsl:value-of select="local-name()"/>
        <xsl:if test="count(key('qname', local-name())) &gt; 1">
          <xsl:number level="any"/>
        </xsl:if>
      </xsl:when>
      <!-- numérotation des notes, préfixées par la section -->
      <xsl:when test="self::tei:note or self::tei:app or self::tei:cit[@n]">
        <xsl:choose>
          <xsl:when test="ancestor::*[@xml:id]">
            <xsl:value-of select="ancestor::*[@xml:id][1]/@xml:id"/>
            <xsl:text>-</xsl:text>
          </xsl:when>
          <xsl:when test="ancestor::tei:text[parent::tei:group]">
            <xsl:for-each select="ancestor::tei:text[1]">
              <xsl:call-template name="n"/>
            </xsl:for-each>
            <xsl:text>-</xsl:text>
          </xsl:when>
          <xsl:when test="ancestor::*[key('split', generate-id())]">
            <xsl:for-each select="ancestor::*[key('split', generate-id())][1]">
              <xsl:call-template name="id"/>
            </xsl:for-each>
            <xsl:text>-</xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:text>fn</xsl:text>
        <xsl:variable name="n">
          <xsl:call-template name="n"/>
        </xsl:variable>
        <xsl:value-of select="translate($n, '()-', '')"/>
      </xsl:when>
      <!-- Où ?
      <xsl:when test="@n and ancestor::*[@xml:id][local-name() != local-name(/*)]">
        <xsl:value-of select="ancestor::*[@xml:id][1]/@xml:id"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@n"/>
      </xsl:when>
      -->
      <!-- lien vers une ancre -->
      <xsl:when test="starts-with(@target, '#') and not(contains(@target, ' '))">
        <xsl:value-of select="substring(@target, 2)"/>
      </xsl:when>
      <!-- Mauvaise solution par défaut -->
      <xsl:otherwise>
        <xsl:value-of select="generate-id()"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$suffix"/>
  </xsl:template>
  <!--
<h3>mode="n" (numéro)</h3>

<p>
Beaucoup de composants d'un texte peuvent être identifiés par un numéro notamment
les différents types de notes (apparat critique, glose historique, philologique…), ou les sections hiérarchiques.
Un tel numéro peut etre très utile pour 
</p>

-->
  <!-- Numéro élément, priorité aux indications de l'auteur (en général) -->
  <xsl:template match="node()" mode="n" name="n">
    <xsl:variable name="id" select="translate((@xml:id | @id), 'abcdefghijklmnopqrstuvwxyz', '')"/>
    <xsl:choose>
      <xsl:when test="@n">
        <xsl:value-of select="@n"/>
      </xsl:when>
      <!-- numérotation hiérarchique des sections -->
      <xsl:when test="self::tei:div">
        <xsl:number format="1-1" level="multiple"/>
      </xsl:when>
      <xsl:when test="self::tei:div0 or self::tei:div1 or self::tei:div2 or self::tei:div3 or self::tei:div4 or self::tei:div5 or self::tei:div6 or self::tei:div7">
        <xsl:number count="tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7" format="1-1" level="multiple"/>
      </xsl:when>
      <xsl:when test="number($id)">
        <xsl:value-of select="$id"/>
      </xsl:when>
      <!-- textes non identifiés (ou numérotés) -->
      <xsl:when test="self::tei:text and ancestor::tei:group">
        <xsl:number from="tei:text/tei:group" level="any"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:number from="/*/tei:text/tei:body | /*/tei:text/tei:front | /*/tei:text/tei:back" level="any"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
<h3>mode="title" (titre long)</h3>

<p>
Ce mode permet de traverser un arbre jusqu'à trouver un élément satisfaisant pour le titrer (souvent <head>).
Une fois cet elément trouvé, le contenu est procédé en mode texte afin de passer les notes,
résoudre les césures, ou les alternatives éditoriales.
</p>
<p>Utiliser pour la génération de tables des matières, epub toc.ncx, ou site nav.html, index.html</p>
  -->
  <xsl:template match="tei:elementSpec" mode="title">
    <xsl:value-of select="@ident"/>
  </xsl:template>
  <xsl:template name="pipe-comma">
    <xsl:param name="text" select="."/>
    <xsl:choose>
      <xsl:when test="normalize-space($text)=''"/>
      <xsl:when test="contains($text, '|')">
        <xsl:value-of select="normalize-space(substring-before($text, '|'))"/>
        <xsl:text>, </xsl:text>
        <xsl:call-template name="pipe-comma">
          <xsl:with-param name="text" select="substring-after($text, '|')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($text)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- find a title for a section  -->
  <xsl:template match="tei:back | tei:body | tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7 | tei:front | tei:group | tei:TEI | tei:text | tei:titlePage" mode="title" name="title">
    <!-- Author in a title ? -->
    <!-- Numérotation construite (?) -->
    <xsl:choose>
      <!-- Short title, not displayed -->
      <xsl:when test="tei:index[@indexName='head'][@n != '']">
        <xsl:value-of select="tei:index[@indexName='head'][@n != '']/@n"/>
      </xsl:when>
      <xsl:when test="tei:index/tei:term[@type='head']">
        <xsl:apply-templates mode="title" select="(tei:index/tei:term[@type='head'])[1]"/>
      </xsl:when>
      <!-- title for a titlePage is "Title page" -->
      <xsl:when test="self::tei:titlePage">
        <xsl:call-template name="message"/>
      </xsl:when>
      <xsl:when test="tei:head[not(@type='sub')]">
        <xsl:variable name="byline">
          <xsl:choose>
            <xsl:when test="tei:byline">
              <xsl:apply-templates mode="title" select="tei:byline"/>
            </xsl:when>
            <xsl:when test="tei:index[@indexName='author' or @indexName='creator']">
              <xsl:for-each select="tei:index[@indexName='author' or @indexName='creator']">
                <xsl:choose>
                  <xsl:when test="@n">
                    <xsl:variable name="n" select="translate(@n, '0123456789', '')"/>
                    <xsl:choose>
                      <xsl:when test="$n='unknown'"/>
                      <xsl:when test="contains($n, '|')">
                        <xsl:call-template name="pipe-comma">
                          <xsl:with-param name="text" select="$n"/>
                        </xsl:call-template>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="normalize-space($n)"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                  <xsl:when test="position()=1"/>
                  <xsl:when test="position() = last()"/>
                  <xsl:otherwise>, </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="title">
          <xsl:for-each select="tei:head[not(@type='sub')]">
            <xsl:apply-templates mode="title" select="."/>
            <xsl:if test="position() != last()">
              <!-- test if title end by ponctuation -->
              <xsl:variable name="norm" select="normalize-space(.)"/>
              <xsl:variable name="last" select="substring($norm, string-length($norm))"/>
              <xsl:if test="translate($last, '.;:?!»', '')!=''">. </xsl:if>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:copy-of select="$title"/>
        <!-- Afficher un Byline en TOC ?
        <xsl:choose>
          <xsl:when test="$byline != ''">
            <xsl:variable name="norm" select="normalize-space($title)"/>
            <xsl:if test="substring($norm, string-length($norm)) != '.'">
              <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:text> </xsl:text>
            <xsl:copy-of select="$byline"/>
          </xsl:when>
        </xsl:choose>
        -->
      </xsl:when>
      <!-- titlePage is not the title of a front
      <xsl:when test="tei:titlePage">
        <xsl:apply-templates select="(tei:titlePage[1]/tei:docTitle/tei:titlePart|tei:titlePage[1]/tei:titlePart)[1]" mode="title"/>
      </xsl:when>
      -->
      <!-- Front or back with no local title, use a generic label  -->
      <xsl:when test="self::tei:front|self::tei:back">
        <xsl:call-template name="message"/>
      </xsl:when>
      <!-- Level <text>, get a short title to display, an author maybe nice as a prefix -->
      <xsl:when test=" self::tei:text or self::tei:body ">
        <xsl:variable name="title">
          <xsl:choose>
            <xsl:when test="tei:body/tei:head">
              <xsl:apply-templates mode="title" select="tei:body/tei:head[1]"/>
            </xsl:when>
            <xsl:when test="tei:front/tei:head">
              <xsl:apply-templates mode="title" select="tei:front/tei:head[1]"/>
            </xsl:when>
            <xsl:when test="not(ancestor::tei:group)">
              <xsl:copy-of select="$doctitle"/>
            </xsl:when>
            <!-- title for a titlePage is "Title page" -->
            <xsl:when test="tei:front/tei:titlePage">
              <xsl:apply-templates mode="title" select="(.//tei:front/tei:titlePage[1]/tei:docTitle[1]/tei:titlePart[1] | .//tei:front/tei:titlePage[1]/tei:titlePart[1])[1]"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="author">
          <xsl:choose>
            <!-- search for docDates ? -->
            <xsl:when test="ancestor::tei:group"/>
            <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author">
              <xsl:for-each select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[1]">
                <xsl:choose>
                  <xsl:when test="contains(@key, '(')">
                    <xsl:value-of select="normalize-space(substring-before(@key, '('))"/>
                  </xsl:when>
                  <xsl:when test="@key">
                    <xsl:value-of select="@key"/>
                  </xsl:when>
                  <xsl:when test="contains(., '(')">
                    <xsl:value-of select="normalize-space(substring-before(., '('))"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
              <xsl:choose>
                <xsl:when test="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author[2]">… </xsl:when>
                <xsl:otherwise>. </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <!-- Juste title, no author ?
          <xsl:when test="$author != ''">
            <xsl:copy-of select="$author"/>
            <i>
              <xsl:copy-of select="$title"/>
            </i>
          </xsl:when>
          -->
          <xsl:when test="$title">
            <xsl:copy-of select="$title"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="idpath"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="tei:docTitle">
        <xsl:apply-templates mode="title" select="tei:docTitle[1]/tei:titlePart[1]"/>
      </xsl:when>
      <!-- a date as a title (ex, acte) -->
      <xsl:when test="tei:docDate">
        <xsl:apply-templates mode="title" select="tei:docDate[1]"/>
      </xsl:when>
      <!-- A <text> ? -->
      <xsl:when test="tei:front/tei:titlePage">
        <xsl:apply-templates mode="title" select="tei:front/tei:titlePage"/>
      </xsl:when>
      <!-- /TEI/text ? -->
      <xsl:when test="../tei:teiHeader">
        <xsl:apply-templates mode="title" select="../tei:teiHeader"/>
      </xsl:when>
      <!-- Après front, supposé plus affichable qu'un teiHeader -->
      <xsl:when test="tei:teiHeader">
        <xsl:apply-templates mode="title" select="tei:teiHeader"/>
      </xsl:when>
      <xsl:when test="tei:dateline">
        <xsl:apply-templates mode="title" select="tei:dateline"/>
      </xsl:when>
      <xsl:when test="@n">
        <xsl:value-of select="@n"/>
      </xsl:when>
      <xsl:when test="@type">
        <xsl:call-template name="message">
          <xsl:with-param name="id" select="@type"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="self::tei:div and parent::tei:body">
        <xsl:text>[</xsl:text>
        <xsl:call-template name="message">
          <xsl:with-param name="id">chapter</xsl:with-param>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:call-template name="n"/>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[</xsl:text>
        <xsl:call-template name="n"/>
        <xsl:text>]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- title, verify if empty -->
  <xsl:template match="tei:head" mode="title">
    <xsl:variable name="html">
      <xsl:apply-templates mode="title"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$html = ''">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="ancestor::tei:div[1]">
          <xsl:call-template name="n"/>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$html"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- titre dans un front -->
  <xsl:template match="tei:titlePart" mode="title">
    <xsl:apply-templates mode="title"/>
  </xsl:template>
  <!-- no notes in title mode -->
  <xsl:template match="tei:note | tei:index" mode="title"/>
  <xsl:template match="tei:pb" mode="title">
    <xsl:text> </xsl:text>
  </xsl:template>
  <xsl:template match="tei:lb" mode="title">
    <xsl:variable name="prev" select="preceding-sibling::node()[1]"/>
    <xsl:variable name="norm" select="normalize-space( $prev )"/>
    <xsl:variable name="lastchar" select="substring($norm, string-length($norm))"/>
    <xsl:choose>
      <xsl:when test="contains(',.;:—–-', $lastchar)">
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="string-length($prev) = string-length($norm)">
        <xsl:text>. </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> – </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
  </xsl:template>
  <xsl:template match="tei:choice" mode="title">
    <xsl:choose>
      <xsl:when test="tei:reg">
        <xsl:apply-templates mode="title" select="tei:reg/node()"/>
      </xsl:when>
      <xsl:when test="tei:expan">
        <xsl:apply-templates mode="title" select="tei:expan/node()"/>
      </xsl:when>
      <xsl:when test="tei:corr">
        <xsl:apply-templates mode="title" select="tei:corr/node()"/>
      </xsl:when>
      <xsl:when test="tei:ex">
        <xsl:apply-templates mode="title" select="tei:ex/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- default, cross all, keep only text -->
  <xsl:template match="*" mode="title" priority="-2">
    <xsl:apply-templates mode="title"/>
  </xsl:template>
  <!-- Keep text from some element with possible values in attributes -->
  <xsl:template match="tei:date | tei:docDate | tei:origDate" mode="title">
    <xsl:variable name="text">
      <xsl:apply-templates select="."/>
    </xsl:variable>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$text"/>
    <xsl:text> </xsl:text>
  </xsl:template>
  <!-- strip last space in ponctuated elements -->
  <xsl:template match="tei:head/text() | tei:byline/text()" mode="title">
    <xsl:choose>
      <xsl:when test="position()=1">
        <xsl:variable name="norm" select="normalize-space(.)"/>
        <xsl:value-of select="$norm"/>
        <xsl:if test="$norm != '' and substring(., string-length(.)) = ' '">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="position()=last()">
        <xsl:if test="starts-with(., ' ')">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Mode title -->
  <xsl:template match="tei:teiHeader" mode="title">
    <xsl:if test="tei:fileDesc/tei:titleStmt/tei:author">
      <xsl:apply-templates mode="title" select="tei:fileDesc/tei:titleStmt/tei:author[1]"/>
      <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:apply-templates mode="title" select="tei:fileDesc/tei:titleStmt/tei:title[1]"/>
    <xsl:variable name="date">
      <xsl:apply-templates mode="title" select="tei:profileDesc[1]/tei:creation[1]/tei:date[1]"/>
    </xsl:variable>
    <xsl:if test="normalize-space($date) != ''">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="normalize-space($date)"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>
  <!-- Keep some rendering in title TOC -->
  <xsl:template match="tei:hi" mode="title">
    <xsl:choose>
      <xsl:when test=". =''"/>
      <!-- si @rend est un nom d'élément HTML -->
      <xsl:when test="contains( ' b big em i s small strike strong sub sup tt u ', concat(' ', @rend, ' '))">
        <xsl:element name="{@rend}" namespace="http://www.w3.org/1999/xhtml">
          <xsl:if test="@type">
            <xsl:attribute name="class">
              <xsl:value-of select="@type"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates mode="title"/>
        </xsl:element>
      </xsl:when>
      <!-- sinon appeler le span général -->
      <xsl:otherwise>
        <span class="{@rend}">
          <xsl:apply-templates mode="title"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:emph" mode="title">
    <em>
      <xsl:apply-templates mode="title"/>
    </em>
  </xsl:template>
  <xsl:template match="tei:name | tei:num | tei:surname" mode="title">
    <span class="{local-name()}">
      <xsl:apply-templates mode="title"/>
    </span>
  </xsl:template>
  <xsl:template match="tei:title" mode="title">
    <xsl:variable name="cont">
      <xsl:apply-templates mode="title"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$cont = ''"/>
      <xsl:otherwise>
        <em class="{local-name()}">
          <xsl:copy-of select="$cont"/>
        </em>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Good idea ?  -->
  <!--
  <xsl:template match="tei:num/text() | tei:surname/text()" mode="title">
    <xsl:value-of select="translate(., $mins, $caps)"/>
  </xsl:template>
  -->
  <xsl:template match="*" mode="label">
    <xsl:apply-templates mode="title" select="."/>
  </xsl:template>
  <!-- 
    Centralisation of internal links rewriting, to call when current() node is the target.
    This template will choose if link should stay an anchor or will be rewritten according to the split
    policy.
  -->
  <xsl:template name="href">
    <xsl:param name="base" select="$base"/>
    <xsl:param name="class"/>
    <!-- possible override id -->
    <xsl:param name="id">
      <xsl:call-template name="id"/>
    </xsl:param>
    <xsl:choose>
      <!-- When transform is called from monopage  -->
      <xsl:when test="$this = 'tei2html.xsl' or $this = 'tei2toc.xsl'">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="$id"/>
      </xsl:when>
      <!-- For a deported page of notes (site or epub) -->
      <xsl:when test="$class = 'noteref' and $fnpage != ''">
        <xsl:value-of select="$base"/>
        <xsl:value-of select="$fnpage"/>
        <xsl:value-of select="$_html"/>
        <xsl:text>#</xsl:text>
        <xsl:value-of select="$id"/>
      </xsl:when>
      <!-- -->
      <xsl:when test="/*/tei:text/tei:body and count(.|/*/tei:text/tei:body)=1">
        <xsl:value-of select="$base"/>
        <xsl:choose>
          <xsl:when test="$_html = ''">.</xsl:when>
          <xsl:otherwise>index<xsl:value-of select="$_html"/></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- Structure TEI, renommés par le template "id" -->
      <xsl:when test="count(../.. | /*) = 1">
        <xsl:value-of select="$base"/>
        <xsl:value-of select="$id"/>
        <xsl:value-of select="$_html"/>
      </xsl:when>
      <!-- is a splitted section -->
      <xsl:when test="self::*[key('split', generate-id())]">
        <xsl:value-of select="$base"/>
        <xsl:value-of select="$id"/>
        <xsl:value-of select="$_html"/>
      </xsl:when>
      <!-- parent of a split section -->
      <xsl:when test="descendant::*[key('split', generate-id())]">
        <xsl:value-of select="$base"/>
        <xsl:value-of select="$id"/>
        <xsl:value-of select="$_html"/>
      </xsl:when>
      <!-- Enfant d'une page, id du parent splité + ancre -->
      <xsl:when test="ancestor::*[key('split', generate-id())]">
        <xsl:value-of select="$base"/>
        <xsl:for-each select="ancestor::*[key('split', generate-id())][1]">
          <xsl:call-template name="id"/>
          <xsl:value-of select="$_html"/>
        </xsl:for-each>
        <xsl:text>#</xsl:text>
        <xsl:value-of select="$id"/>
      </xsl:when>
      <!-- A été rencontré, laissé pour mémoire -->
      <xsl:when test="ancestor::tei:*[local-name(../..)='TEI']">
        <xsl:for-each select="ancestor::tei:*[local-name(../..)='TEI'][1]">
          <xsl:call-template name="id"/>
          <xsl:value-of select="$_html"/>
        </xsl:for-each>
        <xsl:text>#</xsl:text>
        <xsl:value-of select="$id"/>
      </xsl:when>
      <!-- Pas de split, juste des ancres -->
      <xsl:otherwise>
        <xsl:text>#</xsl:text>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--
<h3>mode="label" (titre court)</h3>

<p>
Le mode label génère un intitulé court obtenu par une liste de valeurs localisés (./tei.rdfs).
</p>
  -->
  <!-- Message, intitulé court d'un élément TEI lorsque disponible -->
  <xsl:template name="message">
    <xsl:param name="id" select="local-name()"/>
    <xsl:choose>
      <xsl:when test="$rdf:Property[@xml:id = $id]/rdfs:label[starts-with( $lang, @xml:lang)]">
        <xsl:copy-of select="$rdf:Property[@xml:id = $id]/rdfs:label[starts-with( $lang, @xml:lang)][1]/node()"/>
      </xsl:when>
      <xsl:when test="$rdf:Property[@xml:id = $id]/rdfs:label">
        <xsl:copy-of select="$rdf:Property[@xml:id = $id]/rdfs:label[1]/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- pour obtenir un chemin relatif à l'XSLT appliquée -->
  <xsl:template name="xslbase">
    <xsl:param name="path" select="/processing-instruction('xml-stylesheet')[contains(., 'xsl')]"/>
    <xsl:choose>
      <xsl:when test="contains($path, 'href=&quot;')">
        <xsl:call-template name="xslbase">
          <xsl:with-param name="path" select="substring-after($path, 'href=&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($path, '&quot;')">
        <xsl:variable name="p" select="substring-before($path, '&quot;')"/>
        <xsl:choose>
          <xsl:when test="not(contains($p, '/')) and not(contains($p, '\'))">./</xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="xslbase">
              <xsl:with-param name="path" select="$p"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- Absolute, do nothing -->
      <xsl:when test="starts-with($path, 'http')"/>
      <!-- cut beforer quote -->
      <xsl:when test="contains($path, '/')">
        <xsl:value-of select="substring-before($path, '/')"/>
        <xsl:text>/</xsl:text>
        <xsl:call-template name="xslbase">
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <!-- win centric -->
      <xsl:when test="contains($path, '\')">
        <xsl:value-of select="substring-before($path, '\')"/>
        <xsl:text>/</xsl:text>
        <xsl:call-template name="xslbase">
          <xsl:with-param name="path" select="substring-after($path, '\')"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- <*>, modèle par défaut d'interception des éléments non pris en charge -->
  <xsl:template match="*">
    <span class="error">
      <xsl:call-template name="tag"/>
      <xsl:apply-templates/>
      <b style="color:red">
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt;</xsl:text>
      </b>
    </span>
  </xsl:template>
  <!-- Utile au déboguage, affichage de l'élément en cours -->
  <xsl:template name="tag">
    <b style="color:red">
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:for-each select="@*">
        <xsl:text> </xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>="</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
      </xsl:for-each>
      <xsl:text>&gt;</xsl:text>
    </b>
  </xsl:template>
  <!--
    AGA, xslt 1 donc pas de fonction replace, un template pour y remedier.
  -->
  <xsl:template name="string-replace-all">
    <xsl:param name="text"/>
    <xsl:param name="replace"/>
    <xsl:param name="by"/>
    <xsl:choose>
      <xsl:when test="contains($text,$replace)">
        <xsl:value-of select="substring-before($text,$replace)"/>
        <xsl:value-of select="$by"/>
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text" select="substring-after($text,$replace)"/>
          <xsl:with-param name="replace" select="$replace"/>
          <xsl:with-param name="by" select="$by"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- attribut de dates en fonctions de la valeur courant,
dégrossi le travail, mais du reste à faire  -->
  <xsl:template name="date">
    <!-- arondir dates inventées -->
    <xsl:choose>
      <!-- déjà des attributs -->
      <xsl:when test="@notBefore and @notAfter and @notAfter=@notBefore">
        <xsl:attribute name="when">
          <xsl:value-of select="@notAfter"/>
        </xsl:attribute>
      </xsl:when>
      <!-- notBefore="1200-09-01" notAfter="1200-09-30" -->
      <xsl:when test="substring(@notBefore, 8, 3) = '-01' and contains('-30-31-28', substring(@notAfter, 8, 3))">
        <xsl:attribute name="when">
          <xsl:value-of select="substring(@notBefore, 1, 7)"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="@notBefore|@notAfter|@when">
        <xsl:copy-of select="@*"/>
      </xsl:when>
      <!-- deux dates, problème -->
      <xsl:when test="contains(., ')(')">
        <!-- xsl:message>Acte <xsl:value-of select="ancestor::text[1]/@n"/>, 2 dates <xsl:value-of select="."/></xsl:message --> </xsl:when>
      <!-- que des chiffres, année ? -->
      <xsl:when test="translate(., '()1234567890.', '') = ''">
        <xsl:attribute name="when">
          <xsl:value-of select="translate(., '(). ', '')"/>
        </xsl:attribute>
      </xsl:when>
      <!-- date simple -->
      <xsl:when test="starts-with(., '(Vers')">
        <xsl:attribute name="when">
          <xsl:value-of select="translate(., '(Vers) ', '')"/>
        </xsl:attribute>
      </xsl:when>
      <!-- date simple -->
      <xsl:when test="starts-with(., '(Avant')">
        <xsl:attribute name="notAfter">
          <xsl:value-of select="translate(., '(Avant) ', '')"/>
        </xsl:attribute>
      </xsl:when>
      <!-- date simple -->
      <xsl:when test="starts-with(., '(Après')">
        <xsl:attribute name="notBefore">
          <xsl:value-of select="translate(., '(Après) ', '')"/>
        </xsl:attribute>
      </xsl:when>
      <!-- période -->
      <xsl:when test="starts-with(., '(Entre')">
        <xsl:attribute name="notBefore">
          <xsl:value-of select="substring-before(substring-after(., 'Entre '), ' ')"/>
        </xsl:attribute>
        <xsl:attribute name="notAfter">
          <xsl:value-of select="translate( substring-before(substring-after(., 'et '), ')') , '(). ', '')"/>
        </xsl:attribute>
      </xsl:when>
      <!-- cas non pris en compte, à remplir ensuite -->
      <xsl:otherwise>
        <!-- xsl:message>Acte <xsl:value-of select="ancestor::text[1]/@n"/>, date non prise en charge <xsl:value-of select="."/></xsl:message --> </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Pour débogage afficher un path -->
  <xsl:template name="idpath">
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:if test="count(../*[name()=name(current())]) &gt; 1">
        <xsl:text>[</xsl:text>
        <xsl:number/>
        <xsl:text>]</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <!-- Mettre un point à la fin d'un contenu -->
  <xsl:template name="dot">
    <xsl:param name="current" select="."/>
    <xsl:variable name="lastChar" select="substring($current, string-length($current))"/>
    <xsl:if test="translate($lastChar, '.?!,;:', '') != ''">. </xsl:if>
  </xsl:template>
  <!--
Historique
==========

* 2010-03 [FG] Factorisation et documentation pour présentation CCH
* 2009-07 [FG] Création à partir des corpus sanctoral et cartulairesIdF

-->
</xsl:transform>
