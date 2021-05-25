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
2021, frederic.glorieux@fictif.org
  -->
  <xsl:template match="tei:cell">
    <xsl:if test="preceding-sibling::tei:cell">\tabcellsep </xsl:if>
    <xsl:choose>
      <xsl:when test="@role='label'">
        <xsl:text>\Panel{</xsl:text>
        <xsl:if test="starts-with(normalize-space(.),'[')">
          <xsl:text>{}</xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:text>}{label}{</xsl:text>
        <xsl:choose>
          <xsl:when test="@cols">
            <xsl:value-of select="@cols"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
        <xsl:text>}{</xsl:text>
        <xsl:choose>
          <xsl:when test="@align='right'">r</xsl:when>
          <xsl:when test="@align='centre'">c</xsl:when>
          <xsl:when test="@align='center'">c</xsl:when>
          <xsl:when test="@align='left'">l</xsl:when>
          <xsl:otherwise>l</xsl:otherwise>
        </xsl:choose>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="@cols &gt; 1">
        <xsl:text>\multicolumn{</xsl:text>
        <xsl:value-of select="@cols"/>
        <xsl:text>}{</xsl:text>
        <xsl:if test="@role='label' or
			  parent::tei:row/@role='label'">
          <xsl:text>){\columncolor{label}}</xsl:text>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="@align='right'">r</xsl:when>
          <xsl:when test="@align='centre'">c</xsl:when>
          <xsl:when test="@align='center'">c</xsl:when>
          <xsl:when test="@align='left'">l</xsl:when>
          <xsl:otherwise>l</xsl:otherwise>
        </xsl:choose>
        <xsl:text>}{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="@align">
        <xsl:text>\multicolumn{1}{</xsl:text>
        <xsl:if test="@role='label' or
			  parent::tei:row/@role='label'">
          <xsl:text>){\columncolor{label}}</xsl:text>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="@align='right'">r</xsl:when>
          <xsl:when test="@align='centre'">c</xsl:when>
          <xsl:when test="@align='center'">c</xsl:when>
          <xsl:when test="@align='left'">l</xsl:when>
          <xsl:otherwise>l</xsl:otherwise>
        </xsl:choose>
        <xsl:text>}{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="starts-with(normalize-space(.),'[')">
          <xsl:text>{}</xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:figDesc"/>
  
  <xsl:template match="tei:figure">
    <xsl:call-template name="makeFigureStart"/>
    <xsl:apply-templates/>
    <xsl:call-template name="makeFigureEnd"/>
  </xsl:template>
  
  <xsl:template match="tei:graphic|tei:media">
    <xsl:call-template name="makePic"/>
  </xsl:template>
  
  <xsl:template match="tei:row">
    <xsl:if test="@role='label'">\rowcolor{label}</xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="following-sibling::tei:row">
      <xsl:text>\\</xsl:text>
      <xsl:if test="@role='label' or parent::tei:table[contains(@rend, 'rules')]">\hline </xsl:if>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:table" mode="xref">
    <xsl:text>the table on p. \pageref{</xsl:text>
    <xsl:value-of select="@xml:id"/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:table">
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:text> \par </xsl:text>
    <xsl:choose>
      <xsl:when test="ancestor::tei:table or $longtables='false'">
        <xsl:text>\begin{tabular}</xsl:text>
        <xsl:call-template name="makeTable"/>
        <xsl:text>\end{tabular}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#10;\begin{longtable}</xsl:text>
        <xsl:call-template name="makeTable"/>
        <xsl:text>\end{longtable} \par&#10; </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:table[contains(@rend, 'display')]" mode="xref">
    <xsl:text>Table </xsl:text>
    <xsl:number count="tei:table[contains(@rend, 'display')]" level="any"/>
  </xsl:template>
  
  <xsl:template match="tei:table[contains(@rend, 'display')]">
    <xsl:text>\begin{table}</xsl:text>
    <xsl:text>\begin{center} \begin{small} \begin{tabular}</xsl:text>
    <xsl:call-template name="makeTable"/>
    <xsl:text>\end{tabular} 
      \caption{</xsl:text>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:apply-templates mode="ok" select="tei:head"/>
    <xsl:text>}
     \end{small} 
     \end{center}
     \end{table}</xsl:text>
  </xsl:template>
  
  <xsl:template name="makeFigureStart">
    <xsl:choose>
      <xsl:when test="@place='inline' and tei:head">
        <xsl:text>\begin{figure}[H]&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@rend, 'display') or not(@place='inline') or tei:head or tei:p">
        <xsl:text>\begin{figure}[htbp]&#10;</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="contains(@rend, 'center')">
        <xsl:text>\begin{center}</xsl:text>
      </xsl:when>
      <xsl:otherwise>\noindent</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="makeFigureEnd">
    <xsl:choose>
      <xsl:when test="tei:head or tei:p">
        <xsl:text>&#10;\caption{</xsl:text>
        <xsl:call-template name="tei:makeHyperTarget"/>
        <xsl:for-each select="tei:head">
          <xsl:apply-templates/>
        </xsl:for-each>
        <xsl:text>}</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="contains(@rend,'center')">
      <xsl:text>\end{center}</xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@place='inline' and tei:head">
        <xsl:text>\end{figure}&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@rend,'display') or not(@place='inline')">
        <xsl:text>\end{figure}&#10;</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="makePic">
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:choose>
      <xsl:when test="contains(@rend, 'noindent')">
        <xsl:text>\noindent</xsl:text>
      </xsl:when>
      <xsl:when test="not(preceding-sibling::*)">
        <xsl:text>\noindent</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:variable name="pic">
      <xsl:text>\includegraphics[</xsl:text>
      <xsl:call-template name="graphicsAttributes">
        <xsl:with-param name="mode">latex</xsl:with-param>
      </xsl:call-template>
      <xsl:text>]{</xsl:text>
      <!-- tei:resolveURI may be used here -->
      <xsl:choose>
        <xsl:when test="$realFigures='true'">
          <xsl:value-of select="@url"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="F">
            <xsl:value-of select="@url"/>
          </xsl:variable>
          <xsl:text>Pictures/resource</xsl:text>
          <xsl:number level="any"/>
          <xsl:text>.</xsl:text>
          <!-- ?? extension ?  -->
          <xsl:value-of select="@url"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}</xsl:text>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="parent::tei:ref">
        <xsl:value-of select="$pic"/>
      </xsl:when>
      <xsl:when test="not(following-sibling::tei:graphic[contains(@rend,'alignright')])
        and contains(@rend,'alignright')">
        <xsl:text>\begin{wrapfigure}{r}{</xsl:text>
        <xsl:value-of select="@width"/>
        <xsl:text>}</xsl:text>
        <xsl:value-of select="$pic"/>
        <xsl:text>\end{wrapfigure}</xsl:text>
      </xsl:when>
      <xsl:when test="not (following-sibling::tei:graphic[contains(@rend,'alignleft')])
			and contains(@rend,'alignleft')">
        <xsl:text>\begin{wrapfigure}{l}{</xsl:text>
        <xsl:value-of select="@width"/>
        <xsl:text>}</xsl:text>
        <xsl:value-of select="$pic"/>
        <xsl:text>\end{wrapfigure}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$pic"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="graphicsAttributes">
    <xsl:if test="@width">
      <xsl:variable name="unit" select="translate(@width, '  0123456789', '')"/>
      <xsl:choose>
        <xsl:when test="$unit = '%'">
          <xsl:text>width=</xsl:text>
          <xsl:value-of select="number(substring-before(@width,'%')) div 100"/>
          <xsl:text>\textwidth,</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="w">
            <xsl:choose>
              <xsl:when test="$unit = 'px'">
                <xsl:value-of select="substring-before(@width,'px')"/>
                <xsl:text>pt</xsl:text>
              </xsl:when>
              <xsl:when test="$unit = ''">
                <xsl:value-of select="@width"/>
                <xsl:text>pt</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@width"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:text>width=</xsl:text>
          <xsl:value-of select="$w"/>
          <xsl:text>,</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="@height">
      <xsl:variable name="unit" select="translate(@height, '  0123456789', '')"/>
      <xsl:choose>
        <xsl:when test="$unit = '%'">
          <xsl:text>height=</xsl:text>
          <xsl:value-of select="number(substring-before(@height,'%')) div 100"/>
          <xsl:text>\textheight,</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="h">
            <xsl:choose>
              <xsl:when test="$unit = 'px'">
                <xsl:value-of select="substring-before(@height,'px')"/>
                <xsl:text>pt</xsl:text>
              </xsl:when>
              <xsl:when test="$unit = ''">
                <xsl:value-of select="@height"/>
                <xsl:text>pt</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@height"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:text>height=</xsl:text>
          <xsl:value-of select="$h"/>
          <xsl:text>,</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <!-- For larger graphics in XSL:FO, we want to make sure they're scaled 
     nicely to fit on the page. -->
    <!-- We have no idea how the height & width were specified for latex -->
    <xsl:variable name="unit" select="translate(@height, '  0123456789', '')"/>
    <xsl:variable name="s">
      <xsl:choose>
        <xsl:when test="@scale and $unit = '%'">
          <xsl:value-of select="number(substring-before(@scale,'%')) div 100"/>
        </xsl:when>
        <xsl:when test="@scale">
          <xsl:value-of select="@scale"/>
        </xsl:when>
        <xsl:when test="not(@width) and not(@height) and not($standardScale=1)">
          <xsl:value-of select="$standardScale"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="not($s='')">
      <xsl:text>scale=</xsl:text>
      <xsl:value-of select="$s"/>
      <xsl:text>,</xsl:text>
    </xsl:if>
  </xsl:template>
  
  
  
  
  <xsl:template name="makeTable">
    <xsl:variable name="r">
      <xsl:value-of select="@rend"/>
    </xsl:variable>
    <xsl:text>{</xsl:text>
    <xsl:if test="contains($r,'rules')">|</xsl:if>
    <xsl:choose>
      <xsl:when test="@preamble">
        <xsl:value-of select="@preamble"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="makePreamble-complex">
          <xsl:with-param name="r" select="$r"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>}&#10;</xsl:text>
    <xsl:if test="contains($r,'rules') or tei:head">
      <xsl:call-template name="tableHline"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="tei:head and not(contains(@rend, 'display'))">
        <xsl:if test="not(ancestor::tei:table or $longtables='false')">
          <xsl:text>\endfirsthead </xsl:text>
          <xsl:text>\multicolumn{</xsl:text>
          <xsl:value-of select="count(tei:row[1]/tei:cell)"/>
          <xsl:text>}{c}{</xsl:text>
          <xsl:apply-templates mode="ok" select="tei:head"/>
          <xsl:text>(cont.)}\\\hline \endhead </xsl:text>
        </xsl:if>
        <xsl:text>\caption{</xsl:text>
        <xsl:apply-templates mode="ok" select="tei:head"/>
        <xsl:text>}\\ </xsl:text>
      </xsl:when>
      <xsl:otherwise> </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="contains($r,'rules') or tei:row[1][@role='label']">\hline </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="contains($r,'rules')">
      <xsl:text>\\ \hline </xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template name="tableHline">
    <xsl:choose>
      <xsl:when test="ancestor::tei:table or $longtables='false' or contains(@rend,'display')"> \hline </xsl:when>
      <xsl:otherwise> \hline\endfoot\hline\endlastfoot </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="makePreamble-complex">
    <xsl:param name="r"/>
    <xsl:variable name="valign">
      <xsl:choose>
        <xsl:when test="contains($r,'bottomAlign')">B</xsl:when>
        <xsl:when test="contains($r,'midAlign')">M</xsl:when>
        <xsl:otherwise>P</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="tds">
      <xsl:for-each select="tei:row">
        <xsl:variable name="row">
          <xsl:for-each select="tei:cell">
            <xsl:variable name="stuff">
              <xsl:apply-templates/>
            </xsl:variable>
            <cell>
              <xsl:value-of select="string-length($stuff)"/>
            </cell>
            <xsl:if test="@cols">
              <xsl:variable name="c" select="round(@cols) - 1 "/>
              <xsl:for-each select="(//*)[position() &lt; $c]">
                <cell>0</cell>
              </xsl:for-each>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="$row/cell">
          <cell col="{position()}">
            <xsl:value-of select="."/>
          </cell>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="total">
      <xsl:value-of select="sum($tds/cell)"/>
    </xsl:variable>
    <xsl:for-each select="$tds/cell">
      <xsl:variable name="c" select="@col"/>
      <xsl:if test="not(preceding-sibling::cell[$c=@col])">
        <xsl:variable name="len">
          <xsl:value-of select="sum(following-sibling::cell[$c=@col]) + current()"/>
        </xsl:variable>
        <xsl:value-of select="$valign"/>
        <xsl:text>{</xsl:text>
        <xsl:value-of select="($len div $total) * $tableMaxWidth"/>
        <xsl:text>\textwidth}</xsl:text>
        <xsl:if test="contains($r,'rules')">|</xsl:if>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="makePreamble-simple">
    <xsl:param name="r"/>
    <xsl:for-each select="tei:row[1]/tei:cell">
      <xsl:text>l</xsl:text>
      <xsl:if test="contains($r,'rules')">|</xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:transform>
