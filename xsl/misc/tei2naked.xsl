<?xml version="1.0" encoding="UTF-8"?>
<!--

LGPL  http://www.gnu.org/licenses/lgpl.html
© 2005 ajlsm.com (Cybertheses) et Frederic.Glorieux@fictif.org
© 2007 Frederic.Glorieux@fictif.org
© 2010 Frederic.Glorieux@fictif.org et École nationale des chartes
© 2012 Frederic.Glorieux@fictif.org 
© 2016 Frederic.Glorieux@fictif.org et LABEX OBVIL

Texte nu, par exemple pièce de théâtre sans didascalies, ou critique sans citations
-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <!-- TEI common, metadatas -->
  <xsl:import href="common.xsl"/>
  <!-- Name of this xsl  -->
  <xsl:variable name="this">tei2naked.xsl</xsl:variable>
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

  <xsl:template match="*" mode="naked">
    <xsl:apply-templates mode="naked"/>
  </xsl:template>
  <xsl:template match="tei:TEI">
    <book>
      <xsl:apply-templates mode="naked"/>
    </book>
  </xsl:template>
  <!-- éléments à arrêter -->
  <xsl:template match="
      tei:back
    | tei:bibl
    | tei:byline
    | tei:cit
    | tei:castList
    | tei:castItem
    | tei:dateline
    | tei:docAuthor 
    | tei:docDate 
    | tei:docImprint
    | tei:event
    | tei:figure
    | tei:front
    | tei:head
    | tei:label
    | tei:listBibl
    | tei:note
    | tei:person
    | tei:place
    | tei:quote
    | tei:ref[not(node())] 
    | tei:salute 
    | tei:signed
    | tei:speaker
    | tei:stage
    | tei:titlePart 
    | tei:trailer
    | tei:teiHeader
    | tei:titlePage
    | tei:titlePart
    
    " mode="naked"/>
  <xsl:template match="tei:list">
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates select="*" mode="naked"/>
    <xsl:value-of select="$lf"/>
  </xsl:template>
  <xsl:template match="tei:item" mode="naked">
    <xsl:value-of select="$lf"/>
    <xsl:text> * </xsl:text>
    <xsl:variable name="text">
      <xsl:apply-templates mode="naked"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($text)"/>
  </xsl:template>
  <xsl:template match="tei:cb | tei:fw | tei:g | tei:pb" mode="naked">
    <xsl:if test="translate(substring(following-sibling::node()[1], 1, 1), '  ,;.?!…:*$€', '') != ''">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:sp" mode="naked">
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates select="*" mode="naked"/>
  </xsl:template>

    
  <!-- Verse, no division by sentence -->
  <xsl:template match="tei:l" mode="naked">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="naked"/>
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
  <xsl:template match="tei:lg" mode="naked">
    <!-- verses on one line
    <xsl:variable name="lg">
      <xsl:for-each select="*">
        <xsl:if test="position() != 1"> / </xsl:if>
        <xsl:apply-templates select="." mode="naked"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="$lf"/>
    <xsl:value-of select="normalize-space($lg)"/>
    -->
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates select="*" mode="naked"/>
  </xsl:template>

  <xsl:template match="tei:p" mode="naked">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="naked"/>
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

  <xsl:template match="tei:lb" mode="naked">
    <xsl:text>  </xsl:text>
    <xsl:value-of select="$lf"/>
  </xsl:template>

  <!-- Corpus lemmatisé -->
  <xsl:template match="tei:l[tei:w] | tei:p[tei:w]" mode="naked">
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
      <xsl:apply-templates mode="naked"/>
    </xsl:for-each>    
  </xsl:template>
  <!-- Mot de corpus lemmatisé -->
  <xsl:template match="tei:w | tei:c" mode="naked">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- Segments, could be filtered by function  -->
  <xsl:template match="tei:seg[@function]" mode="naked">
    <xsl:param name="function"/>
    <xsl:choose>
      <xsl:when test="normalize-space($function) != '' and not(contains(concat(' ',normalize-space($function), ' '), concat(' ', @function, ' ')))">
        <!-- Procéder les enfants au cas où -->
        <xsl:apply-templates select="*[@function]" mode="naked"/>
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
            <xsl:apply-templates select="." mode="naked">
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
" mode="naked">
    <xsl:choose>
      <xsl:when test="@type='argument'"/>
      <xsl:when test="@type='appendix'"/>
      <xsl:when test="@type='dedication'"/>
      <xsl:when test="@type='postface'"/>
      <xsl:when test="@type='preface'"/>
      <xsl:when test="@type='privilege'"/>
      <xsl:when test="@type='set'"/>
      <xsl:otherwise>
        <xsl:apply-templates select="*" mode="naked"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Rétablissement de césure -->
  <xsl:template match="tei:caes" mode="naked">
    <xsl:choose>
      <xsl:when test="@whole">
        <xsl:value-of select="@whole"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Mot ajouté -->
  <xsl:template match="tei:supplied" mode="naked">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates mode="naked"/>
    <xsl:text>]</xsl:text>
  </xsl:template>


  <!-- alternative critique -->
  <xsl:template match="tei:app" mode="naked">
    <xsl:apply-templates select="tei:lem" mode="naked"/>
  </xsl:template>
  <xsl:template match="tei:choice" mode="naked">
    <xsl:choose>
      <xsl:when test="tei:corr">
        <xsl:apply-templates select="tei:corr" mode="naked"/>
      </xsl:when>
      <xsl:when test="tei:expan">
        <xsl:apply-templates select="tei:expan" mode="naked"/>
      </xsl:when>
      <xsl:when test="tei:reg">
        <xsl:apply-templates select="tei:reg" mode="naked"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[1]" mode="naked"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Table -->
  <xsl:template match="tei:table" mode="naked">
    <xsl:value-of select="$lf"/>
    <xsl:apply-templates select="*" mode="naked"/>
    <xsl:value-of select="$lf"/>
  </xsl:template>

  <xsl:template match="tei:row" mode="naked">
    <xsl:apply-templates select="*" mode="naked"/>
    <xsl:value-of select="$lf"/>
  </xsl:template>

  <xsl:template match="tei:cell" mode="naked">
    <xsl:variable name="txt">
      <xsl:apply-templates mode="naked"/>
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
  <xsl:template match="text()" mode="naked">
     <xsl:value-of select="translate(., '*[]', '')"/>
  </xsl:template>
</xsl:transform>
