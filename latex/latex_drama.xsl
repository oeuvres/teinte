<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  exclude-result-prefixes="tei">
  <!-- 
TEI Styleshest for LaTeX, forked from Sebastian Rahtz
https://github.com/TEIC/Stylesheets/tree/dev/latex
  
1. Distributed under a Creative Commons Attribution-ShareAlike 3.0
   License http://creativecommons.org/licenses/by-sa/3.0/ 
2. http://www.opensource.org/licenses/BSD-2-Clause

A light version for XSLT1, with local improvements.
2021, frederic.glorieux@fictif.org
  -->
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element actor</desc>
   </doc>
  <xsl:template match="tei:actor">
      <xsl:text>\textit{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element camera</desc>
   </doc>
  <xsl:template match="tei:camera">
      <xsl:text>\textit{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element caption</desc>
   </doc>
  <xsl:template match="tei:caption">
      <xsl:text>\textit{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element castGroup</desc>
   </doc>
  <xsl:template match="tei:castGroup"> 
      <xsl:text>\begin{itemize} </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&#10;\end{itemize}</xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element castItem</desc>
   </doc>
  <xsl:template match="tei:castItem">
    <xsl:text>&#10;\item </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element castList</desc>
   </doc>
  <xsl:template match="tei:castList">
      <xsl:if test="tei:head">
         <xsl:text> \par\textit{</xsl:text>
         <xsl:for-each select="tei:head">
            <xsl:apply-templates/>
         </xsl:for-each>
         <xsl:text>}&#10;</xsl:text>
      </xsl:if> 
      <xsl:text>\begin{itemize} </xsl:text>
      <xsl:apply-templates/> 
      <xsl:text>\end{itemize} </xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process elementp/tei:stage</desc>
   </doc>
  <xsl:template match="tei:p/tei:stage">
      <xsl:text>\textit{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element role</desc>
   </doc>
  <xsl:template match="tei:role">
      <xsl:text>\textbf{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element roleDesc</desc>
   </doc>
  <xsl:template match="tei:roleDesc">
      <xsl:text>\begin{quote}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{quote}</xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element set</desc>
   </doc>
  <xsl:template match="tei:set">
      <xsl:text>\textit{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element sound</desc>
   </doc>
  <xsl:template match="tei:sound">
      <xsl:text>\textit{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element sp</desc>
   </doc>
  <xsl:template match="tei:sp"> \begin{description} \item[<xsl:apply-templates select="tei:speaker"/>] <xsl:apply-templates select="tei:p | tei:l | tei:lg | tei:seg |      tei:ab | tei:stage"/>
      <xsl:text>\end{description}
</xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element sp/tei:p</desc>
   </doc>
  <xsl:template match="tei:sp/tei:p">
    <xsl:text>&#10;&#10;</xsl:text>
      <xsl:apply-templates/>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element stage</desc>
   </doc>
  <xsl:template match="tei:stage">
      <xsl:text>\textit{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}\par&#10;</xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element sp/tei:stage</desc>
   </doc>
  <xsl:template match="tei:sp/tei:stage">
      <xsl:text/>
      <xsl:text>\textit{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>} </xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element tech</desc>
   </doc>
  <xsl:template match="tei:tech">
      <xsl:text>\textit{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
      <desc>Process element view</desc>
   </doc>
  <xsl:template match="tei:view">
      <xsl:text>\textit{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
  </xsl:template>
</xsl:transform>