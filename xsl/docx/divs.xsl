<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"

  >
  <xsl:template match="node() | @*" name="copy">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>


  <!--
  <xsl:template match="tei:item" name="item">
    <xsl:variable name="level" select="@level"/>
    <xsl:variable name="prev" select="preceding-sibling::*[1][self::tei:item]"/>
    <xsl:variable name="next" select="following-sibling::*[1][self::tei:item]"/>
    <xsl:choose>
      <xsl:when test="not($prev)">
        <list>
          <xsl:text>&#10;</xsl:text>
          <xsl:call-template name="copy"/>
          <xsl:text>&#10;</xsl:text>
          <xsl:for-each select="following-sibling::*[1][self::tei:item]">
            <xsl:call-template name="item"/>
          </xsl:for-each>
          <xsl:text>&#10;</xsl:text>
        </list>
      </xsl:when>
      <xsl:when test="$prev/@level &lt; $level">
        <list>
          <xsl:text>&#10;</xsl:text>
          <xsl:call-template name="copy"/>
          <xsl:text>&#10;</xsl:text>
          <xsl:if test="$next/@level &gt;= $level">
            <xsl:for-each select="following-sibling::*[1][self::tei:item]">
              <xsl:call-template name="item"/>
            </xsl:for-each>
          </xsl:if>
        </list>
        <xsl:if test="$next/@level &lt; $level">
          <xsl:for-each select="following-sibling::*[1][self::tei:item]">
            <xsl:call-template name="item"/>
          </xsl:for-each>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="copy"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:for-each select="following-sibling::*[1][self::tei:item]">
          <xsl:call-template name="item"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:item[preceding-sibling::*[1][self::tei:item]]"/>
  -->

  <xsl:template match="tei:item">
    <xsl:variable name="level" select="@level"/>
    <xsl:variable name="prev" select="preceding-sibling::*[1][self::tei:item]/@level"/>
    <xsl:choose>
      <xsl:when test="not($prev)">
        <xsl:call-template name="tagOpen">
          <xsl:with-param name="tag">list</xsl:with-param>
          <xsl:with-param name="n" select="1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$prev = $level"/>
      <xsl:when test="$level - $prev &gt; 0">
        <xsl:call-template name="tagOpen">
          <xsl:with-param name="tag">list</xsl:with-param>
          <xsl:with-param name="n" select="$level - $prev"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
    <xsl:variable name="next" select="following-sibling::*[1][self::tei:item]/@level"/>
    <xsl:choose>
      <xsl:when test="not($next)">
        <xsl:call-template name="tagClose">
          <xsl:with-param name="tag">list</xsl:with-param>
          <xsl:with-param name="n" select="$level"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$next = $level"/>
        <xsl:when test="$level - $next &gt; 0">
        <xsl:call-template name="tagClose">
          <xsl:with-param name="tag">list</xsl:with-param>
          <xsl:with-param name="n" select="$level - $next"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:item/@level"/>


  <xsl:template match="tei:head">
    <xsl:choose>
      <xsl:when test="ancestor::tei:item"/>
      <xsl:when test="ancestor::tei:note"/>
      <xsl:when test="ancestor::tei:table"/>
      <xsl:otherwise>
        <xsl:variable name="level" select="@level"/>
        <xsl:variable name="prev" select="preceding::tei:head[1]/@level"/>
        <xsl:if test="$prev">
          <xsl:call-template name="tagClose">
            <xsl:with-param name="tag">div</xsl:with-param>
            <xsl:with-param name="n" select="1+ $prev - $level"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="tagOpen">
          <xsl:with-param name="tag">div</xsl:with-param>
          <xsl:with-param name="n" select="1"/>
        </xsl:call-template>
         <xsl:variable name="open">
          <xsl:choose>
            <xsl:when test="$prev">
              <xsl:value-of select="$level - $prev - 1"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$level - 1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="tagOpen">
          <xsl:with-param name="tag">div</xsl:with-param>
          <xsl:with-param name="n" select="$open"/>
        </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:head/@level"/>

  <xsl:template name="tagClose">
    <xsl:param name="n"/>
    <xsl:param name="tag"/>
    <xsl:choose>
      <xsl:when test="$n &gt; 0">
        <xsl:text>&#10;</xsl:text>
        <xsl:processing-instruction name="{$tag}">/</xsl:processing-instruction>
        <xsl:call-template name="tagClose">
          <xsl:with-param name="tag" select="$tag"/>
          <xsl:with-param name="n" select="$n - 1"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="tagOpen">
    <xsl:param name="n"/>
    <xsl:param name="tag"/>
    <xsl:choose>
      <xsl:when test="$n &gt; 0">
        <xsl:text>&#10;</xsl:text>
        <xsl:processing-instruction name="{$tag}"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:call-template name="tagOpen">
          <xsl:with-param name="tag" select="$tag"/>
          <xsl:with-param name="n" select="$n - 1"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:body">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:variable name="last" select=".//tei:head[position() = last()]"/>
      <xsl:call-template name="tagClose">
        <xsl:with-param name="tag">div</xsl:with-param>
        <xsl:with-param name="n" select="$last/@level"/>
      </xsl:call-template>
      <xsl:text>&#10;</xsl:text>
    </xsl:copy>
  </xsl:template>

</xsl:transform>