<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:depify="https://github.com/depify"
    version="2.0">
    <xsl:output method="text" indent="no" encoding="UTF-8" />
    <xsl:template match="/"><installremove>
      installed package:
      
      <xsl:text>
</xsl:text>
    <xsl:apply-templates/>
  </installremove>
    </xsl:template>
    <xsl:template match="depify:depify">
      \n\n
\033[1;34m<xsl:value-of select="@name"/>\033[0m [v<xsl:value-of select="@version"/>] - <xsl:value-of select="@repo-uri"/>\n

      <xsl:if test="depify:xproc">\n
      package contains xproc library\n  
      xproc version <xsl:value-of select="depify:xproc/@version"/>\n
      library - <xsl:value-of select="depify:xproc/@library-uri"/>\n   
      ns - <xsl:value-of select="depify:xproc/@ns"/>\n
      jar - <xsl:value-of select="depify:xproc/@jar"/>\n
      </xsl:if>

    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet> 
