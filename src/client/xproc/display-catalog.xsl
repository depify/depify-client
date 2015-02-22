<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:depify="https://github.com/depify"
    version="2.0">
    <xsl:output method="text" indent="no" encoding="UTF-8" />
    <xsl:param name="package"/>
    <xsl:param name="app_dir_lib"/>

    <xsl:template match="/"><catalog>
      generate catalog for packages:\n\n
      <xsl:apply-templates select="*/depify:depify[depify:xproc]">
        <xsl:sort select="@name"/>
      </xsl:apply-templates>
  </catalog>
    </xsl:template>
    <xsl:template match="depify:depify">
      \033[1;34m<xsl:value-of select="@name"/>\033[0m\n
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="depify:xproc">
      <xsl:value-of select="@ns"/>#library.xpl = <xsl:value-of select="concat('jar:file:',replace($app_dir_lib,'/',''),'/',@jar,'!',@library-uri)"/>\n      

      <xsl:apply-templates select="depify:catalog"/>
    </xsl:template>

    <xsl:template match="depify:catalog">
      <xsl:value-of select="@name"/> = <xsl:value-of select="@uri"/>\n
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet> 
