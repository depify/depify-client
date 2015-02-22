<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:depify="https://github.com/depify"
                xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog"
                version="2.0">
  <xsl:output method="xml" indent="no" encoding="UTF-8" />
  <xsl:param name="app_dir_lib"/>
  <xsl:param name="depify_dir"/>
  <xsl:template match="/"><xproc>
#!/bin/sh
    
java -cp <xsl:value-of select="$depify_dir"/>/deps/xmlcalabash/calabash.jar<xsl:for-each select="//@jar">:<xsl:value-of select="replace($app_dir_lib,'/','')"/>/<xsl:value-of select="."/></xsl:for-each> com.xmlcalabash.drivers.Main -oresult=- -Xtransparent-json "$@"</xproc>    
  </xsl:template>
  <xsl:template match="text()"/>
</xsl:stylesheet> 
