<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:rels="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"

  xmlns:teinte="https://oeuvres.github.io/teinte"

  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="pkg r rels teinte w"
  >
  <xsl:output encoding="UTF-8" indent="no" omit-xml-declaration="yes"/>
  <xsl:variable name="sheet" select="document('styles.xml', document(''))"/>
  <xsl:variable name="UC">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
  <xsl:variable name="lc">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:key name="footnotes" match="//w:footnotes/w:footnote" use="@w:id"/>
  <xsl:key name="endnotes" match="//w:endnotes/w:endnote" use="@w:id"/>
  <xsl:key name="document.xml.rels" 
    match="//pkg:part[contains(@pkg:name, 'document.xml.rels')]/*/*/rels:Relationship" 
    use="@Id"/>
  <xsl:key name="footnotes.xml.rels" 
    match="//pkg:part[contains(@pkg:name, 'footnotes.xml.rels')]/*/*/rels:Relationship" 
    use="@Id"/>
  <xsl:key name="endnotes.xml.rels" 
    match="//pkg:part[contains(@pkg:name, 'endnotes.xml.rels')]/*/*/rels:Relationship" 
    use="@Id"/>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="/">
    <xsl:apply-templates select="//w:document"/>
  </xsl:template>
  <!-- root element -->
  <xsl:template match="w:document">
    <article>
      <xsl:apply-templates/>
    </article>
  </xsl:template>
  <xsl:template match="w:body">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- Stripped elements -->
  <xsl:template match="w:lastRenderedPageBreak"/>
  <!-- block -->
  <xsl:template match="w:p">
    <xsl:variable name="val" select="normalize-space(translate(w:pPr/w:pStyle/@w:val, $UC, $lc))"/>
    <xsl:variable name="style" select="$sheet/*/teinte:style[@level='p'][@name=$val]"/>
    <xsl:choose>
      <!-- para in footnote force line break -->
      <xsl:when test="ancestor::w:footnote|ancestor::w:endnote">
        <xsl:text>&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#10;&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <!-- get some local rendering -->
    <xsl:variable name="_rend">
      <xsl:if test="number(w:pPr/w:ind/@w:hanging) &gt; 150"> hanging </xsl:if>
    </xsl:variable>
    <xsl:variable name="rend" select="normalize-space($_rend)"/>
    <xsl:choose>
      <xsl:when test="$sheet/*/teinte:style[@level='0'][@name=$val] or $val = ''">
        <p>
          <xsl:if test="$rend != ''">
            <xsl:attribute name="rend">
              <xsl:value-of select="$rend"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="w:hyperlink | w:r"/>
        </p>
      </xsl:when>
      <xsl:when test="$style/@parent != ''">
        <xsl:element name="{$style/@parent}">
          <xsl:element name="{$style/@element}">
            <xsl:if test="$style/@attribute">
              <xsl:attribute name="{$style/@attribute}">
                <xsl:value-of select="$style/@value"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="w:hyperlink | w:r"/>
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$style/@element">
        <xsl:element name="{$style/@element}">
          <xsl:if test="$style/@attribute">
            <xsl:attribute name="{$style/@attribute}">
              <xsl:value-of select="$style/@value"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="w:hyperlink | w:r"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:if test="$rend != ''">
            <xsl:attribute name="rend">
              <xsl:value-of select="$rend"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="w:hyperlink | w:r"/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="(ancestor::w:footnote|ancestor::w:endnote) and position() = last()">
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template match="w:br">
    <xsl:text>&#10;</xsl:text>
    <lb/>
  </xsl:template>
  <xsl:template match="w:br[@w:type='page']">
    <xsl:text>&#10;</xsl:text>
    <pb/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="w:t">
    <xsl:value-of select="."/>
  </xsl:template>
  <!-- chars -->
  <xsl:template match="w:r">
    <xsl:variable name="t">
      <xsl:for-each select="*[not(self::w:rPr)]">
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </xsl:variable>
    <!-- What about line break in superscript ? -->
    <xsl:variable name="sup">
      <xsl:choose>
        <!-- probably footnote reference or  -->
        <xsl:when test="$t = ''"/>
        <xsl:when test="w:rPr/w:vertAlign/@w:val = 'superscript'">
          <sup>
            <xsl:copy-of select="$t"/>
          </sup>
        </xsl:when>
        <xsl:when test="w:rPr/w:vertAlign/@w:val = 'subscript'">
          <sup>
            <xsl:copy-of select="$t"/>
          </sup>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$t"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sc">
      <xsl:choose>
        <xsl:when test="w:rPr/w:smallCaps">
          <sc>
            <xsl:copy-of select="$sup"/>
            <xsl:apply-templates select="w:footnoteReference"/>
            <xsl:apply-templates select="w:endnoteReference"/>
          </sc>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$sup"/>
          <xsl:apply-templates select="w:footnoteReference"/>
          <xsl:apply-templates select="w:endnoteReference"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="i">
      <xsl:choose>
        <xsl:when test="w:rPr/w:i">
          <i>
            <xsl:copy-of select="$sc"/>
          </i>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$sc"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- last out -->
    <xsl:variable name="val" select="normalize-space(translate(w:rPr/w:rStyle/@w:val, $UC, $lc))"/>
    <xsl:variable name="style" select="$sheet/*/teinte:style[@level='c'][@name=$val]"/>
    <xsl:choose>
      <xsl:when test="$val = ''">
        <xsl:copy-of select="$i"/>
      </xsl:when>
      <!-- redundant -->
      <xsl:when test="ancestor::w:hyperlink and $style/@element = 'ref'">
        <xsl:copy-of select="$i"/>
      </xsl:when>
      <xsl:when test="$style/@element != ''">
        <xsl:element name="{$style/@element}">
          <xsl:copy-of select="$i"/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$sheet/*/teinte:style[@level='0'][@name=$val]">
        <xsl:copy-of select="$i"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{$val}">
          <xsl:copy-of select="$i"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="w:sectPr"/>
  <!-- spaces -->
  <xsl:template match="w:tab">
    <space type="tab">
      <xsl:text>    </xsl:text>
    </space>
  </xsl:template>
  <!-- Notes -->
  <xsl:template match="w:footnoteReference">
    <xsl:for-each select="key('footnotes',@w:id)">
      <note place="foot">
        <xsl:choose>
          <xsl:when test="count(w:p) = 1">
            <xsl:apply-templates select="w:p/w:hyperlink | w:p/w:r"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="*"/>
          </xsl:otherwise>
        </xsl:choose>
      </note>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="w:endnoteReference">
    <xsl:for-each select="key('endnotes',@w:id)">
      <note place="end">
        <xsl:choose>
          <xsl:when test="count(w:p) = 1">
            <xsl:apply-templates select="w:p/w:hyperlink | w:p/w:r"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="*"/>
          </xsl:otherwise>
        </xsl:choose>
      </note>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="w:hyperlink">
    <ref>
      <xsl:variable name="target">
        <xsl:choose>
          <xsl:when test="ancestor::w:endnote">
            <xsl:for-each select="key('endnotes.xml.rels', @r:id)">
              <xsl:value-of select="@Target"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="ancestor::w:footnote">
            <xsl:for-each select="key('footnotes.xml.rels', @r:id)">
              <xsl:value-of select="@Target"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="key('document.xml.rels', @r:id)">
              <xsl:value-of select="@Target"/>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="$target != ''">
        <xsl:attribute name="target">
          <xsl:value-of select="$target"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="w:r"/>
    </ref>
  </xsl:template>
  <xsl:template match="w:bookmarkStart"/>
  <xsl:template match="w:bookmarkEnd"/>
</xsl:transform>
