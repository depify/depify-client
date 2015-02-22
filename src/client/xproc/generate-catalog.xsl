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
    <xsl:template match="depify:xproc[@jar][starts-with(@library-uri,'!')]">
      <uri name="{@ns}#library.xpl">
            <xsl:attribute name="uri" select="concat('jar:file:',replace($app_dir_lib,'/',''),'/',@jar,@library-uri)"/>
      </uri> 
      <xsl:apply-templates select="depify:catalog"/>
    </xsl:template>
    <xsl:template match="depify:catalog">
      <uri name="{@name}">
        <xsl:choose>
          <xsl:when test="@jar">
            <xsl:attribute name="uri" select="concat('jar:file:',replace($app_dir_lib,'/',''),'/',@jar,'!',@uri)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="uri" select="concat('.',$app_dir_lib,@uri)"/>
          </xsl:otherwise>
        </xsl:choose>
      </uri>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet> 
