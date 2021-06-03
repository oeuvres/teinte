<?xml version="1.0" encoding="utf-8"?>
<xsl:transform  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  exclude-result-prefixes="tei"

  xmlns:str="http://exslt.org/strings"
  xmlns:exslt="http://exslt.org/common" 
  extension-element-prefixes="str exslt"
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
  <xsl:import href="latex_param.xsl"/>
  <xsl:import href="common1.xsl"/>
  <!-- TODO, move params -->
  <xsl:variable name="preQuote">« </xsl:variable>
  <xsl:variable name="postQuote"> »</xsl:variable>
  <!-- TODO, handle dinkus etc… -->
  <xsl:template match="tei:ab">
    <xsl:variable name="norm" select="normalize-space(.)"/>
    <xsl:variable name="dinkus" select="boolean(translate($norm, '  *⁂', '') = '')"/>
    <xsl:choose>
      <xsl:when test="$norm = '*'">
        <xsl:text>&#10;\astermono&#10;&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="($dinkus and tei:lb) or $norm = '⁂'">
        <xsl:text>&#10;\asterism&#10;&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="$dinkus">
        <xsl:text>&#10;\astertri&#10;&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="@type = 'ornament'">
        <xsl:text>&#10;\begin{center}</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>\end{center}&#10;&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
        <xsl:text>\par&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Who call that mode cite ? -->
  <xsl:template match="tei:bibl" mode="cite">
    <xsl:apply-templates select="text()[1]"/>
  </xsl:template>
  <!-- Semantic blocks  -->
  <xsl:template match="tei:byline | tei:dateline | tei:salute | tei:signed">
    <xsl:call-template name="makeBlock"/>
  </xsl:template>
  
  <xsl:template match="tei:argument">
    <xsl:call-template name="makeGroup"/>
  </xsl:template>
  
  
  
  <xsl:template match="tei:cit">
    <xsl:choose>
      <xsl:when test="
          contains(@rend, 'display') or tei:q/tei:p or
          tei:quote/tei:l or tei:quote/tei:p">
        <xsl:text>&#10;\begin{</xsl:text>
        <xsl:value-of select="$quoteEnv"/>
        <xsl:text>}&#10;</xsl:text>
        <xsl:if test="@n">
          <xsl:text>(</xsl:text>
          <xsl:value-of select="@n"/>
          <xsl:text>) </xsl:text>
        </xsl:if>
        <xsl:call-template name="tei:makeHyperTarget"/>
        <xsl:apply-templates select="*[not(self::tei:bibl)]"/>
        <xsl:text>\par&#10;</xsl:text>
        <xsl:apply-templates select="tei:bibl"/>
        <xsl:text>&#10;\end{</xsl:text>
        <xsl:value-of select="$quoteEnv"/>
        <xsl:text>}&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$preQuote"/>
        <xsl:if test="@n">
          <xsl:text>(</xsl:text>
          <xsl:value-of select="@n"/>
          <xsl:text>) </xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:value-of select="$postQuote"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:code">
    <xsl:text>\texttt{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <!-- code example, for TEI documentation, not yet relevant here
  <xsl:template match="tei:seg[tei:match(@rend, 'pre')] | tei:eg | tei:q[tei:match(@rend, 'eg')]">
    <xsl:variable name="stuff">
      <xsl:apply-templates mode="eg"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="ancestor::tei:cell and count(*) = 1 and string-length(.) &lt; 60">
        <xsl:text>\fbox{\ttfamily </xsl:text>
        <xsl:value-of select="tei:escapeCharsVerbatim($stuff)"/>
        <xsl:text>} </xsl:text>
      </xsl:when>
      <xsl:when test="ancestor::tei:cell and not(*) and string-length(.) &lt; 60">
        <xsl:text>\fbox{\ttfamily </xsl:text>
        <xsl:value-of select="tei:escapeCharsVerbatim($stuff)"/>
        <xsl:text>} </xsl:text>
      </xsl:when>
      <xsl:when test="ancestor::tei:cell or tei:match(@rend, 'pre')">
        <xsl:text>\mbox{}\hfill\\[-10pt]\begin{Verbatim}[fontsize=\small]
</xsl:text>
        <xsl:copy-of select="$stuff"/>
        <xsl:text>
\end{Verbatim}
</xsl:text>
      </xsl:when>
      <xsl:when test="ancestor::tei:list[@type = 'gloss']">
        <xsl:text>\hspace{1em}\hfill\linebreak</xsl:text>
        <xsl:text>\bgroup\exampleFont</xsl:text>
        <xsl:text>\vskip 10pt\begin{shaded}
\noindent\obeyspaces{}</xsl:text>
        <xsl:value-of select="tei:escapeCharsVerbatim($stuff)"/>
        <xsl:text>\end{shaded}
\egroup 
</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\par\hfill\bgroup\exampleFont</xsl:text>
        <xsl:text>\vskip 10pt\begin{shaded}
\obeyspaces </xsl:text>
        <xsl:value-of select="tei:escapeCharsVerbatim($stuff)"/>
        <xsl:text>\end{shaded}
\par\egroup 
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="@n">
	<xsl:text>&#10;\begin{Verbatim}[fontsize=\scriptsize,numbers=left,label={</xsl:text>
	<xsl:value-of select="@n"/>
      <xsl:text>}]&#10;</xsl:text>
      <xsl:apply-templates mode="eg"/> 
      <xsl:text>&#10;\end{Verbatim}&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>&#10;\begin{Verbatim}[fontsize=\scriptsize,frame=single]&#10;</xsl:text>
	<xsl:apply-templates mode="eg"/>
	<xsl:text>&#10;\end{Verbatim}&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  -->
  <xsl:template match="tei:emph">
    <xsl:text>\emph{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <!-- Calculate a level 
-1 	\part{part}
0 	\chapter{chapter}
1 	\section{section}
2 	\subsection{subsection}
3 	\subsubsection{subsubsection}
4 	\paragraph{paragraph}
5 	\subparagraph{subparagraph}
  -->
  <xsl:template name="level">
    <xsl:variable name="chapter" select="ancestor::*[key('CHAPTERS',generate-id(.))][1]"/>
    <xsl:choose>
      <xsl:when test="$chapter">
        <xsl:value-of select="count(ancestor::tei:div[ancestor::*[count(.|$chapter) = 1]])"/>
      </xsl:when>
      <xsl:when test="ancestor::tei:div[1]/descendant::*[key('CHAPTERS',generate-id(.))]">-1</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count(ancestor-or-self::tei:div) - 1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="tei:head">
    <xsl:choose>
      <xsl:when test="parent::tei:castList"/>
      <xsl:when test="parent::tei:figure"/>
      <xsl:when test="parent::tei:list"/>
      <xsl:when test="parent::tei:lg"> \subsection*{<xsl:apply-templates/>} </xsl:when>
      <xsl:when test="parent::tei:front or parent::tei:body or parent::tei:back"> \section*{<xsl:apply-templates/>} </xsl:when>
      <xsl:when test="parent::tei:table"/>
      <xsl:otherwise>
        <!-- 
        -->
        <xsl:variable name="level">
          <xsl:call-template name="level"/>
        </xsl:variable>
        <xsl:text>\</xsl:text>
        <xsl:choose>
          <xsl:when test="$documentclass = 'book'">
            <xsl:choose>
              <xsl:when test="$level &lt; 0">part</xsl:when>
              <xsl:when test="$level = 0">chapter</xsl:when>
              <xsl:when test="$level = 1">section</xsl:when>
              <xsl:when test="$level = 2">subsection</xsl:when>
              <xsl:when test="$level = 3">subsubsection</xsl:when>
              <xsl:when test="$level = 4">paragraph</xsl:when>
              <xsl:when test="$level = 5">subparagraph</xsl:when>
              <xsl:when test="$level &gt; 5">subparagraph</xsl:when>
              <xsl:otherwise>section</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$level &lt; 0">part</xsl:when>
              <xsl:when test="$level = 0">section</xsl:when>
              <xsl:when test="$level = 1">subsection</xsl:when>
              <xsl:when test="$level = 2">subsubsection</xsl:when>
              <xsl:when test="$level = 3">paragraph</xsl:when>
              <xsl:when test="$level = 4">subparagraph</xsl:when>
              <xsl:when test="$level &gt; 4">subparagraph</xsl:when>
              <xsl:otherwise>section</xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <!-- 
Old logic of numbering, let Latex consumer choose, but get 
parent::tei:body or ancestor::tei:floatingText
or (ancestor::tei:back and $numberBackHeadings = '')
or (not($numberHeadings = 'true') and ancestor::tei:body)
or (ancestor::tei:front and $numberFrontHeadings = '')
or parent::tei:div[contains(@rend, 'nonumber')]

\chapter[toc-title text only]{title with maybe notes}
        -->
        <xsl:text>[</xsl:text>
        <xsl:variable name="title">
          <xsl:apply-templates select="." mode="title"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($title)"/>
        <xsl:text>]</xsl:text>
        <xsl:text>{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
        <xsl:if test="../@xml:id">
          <xsl:text>\label{</xsl:text>
          <xsl:value-of select="../@xml:id"/>
          <xsl:text>}</xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>


  
  <xsl:template match="tei:gloss">
    <xsl:text>\emph{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="tei:hi">
    <xsl:call-template name="rendering"/>
  </xsl:template>
  <xsl:template name="rendering">
    <xsl:choose>
      <xsl:when test="not(@rend) or normalize-space(@rend) = ''">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="tokens">
          <xsl:choose>
            <xsl:when test="function-available(str:tokenize)">
              <xsl:copy-of select="str:tokenize(normalize-space(@rend))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="str:tokenize">
                <xsl:with-param name="string" select="normalize-space(@rend)"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="decls">
          <xsl:for-each select="exslt:node-set($tokens)">
            <xsl:choose>
              <xsl:when test=". = 'i'">\itshape</xsl:when>
              <xsl:when test=". = 'it'">\itshape</xsl:when>
              <xsl:when test=". = 'ital'">\itshape</xsl:when>
              <xsl:when test=". = 'italics'">\itshape</xsl:when>
              <xsl:when test=". = 'italique'">\itshape</xsl:when>
              <xsl:when test=". = 'b'">\bfseries</xsl:when>
              <xsl:when test=". = 'bold'">\bfseries</xsl:when>
              <xsl:when test=". = 'tt'">\ttfamily</xsl:when>
              <xsl:when test=". = 'sc'">\scshape</xsl:when>
              <xsl:when test=". = 'large'">\large</xsl:when>
              <xsl:when test=". = 'larger'">\larger</xsl:when>
              <xsl:when test=". = 'small'">\small</xsl:when>
              <xsl:when test=". = 'smaller'">\smaller</xsl:when>
              <xsl:when test="starts-with(., 'color')">
                <xsl:text>\color</xsl:text>
                <xsl:choose>
                  <xsl:when test="starts-with(., 'color(')">
                    <xsl:text>{</xsl:text>
                    <xsl:value-of select="substring-before(substring-after(., 'color('), ')')"/>
                    <xsl:text>}</xsl:text>
                  </xsl:when>
                  <xsl:when test="starts-with(., 'color')">
                    <xsl:text>{</xsl:text>
                    <xsl:value-of select="substring-after(., 'color')"/>
                    <xsl:text>}</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="cmd">
          <xsl:for-each select="exslt:node-set($tokens)">
            <xsl:choose>
              <xsl:when test=". = 'strike'">\sout{</xsl:when>
              <xsl:when test=". = 'calligraphic'">\textcal{</xsl:when>
              <xsl:when test=". = 'allcaps'">\uppercase{</xsl:when>
              <xsl:when test=". = 'center'">\centerline{</xsl:when>
              <xsl:when test=". = 'gothic'">\textgothic{</xsl:when>
              <xsl:when test=". = 'noindex'">\textrm{</xsl:when>
              <xsl:when test=". = 'overbar'">\textoverbar{</xsl:when>
              <xsl:when test=". = 'plain'">\textrm{</xsl:when>
              <xsl:when test=". = 'quoted'">\textquoted{</xsl:when>
              <xsl:when test=". = 'sub'">\textsubscript{</xsl:when>
              <xsl:when test=". = 'subscript'">\textsubscript{</xsl:when>
              <xsl:when test=". = 'underline'">\uline{</xsl:when>
              <xsl:when test=". = 'sup'">\textsuperscript{</xsl:when>
              <xsl:when test=". = 'superscript'">\textsuperscript{</xsl:when>
              <xsl:when test=". = 'wavyunderline'">\uwave{</xsl:when>
              <xsl:when test=". = 'doubleunderline'">\uuline{</xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$cmd"/>
        <xsl:choose>
          <xsl:when test="$decls = ''">
            <xsl:apply-templates/>
          </xsl:when>
          <!-- declaration to enclose -->
          <xsl:otherwise>
            <xsl:if test="$cmd = ''">
              <xsl:text>{</xsl:text>
            </xsl:if>
            <xsl:value-of select="$decls"/>
            <!-- matches($decls, '[a-z]$') ? -->
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
            <xsl:if test="$cmd = ''">
              <xsl:text>}</xsl:text>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$cmd != ''">
          <xsl:value-of select="substring('}}}}}}}}}}}}}}}}}}}}}}}}}', 1, string-length($cmd) - string-length(translate($cmd, '{', '')))"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:lb[@type = 'line']"> \hline </xsl:template>

  <xsl:template match="tei:ident">
    <xsl:text>\textsf{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="tei:item" mode="gloss">
    <xsl:text>
\item[{</xsl:text>
    <xsl:apply-templates select="preceding-sibling::tei:label[1]" mode="gloss"/>
    <xsl:text>}]</xsl:text>
    <xsl:if test="tei:list">\hspace{1em}\hfill\linebreak&#10;</xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:list/tei:label"/>

  <xsl:template match="tei:item/tei:label">
    <xsl:text>\textbf{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="tei:label" mode="gloss">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:label">
    <xsl:variable name="inline">
      <xsl:call-template name="tei:isInline"/>
    </xsl:variable>   
    <xsl:choose>
      <xsl:when test="$inline != ''">
        <xsl:call-template name="makeInline">
          <xsl:with-param name="style" select="@type"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\begin{blabel}&#10;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&#10;\end{blabel}\par&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="lb">
    <xsl:text>{\hskip1pt}\\{}</xsl:text>
  </xsl:template>
  <xsl:template name="lineBreakAsPara">
    <xsl:text>\par&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:list">
    <xsl:if test="tei:head">
      <xsl:text>\leftline{\textbf{</xsl:text>
      <xsl:for-each select="tei:head">
        <xsl:apply-templates/>
      </xsl:for-each>
      <xsl:text>}} </xsl:text>
    </xsl:if>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:variable name="rend" select="concat(' ', normalize-space(@rend), ' ')"/>
    <xsl:choose>
      <xsl:when test="not(tei:item)"/>
      <xsl:when test="@type = 'gloss' or tei:label">
        <xsl:text>\begin{description}&#10;</xsl:text>
        <xsl:apply-templates mode="gloss" select="tei:item"/>
        <xsl:text>&#10;\end{description} </xsl:text>
      </xsl:when>
      <xsl:when test="contains($rend, ' ol ') or contains($rend, ' ordered ')">
        <xsl:text>\begin{enumerate}</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&#10;\end{enumerate}</xsl:text>
      </xsl:when>
      <xsl:when test="@type = 'runin' or contains($rend, ' runin ') or contains($rend, ' runon ')">
        <xsl:apply-templates mode="runin" select="tei:item"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\begin{itemize}</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&#10;\end{itemize}&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:listBibl">
    <xsl:if test="tei:head">
      <xsl:text>\leftline{\textbf{</xsl:text>
      <xsl:for-each select="tei:head">
        <xsl:apply-templates/>
      </xsl:for-each>
      <xsl:text>}} </xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="tei:biblStruct and not(tei:bibl)">
        <xsl:text>\begin{bibitemlist}{1}</xsl:text>
        <xsl:for-each select="tei:biblStruct">
          <!-- Do not sort here, editor should know what he is doing -->
          <xsl:text>&#10;\bibitem[</xsl:text>
          <xsl:apply-templates select="." mode="xref"/>
          <xsl:text>]{</xsl:text>
          <xsl:value-of select="@xml:id"/>
          <xsl:text>}</xsl:text>
          <xsl:call-template name="tei:makeHyperTarget"/>
          <xsl:apply-templates select="."/>
        </xsl:for-each>
        <xsl:text>&#10;\end{bibitemlist}&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="tei:msDesc">
        <xsl:apply-templates select="*[not(self::tei:head)]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\begin{bibitemlist}{1}&#10;</xsl:text>
        <xsl:apply-templates select="*[not(self::tei:head)]"/>
        <xsl:text>&#10;\end{bibitemlist}&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:listBibl/tei:bibl">
    <xsl:text> \bibitem {</xsl:text>
    <xsl:choose>
      <xsl:when test="@xml:id">
        <xsl:value-of select="@xml:id"/>
      </xsl:when>
      <xsl:otherwise>bibitem-<xsl:number level="any"/> </xsl:otherwise>
    </xsl:choose>
    <xsl:text>}</xsl:text>
    <xsl:choose>
      <xsl:when test="parent::tei:listBibl/@xml:lang = 'zh-TW' or @xml:lang = 'zh-TW'">
        <xsl:text>{\textChinese </xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="parent::tei:listBibl/@xml:lang = 'ja' or @xml:lang = 'ja'">
        <xsl:text>{\textJapanese </xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="parent::tei:listBibl/@xml:lang = 'ko' or @xml:lang = 'ko'">
        <xsl:text>{\textKorean </xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template name="marginalNote">
    <xsl:choose>
      <xsl:when test="
          @place = 'left' or
          @place = 'marginLeft' or
          @place = 'margin-left' or
          @place = 'margin_left'"> \reversemarginpar </xsl:when>
      <xsl:otherwise> \normalmarginpar </xsl:otherwise>
    </xsl:choose>
    <xsl:text>\marginnote{</xsl:text>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template name="displayNote">
    <xsl:text>&#10;\begin{</xsl:text>
    <xsl:value-of select="$quoteEnv"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{</xsl:text>
    <xsl:value-of select="$quoteEnv"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template name="endNote">
    <xsl:text>\endnote{</xsl:text>
    <xsl:call-template name="tei:makeHyperTarget"/>
    
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template name="plainNote">
    <xsl:text> {\small\itshape [</xsl:text>
    <xsl:choose>
      <xsl:when test="@n">
        <xsl:value-of select="@n"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="tei:i18n">
          <xsl:with-param name="code">note:</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
    <xsl:text>]} </xsl:text>
  </xsl:template>
  
  <xsl:template name="footNote">
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:choose>
      <xsl:when test="@target">
        <xsl:text>\footnotetext{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="count(key('APP', 1)) &gt; 0">
        <xsl:text>\footnote{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\footnote{</xsl:text>
        <xsl:call-template name="tei:makeHyperTarget"/>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:p">
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:if test="preceding-sibling::*[1][not(self::tei:p)]">\noindent </xsl:if>
    <xsl:if test="$numberParagraphs = 'true'">
      <xsl:call-template name="numberParagraph"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="count(key('APP', 1)) &gt; 0">
      <xsl:text>&#10;\pend&#10;</xsl:text>
    </xsl:if>
    <!-- Especially at the end of a footnote or a quote, this command produce a bad empty line -->
    <xsl:if test="following-sibling::*">
      <xsl:text>\par</xsl:text>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template name="numberParagraph">
    <xsl:text>\emph{\footnotesize[</xsl:text>
    <xsl:number/>
    <xsl:text>]} </xsl:text>
  </xsl:template>

  <!--
      <p>Process element pb</p>
      <p>Indication of a page break. We make it an anchor if it has an ID.</p>
    -->

  <xsl:template match="tei:pb">
    <!-- string " Page " is now managed through the i18n file -->
    <xsl:choose>
      <xsl:when test="$pagebreakStyle = 'active'">
        <xsl:text>\clearpage </xsl:text>
      </xsl:when>
      <xsl:when test="$pagebreakStyle = 'visible'">
        <xsl:text>✁[</xsl:text>
        <xsl:value-of select="@unit"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="tei:i18n">
          <xsl:with-param name="code">p.</xsl:with-param>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>]✁</xsl:text>
      </xsl:when>
      <xsl:when test="$pagebreakStyle = 'bracketsonly'">
        <!-- To avoid trouble with the scisssors character "✁" -->
        <xsl:text>[</xsl:text>
        <xsl:value-of select="@unit"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="tei:i18n">
          <xsl:with-param name="code">p.</xsl:with-param>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:when test="$pagebreakStyle = 'plain'">
        <xsl:text>\vspace{1ex}&#10;\par&#10;</xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>\vspace{1ex}&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="$pagebreakStyle = 'sidebyside'">
        <xsl:text>\cleartoleftpage&#10;\begin{figure}[ht!]\makebox[\textwidth][c]{</xsl:text>
        <xsl:text>\includegraphics[width=\textwidth]{</xsl:text>
        <xsl:value-of select="tei:resolveURI(., @facs)"/>
        <xsl:text>} }\end{figure}</xsl:text> 
        <xsl:text>\cleardoublepage&#10;</xsl:text> 
        <xsl:text>\vspace{1ex}&#10;\par&#10;</xsl:text> 
        <xsl:value-of select="@n"/> 
        <xsl:text>\vspace{1ex}&#10;</xsl:text> 
      </xsl:when>
      <xsl:when test="@facs">
        <xsl:value-of select="concat('% image:', tei:resolveURI(., @facs), '&#10;')"/>
      </xsl:when>
      <xsl:otherwise> </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="tei:makeHyperTarget"/>
  </xsl:template>

  <xsl:template match="tei:q | tei:said">
    <xsl:variable name="isInline">
      <xsl:call-template name="tei:isInline"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$isInline = ''">
        <xsl:text>&#10;\begin{</xsl:text>
        <xsl:value-of select="$quoteEnv"/>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>\end{</xsl:text>
        <xsl:value-of select="$quoteEnv"/>
        <xsl:text>}&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:quote">
    <xsl:variable name="isInline">
      <xsl:call-template name="tei:isInline"/>
    </xsl:variable>
    <xsl:choose>
      <!-- Inline, shall we tag ? -->
      <xsl:when test="isInline != ''">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="parent::tei:cit or parent::tei:note">
        <xsl:call-template name="tei:makeHyperTarget"/>
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::*">
          <xsl:text>\par&#10;</xsl:text>
        </xsl:if>
      </xsl:when>
      <!-- block -->
      <xsl:when test="$isInline = ''">
        <xsl:text>&#10;\begin{</xsl:text>
        <xsl:value-of select="$quoteEnv"/>
        <xsl:text>}&#10;</xsl:text>
        <xsl:call-template name="tei:makeHyperTarget"/>
        <xsl:apply-templates/>
        <xsl:text>&#10;\end{</xsl:text>
        <xsl:value-of select="$quoteEnv"/>
        <xsl:text>}&#10;&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:p[contains(@rend, 'display')]">
    <xsl:text>&#10;\begin{</xsl:text>
    <xsl:value-of select="$quoteEnv"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{</xsl:text>
    <xsl:value-of select="$quoteEnv"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:ref[@type = 'cite']">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:signed">
    <xsl:text>&#10;&#10;\begin{</xsl:text>
    <xsl:value-of select="$quoteEnv"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{</xsl:text>
    <xsl:value-of select="$quoteEnv"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:soCalled">
    <xsl:value-of select="$preQuote"/>
    <xsl:apply-templates/>
    <xsl:value-of select="$postQuote"/>
  </xsl:template>
  <xsl:template match="tei:space">
    <xsl:variable name="unit">
      <xsl:choose>
        <xsl:when test="@unit">
          <xsl:value-of select="@unit"/>
        </xsl:when>
        <xsl:otherwise>em</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="quantity">
      <xsl:choose>
        <xsl:when test="@quantity">
          <xsl:value-of select="@quantity"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>\hspace{</xsl:text>
    <xsl:value-of select="$quantity"/>
    <xsl:value-of select="$unit"/>
    <xsl:text>}</xsl:text>
  </xsl:template>
    <!-- If $verseNumbering, something will be done with a specific latex package, todo -->
  <xsl:template match="tei:l">
    <xsl:choose>
      <xsl:when test="parent::tei:lg">
        <xsl:choose>
          <xsl:when test="following-sibling::tei:l">
            <xsl:apply-templates/>
            <xsl:text>\\&#10;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="next" select="following-sibling::tei:l"/>
        <xsl:variable name="prev" select="preceding-sibling::tei:l"/>
        <xsl:choose>
          <xsl:when test="not($prev) and $next">
            <xsl:text>&#10;\begin{verse}&#10;</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>\\&#10;</xsl:text>
          </xsl:when>
          <xsl:when test="$prev and not($next)">
            <xsl:apply-templates/>
            <xsl:text>\\&#10;\end{verse}&#10;</xsl:text>
          </xsl:when>
          <xsl:when test="$next and $next =''">
            <xsl:apply-templates/>
            <xsl:text>\\!&#10;&#10;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
            <xsl:text>\\&#10;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:del">
    <xsl:text>\sout{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="tei:p[contains(@rend, 'center')]">
    <xsl:text>&#10;\begin{center}&#10;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>\end{center}&#10;</xsl:text>
  </xsl:template>
</xsl:transform>
