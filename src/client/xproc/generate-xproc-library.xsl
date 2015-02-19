<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:depify="https://github.com/depify"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                version="2.0">
  <xsl:output method="xml" indent="no" encoding="UTF-8" />
  <xsl:param name="app_dir_lib"/>
    <xsl:template match="depify:depify[depify:xproc]">
      <p:library version="1.0">
          <xsl:apply-templates select="depify:xproc"/>
      </p:library>
    </xsl:template>
    <xsl:template match="depify:xproc">
      <p:import href="{depify:catalog/@name}"/>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet> 
