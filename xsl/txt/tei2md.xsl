<?xml version="1.0" encoding="UTF-8"?>
<!--

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2005 ajlsm.com (Cybertheses) et Frederic.Glorieux@fictif.org
© 2007 Frederic.Glorieux@fictif.org
© 2010 Frederic.Glorieux@fictif.org et École nationale des chartes
© 2012 Frederic.Glorieux@fictif.org 
© 2013 Frederic.Glorieux@fictif.org et LABEX OBVIL

Syntaxe texte de référence : Markdown

Extraction du texte d'un corpus TEI pour recherche plein texte ou traitements linguistiques
(ex : suppressions des notes, résolution de l'apparat)
Doit pouvoir fonctionner en import.

TODO: listes, tables, liens

-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <!-- TEI common, metadatas -->
  <xsl:import href="common.xsl"/>
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" method="text" indent="yes"/>
  <!-- Permet l'indentation des éléments de structure -->
  <xsl:strip-space elements="tei:TEI tei:TEI.2 tei:body tei:castList  tei:div tei:div1 tei:div2  tei:docDate tei:docImprint tei:docTitle tei:fileDesc tei:front tei:group tei:index tei:listWit tei:publicationStmp tei:publicationStmt tei:sourceDesc tei:SourceDesc tei:sources tei:text tei:teiHeader tei:text tei:titleStmt"/>
  <xsl:preserve-space elements="tei:l tei:p tei:s "/>
  <xsl:variable name="lf">
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>
  <xsl:variable name="tab">
    <xsl:text>&#9;</xsl:text>
  </xsl:variable>
  <xsl:variable name="apos">'</xsl:variable>
  <xsl:variable name="quot">"</xsl:variable>
  <xsl:variable name="bar">-------------------------------------------------------</xsl:variable>  
  <xsl:template match="*" mode="md">
    <xsl:apply-templates mode="md"/>
  </xsl:template>
  <xsl:template match="tei:TEI">
    <book>
      <xsl:text>---</xsl:text>
      <xsl:value-of select="$lf"/>
      <xsl:call-template name="txt-fields"/>
      <xsl:text>---</xsl:text>
      <xsl:value-of select="$lf"/>
      <xsl:value-of select="$lf"/>
      <xsl:apply-templates mode="md"/>
      <xsl:variable name="notes">
        <xsl:apply-templates mode="txt-fn"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$notes = ''"/>
        <xsl:otherwise>

-------
<xsl:copy-of select="$notes"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$lf"/>
    </book>
  </xsl:template>
  <xsl:template name="txt-fields">
    <xsl:text>identifier: </xsl:text>
    <xsl:value-of select="$docid"/>
    <xsl:text>  </xsl:text>
    <xsl:value-of select="$lf"/>
    <xsl:text>creator: </xsl:text>
    <xsl:value-of select="$byline"/>
    <xsl:text>  </xsl:text>
    <xsl:value-of select="$lf"/>
    <xsl:text>date: </xsl:text>
    <xsl:value-of select="$docdate"/>
    <xsl:text>  </xsl:text>
    <xsl:value-of select="$lf"/>
    <xsl:text>title: </xsl:text>
    <xsl:value-of select="$doctitle"/>
    <xsl:text>  </xsl:text>
    <xsl:value-of select="$lf"/>
  </xsl:template>
  <xsl:template match="node()" mode="txt-fn">
    <xsl:apply-templates mode="txt-fn"/>
  </xsl:template>
  <xsl:template match="tei:note" mode="txt-fn">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:text>[</xsl:text>
    <xsl:call-template name="n"/>
    <xsl:text>] </xsl:text>
    <xsl:apply-templates mode="md"/>
  </xsl:template>
  <!-- éléments à arrêter -->
  <xsl:template match="tei:ref[not(node())] | tei:teiHeader" mode="md"/>
  <xsl:template match="tei:back | tei:front" mode="md">
    <xsl:apply-templates mode="md"/>
  </xsl:template>
  <xsl:template match="tei:figure" mode="md"/>
  <xsl:template match="tei:castList | tei:list | tei:listBibl">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates select="*" mode="md"/>
    <xsl:value-of select="$lf"/>
  </xsl:template>
  <xsl:template match="tei:castItem" mode="md">
    <xsl:value-of select="$lf"/>
    <xsl:text> – </xsl:text>
    <xsl:variable name="text">
      <xsl:apply-templates mode="md"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($text)"/>
  </xsl:template>
  <xsl:template match="tei:item" mode="md">
    <xsl:value-of select="$lf"/>
    <xsl:text> * </xsl:text>
    <xsl:variable name="text">
      <xsl:apply-templates mode="md"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($text)"/>
  </xsl:template>

  <xsl:template match="tei:bibl | tei:cit" mode="md">
    <xsl:apply-templates select="*" mode="md"/>
    <xsl:value-of select="$lf"/>
  </xsl:template>
 <xsl:template match="tei:note//tei:bibl | tei:note//tei:cit" mode="md">
    <xsl:apply-templates mode="md"/>
  </xsl:template>
  <xsl:template match="tei:cb | tei:fw | tei:g | tei:pb" mode="md">
    <xsl:if test="translate(substring(following-sibling::node()[1], 1, 1), '  ,;.?!…:*$€', '') != ''">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  <!-- Traitement des notes -->
  <xsl:template match="tei:note" mode="md">
     <xsl:text> [</xsl:text>
     <xsl:call-template name="n"/>
     <xsl:text>]</xsl:text>
  </xsl:template>
  <xsl:template name="n">
    <xsl:choose>
      <xsl:when test="@n">
        <xsl:value-of select="@n"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:number level="any"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:titlePage" mode="md">
    <xsl:apply-templates select="*" mode="md"/>
  </xsl:template>
  
  <xsl:template match="tei:quote" mode="md">
    <xsl:choose>
      <xsl:when test="ancestor::tei:p">
        <xsl:apply-templates mode="md"/>
      </xsl:when>
      <xsl:when test="tei:p|tei:l">
        <xsl:value-of select="$lf"/>
        <xsl:apply-templates select="*" mode="md"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$lf"/>
        <xsl:text>    </xsl:text>
        <xsl:apply-templates mode="md"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> 

  <xsl:template name="id-label">
    <xsl:variable name="id" select="ancestor-or-self::*[@xml:id][1]/@xml:id"/>
    <!-- some id could be very long, préfexed by document id -->
    <xsl:variable name="strip" select="substring-after($id, /*/@xml:id)"/>
    <xsl:choose>
      <xsl:when test="$id =''">NOID</xsl:when>
      <xsl:when test="$strip = ''">
        <xsl:value-of select="$id"/>
      </xsl:when>
      <xsl:when test="starts-with($strip, '_')">
        <xsl:value-of select="substring($strip, 2)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$strip"/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>


  <xsl:template match="tei:sp" mode="md">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates select="*" mode="md"/>
  </xsl:template>
  <xsl:template match="tei:speaker" mode="md">
    <xsl:text>    </xsl:text>
    <xsl:variable name="raw">
      <xsl:apply-templates mode="md"/>
    </xsl:variable>
    <xsl:variable name="speaker" select="normalize-space($raw)"/>
    <xsl:value-of select="$speaker"/>
    <xsl:variable name="last" select="substring($speaker, string-length($speaker))"/>
    <xsl:if test="$last != '.' and $last != '?' and $last != '!' and $last != '…'">.</xsl:if>
  </xsl:template>
  <xsl:template match="tei:speaker/text()" mode="md">
    <xsl:value-of select="translate(., $lc, $uc)"/>
  </xsl:template>
  <xsl:template match="tei:stage" mode="md">
    <xsl:choose>
      <xsl:when test="parent::tei:div or parent::tei:div1 or parent::tei:div2 or parent::tei:sp">
        <xsl:value-of select="$lf"/>
        <xsl:variable name="text">
          <xsl:apply-templates mode="md"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($text)"/>
        <xsl:value-of select="$lf"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="md"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- 
<person xml:id="Valois-Madeleine">
                        <persName>Valois, Madeleine de</persName>
                        <birth>1520</birth>
                        <death>1537</death>
                        <event>
                            <p>fille de François I<hi rend="sup">er</hi>, avait épousé en janvier 1537 Jacques V (1512-1542), roi d'Écosse (1513-1542) ; elle mourut six mois plus tard, en juillet 1537.</p>
                        </event>
                    </person>
-->


  <!-- Ligne sans indentation -->
  <xsl:template match="tei:person | tei:event | tei:place" mode="md">
    <xsl:apply-templates select="*" mode="md"/>
  </xsl:template>
  <xsl:template match="tei:birth" mode="md">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates mode="md"/>
    <xsl:text>–</xsl:text>
    <xsl:if test="not(following-sibling::tei:death)">–…) </xsl:if>
  </xsl:template>
  <xsl:template match="tei:death" mode="md">
    <xsl:if test="not(preceding-sibling::tei:death)"> (…</xsl:if>
    <xsl:text>–</xsl:text>
    <xsl:apply-templates mode="md"/>
    <xsl:text>) </xsl:text>
  </xsl:template>

  <!-- 
                          <place xml:id="Chevagnes">
                            <placeName>Chevagnes</placeName>
                            <location>
                                <district type="departement">allier</district>
                                <district type="arrondissement">Moulins</district>
                                <district type="canton">ch.-l. de cant.</district>
                            </location>
                        </place>
