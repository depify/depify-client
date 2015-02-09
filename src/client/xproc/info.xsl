<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:depify="https://github.com/depify"
    version="2.0">
    <xsl:output method="text" indent="no" encoding="UTF-8" />
    <xsl:param name="package"/>
    <xsl:template match="/"><info>
       -----------------------------\n
      depify 1.0 \n
      copyright (c)2015 Jim Fuller \n
      see https://github.com/depify \n
      -----------------------------\n
      \n      
      <xsl:text>
</xsl:text>
    <xsl:apply-templates/>
  </info>
    </xsl:template>
    <xsl:template match="*:depify[contains(@name,$package)]">

      \033[1;34m<xsl:value-of select="*:title"/>\033[0m\n
      <xsl:value-of select="*:desc"/>\n\n
      package-name: <xsl:value-of select="@name"/>\n
      latest-version: <xsl:value-of select="@version"/>\n
      repo-uri: <xsl:value-of select="@repo-uri"/>\n
      path: <xsl:value-of select="@path"/>\n
      license: <xsl:value-of select="*:license/@type"/>\n
       author: <xsl:value-of select="*:author"/>\n
       website: <xsl:value-of select="*:website"/>\n
       
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet> 
