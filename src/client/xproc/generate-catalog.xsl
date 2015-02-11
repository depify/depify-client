<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:depify="https://github.com/depify"
                xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog"
                version="2.0">
  <xsl:output method="xml" indent="no" encoding="UTF-8" />
  <xsl:param name="app_dir_lib"/>
    <xsl:template match="/">
      <catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
        <xsl:for-each select="depify:depify">
          <xsl:apply-templates select="*"/>
        </xsl:for-each>
      </catalog>
    </xsl:template>
    <xsl:template match="depify:xproc">
        <uri name="{depify:catalog/@name}" 
             uri=".{$app_dir_lib}{depify:catalog/@uri}"/>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet> 
