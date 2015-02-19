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
    xmlns:depify="https://github.com/depify"
    xmlns:impl="https://github.com/depify/impl"
    version="1.0"
    name="main"
    type="depify:depify"
    exclude-inline-prefixes="cx c p cxf pxp impl depify">

  <p:serialization port="result" media-type="text/plain" method="text" /> 

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
  <p:option name="version" select="'latest'"/>
  <p:option name="init-repo-uri" select="''"/>
  <p:option name="app_dir" select="'.'"/>
  <p:option name="app_dir_lib" select="'lib'"/>
  <p:option name="download_master_if_version_does_not_exist" select="true()"/>

  <p:in-scope-names name="vars"/>

  <p:try>
  <p:group>
      
  <p:filter name="get-package">
    <p:with-option name="select" select="concat('/depify:packages/depify:depify[@name eq &quot;',$package,'&quot;]')"/>
    <p:input port="source">
      <p:pipe step="main" port="packages"/>
    </p:input>
  </p:filter>
  
  <p:choose name="command-step">
    <p:when test="$command eq 'init' and not(doc-available( concat($app_dir,'.depify.xml') ))">
      <p:output port="result"/>
      <p:xslt>
        <p:input port="source">
          <p:inline>
            <dummy/>
          </p:inline>
        </p:input>
        <p:input port="stylesheet">
          <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            xmlns="https://github.com/depify"
                            version="2.0">
              <xsl:output method="xml" indent="yes" encoding="UTF-8" />
              <xsl:param name="package"/>
              <xsl:param name="version"/>
              <xsl:param name="init-repo-uri"/>
              <xsl:template match="/">
                <depify xmlns="https://github.com/depify" name="{$package}" version="{$version}" repo-uri="{$init-repo-uri}">
                  <title><xsl:value-of select="$package"/></title>
                  <desc></desc>
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
    <p:when test="$command eq 'install' and $package eq ''">
      <p:output port="result"/>
      <p:for-each>
        <p:iteration-source select="/depify:depify/depify:depify">  
          <p:pipe step="main" port="source"/>
        </p:iteration-source>
        <depify:depify>
          <p:input port="source">
            <p:pipe step="main" port="source"/>
          </p:input>
          <p:with-option name="depify-repo-download-url" select="$depify-repo-download-url"/>
          <p:with-option name="command" select="'install'"/>
          <p:with-option name="package" select="/depify:depify/@name"/>
          <p:with-option name="version" select="/depify:depify/@version"/>
          <p:with-option name="app_dir" select="$app_dir"/>
          <p:with-option name="app_dir_lib" select="$app_dir_lib"/>
        </depify:depify> 
      </p:for-each>
      <p:identity>
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input>
      </p:identity>   
    </p:when>
    <p:when test="$command eq 'install'">
      <p:output port="result"/>
      <p:choose>        
        <p:variable name="repo-uri" select="/depify:depify/@repo-uri/data(.)">
          <p:pipe step="get-package" port="result"/>
        </p:variable>
        <p:variable name="package-repo-uri"
                    select="concat(if(ends-with($repo-uri,'.git'))
                            then substring-before($repo-uri,'.git') else $repo-uri,'/archive/master.zip')"/>

        <!-- download zip file //-->
        <p:when test="contains($repo-uri,'.zip')">
          <p:variable name="package-repo-uri" select="$repo-uri"/>
          <cx:message>
            <p:with-option name="message" select="concat('downloading ',$package,' from ',$package-repo-uri)"/>
          </cx:message>
          <impl:get-package-from-github-repo>
            <p:with-option name="github-download-uri" select="$package-repo-uri"/>
            <p:with-option name="app_dir" select="$app_dir"/>
            <p:with-option name="app_dir_lib" select="$app_dir_lib"/>
          </impl:get-package-from-github-repo>
        </p:when>
        
        <!-- download github latest release or master zip  //-->
        <p:when test="starts-with($repo-uri,'https://github.com/') and ($version eq 'latest' or empty($version))">
          <cx:message>
            <p:with-option name="message" select="concat('downloading ',$package,' from ',$package-repo-uri)"/>
          </cx:message>
          <impl:get-package-from-github-repo>
            <p:with-option name="github-download-uri" select="$package-repo-uri"/>
            <p:with-option name="app_dir" select="$app_dir"/>
            <p:with-option name="app_dir_lib" select="$app_dir_lib"/>
          </impl:get-package-from-github-repo>
        </p:when>

        <!-- download github specific release //-->
        <p:when test="starts-with($repo-uri,'https://github.com/') and ($version ne 'latest' or not(empty($version))) and doc-available(concat($repo-uri,'/releases/tag/',$version))">
          <p:variable name="package-repo-uri"
                      select="concat(if(ends-with($repo-uri,'.git'))
                              then substring-before($repo-uri,'.git') else $repo-uri,'/archive/v',$version,'.zip')"/>
          <cx:message>
            <p:with-option name="message" select="concat('downloading ',$package,' from ',$package-repo-uri)"/>
          </cx:message>
          <impl:get-package-from-github-repo>
            <p:with-option name="github-download-uri" select="$package-repo-uri"/>
            <p:with-option name="app_dir" select="$app_dir"/>
            <p:with-option name="app_dir_lib" select="$app_dir_lib"/>
          </impl:get-package-from-github-repo>
        </p:when>
        
        <p:otherwise>
          <cx:message>
            <p:with-option name="message" select="concat('downloading ',$package,' from ',$package-repo-uri)"/>
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
        <p:when test="/depify:depify/depify:depify">  
          <p:for-each>
            <p:iteration-source select="/depify:depify/depify:depify">  
              <p:pipe step="get-package" port="result"/>
            </p:iteration-source>
            <depify:depify>
                <p:with-option name="depify-repo-download-url" select="$depify-repo-download-url"/>
                <p:with-option name="command" select="'install'"/>
                <p:with-option name="package" select="/depify:depify/@name"/>
                <p:with-option name="version" select="/depify:depify/@version"/>
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
    <p:with-option name="href" select="concat($app_dir,'/.depify.xml')"/>
  </p:store>
  
  <p:choose name="transform-output-step">
    <p:when test="$command eq 'catalog'">
      <impl:generate-catalog>
        <p:input port="source">
          <p:pipe step="command-step" port="result"/>
        </p:input>
        <p:input port="parameters">
          <p:pipe step="vars" port="result"/>
        </p:input>
        <p:with-option name="app_dir" select="$app_dir"/>
      </impl:generate-catalog>    
      <p:xslt>
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input> 
        <p:input port="stylesheet">
          <p:document href="display-catalog.xsl"/>
        </p:input>
        <p:input port="parameters">
          <p:pipe step="vars" port="result"/>
        </p:input>
      </p:xslt>   
    </p:when>
    <p:when test="$command eq 'library'">
      <impl:generate-xproc-library>
        <p:input port="source">
          <p:pipe step="command-step" port="result"/>
        </p:input>
        <p:input port="parameters">
          <p:pipe step="vars" port="result"/>
        </p:input>
        <p:with-option name="app_dir" select="$app_dir"/>
      </impl:generate-xproc-library>    
      <p:xslt>
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input> 
        <p:input port="stylesheet">
          <p:document href="display-library.xsl"/>
        </p:input>
        <p:input port="parameters">
          <p:pipe step="vars" port="result"/>
        </p:input>
      </p:xslt>   
    </p:when>
    <p:when test="$command eq 'search'">
      <p:xslt>
        <p:input port="source">
          <p:pipe step="main" port="packages"/>
        </p:input> 
        <p:input port="stylesheet">
          <p:document href="search.xsl"/>
        </p:input>
          <p:input port="parameters">
            <p:pipe step="vars" port="result"/>
          </p:input>
      </p:xslt>      
    </p:when>
    <p:when test="$command eq 'list' and $package eq ''">
      <p:xslt>
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input> 
        <p:input port="stylesheet">
          <p:document href="list.xsl"/>
        </p:input>
          <p:input port="parameters">
            <p:pipe step="vars" port="result"/>
          </p:input>
      </p:xslt>      
    </p:when>
    <p:when test="$command eq 'install' and $package eq ''">
      <p:xslt>
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input> 
        <p:input port="stylesheet">
          <p:document href="list.xsl"/>
        </p:input>
          <p:input port="parameters">
            <p:pipe step="vars" port="result"/>
          </p:input>
      </p:xslt>      
    </p:when>
    <p:when test="$command eq 'info' and $package ne ''">
      <p:xslt>
        <p:input port="source">
          <p:pipe step="main" port="packages"/>
        </p:input> 
        <p:input port="stylesheet">
          <p:document href="info.xsl"/>
        </p:input>
          <p:input port="parameters">
            <p:pipe step="vars" port="result"/>
          </p:input>
      </p:xslt>      
    </p:when>
    <p:when test="$command eq 'info' and $package eq ''">
      <p:xslt>
        <p:input port="source">
          <p:pipe step="main" port="source"/>
        </p:input> 
        <p:input port="stylesheet">
          <p:document href="all-info.xsl"/>
        </p:input>
          <p:input port="parameters">
            <p:pipe step="vars" port="result"/>
          </p:input>
      </p:xslt>    
    </p:when>
    <p:when test="$command eq 'install' and $package ne ''">
      <p:xslt>
        <p:input port="source">
          <p:pipe step="get-package" port="result"/>
        </p:input> 
        <p:input port="stylesheet">
          <p:document href="install.xsl"/>
        </p:input>
          <p:input port="parameters">
            <p:pipe step="vars" port="result"/>
          </p:input>
      </p:xslt>    
    </p:when>
    <p:when test="$command eq 'remove' and $package ne ''">
      <p:xslt>
        <p:input port="source">
          <p:pipe step="get-package" port="result"/>
        </p:input> 
        <p:input port="stylesheet">
          <p:document href="remove.xsl"/>
        </p:input>
          <p:input port="parameters">
            <p:pipe step="vars" port="result"/>
          </p:input>
      </p:xslt>    
    </p:when>        
    <p:when test="$command eq 'init'">
    <p:identity>
      <p:input port="source">
        <p:inline>
          <error>\n
 -----------------------------\n
 depify 1.0\n
 copyright (c) 2015 Jim Fuller\n
 see https://github.com/depify\n
 -----------------------------\n
\n
 .depify created.\n</error>
        </p:inline>
      </p:input>
    </p:identity>
      
    </p:when>
    <p:otherwise> 
    <p:identity>
      <p:input port="source">
        <p:inline>
          <error>\n
 -----------------------------\n
 depify 1.0\n
 copyright (c) 2015 Jim Fuller\n
 see https://github.com/depify\n
 -----------------------------\n
\n
 invalid command.\n</error>
        </p:inline>
      </p:input>
    </p:identity>

    </p:otherwise>
  </p:choose>
  </p:group>

  <p:catch>
    <p:identity>
      <p:input port="source">
        <p:inline>
          <error>\n
 -----------------------------\n
 depify 1.0\n
 copyright (c) 2015 Jim Fuller\n
 see https://github.com/depify\n
 -----------------------------\n
\n
 package not found.\n</error>
        </p:inline>
      </p:input>
    </p:identity>
  </p:catch>  
</p:try>

</p:declare-step>
