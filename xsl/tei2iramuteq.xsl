<?xml version="1.0" encoding="UTF-8"?>
<!--

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2013 Frederic.Glorieux@fictif.org et LABEX OBVIL

Extraction du texte d'un corpus TEI pour recherche plein texte ou traitements linguistiques
(ex : suppressions des notes, résolution de l'apparat)
Doit pouvoir fonctionner en import.


-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
  >
  <!-- Importer des dates -->
  <xsl:import href="common.xsl"/>
  <xsl:key name="split" match="/" use="'root'"/>
  <!-- Key on structural items, do not use the keyword "split", or it will override the split key for 2site  -->
  <xsl:key name="div" match="*[descendant-or-self::*[starts-with(local-name(), 'div')][@type][contains(@type, 'article') or contains(@type, 'letter') or contains(@type, 'scene') or contains(@type, 'act') or contains(@type, 'chapter') or contains(@type, 'poem') or contains(@subtype, 'split')]] | tei:group/tei:text | tei:TEI/tei:text/tei:front/* | tei:TEI/tei:text/tei:back/* | tei:TEI/tei:text/tei:body/* " use="generate-id(.)"/>
  <xsl:variable name="who1">ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïñòóôõöùúûüý -’'</xsl:variable>
  <xsl:variable name="who2">abcdefghijklmnopqrstuvwxyzaaaaaaceeeeiiiinooooouuuuyaaaaaaceeeeiiiinooooouuuuy__</xsl:variable>
  <xsl:key name="who" match="tei:sp" use="@who"/>
  <xsl:key name="role" match="tei:castList//tei:role" use="@xml:id"/>
  <!-- Clé sur les personnages ? -->
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" method="text" indent="yes"/>
  <!-- Permet l'indentation des éléments de structure -->
  <xsl:strip-space elements="tei:TEI tei:TEI.2 tei:body tei:castList  tei:div tei:div1 tei:div2  tei:docDate tei:docImprint tei:docTitle tei:fileDesc tei:front tei:group tei:index tei:listWit tei:publicationStmp tei:publicationStmt tei:sourceDesc tei:SourceDesc tei:sources tei:text tei:teiHeader tei:text tei:titleStmt"/>
  <xsl:preserve-space elements="tei:l tei:p tei:s "/>
  <xsl:variable name="apos">'</xsl:variable>
  <xsl:variable name="quot">"</xsl:variable>
  <xsl:template match="/">
    <xsl:apply-templates mode="iramuteq"/>
  </xsl:template>
  <xsl:template match="*" mode="iramuteq">
    <xsl:apply-templates mode="iramuteq"/>
  </xsl:template>
  <xsl:template match="/*" mode="iramuteq">
    <book>
      <xsl:apply-templates mode="iramuteq"/>
      <xsl:value-of select="$lf"/>
    </book>
  </xsl:template>
  <!-- éléments à arrêter -->
  <xsl:template match="tei:ref[not(node())] | tei:teiHeader" mode="iramuteq"/>
  <xsl:template match="tei:back | tei:front | tei:note" mode="iramuteq"/>
  <xsl:template match="tei:figure" mode="iramuteq"/>
  <xsl:template match="tei:bibl | tei:listBibl | tei:cit" mode="iramuteq"/>
  <!-- Pour bulle, garder la biblio dans une note -->
  <xsl:template match="tei:note//tei:bibl | tei:note//tei:cit" mode="iramuteq">
    <xsl:apply-templates mode="iramuteq"/>
  </xsl:template>
  <xsl:template match="tei:cb | tei:fw | tei:g | tei:pb" mode="iramuteq">
    <xsl:if test="translate(substring(following-sibling::node()[1], 1, 1), '  ,;.?!…:*$€', '') != ''">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:castList" mode="iramuteq"/>
  <xsl:template match="tei:sp" mode="iramuteq">
    <!-- iramuteq title -->
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:text>-*who_</xsl:text>
    <xsl:variable name="who">
      <xsl:choose>
        <xsl:when test="@who">
          <xsl:value-of select="translate(@who, $who1, $who2)"/>
        </xsl:when>
        <xsl:when test="tei:speaker">
          <xsl:value-of select="translate(tei:speaker, $who1, $who2)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$who"/>
    <!-- only one var allowed
          <xsl:variable name="role" select="key('role', $who)"/>
          <xsl:if test="$role/@civil">
            <xsl:value-of select="$lf"/>
            <xsl:text>-*civil_</xsl:text>
            <xsl:value-of select="$role/@civil"/>
          </xsl:if>
          -->
    <xsl:apply-templates select="*" mode="iramuteq"/>
  </xsl:template>
  <xsl:template match="tei:speaker" mode="iramuteq"/>
  <xsl:template match="tei:stage" mode="iramuteq"/>

  <!-- Ligne sans indentation -->
  <xsl:template match="tei:person | tei:event | tei:place" mode="iramuteq">
    <xsl:apply-templates select="*" mode="iramuteq"/>
  </xsl:template>
  <xsl:template match="tei:birth" mode="iramuteq">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates mode="iramuteq"/>
    <xsl:text>–</xsl:text>
    <xsl:if test="not(following-sibling::tei:death)">–…) </xsl:if>
  </xsl:template>
  <xsl:template match="tei:death" mode="iramuteq">
    <xsl:if test="not(preceding-sibling::tei:death)"> (…</xsl:if>
    <xsl:text>–</xsl:text>
    <xsl:apply-templates mode="iramuteq"/>
    <xsl:text>) </xsl:text>
  </xsl:template>
  <xsl:template match="tei:location" mode="iramuteq">
    <xsl:text> (</xsl:text>
    <xsl:for-each select="*">
      <xsl:if test="position() != 1">, </xsl:if>
      <xsl:apply-templates select="." mode="iramuteq"/>
    </xsl:for-each>
    <xsl:text>) </xsl:text>
  </xsl:template>
  <!-- Verse, no division by sentence -->
  <xsl:template match="tei:l" mode="iramuteq">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="iramuteq"/>
    </xsl:variable>
    <xsl:value-of select="$lf"/>
    <xsl:if test="@part = 'f' or @part = 'F' or @part = 'm' or @part = 'M' ">
      <xsl:text>      </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space($txt)"/>
  </xsl:template>
  <xsl:template match="tei:lg" mode="iramuteq">
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates select="*" mode="iramuteq"/>
  </xsl:template>
  <xsl:template match="tei:byline" mode="iramuteq">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="iramuteq"/>
    </xsl:variable>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="normalize-space($txt)"/>
    <xsl:copy-of select="$lf"/>
  </xsl:template>
  <xsl:template match="tei:p " mode="iramuteq">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="iramuteq"/>
    </xsl:variable>
    <!-- Spacing ? -->
    <xsl:choose>
      <xsl:when test="ancestor::tei:note and position()=1"/>
      <xsl:when test="ancestor::tei:note">
        <xsl:value-of select="$lf"/>
        <xsl:text>    </xsl:text>
      </xsl:when>
      <xsl:when test="parent::tei:sp">
        <xsl:value-of select="$lf"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$lf"/>
        <xsl:copy-of select="$lf"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="sent">
      <xsl:with-param name="txt" select="normalize-space($txt)"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:lb" mode="iramuteq">
    <xsl:value-of select="$lf"/>
  </xsl:template>
  <!-- Corpus lemmatisé -->
  <xsl:template match="tei:l[tei:w] | tei:p[tei:w]" mode="iramuteq">
    <xsl:value-of select="$lf"/>
    <xsl:for-each select="*">
      <xsl:variable name="last" select="substring(preceding-sibling::tei:*[1], string-length(preceding-sibling::tei:*[1]))"/>
      <xsl:choose>
        <xsl:when test="position()=1"/>
        <xsl:when test=". = $apos or .=$quot"/>
        <!-- espace insécable pour ponctuation double -->
        <xsl:when test="substring-before('$;:!?»', .)"> </xsl:when>
        <!-- ponctuation simple -->
        <xsl:when test="substring-before('$...…,‘’()[]“”', .)"/>
        <xsl:when test="$last=$apos or $last=$quot or substring-before('$’  ', $last)"/>
        <xsl:when test="starts-with(., '-')"/>
        <xsl:otherwise>
          <xsl:text> </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="iramuteq"/>
    </xsl:for-each>
  </xsl:template>
  <!-- Mot de corpus lemmatisé -->
  <xsl:template match="tei:w | tei:c" mode="iramuteq">
    <xsl:value-of select="."/>
  </xsl:template>
  <!-- Sections, split candidates -->
  <xsl:template match="
    tei:body | tei:group |
    tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div4 | tei:div5 | tei:div6 | tei:div7 
