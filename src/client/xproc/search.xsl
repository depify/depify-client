<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:depify="https://github.com/depify"
    version="2.0">
    <xsl:output method="text" indent="no" encoding="UTF-8" />
    <xsl:param name="package" select="''"/>
    <xsl:template match="/"><search>
      search results on '<xsl:value-of select="$package"/>':\n\n      
      <xsl:apply-templates select="/depify:packages/depify:depify">
        <xsl:sort select="@name"/>
      </xsl:apply-templates>
  </search>
    </xsl:template>
    <xsl:template match="*:depify[contains(.,$package)]">
      \033[1;34m<xsl:value-of select="@name"/>\033[0m <xsl:value-of select="@version"/> - <xsl:value-of select="@repo-uri"/>\n
      <xsl:value-of select="depify:desc"/>\n
      <xsl:if test="depify:depify"> - deps: [<xsl:value-of select="string-join(depify:depify/@name,',')"/>]</xsl:if>\n\n
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet> 
