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
  <xsl:key name="div" match="*[descendant-or-self::*[starts-with(local-name(), 'div')][@type][contains(@type, 'article') or contains(@type, 'letter') or contains(@type, 'act') or contains(@type, 'chapter') or contains(@type, 'poem') or contains(@subtype, 'split')]] | tei:group/tei:text | tei:TEI/tei:text/tei:front/* | tei:TEI/tei:text/tei:back/* | tei:TEI/tei:text/tei:body/* " use="generate-id(.)"/>
  <xsl:variable name="who1">ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïñòóôõöùúûüý’'-</xsl:variable>
  <xsl:variable name="who2">abcdefghijklmnopqrstuvwxyzaaaaaaceeeeiiiinooooouuuuyaaaaaaceeeeiiiinooooouuuuy</xsl:variable>
  <xsl:key name="who" match="tei:sp" use="@who"/>
  <xsl:key name="role" match="tei:castList//tei:role" use="@xml:id"/>
  <!-- Clé sur les personnages ? -->
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" method="text" indent="yes"/>
  <!-- Permet l'indentation des éléments de structure -->
  <xsl:strip-space elements="tei:TEI tei:TEI.2 tei:body tei:castList  tei:div tei:div1 tei:div2  tei:docDate tei:docImprint tei:docTitle tei:fileDesc tei:front tei:group tei:index tei:listWit tei:publicationStmp tei:publicationStmt tei:sourceDesc tei:SourceDesc tei:sources tei:text tei:teiHeader tei:text tei:titleStmt"/>
  <xsl:preserve-space elements="tei:l tei:p tei:s "/>
  <xsl:variable name="apos">'</xsl:variable>
  <xsl:variable name="quot">"</xsl:variable>
  <xsl:variable name="male">male</xsl:variable>
  <xsl:variable name="female">female</xsl:variable>
  <xsl:variable name="neutral">neutral</xsl:variable>
  <xsl:variable name="veteran">veteran</xsl:variable>
  <xsl:variable name="senior">senior</xsl:variable>
  <xsl:variable name="junior">junior</xsl:variable>
  <xsl:variable name="noage">noage</xsl:variable>
  <xsl:variable name="superior">superior</xsl:variable>
  <xsl:variable name="free">free</xsl:variable>
  <xsl:variable name="inferior">inferior</xsl:variable>
  <xsl:variable name="exterior">exterior</xsl:variable>
  <xsl:variable name="maid">maid</xsl:variable>
  <xsl:variable name="jack">jack</xsl:variable>
  <xsl:variable name="daughter">daughter</xsl:variable>
  <xsl:variable name="son">son</xsl:variable>
  <xsl:variable name="mother">mother</xsl:variable>
  <xsl:variable name="father">father</xsl:variable>
  <xsl:variable name="other">other</xsl:variable>
  <xsl:variable name="verse">verse</xsl:variable>
  <xsl:variable name="prose">prose</xsl:variable>
  <!-- Theatre, <sp who="">, minimun count of <sp> for a <role xml:id=""> -->
  <xsl:variable name="minsp">300</xsl:variable>
  <!-- style -->
  <xsl:key name="el" match="*[ancestor::tei:body]" use="local-name()"/>
  <xsl:variable name="style">
    <xsl:choose>
      <xsl:when test="count(key('el', 'l')) &gt; count(key('el', 'p'))">
        <xsl:value-of select="$verse"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$prose"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates mode="iramuteq"/>
  </xsl:template>
  <xsl:template match="*" mode="iramuteq">
    <xsl:apply-templates mode="iramuteq"/>
  </xsl:template>
  <xsl:template match="/*" mode="iramuteq">
    <book>
      <xsl:choose>
        <!-- supposed to be theatre -->
        <xsl:when test="//tei:sp[@who]">
          <xsl:for-each select="//tei:role[@xml:id]">
            <xsl:variable name="id" select="@xml:id"/>
            <xsl:variable name="txt">
              <xsl:for-each select="key('who', $id)">
                <xsl:choose>
                  <xsl:when test="ancestor::*[@type = 'interlude']"/>
                  <xsl:otherwise>
                    <xsl:value-of select="$lf"/>
                    <xsl:apply-templates mode="iramuteq"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:variable>           
            <xsl:if test="normalize-space($txt) != ''">
              <xsl:value-of select="$lf"/>
              <xsl:value-of select="$lf"/>
              <xsl:text>****</xsl:text>
              <xsl:call-template name="iratext"/>
              <xsl:call-template name="irarole"/>
              <xsl:value-of select="$lf"/>
              <xsl:value-of select="$txt"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="iramuteq"/>
        </xsl:otherwise>
      </xsl:choose>
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
  
  <xsl:template name="gender">
    <xsl:param name="rend" select="concat(' ', @rend, ' ')"/>
    <xsl:choose>
      <xsl:when test="contains($rend, concat(' ', $male, ' '))">masculin</xsl:when>
      <xsl:when test="contains($rend, concat(' ', $female, ' '))">feminin</xsl:when>
      <xsl:otherwise>masculin</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="age">
    <xsl:param name="rend" select="concat(' ', @rend, ' ')"/>
    <xsl:choose>
      <xsl:when test="contains($rend, concat(' ', $junior, ' '))">jeune</xsl:when>
      <xsl:when test="contains($rend, concat(' ', $veteran, ' '))">veteran</xsl:when>
      <xsl:when test="contains($rend, concat(' ', $exterior, ' '))">sans-age</xsl:when>
      <xsl:when test="contains($rend, concat(' ', $inferior, ' '))">sans-age</xsl:when>
      <!-- A character should have a gender to have an age -->
      <xsl:when test="contains($rend, concat(' ', $male, ' ')) or contains($rend, concat(' ', $female, ' '))">mur</xsl:when>
      <xsl:otherwise>sans-age</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="status">
    <xsl:param name="rend" select="concat(' ', @rend, ' ')"/>
    <xsl:choose>
      <xsl:when test="contains($rend, concat(' ', $inferior, ' '))">serviteur</xsl:when>
      <xsl:when test="contains($rend, concat(' ', $exterior, ' '))">exterieur</xsl:when>
      <!-- A character should have a gender to have a status (let alone “clercs” or other “gens d’armes”) -->
      <xsl:when test="contains($rend, concat(' ', $male, ' ')) or contains($rend, concat(' ', $female, ' '))">maitre</xsl:when>
      <xsl:otherwise>exterieur</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="function">
    <xsl:param name="rend" select="concat(' ', @rend, ' ')"/>
    <xsl:choose>
      <xsl:when test="contains($rend, concat(' ', $inferior, ' ')) and contains($rend, concat(' ', $female, ' '))">servante</xsl:when>
      <xsl:when test="contains($rend, concat(' ', $inferior, ' ')) and contains($rend, concat(' ', $male, ' '))">valet</xsl:when>
      <xsl:when test="contains($rend, concat(' ', $inferior, ' '))">autres</xsl:when>
      <xsl:when test="contains($rend, concat(' ', $superior, ' '))">autres</xsl:when>
      <xsl:when test="contains($rend, concat(' ', $exterior, ' '))">autres</xsl:when>
      <xsl:when test="contains($rend, concat(' ', $female, ' ')) and contains($rend, concat(' ', $junior, ' '))">fille</xsl:when>
      <xsl:when test="contains($rend, concat(' ', $male, ' ')) and contains($rend, concat(' ', $junior, ' '))">fils</xsl:when>
      <xsl:when test="contains($rend, concat(' ', $female, ' '))">mere</xsl:when>
      <xsl:when test="contains($rend, concat(' ', $male, ' '))">pere</xsl:when>
      <xsl:otherwise>autres</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="irarole">
    <!--
    <xsl:param name="role" select="."/>
    <xsl:variable name="rend" select="concat(' ', $role/@rend, ' ')"/>
    <xsl:text> *labbe_</xsl:text>
    <xsl:value-of select="substring-after($filename, '_')"/>
    <xsl:text>_</xsl:text>
    <xsl:value-of select="$style"/>
    -->
    <xsl:text> *sexe_</xsl:text>
    <xsl:call-template name="gender"/>
    <xsl:text> *age_</xsl:text>
    <xsl:call-template name="age"/>
    <xsl:text> *statut_</xsl:text>
    <xsl:call-template name="status"/>
    <xsl:text> *fonction_</xsl:text>
    <xsl:call-template name="function"/>
    <xsl:text> *role_</xsl:text>
    <xsl:value-of select="translate(@xml:id, $who1, $who2)"/>
  </xsl:template>

  <xsl:template match="tei:castList" mode="iramuteq"/>
  <xsl:template match="tei:sp" mode="iramuteq">
    <xsl:value-of select="$lf"/>
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
    <xsl:value-of select="normalize-space($txt)"/>
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
  <xsl:template match="tei:div1[@type='interlude'] | tei:div[@type='interlude']" mode="iramuteq"/>
  <!-- Sections, split candidates -->
  <xsl:template match="
    tei:body | tei:group |
    tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div4 | tei:div5 | tei:div6 | tei:div7 
