<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" xmlns:str="http://exslt.org/strings" xmlns:exslt="http://exslt.org/common" extension-element-prefixes="str exslt">
  <!-- 
TEI Styleshest for LaTeX, forked from Sebastian Rahtz
https://github.com/TEIC/Stylesheets/tree/dev/latex
  
1. Distributed under a Creative Commons Attribution-ShareAlike 3.0
   License http://creativecommons.org/licenses/by-sa/3.0/ 
2. http://www.opensource.org/licenses/BSD-2-Clause

A light version for XSLT1, with local improvements.
Should work as an import (or include) to generate flow latex,
for example: abstract.
2021, frederic.glorieux@fictif.org
  -->
  <xsl:import href="tei_common.xsl"/>
  <xsl:import href="latex_common.xsl"/>
  <xsl:param name="quoteEnv">quoteblock</xsl:param>
  <!-- TODO hadle LaTeX side -->
  <xsl:param name="pbStyle"/>
  <!-- TODO, move params -->
  <xsl:variable name="preQuote">« </xsl:variable>
  <xsl:variable name="postQuote"> »</xsl:variable>
  <!-- TODO, handle dinkus etc… -->
  
  <xsl:template match="tei:ab">
    <xsl:param name="message"/>
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
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>\end{center}&#10;&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>\par&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:anchor">
    <xsl:param name="message"/>
    <xsl:call-template name="tei:makeHyperTarget"/>
  </xsl:template>
  
  <xsl:template match="tei:bibl">
    <xsl:param name="message"/>
    <xsl:variable name="inline">
      <xsl:call-template name="tei:isInline"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="parent::tei:cit[contains(@rend,'display')] or
        (parent::tei:cit and tei:p) or $inline != ''">
        <xsl:call-template name="makeInline">
          <xsl:with-param name="style">citbibl</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="parent::tei:q/parent::tei:head or parent::tei:q[contains(@rend,'inline')]">
        <xsl:call-template name="makeBlock">
          <xsl:with-param name="style">citbibl</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$inline = ''">
        <xsl:call-template name="makeBlock">
          <xsl:with-param name="style">biblfree</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="makeInline">
          <xsl:with-param name="style">
            <xsl:text>bibl</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="before">
            <xsl:if test="parent::tei:cit">
              <xsl:text> (</xsl:text>
            </xsl:if>
          </xsl:with-param>
          <xsl:with-param name="after">
            <xsl:if test="parent::tei:cit">
              <xsl:text>)</xsl:text>
            </xsl:if>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Who call that mode cite ? -->
  
  <xsl:template match="tei:bibl" mode="cite">
    <xsl:apply-templates select="text()[1]"/>
  </xsl:template>
  <!-- Semantic blocks  -->
  
  <xsl:template match="tei:byline | tei:dateline | tei:salute | tei:signed">
    <xsl:param name="message"/>
    <xsl:call-template name="makeBlock"/>
  </xsl:template>
  
  <xsl:template match="tei:argument | tei:epigraph">
    <xsl:param name="message"/>
    <!-- An environment to group blocks -->
    <xsl:param name="env" select="local-name()"/>
    <xsl:text>&#10;\begin{</xsl:text>
    <xsl:value-of select="$env"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>&#10;\end{</xsl:text>
    <xsl:value-of select="$env"/>
    <xsl:text>}&#10;&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:cit">
    <xsl:param name="message"/>
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
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:value-of select="$postQuote"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:code">
    <xsl:param name="message"/>
    <xsl:text>\texttt{</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
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
    
    
  <xsl:template match="tei:del">
    <xsl:param name="message"/>
    <xsl:text>\sout{</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>}</xsl:text>
  </xsl:template>
    
  <xsl:template match="tei:emph | tei:foreign | tei:gloss | tei:surname | tei:term">
    <xsl:param name="message"/>
    <xsl:text>\</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>{</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  
  <xsl:template match="tei:hi">
    <xsl:param name="message"/>
    <xsl:call-template name="rendering">
      <xsl:with-param name="message" select="$message"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="rendering">
    <xsl:param name="message"/>
    <xsl:param name="rend">
      <xsl:value-of select="@rend"/>
    </xsl:param>
    <xsl:param name="cont">
      <xsl:apply-templates>
        <xsl:with-param name="message" select="$message"/>
      </xsl:apply-templates>
    </xsl:param>
    <xsl:variable name="zerend" select="concat(' ', normalize-space($rend), ' ')"/>
    <xsl:choose>
      <xsl:when test="normalize-space($zerend) = ''">
        <xsl:copy-of select="$cont"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="decls">
            <xsl:choose>
              <xsl:when test="contains($zerend, ' i ')">\itshape</xsl:when>
              <xsl:when test="contains($zerend, ' it ')">\itshape</xsl:when>
              <xsl:when test="contains($zerend, ' ital ')">\itshape</xsl:when>
              <xsl:when test="contains($zerend, ' italics ')">\itshape</xsl:when>
              <xsl:when test="contains($zerend, ' italique ')">\itshape</xsl:when>
              <xsl:when test="contains($zerend, ' tt ')">\ttfamily</xsl:when>
              <xsl:when test="contains($zerend, ' sc ')">\scshape</xsl:when>
              <xsl:when test="contains($zerend, ' large ')">\large</xsl:when>
              <xsl:when test="contains($zerend, ' larger ')">\larger</xsl:when>
              <xsl:when test="contains($zerend, ' small ')">\small</xsl:when>
              <xsl:when test="contains($zerend, ' smaller ')">\smaller</xsl:when>
              <xsl:when test="contains($zerend, ' color')">
                <xsl:variable name="color" select="substring-before(substring-after($zerend, ' color'), ' ')"/>
                <xsl:text>\color{</xsl:text>
                <xsl:value-of select="translate($color, '(}', '')"/>
                <xsl:text>}</xsl:text>
              </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="cmd">
          <xsl:choose>
            <xsl:when test="contains($zerend, ' allcaps ')">\uppercase{</xsl:when>
            <xsl:when test="contains($zerend, ' b ')">\textbf{</xsl:when>
            <xsl:when test="contains($zerend, ' bold ')">\textbf{</xsl:when>
            <xsl:when test="contains($zerend, ' gothic ')">\textgothic{</xsl:when>
            <xsl:when test="contains($zerend, ' noindex ')">\textrm{</xsl:when>
            <xsl:when test="contains($zerend, ' plain ')">\textrm{</xsl:when>
            <xsl:when test="contains($zerend, ' strong ')">\textbf{</xsl:when>
            <xsl:when test="contains($zerend, ' sub ')">\textsubscript{</xsl:when>
            <xsl:when test="contains($zerend, ' subscript ')">\textsubscript{</xsl:when>
            <xsl:when test="contains($zerend, ' sup ')">\textsuperscript{</xsl:when>
            <xsl:when test="contains($zerend, ' superscript ')">\textsuperscript{</xsl:when>
            <xsl:when test="contains($zerend, ' uc ')">\uppercase{</xsl:when>
            <xsl:when test="contains($zerend, ' underline ')">\uline{</xsl:when>
            <xsl:when test="contains($zerend, ' uppercase ')">\uppercase{</xsl:when>
            <!-- 
            <xsl:when test=". = 'strike'">\sout{</xsl:when>
            <xsl:when test=". = 'overbar'">\textoverbar{</xsl:when>
            <xsl:when test=". = 'doubleunderline'">\uuline{</xsl:when>
            <xsl:when test=". = 'wavyunderline'">\uwave{</xsl:when>
            <xsl:when test=". = 'quoted'">\textquoted{</xsl:when>
            <xsl:when test=". = 'center'">\centerline{</xsl:when>
            <xsl:when test=". = 'calligraphic'">\textcal{</xsl:when>

            -->
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$cmd"/>
        <xsl:choose>
          <xsl:when test="$decls = ''">
            <xsl:copy-of select="$cont"/>
          </xsl:when>
          <!-- declaration to enclose -->
          <xsl:otherwise>
            <xsl:if test="$cmd = ''">
              <xsl:text>{</xsl:text>
            </xsl:if>
            <xsl:value-of select="$decls"/>
            <!-- matches($decls, '[a-z]$') ? -->
            <xsl:text> </xsl:text>
            <xsl:copy-of select="$cont"/>
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
  
  <xsl:template match="tei:hi[starts-with(@rend, 'initial')]">
    <xsl:param name="message"/>
    <xsl:param name="text" select="normalize-space(.)"/>
    <xsl:variable name="cmd">
      <xsl:choose>
        <xsl:when test="@rend = 'initial2'">\initial</xsl:when>
        <xsl:when test="@rend = 'initial4'">\initialiv</xsl:when>
        <xsl:otherwise>\initialiv</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$cmd"/>
    <xsl:variable name="c" select="substring($text, 2, 1)"/>
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:choose>
      <!-- L’, D’ \kern-0.08em{’} -->
      <xsl:when test="$c = '’' or $c = $apos">{<xsl:value-of select="substring($text, 1, 1)"/>\kern-0.08em{’}}{<xsl:value-of select="substring($text, 3)"/>}</xsl:when>
      <xsl:otherwise>{<xsl:value-of select="substring($text, 1, 1)"/>}{<xsl:value-of select="substring($text, 2)"/>}</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:ident">
    <xsl:param name="message"/>
    <xsl:text>\textsf{</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:item">
    <xsl:param name="message"/>
    <xsl:choose>
      <xsl:when test="parent::tei:list[@type='gloss'] or preceding-sibling::tei:label">
        <xsl:text>\item</xsl:text>
        <xsl:if test="@n">[<xsl:value-of select="@n"/>]</xsl:if>
        <xsl:text> </xsl:text>
        <xsl:call-template name="rendering"/>
        <xsl:text>&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="parent::tei:list[@type='elementlist']">
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\item</xsl:text>
        <xsl:if test="@n">[<xsl:value-of select="@n"/>]</xsl:if>
        <xsl:text> </xsl:text>
        <xsl:call-template name="tei:makeHyperTarget"/>
        <xsl:call-template name="rendering"/>
        <xsl:text>&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:item" mode="gloss">
    <xsl:param name="message"/>
    <xsl:text>\item[{</xsl:text>
    <xsl:apply-templates select="preceding-sibling::tei:label[1]" mode="gloss"/>
    <xsl:text>}]</xsl:text>
    <xsl:if test="tei:list">\hspace{1em}\hfill\linebreak&#10;</xsl:if>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:item" mode="inline">
    <xsl:param name="message"/>
    <xsl:if test="preceding-sibling::tei:item">, </xsl:if>
    <xsl:if test="not(following-sibling::tei:item) and preceding-sibling::tei:item"> and </xsl:if>
    <xsl:text>• </xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>&#160;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:l">
    <xsl:param name="message"/>
    <xsl:variable name="next" select="following-sibling::*[1][self::tei:l]"/>
    <xsl:variable name="prev" select="preceding-sibling::*[1][self::tei:l]"/>
    <xsl:choose>
      <!-- empty verse as stanza separator, do notinh -->
      <xsl:when test="normalize-space(.) = ''"/>
      <!-- Start of poem (if not <lg>) -->
      <xsl:when test="not($prev) and $next and not(parent::tei:lg)">
        <xsl:text>&#10;\begin{verse}&#10;</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>\\&#10;</xsl:text>
      </xsl:when>
      <!-- End of poem (if not <lg>) -->
      <xsl:when test="$prev and not($next) and not(parent::tei:lg)">
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>\\&#10;\end{verse}&#10;</xsl:text>
      </xsl:when>
      <!-- End of stanza (with <lg>) -->
      <xsl:when test="$prev and not($next)">
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>\\!</xsl:text>
      </xsl:when>
      <!-- End of stanza given by empty verse -->
      <xsl:when test="$next and $next =''">
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>\\!&#10;&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>\\&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="tei:list/tei:label"/>
  
  <xsl:template match="tei:item/tei:label">
    <xsl:param name="message"/>
    <xsl:text>\textbf{</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:label" mode="gloss">
    <xsl:param name="message"/>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="tei:label">
    <xsl:param name="message"/>
    <xsl:variable name="inline">
      <xsl:call-template name="tei:isInline"/>
    </xsl:variable>
    <xsl:variable name="rend" select="concat(' ', normalize-space(@rend), ' ')"/>
    <xsl:choose>
      <xsl:when test="$inline != ''">
        <xsl:call-template name="makeInline">
          <xsl:with-param name="style" select="@type"/>
        </xsl:call-template>
        <!-- bug when next node is an element, space are strip  -->
        <xsl:if test="name(following-sibling::node()[1])">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#10;\labelblock{</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>}&#10;&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:lb">
    <xsl:param name="message"/>
    <xsl:choose>
      <xsl:when test="@type='hyphenInWord' and contains(@rend,'hidden')"/>
      <xsl:when test="contains(@rend,'hidden')">
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="contains(@rend,'-') or @type='hyphenInWord'">
        <xsl:text>-</xsl:text>
        <xsl:call-template name="lb"/>
      </xsl:when>
      <xsl:when test="contains(@rend,'above')">
        <xsl:text>⌜</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@rend,'below')">
        <xsl:text>⌞</xsl:text>
      </xsl:when>
      <!-- last linebreak of series ? do something ?
      <xsl:when test="normalize-space(following-sibling::node()) = '' or normalize-space(preceding-sibling::node())"/>
      -->
      <xsl:when test="contains(@rend,'show')">
        <xsl:call-template name="lb"/>
      </xsl:when>
      <xsl:when test="contains(@rend,'paragraph')">
        <xsl:call-template name="lineBreakAsPara"/>
      </xsl:when>
      <!-- \\* should be nicer on break page -->
      <xsl:when test="parent::tei:signed | parent::tei:salute">\\&#10;</xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="lb"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:lb[@type = 'line']">&#10;\hline&#10;</xsl:template>
  
  <xsl:template name="lb">
    <xsl:text>\\&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template name="lineBreakAsPara">
    <xsl:text>\par&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:list/tei:head">
    <xsl:param name="message"/>
    <xsl:text>\item[]\listhead{</xsl:text>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:list">
    <xsl:param name="message"/>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:variable name="rend" select="concat(' ', normalize-space(@rend), ' ')"/>
    <xsl:variable name="options">
      <xsl:text>[</xsl:text>
      <xsl:choose>
        <xsl:when test="tei:item/tei:p | tei:item/tei:list">itemsep=\baselineskip,</xsl:when>
        <xsl:otherwise>itemsep=0pt,</xsl:otherwise>
      </xsl:choose>
      <xsl:text>]</xsl:text>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="not(tei:item)"/>
      <xsl:when test="@type = 'gloss' or tei:label">
        <xsl:text>&#10;\begin{description}&#10;</xsl:text>
        <xsl:apply-templates mode="gloss" select="tei:item"/>
        <xsl:text>&#10;\end{description} </xsl:text>
      </xsl:when>
      <xsl:when test="contains($rend, ' ol ') or contains($rend, ' ordered ') or contains($rend, '1')">
        <xsl:text>&#10;\begin{enumerate}</xsl:text>
        <xsl:value-of select="$options"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>\end{enumerate}&#10;&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="contains($rend, 'alpha') or contains($rend, ' lower-latin ') or contains($rend, ' a ') or contains($rend, ' a. ') or contains($rend, ' a) ')">
        <xsl:text>&#10;\begin{listalpha}</xsl:text>
        <xsl:value-of select="$options"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>\end{listalpha}&#10;&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="@type = 'runin' or contains($rend, ' runin ') or contains($rend, ' runon ')">
        <xsl:apply-templates mode="runin" select="tei:item"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#10;\begin{itemize}</xsl:text>
        <xsl:value-of select="$options"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>\end{itemize}&#10;&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:listBibl">
    <xsl:param name="message"/>
    <xsl:apply-templates select="tei:head"/>
    <xsl:apply-templates select="*[not(self::tei:head)]"/>
    <!--
    <xsl:choose>
      <xsl:when test="tei:biblStruct and not(tei:bibl)">
        <xsl:text>\begin{bibitemlist}{1}</xsl:text>
        <xsl:for-each select="tei:biblStruct">
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
    -->
  </xsl:template>
  
  <xsl:template match="tei:listBibl/tei:head">
    <xsl:param name="message"/>
    <xsl:text>\noindent\textbf{</xsl:text>
    <xsl:for-each select="tei:head">
      <xsl:apply-templates>
        <xsl:with-param name="message" select="$message"/>
      </xsl:apply-templates>
    </xsl:for-each>
    <xsl:text>}\par&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:listBibl/tei:bibl">
    <xsl:param name="message"/>
    <xsl:text>\biblitem{</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:lg">
    <xsl:param name="message"/>
    <xsl:choose>
      <xsl:when test="count(key('APP',1))&gt;0">
        <xsl:variable name="c" select="(count(tei:l)+1) div 2"/>
        <xsl:text>\setstanzaindents{1,1,0}</xsl:text>
        <xsl:text>\setcounter{stanzaindentsrepetition}{</xsl:text>
        <xsl:value-of select="$c"/>
        <xsl:text>}</xsl:text>
        <xsl:text>\stanza&#10;</xsl:text>
        <xsl:for-each select="tei:l">
          <xsl:if test="parent::tei:lg/@xml:lang='Av'">{\itshape </xsl:if>
          <xsl:apply-templates>
            <xsl:with-param name="message" select="$message"/>
          </xsl:apply-templates>
          <xsl:if test="parent::tei:lg/@xml:lang='Av'">}</xsl:if>
          <xsl:if test="following-sibling::tei:l">
            <xsl:text>&amp;</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>\&amp;&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- TODO if label inside between verses -->
        <xsl:variable name="next" select="following-sibling::*[1][self::tei:lg]"/>
        <xsl:variable name="prev" select="preceding-sibling::*[1][self::tei:lg]"/>
        <xsl:if test="not($prev)">
          <xsl:text>&#10;\begin{verse}&#10;</xsl:text>
        </xsl:if>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:if test="not($next)">
          <xsl:text>&#10;\end{verse}&#10;</xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="tei:milestone">
    <xsl:param name="message"/>
    <xsl:choose>
      <!-- <hr/> as a milestone ? To think
      <xsl:when test="contains(@rend,'hr')">
        <xsl:call-template name="horizontalRule"/>
      </xsl:when>
      -->
      <xsl:when test="@unit='line'">
        <xsl:text> </xsl:text>
      </xsl:when>
      <!-- Display an edition marker for the span. -->
      <xsl:when test="@ed">
        <xsl:text>\ed{</xsl:text>
        <xsl:value-of select="@ed"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="@n">
        <xsl:if test="preceding-sibling::node()">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:text>\milestone{</xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>}</xsl:text>
        <xsl:text> </xsl:text>
      </xsl:when>
      <!-- Unpredictable, do nothing -->
      <xsl:when test="@unit='unnumbered'"/>
      <xsl:otherwise>
        <xsl:call-template name="makeInline">
          <xsl:with-param name="style" select="@type"/>
          <xsl:with-param name="before">
            <xsl:if test="not(@unit='unspecified')">
              <xsl:value-of select="@unit"/>
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:with-param>
          <xsl:with-param name="after" select="@n"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <xsl:template match="tei:note">
    <xsl:variable name="inline">
      <xsl:call-template name="tei:isInline"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@place='none'"/>
      <xsl:when test="not(@place) and (ancestor::tei:bibl or ancestor::tei:biblFull or ancestor::tei:biblStruct)">
        <xsl:text> (</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>)</xsl:text>
      </xsl:when>
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
      <!-- ?
      <xsl:when test="@place='comment'">
        <xsl:call-template name="commentNote"/>
      </xsl:when>
      -->
      <xsl:when test="@place='inline' and $inline = ''">
        <xsl:call-template name="displayNote"/>
      </xsl:when>
      <xsl:when test="@place='inline'">
        <xsl:call-template name="plainNote"/>
      </xsl:when>
      <!-- $autoEndNotes='true', epub -->
      <xsl:when test="@place='end'">
        <xsl:call-template name="endNote"/>
      </xsl:when>
      <xsl:when test="@place='margin' or @place='marginal'">
        <xsl:call-template name="marginalNote"/>
      </xsl:when>
      <xsl:when test="$inline = '' or tei:q">
        <xsl:call-template name="displayNote"/>
      </xsl:when>
      <xsl:when test="@place = 'foot' or @place = 'bottom' or (not(@place) and $inline != '')">
        <xsl:call-template name="footNote"/>
      </xsl:when>
      <xsl:when test="@place">
        <xsl:message>WARNING: unknown @place for note, <xsl:value-of select="@place"/></xsl:message>
        <xsl:call-template name="displayNote"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="plainNote"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template name="marginalNote">
    <xsl:param name="message"/>
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
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template name="displayNote">
    <xsl:param name="message"/>
    <xsl:text>&#10;\begin{</xsl:text>
    <xsl:value-of select="$quoteEnv"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>\end{</xsl:text>
    <xsl:value-of select="$quoteEnv"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template name="endNote">
    <xsl:param name="message"/>
    <xsl:text>\endnote{</xsl:text>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template name="plainNote">
    <xsl:param name="message"/>
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
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>]} </xsl:text>
  </xsl:template>
  
  <xsl:template name="footNote">
    <xsl:param name="message"/>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:choose>
      <xsl:when test="@target">
        <xsl:text>\footnotetext{</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="count(key('APP', 1)) &gt; 0">
        <xsl:text>\footnote{</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\footnote{</xsl:text>
        <xsl:call-template name="tei:makeHyperTarget"/>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:num/text()">
    <xsl:param name="message"/>
    <xsl:text>\textsc{</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  
  <xsl:template match="tei:p">
    <xsl:param name="message"/>
    <xsl:variable name="first" select="substring(translate(normalize-space(.), ' ', ''), 1, 1)"/>
    <xsl:call-template name="tei:makeHyperTarget"/>
    <xsl:variable name="prev" select="preceding-sibling::*[not(self::tei:pb)][not(self::tei:cb)][1]"/>
    <xsl:variable name="rend" select="concat(' ', normalize-space(@rend), ' ')"/>
    <xsl:variable name="txt">
      <xsl:apply-templates select="." mode="title"/>
    </xsl:variable>   
    <xsl:variable name="cont">
      <xsl:choose>
        <!-- force noindent -->
        <xsl:when test="contains($rend, ' noindent ')">\noindent </xsl:when>
        <!-- force indent -->
        <xsl:when test="contains($rend, ' indent ')"/>
        <!-- if first para is less than 2 “line”, let indent -->
        <xsl:when test="string-length(normalize-space($txt)) &lt; 80"/>
        <xsl:when test="contains($prev/@rend, 'right')  or contains($prev/@rend, 'center')">\noindent </xsl:when>
        <xsl:when test="not(preceding-sibling::*) and not(parent::tei:item)">\noindent </xsl:when>
        <xsl:when test="contains($rend, ' center ') or contains($rend, ' right ')">\noindent </xsl:when>
        <xsl:when test="name($prev) != 'p' and not(parent::tei:item)">\noindent </xsl:when>
        <!-- Moche
      <xsl:when test="contains('-–—', $first)">\noindent </xsl:when>
      -->
      </xsl:choose>
      <xsl:if test="@n != ''">
        <!-- No, number maybe not unique
      <xsl:call-template name="tei:makeHyperTarget">
        <xsl:with-param name="id" select="concat('par', @n)"/>
      </xsl:call-template>
      -->
        <xsl:text>\pn{</xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>}</xsl:text>
      </xsl:if>
      <!-- Ideas of Sebastian , pending
      <xsl:if test="$numberParagraphs = 'true'">
        <xsl:call-template name="numberParagraph"/>
      </xsl:if>
      <xsl:if test="count(key('APP', 1)) &gt; 0">
        <xsl:text>&#10;\pend&#10;</xsl:text>
      </xsl:if>
      -->
      <!-- Rendering char styles -->
      <xsl:call-template name="rendering"/>
      <!-- Especially at the end of a footnote or a quote, \par produce a bad empty line -->
      <xsl:if test="following-sibling::*">
        <xsl:text>\par</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($rend, ' right ')">
        <xsl:text>{\raggedleft </xsl:text>
        <xsl:copy-of select="$cont"/>
        <xsl:text>}&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="contains($rend, 'center')">
         <xsl:text>&#10;\begin{center}&#10;</xsl:text>
          <xsl:copy-of select="$cont"/>
        <xsl:text>&#10;\end{center}&#10;&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$cont"/>
        <xsl:text>&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
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
    <xsl:param name="message"/>
    <!-- string " Page " is now managed through the i18n file -->
    <xsl:choose>
      <xsl:when test="$pbStyle = 'active'">
        <xsl:text>\clearpage </xsl:text>
      </xsl:when>
      <xsl:when test="$pbStyle = 'visible'">
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
      <xsl:when test="$pbStyle = 'bracketsonly'">
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
      <xsl:when test="$pbStyle = 'plain'">
        <xsl:text>\vspace{1ex}&#10;\par&#10;</xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>\vspace{1ex}&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="$pbStyle = 'sidebyside'">
        <xsl:text>\cleartoleftpage&#10;\begin{figure}[ht!]\makebox[\textwidth][c]{</xsl:text>
        <xsl:text>\includegraphics[width=\textwidth]{</xsl:text>
        <xsl:value-of select="tei:resolveURI(., @facs)"/>
        <xsl:text>} }\end{figure}</xsl:text>
        <xsl:text>\cleardoublepage&#10;</xsl:text>
        <xsl:text>\vspace{1ex}&#10;\par&#10;</xsl:text>
        <xsl:value-of select="@n"/>
        <xsl:text>\vspace{1ex}&#10;</xsl:text>
      </xsl:when>
      <!-- Image with facs, do something ? -->
      <xsl:when test="@facs">
        <!--
        <xsl:value-of select="concat('% image:', tei:resolveURI(., @facs), '&#10;')"/>
        -->
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="tei:makeHyperTarget"/>
  </xsl:template>
  
  <xsl:template match="tei:q | tei:said">
    <xsl:param name="message"/>
    <xsl:variable name="inline">
      <xsl:call-template name="tei:isInline"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$inline = ''">
        <xsl:text>&#10;\begin{</xsl:text>
        <xsl:value-of select="$quoteEnv"/>
        <xsl:text>}</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>\end{</xsl:text>
        <xsl:value-of select="$quoteEnv"/>
        <xsl:text>}&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:quote">
    <xsl:param name="message"/>
    <xsl:variable name="inline">
      <xsl:call-template name="tei:isInline"/>
    </xsl:variable>
    <xsl:variable name="rend" select="concat(' ', @rend, ' ')"/>
    <xsl:variable name="begin">
      <xsl:text>\begin{</xsl:text>
      <xsl:value-of select="$quoteEnv"/>
      <xsl:text>}&#10;</xsl:text>
    </xsl:variable>
    <xsl:variable name="end">
      <xsl:text>\end{</xsl:text>
      <xsl:value-of select="$quoteEnv"/>
      <xsl:text>}&#10;</xsl:text>
    </xsl:variable>
    <xsl:choose>
      <!-- Inline, shall we tag ? -->
      <xsl:when test="$inline != ''">
        <xsl:text>\emph{</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="parent::tei:cit or parent::tei:note">
        <xsl:call-template name="tei:makeHyperTarget"/>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:if test="following-sibling::*">
          <xsl:text>\par&#10;</xsl:text>
        </xsl:if>
      </xsl:when>
      <!-- Contains verses, all elements should be blocks. Verse environment doesn’t like to be inside quoting -->
      <xsl:when test="tei:l | tei:lg">
        <xsl:text>&#10;</xsl:text>
        <xsl:call-template name="tei:makeHyperTarget"/>
        <xsl:for-each select="*">
          <!-- Before block -->
          <xsl:choose>
            <!-- quote starting by verse do nothing -->
            <xsl:when test="(self::tei:l or self::tei:lg) and position() = 1"/>
            <!-- non verse opening, begin quote -->
            <xsl:when test="position() = 1">
              <xsl:value-of select="$begin"/>
            </xsl:when>
            <!-- Non verse inside quote, do nothing, let verse know -->
            <xsl:when test="not(self::tei:l) and not(self::tei:lg)"/>
            <!-- Not first verse of a series, do nothing -->
            <xsl:when test="preceding-sibling::*[1][self::tei:l or self::tei:lg]"/>
            <!-- First verse of a series, preceded by a non verse block, end quote environment  -->
            <xsl:otherwise>
              <xsl:value-of select="$end"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="."/>
          <!-- After block -->
          <xsl:choose>
            <!-- quote closing by verse, do nothing -->
            <xsl:when test="position() = last() and (self::tei:l or self::tei:lg)"/>
            <!-- quote closing with a non verse block, end -->
            <xsl:when test="position() = last()">
              <xsl:value-of select="$end"/>
            </xsl:when>
            <!-- Not end, not verse, do nothing -->
            <xsl:when test="not(self::tei:l) and not(self::tei:lg)"/>
            <!-- verse followed by verse, do nothing -->
            <xsl:when test="following-sibling::*[1][self::tei:l or self::tei:lg]"/>
            <!-- Should be last verse a series, followed by something else to enclose in quote -->
            <xsl:otherwise>
              <xsl:value-of select="$begin"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>
      </xsl:when>
      <!-- framed border -->
      <xsl:when test="contains($rend, ' border ')">
        <xsl:text>&#10;</xsl:text>
        <xsl:call-template name="tei:makeHyperTarget"/>
        <xsl:text>\begin{borderbox}&#10;</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>\end{borderbox}&#10;&#10;</xsl:text>
      </xsl:when>
      <!-- Block or multi block -->
      <xsl:otherwise>
        <xsl:text>&#10;</xsl:text>
        <xsl:call-template name="tei:makeHyperTarget"/>
        <xsl:value-of select="$begin"/>
        <xsl:if test="not(tei:p|tei:list)">\noindent </xsl:if>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:if test="not(tei:p|tei:list)">&#10;</xsl:if>
        <xsl:value-of select="$end"/>
        <xsl:text>&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:p[contains(@rend, 'display')]">
    <xsl:param name="message"/>
    <xsl:text>&#10;\begin{</xsl:text>
    <xsl:value-of select="$quoteEnv"/>
    <xsl:text>}&#10;</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>\end{</xsl:text>
    <xsl:value-of select="$quoteEnv"/>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:ref[@type = 'cite']">
    <xsl:param name="message"/>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="tei:ref | tei:ptr">
    <xsl:param name="message"/>
    <!-- Special chars like % _ should have been latex escaped previously -->
    <xsl:variable name="target" select="normalize-space(@target)"/>
    <xsl:choose>
      <xsl:when test="not(@target)">
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="starts-with($target, '#')">
        <xsl:text>\hyperref[</xsl:text>
        <xsl:value-of select="substring-after($target, '#')"/>
        <xsl:text>]</xsl:text>
        <xsl:text>{\dotuline{</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:when test="ancestor::tei:note">
        <xsl:text>\href{</xsl:text>
        <xsl:value-of select="$target"/>
        <xsl:text>}{\dotuline{</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:if test="normalize-space(.) != @target">
          <xsl:text> [</xsl:text>
          <xsl:value-of select="@target"/>
          <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:text>}}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\href{</xsl:text>
        <xsl:value-of select="$target"/>
        <xsl:text>}{\dotuline{</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>}}</xsl:text>
        <xsl:text>\footnote{</xsl:text>
        <xsl:text>\href{</xsl:text>
        <xsl:value-of select="$target"/>
        <xsl:text>}{\url{</xsl:text>
        <xsl:value-of select="$target"/>
        <xsl:text>}}}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:signed">
    <xsl:param name="message"/>
    <xsl:text>&#10;&#10;\signed{</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:soCalled">
    <xsl:param name="message"/>
    <xsl:value-of select="$preQuote"/>
    <xsl:apply-templates>
      <xsl:with-param name="message" select="$message"/>
    </xsl:apply-templates>
    <xsl:value-of select="$postQuote"/>
  </xsl:template>
  <!-- If $verseNumbering, something will be done with a specific latex package, todo -->

    
  
  
  <xsl:template match="tei:space">
    <xsl:param name="message"/>
    <xsl:variable name="inline">
      <xsl:call-template name="tei:isInline"/>
    </xsl:variable>
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
    <xsl:choose>
      <xsl:when test="@quantity = 'vfill' or @extent = 'vfill'">
        <xsl:text>\vfill\null&#10;</xsl:text>
      </xsl:when>
      <!-- vertical spacing -->
      <xsl:when test="$inline = ''">
        <xsl:text>\bigbreak&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\hspace{</xsl:text>
        <xsl:value-of select="$quantity"/>
        <xsl:value-of select="$unit"/>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:title">
    <xsl:param name="message"/>
    <xsl:choose>
      <xsl:when test="parent::tei:titleStmt/parent::tei:fileDesc">
        <xsl:if test="preceding-sibling::tei:title">
          <xsl:text> — </xsl:text>
        </xsl:if>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\emph{</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="message" select="$message"/>
        </xsl:apply-templates>
        <xsl:text>}</xsl:text>
        <xsl:if test="ancestor::tei:biblStruct  or ancestor::tei:biblFull">
          <xsl:text>. </xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

</xsl:transform>
