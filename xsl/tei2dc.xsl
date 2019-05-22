<?xml version="1.0" encoding="UTF-8"?>
<!--
© 2013, 2014, 2015 Frédéric Glorieux, licence  <a href="http://www.gnu.org/licenses/lgpl.html">LGPL</a>

Extract Dublin Core properties from a TEI header with a catch logic
to control order and redundancy of a record.


-->
<xsl:transform version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  exclude-result-prefixes="tei date">
  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
  <xsl:param name="filename"/>
  <!-- Format dc-value, by default, text, could be html -->
  <xsl:param name="dc-value"/>
  <!-- not used for metadata but for possible generated labels -->
  <xsl:variable name="lang">
    <xsl:choose>
        <xsl:when test="tei:profileDesc/tei:langUsage/tei:language">
          <xsl:value-of select="tei:profileDesc/tei:langUsage/tei:language/@ident"/>
        </xsl:when>
        <xsl:when test="/*/@xml:lang">
          <xsl:value-of select="/*/@xml:lang"/>
        </xsl:when>
      </xsl:choose>
  </xsl:variable>
  <xsl:variable name="ABC">ABCDEFGHIJKLMNOPQRSTUVWXYZÀÂÄÉÈÊÏÎÔÖÛÜÇàâäéèêëïîöôüû</xsl:variable>
  <xsl:variable name="abc">abcdefghijklmnopqrstuvwxyzaaaeeeiioouucaaaeeeeiioouu</xsl:variable>
  <xsl:variable name="lf" select="'&#10;'"/>
  <xsl:template name="mydc">
    <!-- Could be overrided by import transformation -->
  </xsl:template>
   <!-- A mode to get the values for fields, html or text plain -->
  <xsl:template name="dc-value">
    <xsl:choose>
      <xsl:when test="$dc-value = 'html'">
        <xsl:apply-templates mode="dc-html"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="dc-text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/*">
    <xsl:apply-templates select="." mode="dc"/>
  </xsl:template>

  <xsl:template match="tei:TEI|tei:TEI.2" mode="dc">
    <xsl:apply-templates select="tei:teiHeader" mode="dc"/>
  </xsl:template>
    
  <xsl:template match="tei:teiHeader" mode="dc">
    <!-- It is not the right context to handle that, too much infos are server dependant, and not source dependant -->
    <!--
    <header>
      <identifier>
        <xsl:value-of select="$oai_id_prefix"/>
        <xsl:value-of select="$filename"/>
      </identifier>
      <datestamp><xsl:value-of select="date:date-time()"/></datestamp>
    </header>
    -->
    <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
      <xsl:choose>
        <xsl:when test="/*/@xml:id">
          <xsl:attribute name="xml:id">
            <xsl:value-of select="/*/@xml:id"/>
          </xsl:attribute>
        </xsl:when>
        <!-- Ajouter ici un filename ? -->
      </xsl:choose>
      <!-- 1! title -->
      <!-- TODO: Aggregate subtitles ? translated titles ? -->
      <xsl:apply-templates select="tei:fileDesc/tei:titleStmt/tei:title[1]" mode="dc"/>
      <!-- n? creator -->
      <xsl:choose>
        <xsl:when test="tei:fileDesc/tei:titleStmt/tei:author">
          <xsl:apply-templates select="tei:fileDesc/tei:titleStmt/tei:author" mode="dc"/>
        </xsl:when>
        <!-- specific BVH, msDesc before a <bibl> ? -->
        <xsl:when test="tei:fileDesc/tei:sourceDesc/tei:msDesc[1]//tei:biblStruct">
          <xsl:apply-templates select="tei:fileDesc/tei:sourceDesc/tei:msDesc[1]//tei:biblStruct/*/tei:author" mode="dc"/>
        </xsl:when>
        <xsl:when test="tei:fileDesc/tei:sourceDesc/tei:bibl[1][tei:author]">
          <xsl:apply-templates select="tei:fileDesc/tei:sourceDesc/tei:bibl[1][tei:author]/tei:author" mode="dc"/>
        </xsl:when>
      </xsl:choose>
      <!-- 1? significant date -->
      <xsl:variable name="date">
        <xsl:choose>
          <xsl:when test="tei:profileDesc/tei:creation/tei:date">
            <xsl:apply-templates select="tei:profileDesc/tei:creation/tei:date[1]" mode="year"/>
          </xsl:when>
          <!-- specific BVH, msDesc before a <bibl> ? -->
          <xsl:when test="tei:fileDesc/tei:sourceDesc/tei:msDesc[1]//tei:date">
            <xsl:apply-templates select="(tei:fileDesc/tei:sourceDesc/tei:msDesc[1]//tei:date)[1]" mode="year"/>
          </xsl:when>
          <xsl:when test="tei:fileDesc/tei:sourceDesc/tei:bibl[1][tei:date]">
            <xsl:apply-templates select="(tei:fileDesc/tei:sourceDesc/tei:bibl[1][tei:date]//tei:date)[1]" mode="year"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="$date != ''">
        <dc:date>
          <xsl:value-of select="$date"/>
        </dc:date>
      </xsl:if>
      <xsl:variable name="date2">
        <xsl:choose>
          <xsl:when test="tei:fileDesc/tei:sourceDesc//tei:date">
            <xsl:apply-templates select="(tei:fileDesc/tei:sourceDesc//tei:date)[1]" mode="year"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="$date2 != $date and $date2 != ''">
        <dcterms:dateCopyrighted>
          <xsl:value-of select="$date2"/>
        </dcterms:dateCopyrighted>
      </xsl:if>
      <xsl:if test="tei:fileDesc/tei:editionStmt/tei:edition[position()=last()]//tei:date">
        <dcterms:issued>
          <xsl:apply-templates select="(tei:fileDesc/tei:editionStmt/tei:edition[position()=last()]//tei:date)[1]" mode="year"/>
        </dcterms:issued>
      </xsl:if>
      <!-- n? contributor -->
      <xsl:apply-templates select="tei:fileDesc/tei:titleStmt/tei:editor" mode="dc"/>
      <xsl:apply-templates select="tei:fileDesc/tei:titleStmt/tei:principal" mode="dc"/>
      <!-- n? publisher -->
      <xsl:apply-templates select="tei:fileDesc/tei:publicationStmt/tei:publisher" mode="dc"/>
      <xsl:apply-templates select="tei:fileDesc/tei:publicationStmt/tei:authority" mode="dc"/>
      <!-- 1! identifier -->
      <xsl:choose>
        <xsl:when test="tei:fileDesc/tei:publicationStmt/tei:idno">
            <xsl:apply-templates select="tei:fileDesc/tei:publicationStmt/tei:idno" mode="dc"/>
        </xsl:when>
        <!-- specific  -->
        <xsl:when test="tei:fileDesc/tei:editionStmt/tei:edition/@xml:base">
          <dc:identifier>
            <xsl:value-of select="tei:fileDesc/tei:editionStmt/tei:edition/@xml:base"/>
          </dc:identifier>
        </xsl:when>
      </xsl:choose>
      <!-- n? language -->
      <xsl:choose>
        <xsl:when test="tei:profileDesc/tei:langUsage/tei:language">
          <xsl:apply-templates select="tei:profileDesc/tei:langUsage/tei:language" mode="dc"/>
        </xsl:when>
        <xsl:when test="/*/@xml:lang">
          <dc:language>
            <xsl:value-of select="/*/@xml:lang"/>
          </dc:language>
        </xsl:when>
      </xsl:choose>
      <!-- 1! rights -->
      <xsl:apply-templates select="tei:fileDesc/tei:publicationStmt/tei:availability" mode="dc"/>
      <!-- n? description -->
      <xsl:choose>
        <xsl:when test="tei:fileDesc/tei:notesStmt/tei:note[@type='abstract']">
          <xsl:apply-templates select="tei:fileDesc/tei:notesStmt/tei:note[@type='abstract']" mode="dc"/>
        </xsl:when>
        <xsl:when test="/*/tei:text/tei:front/tei:argument">
          <xsl:apply-templates select="/*/tei:text/tei:front/tei:argument" mode="dc"/>
        </xsl:when>
        <xsl:when test="/*/tei:text/tei:body/tei:argument">
          <xsl:apply-templates select="/*/tei:text/tei:body/tei:argument" mode="dc"/>
        </xsl:when>
        <!-- pas Acte I, Acte II… -->
        <xsl:when test="/*/tei:text/tei:body/*[@type='act' or @type='acte']"/>
        <xsl:when test="/*/tei:text/tei:body/*[tei:head]">
          <dc:description>
            <xsl:for-each select="/*/tei:text/tei:body/*[tei:head]">
              <xsl:if test="position() != 1">
                <xsl:text> — </xsl:text>
              </xsl:if>
              <xsl:variable name="chapter">
                <xsl:for-each select="tei:head">
                  <xsl:variable name="headraw">
                    <xsl:call-template name="dc-value"/>
                  </xsl:variable>
                  <xsl:variable name="head" select="normalize-space($headraw)"/>
                  <xsl:value-of select="$head"/>
                  <xsl:variable name="last" select="substring($head, string-length($head))"/>
                  <xsl:if test="position() != last() and not(contains('!,?.;:', $last))">
                    <xsl:text>.</xsl:text>
                  </xsl:if>
                  <xsl:text> </xsl:text>
                </xsl:for-each>
                <xsl:choose>
                  <xsl:when test="tei:argument and count(tei:head) = 1 and string-length(tei:head) &lt; 10">
                    <xsl:text> </xsl:text>
                    <xsl:for-each select="tei:argument[1]">
                      <xsl:call-template name="dc-value"/>
                    </xsl:for-each>
                  </xsl:when>
                </xsl:choose>
              </xsl:variable>
              
              <xsl:value-of select="normalize-space($chapter)"/>
              <xsl:value-of select="$lf"/>
            </xsl:for-each>
          </dc:description>
        </xsl:when>
      </xsl:choose>
      <!-- 1? source -->
      <xsl:apply-templates select="tei:fileDesc/tei:sourceDesc/tei:bibl[1]" mode="dc"/>
      <!-- n? subject -->
      <xsl:apply-templates select="tei:profileDesc/tei:textClass//tei:term" mode="dc"/>
      <xsl:call-template name="mydc"/>
    </oai_dc:dc>
  </xsl:template>
  
  <!-- 
    METADATA
  -->
  
  <!-- http://weboai.sourceforge.net/teiHeader.html#el_idno -->
  <!-- obligatoire, unique -->
  <xsl:template match="tei:publicationStmt/tei:idno" mode="dc">
    <xsl:choose>
      <xsl:when test=". != '' and . != '?'">
        <dc:identifier>
          <xsl:apply-templates select="@type" mode="dc"/>
          <xsl:apply-templates/>
        </dc:identifier>
        <xsl:choose>
          <xsl:when test="@type = 'tei'">
            <dc:format>text/xml</dc:format>
          </xsl:when>
          <xsl:when test="@type = 'epub'">
            <dc:format>application/epub+zip</dc:format>
          </xsl:when>
          <xsl:when test="@type = 'txt'">
            <dc:format>text/plain</dc:format>
          </xsl:when>
          <xsl:when test="@type = 'text'">
            <dc:format>text/plain</dc:format>
          </xsl:when>
          <xsl:when test="@type = 'html'">
            <dc:format>text/html</dc:format>
          </xsl:when>
          <xsl:otherwise>
            <dc:format>text/html</dc:format>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:idno/@type" mode="dc">
    <xsl:attribute name="scheme">
      <xsl:value-of select="translate(., '-', '/')"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- http://weboai.sourceforge.net/teiHeader.html#el_title -->
  <!-- obligatoire, unique -->
  <xsl:template match="tei:titleStmt/tei:title" mode="dc">
    <dc:title>
      <xsl:copy-of select="@xml:lang"/>
      <xsl:call-template name="dc-value"/>
    </dc:title>
  </xsl:template>
  <xsl:template match="tei:title/tei:note" mode="dc"/>
  <!-- http://weboai.sourceforge.net/teiHeader.html#el_author -->
  <!-- http://weboai.sourceforge.net/teiHeader.html#el_editor -->
  <!-- http://weboai.sourceforge.net/teiHeader.html#el_publisher -->
  <!-- optionnel, répétable -->
  <xsl:template match="tei:author | tei:principal | tei:titleStmt/tei:editor | tei:publicationStmt/tei:publisher | tei:publicationStmt/tei:authority" name="pers" mode="dc">
    <xsl:variable name="text">
      <xsl:choose>
        <xsl:when test="@key">
          <xsl:value-of select="@key"/>
        </xsl:when>
  <!-- Because life is life