" mode="iramuteq">
    <xsl:choose>
      <!-- section with only notes -->
      <xsl:when test="not(tei:div | tei:div1 | tei:div2 | tei:div3 | tei:l | tei:lg | tei:list | tei:p | tei:quote | tei:sp )"/>
      <!-- Empty parent section -->
      <xsl:when test="descendant::*[key('div', generate-id())]">
        <!-- Process other children -->
        <xsl:apply-templates select="tei:group | tei:div | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6" mode="iramuteq"/>
      </xsl:when>
      <xsl:when test="tei:sp">
        <xsl:apply-templates select="*" mode="iramuteq"/>
      </xsl:when>
      <!-- Should be last level to split -->
      <xsl:when test="key('div', generate-id())">
        <xsl:value-of select="$lf"/>
        <xsl:value-of select="$lf"/>
        <xsl:text>****</xsl:text>
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
    <xsl:variable name="bookid">
      <xsl:choose>
        <xsl:when test="$filename != ''">
          <xsl:value-of select="$filename"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$docid"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="titleshort" select="substring-after($bookid, '_')"/>

    <xsl:variable name="creator">
      <xsl:variable name="key" select="/*/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/@key"/>
      <xsl:choose>
        <xsl:when test="contains($bookid, '_')">
          <xsl:value-of select="substring-before($bookid, '_')"/>
        </xsl:when>
        <xsl:when test="$key != ''">
          <xsl:value-of select="translate(normalize-space(substring-before(concat(substring-before(concat($key, '('), '('), ','), ',')), $who1, $who2)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:text> *creator_</xsl:text>
    <xsl:value-of select="$creator"/>
    
    <xsl:text> *book_</xsl:text>
    <xsl:value-of select="$bookid"/>

    <xsl:text> *style_</xsl:text>
    <xsl:value-of select="$style"/>
    
    
    
    <xsl:variable name="term1" select="/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass//tei:term[@type = 'genre']"/>
    <xsl:variable name="genre">
      <xsl:choose>
        <xsl:when test="$term1/@subtype">
          <xsl:value-of select="$term1/@subtype"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(normalize-space($term1), $who1, $who2)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>   
    <xsl:if test="$genre != ''">
      <xsl:text> *genre_</xsl:text>
      <xsl:value-of select="$genre"/>
      <xsl:text> *dist1_</xsl:text>
      <xsl:value-of select="$creator"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="$style"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="$genre"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="$titleshort"/>
      
      <xsl:text> *dist2_</xsl:text>
      <xsl:value-of select="$creator"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="$style"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="$genre"/>
    </xsl:if>
    
    <xsl:if test="@xml:id">
      <xsl:text> *id_</xsl:text>
      <xsl:value-of select="@xml:id"/>
    </xsl:if>
    
    <xsl:for-each select="ancestor-or-self::tei:*[@type = 'act'][1]">
      <xsl:text> *act_</xsl:text>
      <xsl:value-of select="@xml:id"/>
    </xsl:for-each>
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