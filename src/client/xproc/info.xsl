<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:depify="https://github.com/depify"
    version="2.0">
    <xsl:output method="text" indent="no" encoding="UTF-8" />
    <xsl:param name="package"/>
    <xsl:template match="/"><info>
      get info on package.\n\n
    <xsl:apply-templates/>
  </info>
    </xsl:template>
    <xsl:template match="depify:depify[contains(@name,$package)]">

      \033[1;34m<xsl:value-of select="*:title"/>\033[0m\n
      <xsl:value-of select="*:desc"/>\n
      <xsl:if test="depify:depify"> - deps: [<xsl:value-of select="string-join(depify:depify/@name,',')"/>]</xsl:if>\n
      package-name: <xsl:value-of select="@name"/>\n
      latest-version: <xsl:value-of select="@version"/>\n
      repo-uri: <xsl:value-of select="@repo-uri"/>\n
      depify path: <xsl:value-of select="@path"/>\n
      license: <xsl:value-of select="*:license/@type"/>\n
      author: <xsl:value-of select="*:author"/>\n
      website: <xsl:value-of select="*:website"/>\n

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