" mode="iramuteq">
    <xsl:choose>
      <!-- section avec juste des notes -->
      <xsl:when test="not(tei:div | tei:div1 | tei:div2 | tei:div3 | tei:l | tei:lg | tei:list | tei:p | tei:quote | tei:sp )"/>
      <!-- Empty parent section -->
      <xsl:when test="descendant::*[key('div', generate-id())]">
        <!-- Process other children -->
        <xsl:apply-templates select="tei:group | tei:div | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6" mode="iramuteq"/>
      </xsl:when>
      <!-- Should be last level to split -->
      <xsl:when test="key('div', generate-id())">
        <xsl:call-template name="iratext"/>
        <xsl:apply-templates select="*" mode="iramuteq"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*" mode="iramuteq"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- iramuteq title -->
  <xsl:template name="iratext">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:text>****</xsl:text>
    <xsl:text> *book_</xsl:text>
    <xsl:choose>
      <xsl:when test="/*/@xml:id">
        <xsl:value-of select="/*/@xml:id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$filename"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> *id_</xsl:text>
    <xsl:call-template name="id"/>
    <xsl:if test="@type='scene'">
      <xsl:text> *act_</xsl:text>
      <xsl:value-of select="../@xml:id"/>
    </xsl:if>
    <xsl:variable name="created">
      <xsl:choose>
        <xsl:when test="tei:docDate">
          <xsl:apply-templates select="tei:docDate[1]" mode="year"/>
        </xsl:when>
        <xsl:when test="tei:dateline/tei:docDate">
          <xsl:apply-templates select="(tei:dateline/tei:docDate)[1]" mode="year"/>
        </xsl:when>
        <xsl:when test="tei:byline/tei:docDate">
          <xsl:apply-templates select="(tei:byline/tei:docDate)[1]" mode="year"/>
        </xsl:when>
        <xsl:when test="$docdate">
          <xsl:value-of select="$docdate"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$created != ''">
      <xsl:text> *date_</xsl:text>
      <xsl:value-of select="$created"/>
    </xsl:if>
    <xsl:variable name="creator">
      <xsl:variable name="key" select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/@key"/>
      <xsl:choose>
        <xsl:when test="$key != ''">
          <xsl:value-of select="translate(normalize-space(substring-before(concat(substring-before(concat($key, '('), '('), ','), ',')), $who1, $who2)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$creator != ''">
      <xsl:text> *creator_</xsl:text>
      <xsl:value-of select="$creator"/>
    </xsl:if>
    <xsl:for-each select="tei:index[@indexName]">
      <xsl:text> *</xsl:text>
      <xsl:value-of select="translate(@indexName, $who1, $who2)"/>
      <xsl:text>_</xsl:text>
      <xsl:choose>
        <xsl:when test="@n">
          <xsl:value-of select="translate(@n, $who1, $who2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(., $who1, $who2)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <!-- index/term ? -->
  </xsl:template>
  <xsl:template match="tei:index" mode="iramuteq"/>
  <xsl:template match="*[@type='letter' or @type='act' or @type='scene']/tei:head" mode="iramuteq"/>
  <xsl:template match="tei:head" mode="iramuteq">
    <xsl:variable name="level" select="count(ancestor::*[tei:head])"/>
    <xsl:variable name="text">
      <xsl:apply-templates mode="iramuteq"/>
    </xsl:variable>

        <xsl:value-of select="$lf"/>
        <xsl:value-of select="$lf"/>
        <xsl:value-of select="normalize-space($text)"/>

  </xsl:template>
  <!-- Intertitre -->
  <xsl:template match="tei:label" mode="iramuteq"/>
  <xsl:template match="tei:dateline | tei:salute | tei:signed | tei:trailer" mode="iramuteq"/>
  <!-- Rétablissement de césure -->
  <xsl:template match="tei:caes" mode="iramuteq">
    <xsl:choose>
      <xsl:when test="@whole">
        <xsl:value-of select="@whole"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- Mot ajouté -->
  <xsl:template match="tei:supplied" mode="iramuteq">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates mode="iramuteq"/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  <!-- alternative critique -->
  <xsl:template match="tei:app" mode="iramuteq">
    <xsl:apply-templates select="tei:lem" mode="iramuteq"/>
  </xsl:template>
  <xsl:template match="tei:choice" mode="iramuteq">
    <xsl:choose>
      <xsl:when test="tei:corr">
        <xsl:apply-templates select="tei:corr" mode="iramuteq"/>
      </xsl:when>
      <xsl:when test="tei:expan">
        <xsl:apply-templates select="tei:expan" mode="iramuteq"/>
      </xsl:when>
      <xsl:when test="tei:reg">
        <xsl:apply-templates select="tei:reg" mode="iramuteq"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[1]" mode="iramuteq"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Table -->
  <xsl:template match="tei:table" mode="iramuteq">
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates select="*" mode="iramuteq"/>
    <xsl:value-of select="$lf"/>
  </xsl:template>
  <xsl:template match="tei:row" mode="iramuteq">
    <xsl:apply-templates select="*" mode="iramuteq"/>
    <xsl:value-of select="$lf"/>
  </xsl:template>
  <xsl:template match="tei:cell" mode="iramuteq">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="iramuteq"/>
    </xsl:variable>
    <xsl:if test="preceding-sibling::tei:cell"> | </xsl:if>
    <xsl:value-of select="normalize-space($txt)"/>
  </xsl:template>
  <!-- one sentence by line in context  -->
  <xsl:template name="sent">
    <xsl:param name="txt" select="normalize-space(.)"/>
    <xsl:variable name="maj" select="translate($txt, 
      '?!.ABCDEFGHIJKLMNOPQRSTUVWXYZÀÇÉÈÊËÎÏÔÖŒÜÛ ', 
      '...@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ')"/>
    <xsl:choose>
      <xsl:when test="contains($maj, ' « @')">
        <xsl:variable name="pos" select="string-length(substring-before($maj, ' « @'))"/>
        <xsl:call-template name="sent">
          <xsl:with-param name="txt" select="substring($txt, 1, $pos)"/>
        </xsl:call-template>
        <xsl:value-of select="$lf"/>
        <xsl:text>    </xsl:text>
        <xsl:call-template name="sent">
          <xsl:with-param name="txt" select="substring($txt, $pos + 2)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($maj, '» @')">
        <xsl:variable name="pos" select="string-length(substring-before($maj, '» @'))"/>
        <xsl:call-template name="sent">
          <xsl:with-param name="txt" select="substring($txt, 1, $pos + 1)"/>
        </xsl:call-template>
        <xsl:value-of select="$lf"/>
        <xsl:call-template name="sent">
          <xsl:with-param name="txt" select="substring($txt, $pos + 3)"/>
        </xsl:call-template>
      </xsl:when>
      <!-- H. Spencer -->
      <xsl:when test="contains($maj, '@. @')">
        <xsl:variable name="pos" select="string-length(substring-before($maj, '@. @'))"/>
        <xsl:call-template name="sent">
          <xsl:with-param name="txt" select="substring($txt, 1, $pos+1)"/>
        </xsl:call-template>
        <xsl:text>. </xsl:text>
        <xsl:call-template name="sent">
          <xsl:with-param name="txt" select="substring($txt, $pos+4)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($maj, '. @')">
        <xsl:variable name="pos" select="string-length(substring-before($maj, '. @'))"/>
        <xsl:call-template name="sent">
          <xsl:with-param name="txt" select="substring($txt, 1, $pos+1)"/>
        </xsl:call-template>
        <xsl:value-of select="$lf"/>
        <xsl:call-template name="sent">
          <xsl:with-param name="txt" select="substring($txt, $pos + 3)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$txt"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- For text, give back hand to normal processing, so that it could be overrides (= translate for some device) -->
  <xsl:template match="text()" mode="iramuteq">
    <xsl:value-of select="translate(., '’*­[]', concat( $apos, '⁎'))"/>
  </xsl:template>
</xsl:transform>