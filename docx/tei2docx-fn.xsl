<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
  <xsl:import href="tei2docx.xsl"/>
  <xsl:template match="/">
    <w:footnotes mc:Ignorable="w14 wp14">
      <w:footnote w:id="-1" w:type="separator">
        <w:p>
          <w:pPr>
            <w:spacing w:after="0" w:before="0"/>
          </w:pPr>
          <w:r>
            <w:separator/>
          </w:r>
        </w:p>
      </w:footnote>
      <w:footnote w:id="0" w:type="continuationSeparator">
        <w:p>
          <w:pPr>
            <w:spacing w:after="0" w:before="0"/>
          </w:pPr>
          <w:r>
            <w:continuationSeparator/>
          </w:r>
        </w:p>
      </w:footnote>
      <xsl:apply-templates select="//tei:note[not(parent::tei:body | parent::tei:cell |parent::tei:div | parent::tei:div1 | parent::tei:div2 | parent::tei:div3 | parent::tei:div4 | parent::tei:div5 | parent::tei:div6 | parent::tei:div7 | parent::tei:div8 | parent::tei:div9 | ancestor::tei:note | parent::tei:sp)]"/>
    </w:footnotes>
  </xsl:template>
  <xsl:template match="tei:note[ancestor::tei:note]">
    <xsl:variable name="noteref">
      <xsl:number count="node()" level="any"/>
    </xsl:variable>
    <xsl:variable name="id">
      <xsl:call-template name="id"/>
    </xsl:variable>
    <w:hyperlink w:anchor="{$id}">
      <w:bookmarkStart w:name="{$noteref}" w:id="{$noteref}"/>
      <w:r>
        <w:rPr>
          <w:rStyle w:val="LienInternet"/>
        </w:rPr>
        <w:t>*</w:t>
      </w:r>
      <w:bookmarkEnd w:id="{$noteref}"/>
    </w:hyperlink>
  </xsl:template>
  <!-- Notes in notes -->
  <xsl:template match="tei:note[ancestor::tei:note]" mode="fn2">
    <xsl:call-template name="notein">
      <xsl:with-param name="aster" select="true()"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template name="notein">
    <xsl:param name="aster"/>
    <xsl:variable name="mixed" select="text()[normalize-space(.) != '']"/>
    <xsl:choose>
      <!-- no mixed content, multi block note -->
      <xsl:when test="(tei:p | tei:list | tei:quote | tei:l | tei:lg) and not($mixed)">
        <!-- Bricolage de l’appel sur un bloc à part (?) -->
        <xsl:for-each select="*">
          <xsl:choose>
            <xsl:when test="self::tei:quote">
              <xsl:variable name="pos" select="position()"/>
              <xsl:choose>
                <!-- contains blocks -->
                <xsl:when test="not(text()[normalize-space(.) != '']) and (tei:p|tei:l|tei:lg|tei:label|tei:quote)">
                  <xsl:for-each select="*">
                    <xsl:value-of select="$lf"/>
                    <w:p>
                      <w:pPr>
                        <w:pStyle w:val="quote"/>
                      </w:pPr>
                      <xsl:if test="$pos = 1 and position() = 1 ">
                        <xsl:call-template name="noteret">
                          <xsl:with-param name="aster" select="$aster"/>
                        </xsl:call-template>
                      </xsl:if>
                      <xsl:apply-templates/>
                    </w:p>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <w:p>
                    <w:pPr>
                      <w:pStyle w:val="quote"/>
                    </w:pPr>
                    <xsl:if test="$pos = 1">
                      <xsl:call-template name="noteret">
                        <xsl:with-param name="aster" select="$aster"/>
                      </xsl:call-template>
                    </xsl:if>
                    <xsl:apply-templates/>
                  </w:p>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="self::tei:lg | self::tei:list">
              <xsl:apply-templates select="."/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$lf"/>
              <w:p>
                <w:pPr>
                  <w:pStyle w:val="Notedebasdepage"/>
                </w:pPr>
                <xsl:if test="position() = 1 ">
                  <xsl:call-template name="noteret">
                    <xsl:with-param name="aster" select="$aster"/>
                  </xsl:call-template>
                </xsl:if>
                <xsl:apply-templates/>
              </w:p>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <w:p>
          <w:pPr>
            <w:pStyle w:val="Notedebasdepage"/>
          </w:pPr>
          <xsl:call-template name="noteret">
            <xsl:with-param name="aster" select="$aster"/>
          </xsl:call-template>
          <xsl:apply-templates/>
        </w:p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="noteret">
    <xsl:param name="aster"/>
    <xsl:choose>
      <xsl:when test="$aster">
        <xsl:variable name="id">
          <xsl:call-template name="id"/>
        </xsl:variable>
        <xsl:variable name="noteref">
          <xsl:number count="node()" level="any"/>
        </xsl:variable>
        <w:r>
          <w:t>
            <xsl:attribute name="xml:space">preserve</xsl:attribute>
            <xsl:text> </xsl:text>
          </w:t>
        </w:r>
        <w:hyperlink w:anchor="{$noteref}">
          <w:bookmarkStart w:name="{$id}" w:id="{$id}"/>
          <w:r>
            <w:rPr>
              <w:rStyle w:val="LienInternet"/>
            </w:rPr>
            <w:t>*</w:t>
          </w:r>
          <w:bookmarkEnd w:id="{$id}"/>
        </w:hyperlink>
        <w:r>
          <w:t> </w:t>
        </w:r>
      </xsl:when>
      <xsl:otherwise>
        <w:r>
          <w:rPr>
            <w:rStyle w:val="Appelnotedebasdep"/>
          </w:rPr>
          <w:footnoteRef/>
          <w:t>
            <xsl:attribute name="xml:space">preserve</xsl:attribute>
            <xsl:text> </xsl:text>
          </w:t>
        </w:r>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:note">
    <w:footnote>
      <xsl:attribute name="w:id">
        <xsl:call-template name="id"/>
      </xsl:attribute>
      <xsl:call-template name="notein"/>
      <xsl:apply-templates select=".//tei:note" mode="fn2"/>
    </w:footnote>
  </xsl:template>
</xsl:transform>
