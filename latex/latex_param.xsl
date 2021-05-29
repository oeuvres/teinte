<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <!-- 
TEI Styleshest for LaTeX, forked from Sebastian Rahtz
https://github.com/TEIC/Stylesheets/tree/dev/latex
  
1. Distributed under a Creative Commons Attribution-ShareAlike 3.0
   License http://creativecommons.org/licenses/by-sa/3.0/ 
2. http://www.opensource.org/licenses/BSD-2-Clause

A light version for XSLT1, with local improvements.
2021, frederic.glorieux@fictif.org
  -->
  <!-- keys used for tests -->
  <xsl:key name="ENDNOTES" match="tei:note[@place='end']" use="1"/>
  <xsl:key name="FOOTNOTES" match="tei:note[not(@place) or @place='bottom']" use="1"/>
  <xsl:key name="TREES" match="tei:eTree[not(ancestor::tei:eTree)]" use="1"/>
  <xsl:key name="APP" match="tei:app" use="1"/>
  <xsl:key name="CHAPTERS" match="tei:div[@type='chapter' or @type='article']" use="generate-id()"/>
  
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="numbering" type="boolean">
    <desc>Automatically number sections</desc>
  </doc>
  <xsl:param name="numberHeadings"/>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="numbering" type="string">
    <desc>How to construct heading numbering in back matter</desc>
  </doc>
  <xsl:param name="numberBackHeadings"/>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="numbering" type="string">
    <desc>How to construct heading numbering in front matter</desc>
  </doc>
  <xsl:param name="numberFrontHeadings"/>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="numbering" type="boolean">
    <desc>Automatically number paragraphs.</desc>
  </doc>
  <xsl:param name="numberParagraphs">false</xsl:param>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="output" type="boolean">
    <desc>Whether it should be attempted to make quotes into block
      quotes if they are over a certain length</desc>
  </doc>
  <xsl:param name="autoBlockQuote">false</xsl:param>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="output" type="integer">
    <desc>Length beyond which a quote is a block quote</desc>
  </doc>
  <xsl:param name="autoBlockQuoteLength">150</xsl:param>
  <xsl:param name="parSkip">3pt</xsl:param>
  <xsl:param name="parIndent">3pt</xsl:param>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="output" type="string">
    <desc>location of original XML file, for looking up relative pointers</desc>
  </doc>
  <xsl:param name="ORIGDIR"/>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="layout" type="string">
    <desc>Logo graphics file</desc>
  </doc>
  <xsl:param name="latexLogo"/>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="output" type="string">
    <desc>URL root where referenced documents are located</desc>
  </doc>
  <xsl:param name="baseURL"/>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="userpackage" type="string">
    <desc>The name of a LaTeX style package which should be loaded</desc>
  </doc>
  <xsl:param name="userpackage"/>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="output" type="boolean">
    <desc>Use real name of graphics files rather than pointers</desc>
  </doc>
  <xsl:param name="realFigures">true</xsl:param>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="layout" type="float">
    <desc>When processing a "pb" element, decide what to generate: "active" generates a page break; "visible" generates a bracketed number (with scissors), and "bracketsonly" generates a bracketed number (without scissors).</desc>
  </doc>
  <xsl:param name="pagebreakStyle"/>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="layout" type="float">
    <desc>When making a table, what width must be constrained to fit, as a proportion of the page width.</desc>
  </doc>
  <xsl:param name="tableMaxWidth">0.85</xsl:param>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="layout" type="boolean">
    <desc>Whether to number lines of poetry</desc>
  </doc>
  <xsl:param name="verseNumbering">false</xsl:param>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="layout" type="integer">
    <desc>When numbering poetry, how often to put in a line number</desc>
  </doc>
  <xsl:param name="everyHowManyLines">5</xsl:param>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="layout" type="string">
    <desc>When numbering poetry, when to restart the sequence; this must be the name of a TEI element</desc>
  </doc>
  <xsl:param name="resetVerseLineNumbering">div1</xsl:param>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" class="layout" type="string">
    <desc>Which environment to use for quotes (quote, quotation, quoting, ...)</desc>
  </doc>
  <xsl:param name="quoteEnv">quoting</xsl:param>
  

  <xsl:param name="longtables">true</xsl:param>

  <xsl:template name="makeItem">
    <xsl:text>&#10;\item</xsl:text>
    <xsl:if test="@n">[<xsl:value-of select="@n"/>]</xsl:if>
    <xsl:text> </xsl:text>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:call-template name="rendering"/>
  </xsl:template>
  <xsl:template name="makeLabelItem">
    <xsl:text>&#10;\item</xsl:text>
    <xsl:if test="@n">[<xsl:value-of select="@n"/>]</xsl:if>
    <xsl:text> </xsl:text>
    <xsl:call-template name="rendering"/>
  </xsl:template>
</xsl:transform>
