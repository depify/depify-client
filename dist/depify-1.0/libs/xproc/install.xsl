<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:depify="https://github.com/depify"
    version="2.0">
    <xsl:output method="text" indent="no" encoding="UTF-8" />
    <xsl:template match="/"><installremove>
       -----------------------------\n
      depify 1.0 \n
      copyright (c)2015 Jim Fuller \n
      see https://github.com/depify \n
      -----------------------------\n
      \n
      installed package:
      
      <xsl:text>
</xsl:text>
    <xsl:apply-templates/>
  </installremove>
    </xsl:template>
    <xsl:template match="*:depify">
      \n\n
\033[1;34m<xsl:value-of select="@name"/>\033[0m [v<xsl:value-of select="@version"/>] - <xsl:value-of select="@repo-uri"/><xsl:text>
</xsl:text>

    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet> 
