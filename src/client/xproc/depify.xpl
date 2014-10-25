<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright (c) 2011-2012 James Fuller

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
//-->
<p:declare-step 
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:pxp="http://exproc.org/proposed/steps"
    xmlns:depify="https://github.com/xquery/depify"
    xmlns:impl="https://github.com/xquery/depify/impl"
    version="1.0"
    name="main"
    type="depify:depify"
    exclude-inline-prefixes="cx c p cxf pxp impl depify">

  <p:documentation>
    depify client written in xproc
  </p:documentation>

  <p:input port="source" primary="true"/>

  <p:input port="packages">
    <p:document href="http://depify.com/packages/packages.xml"/>
  </p:input>

  <p:output port="result" sequence="true"/>

  <p:import href="extension-library.xml"/>
  <p:import href="depify-impl.xpl"/>

  <p:option name="depify-repo-download-url" select="'http://depify.com/packages/packages.xml'"/>
  <p:option name="command" select="'list'"/>
  <p:option name="package" select="''"/>
  <p:option name="version" select="'1.0'"/>
  <p:option name="init-repo-uri" select="''"/>
  <p:option name="app_dir" select="'.'"/>
  <p:option name="app_dir_lib" select="'lib'"/>

  <p:in-scope-names name="vars"/>

  <!--p:try-->
  <p:group>
  <p:filter name="get-package">
    <p:with-option name="select" select="concat('/depify:depify/depify:dep[@name eq &quot;',$package,'&quot;]')"/>
    <p:input port="source">
      <p:pipe step="main" port="packages"/>
    </p:input>
  </p:filter>

  <p:choose name="command-step">
    <p:when test="$command eq 'init'">
      <p:output port="result"/>
      <cx:message>
        <p:with-option name="message" select="'depify.xml does not exist, creating now'"/>
      </cx:message>

      <p:xslt>
        <p:input port="source">
          <p:pipe step="main" port="packages"/>
       </p:input> 
         <p:input port="stylesheet">
          <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            xmlns="https://github.com/xquery/depify"
                            version="2.0">
              <xsl:output method="xml" indent="yes" encoding="UTF-8" />
              <xsl:param name="package"/>
              <xsl:param name="version"/>
              <xsl:param name="init-repo-uri"/>
              <xsl:template match="/">
                <depify xmlns="https://github.com/xquery/depify" name="{$package}" version="{$version}" repo-uri="{$init-repo-uri}">
                  <title><xsl:value-of select="$package"/></title>
                  <desc></desc>
                  <!--dep name="functional.xq" version="1.0"/-->  
                </depify>
              </xsl:template>
            </xsl:stylesheet>
          </p:inline>
        </p:input>
          <p:input port="parameters">
            <p:pipe step="vars" port="result"/>
          </p:input>
      </p:xslt>
    </p:when>  
    <p:when test="$command eq 'install'">
      <p:output port="result"/>
      <p:choose>        
        <p:variable name="repo-uri" select="(/depify:dep/@repo-uri/data(.),/depify:dep/depify:repo/depify:uri/data(.))[1]">
          <p:pipe step="get-package" port="result"/>
        </p:variable>
        <p:when test="starts-with($repo-uri,'https://github.com/')">
          <p:variable name="package-repo-uri" select="concat(substring-before($repo-uri,'.git'),'/archive/master.zip')">
            <p:pipe step="get-package" port="result"/>
          </p:variable>
          <cx:message>
            <p:with-option name="message" select="concat('depify downloading ',$package-repo-uri)"/>
          </cx:message>
          <impl:get-package-from-github-repo>
            <p:with-option name="github-download-uri" select="$package-repo-uri"/>
            <p:with-option name="app_dir" select="$app_dir"/>
            <p:with-option name="app_dir_lib" select="$app_dir_lib"/>
          </impl:get-package-from-github-repo>
        </p:when>
        <p:when test="starts-with($repo-uri,'git://')">
          <p:variable name="package-repo-uri" select="concat('https://',substring-after(substring-before($repo-uri,'.git'),'git://'),'/archive/master.zip')">
            <p:pipe step="get-package" port="result"/>
          </p:variable>
          <cx:message>
            <p:with-option name="message" select="concat('depify downloading ',$package-repo-uri)"/>
          </cx:message>      
          <impl:get-package-from-github-repo>
            <p:with-option name="github-download-uri" select="$package-repo-uri"/>
            <p:with-option name="app_dir" select="$app_dir"/>
            <p:with-option name="app_dir_lib" select="$app_dir_lib"/>
          </impl:get-package-from-github-repo>
        </p:when>
        <p:when test="ends-with($repo-uri,'.zip')">
          <p:variable name="package-repo-uri" select="$repo-uri">
            <p:pipe step="get-package" port="result"/>
          </p:variable>
          <cx:message>
            <p:with-option name="message" select="concat('depify downloading ',$package-repo-uri)"/>
          </cx:message>
          <impl:get-package-from-github-repo>
            <p:with-option name="github-download-uri" select="$package-repo-uri"/>
            <p:with-option name="app_dir" select="$app_dir"/>
            <p:with-option name="app_dir_lib" select="$app_dir_lib"/>
          </impl:get-package-from-github-repo>
        </p:when>
        <p:otherwise>
          <p:variable name="package-repo-uri" select="concat('http://depify.com/downloads/',$package,'-',$version,'.zip')"/>
          <cx:message>
            <p:with-option name="message" select="concat('depify downloading ',$package-repo-uri)"/>
          </cx:message>      
          <impl:get-package-from-depify-repo>
            <p:with-option name="depify-download-uri" select="$package-repo-uri"/>
            <p:with-option name="app_dir" select="$app_dir"/>
            <p:with-option name="app_dir_lib" select="$app_dir_lib"/>
          </impl:get-package-from-depify-repo>
        </p:otherwise>
      </p:choose>
      <impl:install name="install">
       <p:with-option name="package-name" select="$package"/>
       <p:with-option name="package-version" select="$version"/>
       <p:input port="source">
         <p:pipe step="main" port="source"/>
       </p:input>         
       <p:input port="package">
         <p:pipe step="get-package" port="result"/>
       </p:input>
      </impl:install>
      <p:choose>
        <p:xpath-context>
          <p:pipe step="get-package" port="result"/>          
        </p:xpath-context>
        <p:when test="/depify:dep/depify:dep">  
          <p:for-each>
            <p:iteration-source select="/depify:dep/depify:dep">  
              <p:pipe step="get-package" port="result"/>
            </p:iteration-source>
            <depify:depify>
                <p:with-option name="depify-repo-download-url" select="$depify-repo-download-url"/>
                <p:with-option name="command" select="'install'"/>
                <p:with-option name="package" select="/depify:dep/@name"/>
                <p:with-option name="version" select="/depify:dep/@version"/>
                <p:with-option name="app_dir" select="$app_dir"/>
                <p:with-option name="app_dir_lib" select="$app_dir_lib"/>
            </depify:depify> 
          </p:for-each>
          <p:identity>
            <p:input port="source">
              <p:pipe step="install" port="result"/>
            </p:input>
          </p:identity>   
        </p:when>
        <p:otherwise>
            <p:identity>
              <p:input port="source">
                <p:pipe step="install" port="result"/>
              </p:input>
            </p:identity>          
        </p:otherwise>
      </p:choose>
    </p:when>
    <p:when test="$command eq 'remove'">
      <p:output port="result"/>
      <impl:remove>
       <p:with-option name="package-name" select="$package"/>
       <p:with-option name="package-version" select="$version"/>
       <p:input port="source">
         <p:pipe step="main" port="source"/>
       </p:input>
      </impl:remove>
    </p:when>
    <p:when test="$command eq 'register'">
      <p:output port="result"/>
      <p:identity>
        <p:input port="source">
           <p:pipe step="main" port="source"/>
       </p:input>
      </p:identity>
      <p:wrap wrapper="c:body" match="/"/>
      <p:add-attribute match="c:body"
                 attribute-name="content-type"
                 attribute-value="application/xml"/>
      <p:wrap wrapper="c:request" match="/"/>
      <p:add-attribute attribute-name="href" match="/c:request">
        <p:with-option name="attribute-value"
                       select="concat('http://www.webcomposite.com?package=',$package,'&amp;version=',$version,'&amp;repo=',$init-repo-uri)"/>
      </p:add-attribute>
      <p:set-attributes match="c:request">
        <p:input port="attributes">
          <p:inline>
            <c:request method="post"/>
          </p:inline>
        </p:input>
      </p:set-attributes>
      <p:http-request/>
      <p:identity>
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input>
      </p:identity>  
    </p:when>  
    <p:otherwise>
      <p:output port="result"/>
      <p:identity>
        <p:input port="source">
           <p:pipe step="main" port="source"/>
       </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>

  <p:store indent="true" name="save-depify-step">
    <p:with-option name="href" select="concat($app_dir,'/depify.xml')"/>
  </p:store>

  <p:choose name="transform-output-step">
    <p:when test="$command eq 'search' and $package eq ''">
      <p:xslt>
        <p:input port="source">
          <p:pipe step="main" port="packages"/>
        </p:input> 
         <p:input port="stylesheet">
          <p:inline>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:depify="https://github.com/xquery/depify"
    version="2.0">
    <xsl:output method="xml" indent="no" encoding="UTF-8" />
    <xsl:variable name="search"/>
    <xsl:template match="*:depify"><search>
      
