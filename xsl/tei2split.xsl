<?xml version="1.0" encoding="UTF-8"?>
<!--
Split a single TEI book in XML chapters.
Could be overrided for other output formats
(epub, html site, html fragments…)

BSD-3-Clause https://opensource.org/licenses/BSD-3-Clause
© 2019 Frederic.Glorieux@fictif.org & LABEX OBVIL & Optéos
© 2013 Frederic.Glorieux@fictif.org & LABEX OBVIL
© 2012 Frederic.Glorieux@fictif.org
© 2010 Frederic.Glorieux@fictif.org & École nationale des chartes
© 2007 Frederic.Glorieux@fictif.org
© 2005 ajlsm.com (Cybertheses)

XSLT 1.0, compatible browser, PHP, Python, Java…
-->
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <xsl:import href="common.xsl"/>
  <xsl:output indent="yes" encoding="UTF-8" method="xml" />
  <xsl:variable name="split" select="true()"/>
  <xsl:key name="split" match="
tei:*[self::tei:div or self::tei:div1 or self::tei:div2][normalize-space(.) != ''][@type][
  contains(@type, 'article') 
    or contains(@type, 'chapter') 
    or contains(@subtype, 'split') 
    or contains(@type, 'act')  
    or contains(@type, 'poem')
    or contains(@type, 'letter')
] 
| tei:group/tei:text 
| tei:TEI/tei:text/tei:*/tei:*[self::tei:div or self::tei:div1 or self::tei:group or self::tei:titlePage  or self::tei:castList][normalize-space(.) != '']" 
use="generate-id(.)"/>
  <!-- Source file name (without extension) -->
  <xsl:param name="src_name"/>
  <!-- Required, folder where to project the generated files -->
  <xsl:param name="dst_dir">
    <xsl:choose>
      <xsl:when test="$src_name != ''">
        <xsl:value-of select="$src_name"/>
        <xsl:text>/</xsl:text>
      </xsl:when>
      <xsl:otherwise>html/</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- Extension for generated files -->
  <xsl:param name="_ext">.xml</xsl:param>
  

  <!-- Process root -->
  <xsl:template match="/*" name="split">
    <xsl:apply-templates select="." mode="split"/>
  </xsl:template>
  
  <!-- Default, go through -->
  <xsl:template match="*" mode="split">
    <xsl:apply-templates mode="split"/>
  </xsl:template>
  <!-- Do not output text -->
  <xsl:template match="text()" mode="split"/>
  
  <!-- section container -->
  <xsl:template match="tei:back | tei:body | tei:front" mode="split">
    <xsl:choose>
      <!-- simple content -->
      <xsl:when test="tei:p|tei:l|tei:list|tei:argument|tei:table|tei:docTitle|tei:docAuthor">
        <xsl:call-template name="document"/>
      </xsl:when>
      <!-- Sections, blocks will be lost -->
      <xsl:when test="descendant::*[key('split', generate-id())]">
        <xsl:apply-templates select="tei:argument  | tei:div | tei:div0 | tei:div1 |  tei:castList | tei:epilogue | tei:performance | tei:prologue | tei:set | tei:titlePage" mode="split"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template> 
  
  <!-- Sections, candidates for split -->
  <xsl:template match="
    tei:group/tei:text | tei:group |
    tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7 
    " mode="split">
    <xsl:param name="type"/>
    <xsl:choose>
      <!-- there are children to split, so we should do something special with what is before (and also after)
          Is it a great idea to open a file/page for such division which could contain no more than a title ?      
      -->
      <xsl:when test="descendant::*[key('split', generate-id())]">
        <!-- take content before sections -->
        <xsl:variable name="before" select="generate-id(tei:group|tei:div|tei:div0|tei:div1|tei:div2|tei:div3|tei:div4|tei:div5|tei:div6)"/>
        <xsl:variable name="blocks" select="tei:*[following-sibling::*[generate-id(.)=$before]]"/>
        <!-- Get last pb ? -->
        <xsl:variable name="lastpb">
          <!-- if a page break just before, catch it -->
          <xsl:if test="preceding-sibling::*[1][self::tei:pb]">
            <xsl:apply-templates select="preceding-sibling::*[1]"/>
          </xsl:if>
        </xsl:variable>
        
        <!-- TO synchronize with tei2opf.xsl -->
        <xsl:choose>
          <xsl:when test="(self::tei:front|self::tei:body|self::tei:back) and not(tei:p|tei:l|tei:list|tei:argument|tei:table)"/>
          <xsl:when test="$blocks[tei:*[local-name()!='head'][local-name()!='pb'][local-name()!='index']]">
            <xsl:call-template name="document">
              <xsl:with-param name="tei" select="$blocks"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
        <xsl:apply-templates select=" tei:div | tei:div0 | tei:div1 | tei:div2 | tei:div3 | tei:div4 | tei:div5 | tei:div6 | tei:div7 " mode="split"/>
        <!-- What about content after last section ? -->
      </xsl:when>
      <!-- Should be a leave with no children to split -->
      <xsl:otherwise>
        <xsl:if test="not(key('split', generate-id()))">
          <xsl:message>tei2split.xsl, split problem for: <xsl:call-template name="id"/>, <xsl:call-template name="title"/></xsl:message>
        </xsl:if>
        <xsl:call-template name="document">
          <xsl:with-param name="tei" select="*"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

  <!-- Metadata, one day, should do something -->
  <xsl:template match="tei:teiHeader" mode="split"/>
  
   
  <!-- Write a document -->
  <xsl:template name="document">
    <!-- TEI to process -->
    <xsl:param name="tei" select="."/>
    <!-- Content generated -->
    <xsl:param name="cont">
      <xsl:call-template name="cont">
        <xsl:with-param name="tei" select="$tei"/>
      </xsl:call-template>
    </xsl:param>
    <!-- Allow id override -->
    <xsl:param name="id">
      <xsl:call-template name="id"/>
    </xsl:param>
    <xsl:param name="href">
      <xsl:value-of select="$dst_dir"/>
      <!-- An anchor mybe needed -->
      <xsl:call-template name="href">
        <xsl:with-param name="id" select="$id"/>
        <!-- no base for such links -->
        <xsl:with-param name="base"/>
      </xsl:call-template>
    </xsl:param>
    <!-- Log something -->
    <document>
      <xsl:value-of select="$href"/>
      <xsl:text> : </xsl:text>
      <xsl:call-template name="idpath"/>
    </document>
    <xsl:document 
      href="{$href}" 
      omit-xml-declaration="yes" 
      encoding="UTF-8" 
      indent="yes"
      >
      <xsl:copy-of select="$cont"/>
    </xsl:document>
  </xsl:template>
  
  <xsl:template name="cont">
    <xsl:param name="tei" select="."/>
    <div>
      <xsl:copy-of select="$tei"/>
    </div>
  </xsl:template>

  

</xsl:transform>
