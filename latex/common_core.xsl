<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  exclude-result-prefixes="tei"
>
  <!-- 
TEI Styleshest for LaTeX, forked from Sebastian Rahtz
https://github.com/TEIC/Stylesheets/tree/dev/latex
  
1. Distributed under a Creative Commons Attribution-ShareAlike 3.0
   License http://creativecommons.org/licenses/by-sa/3.0/ 
2. http://www.opensource.org/licenses/BSD-2-Clause

A light version for XSLT1, with local improvements.
2021, Frederic.Glorieux@fictif.org

Sebastian define in this sheet a logic for most <tag>, for all formats.
For now in Teinte, it is only used for latex generation. Maybe one day
this logic could be generalized.
Idea is to interpret the context of a tag (ex: <bibl>),
to send a parameter (ex: "citbibl", "biblFree"),
to a genereric formatting command ("makeBlock" or "makeInline").
It works quite well for Latex with dedicated TEI environments and commands,
maybe it could be nice for html with a good generic CSS, 
it is dangerous for docx where nesting may produce lots of surprises
(example : <bibl>, in a <note>, in a <quote>).
  -->
  
  
  <xsl:template match="tei:sic">
    <xsl:choose>
      <xsl:when test="parent::tei:choice"> </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="makeInline">
          <xsl:with-param name="after">}</xsl:with-param>
          <xsl:with-param name="before">{</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:supplied">
    <xsl:choose>
      <xsl:when test="parent::tei:choice"> </xsl:when>
      <xsl:when test="@reason='damage'">
        <xsl:call-template name="makeInline">
          <xsl:with-param name="style">supplied</xsl:with-param>
          <xsl:with-param name="before">&lt;</xsl:with-param>
          <xsl:with-param name="after">&gt;</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@reason='illegible' or not(@reason)">
        <xsl:call-template name="makeInline">
          <xsl:with-param name="style">supplied</xsl:with-param>
          <xsl:with-param name="before">[</xsl:with-param>
          <xsl:with-param name="after">]</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@reason='omitted'">
        <xsl:call-template name="makeInline">
          <xsl:with-param name="style">supplied</xsl:with-param>
          <xsl:with-param name="before">⟨</xsl:with-param>
          <xsl:with-param name="after">⟩</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="makeInline">
          <xsl:with-param name="style">supplied</xsl:with-param>
          <xsl:with-param name="after">}</xsl:with-param>
          <xsl:with-param name="before">{</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:reg">
    <xsl:call-template name="makeInline"/>
  </xsl:template>
  
  <xsl:template match="tei:orig">
    <xsl:choose>
      <xsl:when test="parent::tei:choice"> </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="makeInline"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:expan">
    <xsl:call-template name="makeInline"/>
  </xsl:template>
  
  <xsl:template match="tei:corr">
    <xsl:call-template name="makeInline">
      <xsl:with-param name="before">[</xsl:with-param>
      <xsl:with-param name="after">]</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="tei:abbr">
    <xsl:choose>
      <xsl:when test="parent::tei:choice/tei:expan">
        <xsl:call-template name="makeInline">
          <xsl:with-param name="before"> (</xsl:with-param>
          <xsl:with-param name="after">)</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="makeInline"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  
  <xsl:template match="tei:edition">
    <xsl:apply-templates/>
    <xsl:if test="ancestor::tei:biblStruct or ancestor::tei:biblFull">
      <xsl:text>. </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:imprint">
    <xsl:choose>
      <xsl:when test="ancestor::tei:biblStruct or ancestor::tei:biblFull">
        <xsl:apply-templates select="tei:date"/>
        <xsl:apply-templates select="tei:pubPlace"/>
        <xsl:apply-templates select="tei:publisher"/>
        <xsl:apply-templates select="tei:biblScope"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- authors and editors -->
  <xsl:template match="tei:editor|tei:author">
    <xsl:choose>
      <xsl:when test="ancestor::tei:bibl">
        <xsl:choose>
          <xsl:when test="tei:surname">
            <xsl:apply-templates select="*"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="self::tei:author and not(following-sibling::tei:author)">
        <xsl:choose>
          <xsl:when test="tei:surname">
            <xsl:apply-templates select="*"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>. </xsl:text>
      </xsl:when>
      <xsl:when test="self::tei:editor and not(following-sibling::tei:editor)">
        <xsl:choose>
          <xsl:when test="tei:surname">
            <xsl:apply-templates select="*"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="preceding-sibling::tei:editor"> (eds.) </xsl:when>
          <xsl:otherwise> (ed.) </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="tei:surname">
            <xsl:apply-templates select="*"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>, </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:author|tei:editor" mode="mla">
    <!-- <xsl:variable name="totalNbr">
	  <xsl:number select="ancestor::tei:listBibl"/>
        </xsl:variable>
        <xsl:value-of select="$totalNbr"/>. 
        <xsl:choose>
        <xsl:when test="self::tei:author[1] = parent::tei:analytic/parent::tei:biblStruct/preceding-sibling::tei:biblStruct/*/tei:author[1] or self::tei:author[1] =
        parent::tei:analytic/parent::tei:biblStruct/preceding-sibling::tei:biblStruct/tei:monogr/tei:editor[1]">
        <xsl:text>[three hyphens]</xsl:text>
        <xsl:choose>
        <xsl:when test="self::tei:author and following-sibling::tei:author"><xsl:text>, </xsl:text></xsl:when>
        <xsl:otherwise><xsl:text>. </xsl:text></xsl:otherwise>
        </xsl:choose>
        </xsl:when>
        <xsl:when test="self::tei:author[1] = parent::tei:monogr/parent::tei:biblStruct/preceding-sibling::tei:biblStruct/*/tei:author[1] and not(preceding-sibling::tei:analytic) or self::tei:author[1] =
        parent::tei:monogr/parent::tei:biblStruct/preceding-sibling::tei:biblStruct/tei:monogr/tei:editor[1] and not(preceding-sibling::tei:analytic)">
        <xsl:text>[three hyphens]</xsl:text>
        <xsl:choose>
        <xsl:when test="self::tei:author and following-sibling::tei:author"><xsl:text>, </xsl:text></xsl:when>
        <xsl:otherwise><xsl:text>. </xsl:text></xsl:otherwise>
        </xsl:choose>
        </xsl:when>
        <xsl:when test="self::tei:editor[1] = parent::tei:*/parent::tei:biblStruct/preceding-sibling::tei:biblStruct/*/tei:author[1] and
        not(preceding-sibling::tei:analytic) or self::tei:editor[1]
        = parent::tei:*/parent::tei:biblStruct/preceding-sibling::tei:biblStruct/tei:monogr/tei:editor[1] and not(preceding-sibling::tei:analytic)">
        <xsl:text>[three hyphens]</xsl:text>
        <xsl:text>, </xsl:text>
        </xsl:when> 
        TAKE OUT THE EXTRA OPEN CHOOSE BEFORE YOU ADD THIS BACK IN-->
    <xsl:choose>
      <xsl:when test="self::tei:author and not(following-sibling::tei:author)">
        <xsl:variable name="norm" select="normalize-space(.)"/>
        <xsl:variable name="lastchar" select="substring($norm, string-length($norm))"/>
        <xsl:choose>
          <xsl:when test="ancestor::tei:biblStruct and not(preceding-sibling::tei:author)">
            <xsl:apply-templates/>
            <xsl:if test="$lastchar != '.'">
              <xsl:text>. </xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="not(self::tei:author[3])">
              <xsl:text> and </xsl:text>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="contains(self::tei:author, ',')">
                <xsl:value-of select="substring-after(., ',')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="substring-before(., ',')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$lastchar != '.'">
              <xsl:text>. </xsl:text>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="self::tei:author and following-sibling::tei:author">
        <xsl:choose>
          <xsl:when test="ancestor::tei:biblStruct and not(preceding-sibling::tei:author)">
            <xsl:apply-templates/>
            <xsl:text>, </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="contains(self::tei:author, ',')">
                <xsl:value-of select="substring-after(., ',')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="substring-before(., ',')"/>
                <xsl:text>, and </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
                <xsl:text>, and </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="self::tei:editor[@role='translator'] and ancestor::tei:biblStruct">
        <xsl:choose>
          <xsl:when test="preceding-sibling::tei:editor[@role='editor']/text() = self::tei:editor[@role='translator']/text()">
            <xsl:text>Ed. and Trans. </xsl:text>
          </xsl:when>
          <xsl:when test="not(preceding-sibling::tei:editor[@role='translator'])">
            <xsl:text>Trans. </xsl:text>
          </xsl:when>
          <xsl:when test="preceding-sibling::tei:editor[@role='translator'] and following-sibling::tei:editor[@role='translator']">
            <xsl:text>, </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> and </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="contains(self::tei:editor[@role='translator'], ',')">
            <xsl:value-of select="substring-after(., ',')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="substring-before(., ',')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(following-sibling::tei:editor[@role='translator'])">
          <xsl:text>. </xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="self::tei:editor[@role='editor'] and not(parent::tei:monogr/parent::tei:biblStruct/tei:analytic) and not(preceding-sibling::tei:author)">
        <xsl:choose>
          <xsl:when test="ancestor::tei:biblStruct and not(following-sibling::tei:editor[@role='editor']) and not(preceding-sibling::tei:editor[@role='editor'])">
            <xsl:apply-templates/>
            <xsl:text>, ed. </xsl:text>
          </xsl:when>
          <xsl:when test="ancestor::tei:biblStruct and following-sibling::tei:editor[@role='editor'] and not(preceding-sibling::tei:editor[@role='editor'])">
            <xsl:apply-templates/>
            <xsl:choose>
              <xsl:when test="position() + 1 = last()">
                <xsl:text> </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>, </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="ancestor::tei:biblStruct and following-sibling::tei:editor[@role='editor']">
            <xsl:choose>
              <xsl:when test="contains(self::tei:editor[@role='editor'], ',')">
                <xsl:value-of select="substring-after(., ',')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="substring-before(., ',')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="position() + 1 = last()">
                <xsl:text> </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>, </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="ancestor::tei:biblStruct and not(following-sibling::tei:editor[@role='editor'])">
            <xsl:choose>
              <xsl:when test="preceding-sibling::tei:editor[@role='editor']">
                <xsl:text>and </xsl:text>
                <xsl:choose>
                  <xsl:when test="contains(self::tei:editor[@role='editor'], ',')">
                    <xsl:value-of select="substring-after(., ',')"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="substring-before(., ',')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="../tei:editor[@role='editor'][2]">
                <xsl:text>, eds. </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>, ed. </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="self::tei:editor[@role='editor'] and not(following-sibling::tei:editor[@role='editor'])">
        <xsl:choose>
          <xsl:when test="ancestor::tei:biblStruct and not(preceding-sibling::tei:editor[@role='editor'])">
            <xsl:text>Ed. </xsl:text>
            <xsl:choose>
              <xsl:when test="contains(self::tei:editor[@role='editor'], ',')">
                <xsl:value-of select="substring-after(., ',')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="substring-before(., ',')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text>. </xsl:text>
          </xsl:when>
          <xsl:when test="ancestor::tei:biblStruct and preceding-sibling::tei:editor[@role='editor']">
            <xsl:text>and </xsl:text>
            <xsl:choose>
              <xsl:when test="contains(self::tei:editor[@role='editor'], ',')">
                <xsl:value-of select="substring-after(., ',')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="substring-before(., ',')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text>. </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
            <xsl:text> (</xsl:text>
            <xsl:text>ed</xsl:text>
            <xsl:if test="preceding-sibling::tei:editor[@role='editor']">s</xsl:if>
            <xsl:text>.</xsl:text>
            <xsl:text>) </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="self::tei:editor[@role='editor'] and following-sibling::tei:editor[@role='editor']">
        <xsl:choose>
          <xsl:when test="ancestor::tei:biblStruct and not(preceding-sibling::tei:editor[@role='editor'])">
            <xsl:text>Ed. </xsl:text>
            <xsl:choose>
              <xsl:when test="contains(self::tei:editor[@role='editor'], ',')">
                <xsl:value-of select="substring-after(., ',')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="substring-before(., ',')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="position() + 1 = last()">
                <xsl:text> </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>, </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="ancestor::tei:biblStruct and preceding-sibling::tei:editor[@role='editor']">
            <xsl:choose>
              <xsl:when test="contains(self::tei:editor[@role='editor'], ',')">
                <xsl:value-of select="substring-after(., ',')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="substring-before(., ',')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text>, </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="contains(self::tei:editor[@role='editor'], ',')">
                <xsl:value-of select="substring-after(., ',')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="substring-before(., ',')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="position() + 1 = last()">
                <xsl:text> </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>, </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:nameLink"> </xsl:template>
  <!-- title  -->
  <xsl:template match="tei:title" mode="simple">
    <xsl:apply-templates select="text()"/>
  </xsl:template>

  <xsl:template match="tei:meeting">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
    <xsl:if test="following-sibling::* and (ancestor::tei:biblStruct  or ancestor::tei:biblFull)">
          <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:series">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:biblStruct//tei:date|tei:biblFull//tei:date">
    <!--
	 <xsl:choose>
	 <xsl:when test="starts-with(.,'$Date:')">
	 <xsl:value-of select="substring-before(substring-after(.,'$Date:'),'$')"/>
	 </xsl:when>
	 <xsl:otherwise>
	 <xsl:apply-templates/>
	 </xsl:otherwise>
	 </xsl:choose>
     -->
    <xsl:apply-templates/>
    <xsl:text>. </xsl:text>
  </xsl:template>
  <xsl:template match="tei:pubPlace">
    <xsl:apply-templates/>
    <xsl:choose>
      <xsl:when test="ancestor::tei:bibl"/>
      <xsl:when test="following-sibling::tei:pubPlace">
        <xsl:text>, </xsl:text>
      </xsl:when>
      <xsl:when test="../tei:publisher">
        <xsl:text>: </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>. </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:publisher">
    <xsl:apply-templates/>
    <xsl:if test="ancestor::tei:biblStruct or ancestor::tei:biblFull">
      <xsl:text>. </xsl:text>
    </xsl:if>
  </xsl:template>
  <!-- details and notes -->
  <xsl:template match="tei:biblScope">
    <xsl:variable name="Unit" select="(@unit|@type)[1]"/>
    <xsl:choose>
      <xsl:when test="ancestor::tei:bibl">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$Unit='vol' or $Unit='volume'">
        <xsl:call-template name="emphasize">
          <xsl:with-param name="class">
            <xsl:text>vol</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="content">
            <xsl:apply-templates/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$Unit='chap' or $Unit='chapter'">
        <!-- TODO Chapter ? -->
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$Unit='issue' or $Unit='nr'">
        <xsl:text> (</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>) </xsl:text>
      </xsl:when>
      <xsl:when test="$Unit='page_from'">
        <xsl:text>pp. </xsl:text>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$Unit='page_to'">
        <xsl:text>-</xsl:text>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$Unit='pp' or $Unit='pages' or $Unit='page'">
        <xsl:choose>
          <xsl:when test="contains(.,'-')">
            <xsl:text>pp. </xsl:text>
          </xsl:when>
          <xsl:when test="contains(.,'ff')">
            <xsl:text>pp. </xsl:text>
          </xsl:when>
          <xsl:when test="contains(.,' ')">
            <xsl:text>pp. </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>p. </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$Unit='vol' and      following-sibling::tei:biblScope[$Unit='issue']">
            <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="$Unit='vol' and following-sibling::tei:biblScope">
            <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="following-sibling::tei:biblScope">
            <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="ancestor::tei:biblStruct or ancestor::tei:biblFull">
        <xsl:text>. </xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:name|tei:persName|tei:placeName|tei:orgName">
    <xsl:choose>
      <xsl:when test="ancestor::tei:person|ancestor::tei:biblStruct">
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::*[1][self::tei:name|self::tei:persName]">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="makeInline">
          <xsl:with-param name="style" select="local-name()"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:head" mode="plain">
    <xsl:if test="preceding-sibling::tei:head">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates mode="plain"/>
  </xsl:template>
  
  <xsl:template match="tei:*" mode="plain">
    <xsl:apply-templates mode="plain"/>
  </xsl:template>
  <xsl:template match="tei:note" mode="plain"/>
  <xsl:template match="tei:app" mode="plain"/>
  <xsl:template match="tei:pb" mode="plain"/>

  <xsl:template match="tei:figure" mode="plain">
    <xsl:text>[</xsl:text>
    <!-- i18n -->
    <xsl:text>figure</xsl:text>
    <xsl:text>]</xsl:text>
  </xsl:template>
  <xsl:template match="tei:figDesc" mode="plain"/>
  <xsl:template match="tei:ptr" mode="plain"/>
  
  <xsl:template match="tei:forename">
    <xsl:choose>
      <xsl:when test="parent::*/tei:surname"/>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:surname">
    <xsl:if test="parent::*/tei:forename">
      <xsl:for-each select="parent::*/tei:forename">
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:expan/tei:am"/>
  <xsl:template match="tei:expan/tei:ex">
    <xsl:call-template name="makeInline">
      <xsl:with-param name="before">(</xsl:with-param>
      <xsl:with-param name="after">)</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:gap" priority="10">
    <xsl:call-template name="makeInline">
      <xsl:with-param name="before">[...]</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:unclear">
    <xsl:call-template name="makeInline">
      <xsl:with-param name="style">unclear</xsl:with-param>
      <xsl:with-param name="after">[?]</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:geogName|tei:roleName">
    <xsl:choose>
      <xsl:when test="*">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="makeInline"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:mentioned">
    <xsl:call-template name="makeInline">
      <xsl:with-param name="style">mentioned</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="tei:foreign">
    <xsl:message/>
    <xsl:call-template name="makeInline">
      <xsl:with-param name="style">foreign</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="tei:term">
    <xsl:call-template name="makeInline">
      <xsl:with-param name="style">term</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="tei:del">
    <xsl:call-template name="makeInline">
      <xsl:with-param name="style">strikethrough</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="tei:add">
    <xsl:choose>
      <xsl:when test="@place='sup' or @place='above'">
        <xsl:call-template name="makeInline">
          <xsl:with-param name="style">sup</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@place='sub' or @place='below'">
        <xsl:call-template name="makeInline">
          <xsl:with-param name="style">sub</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <!-- TODO
      <xsl:when test="not(tei:isInline(*[last()]))">
        <xsl:call-template name="makeBlock">
          <xsl:with-param name="style">add</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      -->
      <xsl:otherwise>
        <xsl:call-template name="makeInline">
          <xsl:with-param name="style">add</xsl:with-param>
          <xsl:with-param name="after">&#10217;</xsl:with-param>
          <xsl:with-param name="before">&#10216;</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="tei:docAuthor" mode="author">
    <xsl:apply-templates/>
    <xsl:choose>
      <xsl:when test="count(following-sibling::tei:docAuthor)=1">
        <xsl:if test="count(preceding-sibling::tei:docAuthor)&gt;1">
          <xsl:text>,</xsl:text>
        </xsl:if>
        <!-- i18n -->
        <xsl:text> et </xsl:text>
      </xsl:when>
      <xsl:when test="following-sibling::tei:docAuthor">
        <xsl:text>, </xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:author" mode="author">
    <xsl:apply-templates select="*[not(self::tei:email or self::tei:affiliation)]|text()"/>
    <xsl:choose>
      <xsl:when test="count(following-sibling::tei:author)=1">
        <xsl:if test="count(preceding-sibling::tei:author)&gt;1">
          <xsl:text>,</xsl:text>
        </xsl:if>
        <!-- i18n -->
        <xsl:text> et </xsl:text>
      </xsl:when>
      <xsl:when test="following-sibling::tei:author">, </xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