search depify packages: <xsl:value-of select="$search"/><xsl:text>
</xsl:text>
    <xsl:apply-templates/>
  </search>
    </xsl:template>
    <xsl:template match="*:dep">
        <xsl:value-of select="@name"/>, v<xsl:value-of select="@version"/>, <xsl:value-of select="@repo-uri"/> <xsl:text>
</xsl:text>

    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>            
          </p:inline>
        </p:input>
          <p:input port="parameters">
            <p:pipe step="vars" port="result"/>
          </p:input>
      </p:xslt>
      
    </p:when>
    <p:when test="$command eq 'list' and $package eq ''">
      <p:identity>
         <p:input port="source">
           <p:pipe step="main" port="source"/>
       </p:input>
      </p:identity>
    </p:when>
    <p:when test="$command eq 'info' and $package ne ''">
      <p:identity>
         <p:input port="source">
           <p:pipe step="get-package" port="result"/>
       </p:input>
      </p:identity>
    </p:when>
    <p:when test="$command eq 'info' and $package eq ''">
      <p:identity>
         <p:input port="source">
           <p:pipe step="main" port="packages"/>
       </p:input>
      </p:identity>
    </p:when>
    <p:when test="$command eq 'package'">
      <p:identity>
         <p:input port="source">
           <p:pipe step="main" port="source"/>
       </p:input>
      </p:identity>
    </p:when>
    <p:when test="$command eq 'publish'">
      <p:identity>
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input>
      </p:identity>
    </p:when>
    <p:otherwise>
      <p:identity>
        <p:input port="source">
          <p:pipe step="command-step" port="result"/>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>
  </p:group>

  <!--p:catch>
    <p:identity>
      <p:input port="source">
        <p:inline>
          <error>DEPify package not found.</error>
        </p:inline>
      </p:input>
    </p:identity>
  </p:catch>  
</p:try-->

</p:declare-step>