-->
  <xsl:template match="tei:location" mode="md">
    <xsl:text> (</xsl:text>
    <xsl:for-each select="*">
      <xsl:if test="position() != 1">, </xsl:if>
      <xsl:apply-templates select="." mode="md"/>
    </xsl:for-each>
    <xsl:text>) </xsl:text>
  </xsl:template>
  
 
    
  <!-- Verse, no division by sentence -->
  <xsl:template match="tei:l" mode="md">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="md"/>
    </xsl:variable>
    <xsl:value-of select="$lf"/>
    <xsl:choose>
      <xsl:when test="@part = 'm' or @part = 'M'">    </xsl:when>
      <xsl:when test="@part = 'f' or @part = 'F'">        </xsl:when>
    </xsl:choose>
    <xsl:value-of select="normalize-space($txt)"/>
    <xsl:text>  </xsl:text>
    <!-- afficher n° vers ?
    <xsl:choose>
      <xsl:when test="@n and (@n mod 5 = 0)">
        <xsl:text>		</xsl:text>
        <xsl:value-of select="@n"/>
      </xsl:when>
    </xsl:choose>
    -->
  </xsl:template>
  <xsl:template match="tei:lg" mode="md">
    <!-- verses on one line
    <xsl:variable name="lg">
      <xsl:for-each select="*">
        <xsl:if test="position() != 1"> / </xsl:if>
        <xsl:apply-templates select="." mode="md"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="normalize-space($lg)"/>
    -->
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates select="*" mode="md"/>
  </xsl:template>
  <xsl:template match="tei:byline" mode="md">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="md"/>
    </xsl:variable>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="normalize-space($txt)"/>
    <xsl:copy-of select="$lf"/>
  </xsl:template>
  <!-- lines in titlePage -->
  <xsl:template match="tei:docAuthor | tei:docDate | tei:docImprint | tei:titlePart" mode="md">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="md"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($txt)"/>
    <xsl:text>  </xsl:text>
    <xsl:value-of select="$lf"/>
  </xsl:template>
  <!-- blocks of one line -->
  <xsl:template match="tei:docAuthor | tei:docDate | tei:dateline | tei:docImprint | tei:salute | tei:signed | tei:titlePart | tei:trailer" mode="md">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="md"/>
    </xsl:variable>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="normalize-space($txt)"/>
    <xsl:value-of select="$lf"/>
  </xsl:template>
  
  <xsl:template match="tei:trailer" mode="md">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="md"/>
    </xsl:variable>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="normalize-space($txt)"/>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>  
  <xsl:template match="tei:p" mode="md">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="md"/>
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
    <!--
    <xsl:call-template name="sent">
      <xsl:with-param name="txt" select="normalize-space($txt)"/>
    </xsl:call-template>
    -->
    <xsl:value-of select="normalize-space($txt)"/>
  </xsl:template>

  <xsl:template match="tei:lb" mode="md">
    <xsl:text>  </xsl:text>
    <xsl:value-of select="$lf"/>
  </xsl:template>

  <!-- Corpus lemmatisé -->
  <xsl:template match="tei:l[tei:w] | tei:p[tei:w]" mode="md">
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
      <xsl:apply-templates mode="md"/>
    </xsl:for-each>    
  </xsl:template>
  <!-- Mot de corpus lemmatisé -->
  <xsl:template match="tei:w | tei:c" mode="md">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- Segments, could be filtered by function  -->
  <xsl:template match="tei:seg[@function]" mode="md">
    <xsl:param name="function"/>
    <xsl:choose>
      <xsl:when test="normalize-space($function) != '' and not(contains(concat(' ',normalize-space($function), ' '), concat(' ', @function, ' ')))">
        <!-- Procéder les enfants au cas où -->
        <xsl:apply-templates select="*[@function]" mode="md"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="position() != 1">
          <xsl:value-of select="$lf"/>
        </xsl:if>
        <xsl:text>&lt;seg</xsl:text>
        <xsl:value-of select="count(ancestor-or-self::tei:seg[@function])"/>
        <xsl:text>=</xsl:text>
        <xsl:value-of select="@function"/>
        <xsl:variable name="id" select="ancestor::tei:text[@xml:id]/@xml:id"/>
        <xsl:text>_</xsl:text>
        <xsl:choose>
          <xsl:when test="/*/@xml:id  and starts-with($id, concat(/*/@xml:id, '_'))">
            <xsl:value-of select="substring-after($id, concat(/*/@xml:id, '_'))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$id"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&gt; </xsl:text>
        <xsl:for-each select="node()">
          <xsl:variable name="txt">
            <xsl:apply-templates select="." mode="md">
              <xsl:with-param name="function"/>
            </xsl:apply-templates>     
          </xsl:variable>
          <xsl:if test="position() &gt; 1 and normalize-space($txt) != '' and self::tei:seg">
            <xsl:value-of select="$lf"/>
          </xsl:if>
          <xsl:value-of select="normalize-space($txt)"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>

  <!-- Sections, split candidates -->
  <xsl:template match="
    tei:body | tei:group |
    tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div4 | tei:div5 | tei:div6 | tei:div7 
