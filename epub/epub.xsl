<?xml version="1.0" encoding="UTF-8"?>
<!--

LGPL http://www.gnu.org/licenses/lgpl.html
© 2012–2013 frederic.glorieux@fictif.org
© 2013–2015 frederic.glorieux@fictif.org et LABEX OBVIL

Epub parameters
-->
<xsl:transform version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  exclude-result-prefixes="tei" 
  >
  <xsl:param name="cover"/>
  <!-- For link resolution, split -->
  <xsl:variable name="split" select="true()"/>
  <!-- Used on opf template  -->
  <xsl:key name="opfid" match="*" use="@id"/>
  <!-- @type="character" pfff. -->
  <xsl:key name="split" match="
    tei:*[@type][self::tei:div or self::tei:div0 or self::tei:div1 or self::tei:div2 or self::tei:div3][
      contains(@type, 'article') or 
      contains(@type, 'chapter') or 
      contains(@type, 'dedication') or 
      contains(@subtype, 'split') or 
      contains(@type, 'act') 
    ]
| /tei:TEI/tei:text/tei:body[not(tei:div)][not(tei:div1)]
| tei:group/tei:text 
| /tei:TEI/tei:text/tei:*/tei:*[self::tei:argument or self::tei:castList or self::tei:div or self::tei:div1 or self::tei:epilogue or self::tei:group or self::tei:performance or self::tei:prologue or self::tei:set or self::tei:titlePage ][normalize-space(.) != '']
  " use="generate-id(.)"/>
  <!-- Name of page where to project inline footnotes -->
  <xsl:param name="fnpage">
    <xsl:choose>
      <xsl:when test="//tei:note">endnotes</xsl:when>
    </xsl:choose>
  </xsl:param>
</xsl:transform>
