<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:depify="https://github.com/depify"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                version="2.0">
  <xsl:output method="xml" indent="no" encoding="UTF-8" />
  <xsl:param name="app_dir_lib"/>
    <xsl:template match="/">
      <p:library version="1.0">
          <xsl:apply-templates/>
      </p:library>
    </xsl:template>
    <xsl:template match="depify:xproc">
      <xsl:if test="@ns"><p:import href="https://github.com/depify/depify-packages/tree/master{../@path}#xproc"/></xsl:if>
      <xsl:apply-templates select="depify:catalog"/>
    </xsl:template>
    <xsl:template match="depify:catalog">
      <p:import href="{@name}"/>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet> 