<author role="auteur">
<persName key="pers1">
      <surname>Rabelais</surname><forename>François</forename>
</persName>
</author>
  -->
        <xsl:when test=".//tei:surname">
          <xsl:for-each select=".//tei:surname">
            <xsl:call-template name="dc-value"/>
          </xsl:for-each>
          <xsl:for-each select=".//tei:forename">
            <xsl:text>, </xsl:text>
            <xsl:call-template name="dc-value"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="dc-value"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($text)=''"/>
      <xsl:when test="self::tei:author">
        <dc:creator>
          <xsl:value-of select="normalize-space($text)"/>
        </dc:creator>
      </xsl:when>
      <xsl:when test="self::tei:editor">
        <dc:contributor>
          <xsl:value-of select="normalize-space($text)"/>
          <xsl:text> (</xsl:text>
          <xsl:choose>
            <xsl:when test="$lang = 'fr'">édition</xsl:when>
            <xsl:otherwise>edition</xsl:otherwise>
          </xsl:choose>
          <xsl:text>)</xsl:text>
        </dc:contributor>
      </xsl:when>
      <xsl:when test="self::tei:principal">
        <dc:contributor>
          <xsl:value-of select="normalize-space($text)"/>
          <xsl:text> (</xsl:text>
          <xsl:choose>
            <xsl:when test="$lang = 'fr'">direction</xsl:when>
            <xsl:otherwise>direction</xsl:otherwise>
          </xsl:choose>
          <xsl:text>)</xsl:text>
        </dc:contributor>
      </xsl:when>      <xsl:when test="self::tei:publisher | self::tei:authority">
        <dc:publisher>
          <xsl:value-of select="normalize-space($text)"/>
        </dc:publisher>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message><xsl:value-of select="$filename"/> : <xsl:value-of select="$text"/> (role?)</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- http://weboai.sourceforge.net/teiHeader.html#el_licence -->
  <!-- obligatoire, unique -->
  <xsl:template match="tei:availability" mode="dc">
      <xsl:choose>
        <xsl:when test="tei:licence/@target = '' or tei:licence/@target = '?'"/>
        <xsl:when test="tei:licence/@target">
          <dc:rights>
            <xsl:value-of select="tei:licence/@target"/>
          </dc:rights>
        </xsl:when>
        <xsl:when test=". ='' or . ='?'"/>
        <xsl:otherwise>
          <dc:rights>
            <xsl:call-template name="dc-value"/>
          </dc:rights>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
  <!-- http://weboai.sourceforge.net/teiHeader.html#el_idno_2 -->
  <!-- optionnel, ? -->
  <!-- revoir pertinence en fonction de l’implémentation oai des moissonneurs -->
  <xsl:template match="tei:seriesStmt/tei:idno" mode="dc">
    <dcterms:isPartOf><xsl:apply-templates/></dcterms:isPartOf>
  </xsl:template>
  
  <!-- http://weboai.sourceforge.net/teiHeader.html#el_note -->
  <!-- optionnel, répétable par langue -->
  <xsl:template match="tei:notesStmt/tei:note[@type='abstract'] | tei:argument">
    <dc:description>
      <xsl:copy-of select="@xml:lang"/>
      <xsl:call-template name="dc-value"/>
    </dc:description>
  </xsl:template>
  
  <!-- TODO l’URI de la vignette en note ne relève pas de l’OAI mais de la seule application Weboai -> on fait quoi ? 
  [FG] pas de vignette, le client ne peut pas savoir le format dont on a besoin, une image de couverture suffit
  Mais de toute façon, pour l’application, il n’y a de vignette que par corpus, fournies par l’extérieur
  -->
  
  <!-- http://weboai.sourceforge.net/teiHeader.html#el_bibl -->
  <!-- unique, obligatoire -->
  <xsl:template match="tei:sourceDesc/tei:bibl" mode="dc">
    <xsl:choose>
      <xsl:when test=".='' or .='?'"/>
      <xsl:otherwise>
        <dc:source>
          <xsl:call-template name="dc-value"/>
        </dc:source>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- http://weboai.sourceforge.net/teiHeader.html#el_creation -->
  <!-- unique, obligatoire -->
  <xsl:template match="tei:date" mode="dc">
    <dc:date>
      <xsl:call-template name="year"/>
    </dc:date>
  </xsl:template>

  <xsl:template match="tei:language">
    <dc:language>
      <xsl:value-of select="@ident"/>
    </dc:language>
  </xsl:template>

  
  <xsl:template name="lang">
    <xsl:param name="code" select="@xml:lang|@ident"/>
    <xsl:variable name="lang" select="translate($code, $ABC, $abc)"/>
    <xsl:choose>
      <xsl:when test="$lang = 'fr'">fre</xsl:when>
      <xsl:when test="$lang = 'en'">eng</xsl:when>
      <xsl:when test="$lang = 'la'">lat</xsl:when>
      <xsl:when test="$lang = 'gr'">grc</xsl:when>
      <xsl:when test="$lang = 'xx'">xxx</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Get a year from a date tag with different possible attributes -->
  <xsl:template match="*" mode="year" name="year">
    <xsl:choose>
      <xsl:when test="@when">
        <xsl:value-of select="substring(@when,1,4)"/>
      </xsl:when>
      <xsl:when test="@notAfter">
        <xsl:value-of select="substring(@notAfter,1,4)"/>
      </xsl:when>
      <xsl:when test="@notBefore">
        <xsl:value-of select="substring(@notBefore,1,4)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="text" select="string(.)"/>
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
  
  <!-- http://weboai.sourceforge.net/teiHeader.html#el_term -->
  <!-- optionnel, répétable -->
  <xsl:template match="tei:textClass//tei:term" mode="dc">
    <dc:subject><xsl:apply-templates/></dc:subject>
  </xsl:template>
  <xsl:template match="*" mode="dc-html">
    <xsl:apply-templates mode="dc-html"/>
  </xsl:template>
  <xsl:template match="tei:lb" mode="dc-html">
    <xsl:value-of select="$lf"/>
  </xsl:template>
  <xsl:template match="tei:note" mode="dc-html"/>
  <xsl:template match="tei:p" mode="dc-html">
    <p>
      <xsl:apply-templates mode="dc-html"/>
    </p>
  </xsl:template>
  <xsl:template match="tei:hi" mode="dc-html">
    <xsl:variable name="rend" select="translate(@rend, $ABC, $abc)"/>
    <xsl:choose>
      <xsl:when test=". =''"/>
      <!-- si @rend est un nom d'élément HTML -->
      <xsl:when test="contains( ' b big em i s small strike strong sub sup tt u ', concat(' ', $rend, ' '))">
        <xsl:element name="{$rend}" namespace="http://www.w3.org/1999/xhtml">
          <xsl:if test="@type">
            <xsl:attribute name="class">
              <xsl:value-of select="@type"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates mode="dc-html"/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="starts-with($rend, 'it')">
        <i>
          <xsl:apply-templates mode="dc-html"/>
        </i>
      </xsl:when>
      <xsl:when test="starts-with($rend, 'ind')">
        <sub>
          <xsl:apply-templates mode="dc-html"/>
        </sub>
      </xsl:when>
      <xsl:when test="starts-with($rend, 'exp')">
        <sup>
          <xsl:apply-templates mode="dc-html"/>
        </sup>
      </xsl:when>
      <xsl:when test="$rend = ''">
        <em>
          <xsl:apply-templates mode="dc-html"/>
        </em>
      </xsl:when>
      <!-- generic conteneur ? -->
      <xsl:otherwise>
        <xsl:apply-templates mode="dc-html"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:title" mode="dc-html">
    <em class="title">
      <xsl:apply-templates mode="dc-html"/>
    </em>
  </xsl:template>
  <xsl:template match="tei:ref" mode="dc-html">
    <a>     
      <xsl:attribute name="href">
        <xsl:value-of select="@target"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test=". != ''">
          <xsl:apply-templates mode="dc-html"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@target"/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>
  <xsl:template match="*" mode="dc-text">
    <xsl:apply-templates mode="dc-text"/>
  </xsl:template>
  <xsl:template match="tei:lb" mode="dc-text">
    <xsl:value-of select="$lf"/>
  </xsl:template>
  <xsl:template match="tei:note" mode="dc-text"/>
  <xsl:template match="tei:p" mode="dc-text">
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates mode="dc-text"/>
    <xsl:value-of select="$lf"/>
  </xsl:template>
</xsl:transform>