" mode="md">
    <xsl:apply-templates select="*" mode="md"/>
  </xsl:template>



   
  <xsl:template match="tei:head" mode="md">
    <xsl:variable name="level" select="count(ancestor::*[tei:head])"/>
    <xsl:variable name="text">
      <xsl:apply-templates mode="md"/>
    </xsl:variable>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="substring('######', 1, $level)"/>
    <xsl:text> </xsl:text>
    <xsl:variable name="head" select="normalize-space($text)"/>
    <xsl:value-of select="$head"/>
    <xsl:variable name="last" select="substring($head, string-length($head))"/>
    <xsl:if test="$last != '.' and $last != '?' and $last != '!' and $last != '…'">.</xsl:if>
  </xsl:template>

  
  <!-- Intertitre -->
  <xsl:template match="tei:label" mode="md">
    <xsl:text>&lt; </xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text> &gt;</xsl:text>
  </xsl:template> 

  <!-- Rétablissement de césure -->
  <xsl:template match="tei:caes" mode="md">
    <xsl:choose>
      <xsl:when test="@whole">
        <xsl:value-of select="@whole"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Mot ajouté -->
  <xsl:template match="tei:supplied" mode="md">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates mode="md"/>
    <xsl:text>]</xsl:text>
  </xsl:template>


  <!-- alternative critique -->
  <xsl:template match="tei:app" mode="md">
    <xsl:apply-templates select="tei:lem" mode="md"/>
  </xsl:template>
  <xsl:template match="tei:choice" mode="md">
    <xsl:choose>
      <xsl:when test="tei:corr">
        <xsl:apply-templates select="tei:corr" mode="md"/>
      </xsl:when>
      <xsl:when test="tei:expan">
        <xsl:apply-templates select="tei:expan" mode="md"/>
      </xsl:when>
      <xsl:when test="tei:reg">
        <xsl:apply-templates select="tei:reg" mode="md"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[1]" mode="md"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Table -->
  <xsl:template match="tei:table" mode="md">
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates select="*" mode="md"/>
    <xsl:value-of select="$lf"/>
  </xsl:template>

  <xsl:template match="tei:row" mode="md">
    <xsl:apply-templates select="*" mode="md"/>
    <xsl:value-of select="$lf"/>
  </xsl:template>

  <xsl:template match="tei:cell" mode="md">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="md"/>
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
  
  <xsl:template match="tei:hi" mode="md">
    <xsl:choose>
      <xsl:when test="@rend = 'i' or starts-with(@rend, 'it')">
        <xsl:text>*</xsl:text>
        <xsl:apply-templates mode="md"/>
        <xsl:text>*</xsl:text>
      </xsl:when>
      <xsl:when test="@rend = 'b' or @rend = 'bold' or @rend='gras'">
        <xsl:text>**</xsl:text>
        <xsl:apply-templates mode="md"/>
        <xsl:text>**</xsl:text>
      </xsl:when>
      <xsl:when test="@rend = 's' or @rend = 'strike'">
        <xsl:text>~~</xsl:text>
        <xsl:apply-templates mode="md"/>
        <xsl:text>~~</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>*</xsl:text>
        <xsl:apply-templates mode="md"/>
        <xsl:text>*</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- For text, give back hand to normal processing, so that it could be overrides (= translate for some device) -->
  <xsl:template match="text()" mode="md">
     <xsl:value-of select="translate(., '’*­[]', concat( $apos, '⁎'))"/>
  </xsl:template>
</xsl:transform>
