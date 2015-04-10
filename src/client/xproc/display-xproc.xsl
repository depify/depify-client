<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:depify="https://github.com/depify"
    version="2.0">
    <xsl:output method="text" indent="no" encoding="UTF-8" />
    <xsl:param name="package"/>
    <xsl:template match="/"><xproc>
      generated catalog.xml, library.xpl and xproc.sh:\n\n
  </xproc>
    </xsl:template>
    <xsl:template match="*:depify">
      \033[1;34m<xsl:value-of select="@name"/>\033[0m [<xsl:value-of select="@version"/>] - <xsl:value-of select="*/*:catalog/@name"/>=<xsl:value-of select="*/*:catalog/@uri"/>\n
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet> 
