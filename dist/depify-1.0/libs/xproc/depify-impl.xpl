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
<p:library 
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:pxp="http://exproc.org/proposed/steps"
    xmlns:depify="https://github.com/depify"
    xmlns:impl="https://github.com/depify/impl"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:j="http://marklogic.com/json"
    version="1.0"
    exclude-inline-prefixes="cx c p">

  <p:import href="extension-library.xml"/>

  <p:declare-step type="impl:install" name="install-step">
    <p:input port="source" primary="true"/>
    <p:input port="package" primary="false"/>
    <p:output port="result">
      <p:pipe step="update-timestamp" port="result"/>
    </p:output>
    <p:option name="package-name"/>
    <p:option name="package-version"/>
    
    <p:choose>
      <p:when test="/depify:depify/depify:depify[@name eq $package-name]">
        <p:identity/>
      </p:when>
      <p:when test="/depify:depify/depify:depify[@name ne $package-name]">  
        <p:insert match="/depify:depify/depify:dep" position="after">
          <p:input port="insertion">
            <p:pipe port="package" step="install-step"/>
          </p:input>
        </p:insert>
      </p:when>
      <p:when test="/depify:depify">
        <p:insert match="/depify:depify" position="last-child">
          <p:input port="insertion">
            <p:pipe port="package" step="install-step"/>
          </p:input>
        </p:insert>
      </p:when>
      <p:otherwise>
        <p:wrap match="/" wrapper="depify" wrapper-namespace="https://github.com/depify">
          <p:input port="source">
            <p:pipe port="package" step="install-step"/>
          </p:input>
        </p:wrap>
      </p:otherwise>
    </p:choose>    
    <p:add-attribute name="update-timestamp" match="/depify:depify" attribute-name="ts" attribute-value="current datetime"/>
    
  </p:declare-step>

  <p:declare-step type="impl:remove" name="remove-step">
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    <p:option name="package-name" required="true"/>
    <p:option name="package-version"/>
    <p:try>
      <p:group>
       <p:delete>
         <p:with-option name="match" select="concat(
                                             '/depify:depify/depify:depify[@name eq &quot;',
                                             $package-name,
                                             '&quot;]')"/>
       </p:delete>
      </p:group>
      <p:catch>
        <p:identity/>
      </p:catch>
    </p:try>
  </p:declare-step>

  <p:declare-step type="impl:list-installed" name="list-installed-step">
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    <p:option name="package-name"/>
    <p:option name="package-version"/>
    <p:choose>
      <p:when test="$package-name eq ''">
        <p:identity/>
      </p:when>
      <p:otherwise>  
        <p:filter>
          <p:with-option name="select" select="concat('//depify:depify[@name eq &quot;',$package-name,'&quot;]')"/>
        </p:filter>
        <p:wrap-sequence wrapper="depify" wrapper-namespace="https://github.com/depify"/>
    </p:otherwise>
    </p:choose>
    <p:add-attribute match="/depify:depify" attribute-name="ts" attribute-value="current datetime"/>
  </p:declare-step>

    <p:declare-step type="impl:list-repo" name="list-repo-step">
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    <p:option name="depify-repo-package-url"/>
    <p:option name="package-name"/>
    <p:option name="package-version"/>
    <p:http-request>
      <p:input port="source">
        <p:inline>
          <c:request method="GET"
                     href="http://depify.com/packages/package.xml"/>
        </p:inline>
      </p:input>
    </p:http-request>
    </p:declare-step>

    <p:declare-step type="impl:get-package-from-github-repo">
      
      <p:option name="github-download-uri"/>
      <p:option name="app_dir"/>
      <p:option name="app_dir_lib"/>
      
      <p:variable name="repo-uri" select="$github-download-uri"/>
      <p:variable name="temp-zip-file" select="concat('/tmp/depify/tmp',replace(substring-after($github-download-uri,'/'),'/','-'))"/>
      
      <p:in-scope-names name="vars"/>

      <p:template>
        <p:input port="template">
          <p:inline>
            <c:request method="GET" href="{$github-download-uri}"/>
          </p:inline>
        </p:input>
        <p:input port="source">
          <p:empty/>
        </p:input>
        <p:input port="parameters">
          <p:pipe step="vars" port="result"/>
        </p:input>
      </p:template>

      <p:http-request/>
      
      <p:store name="store-temp-zip" cx:decode="true">
          <p:with-option name="href" select="$temp-zip-file"/>
      </p:store>
      
      <cx:unzip name="container" cx:depends-on="store-temp-zip">
        <p:with-option name="href" select="$temp-zip-file"/>
      </cx:unzip>
      
      <p:for-each>
        <p:iteration-source select="//c:file"/>
        <p:variable name="file" select="c:file/@name"/>
        
        <cx:unzip content-type="*">
          <p:with-option name="href" select="$temp-zip-file"/>
          <p:with-option name="file" select="$file"/>
        </cx:unzip>
        
        <p:add-attribute match="/c:data" 
                       attribute-name="encoding" 
                       attribute-value="base64"/>
        
        <p:store cx:decode="true">
          <p:with-option name="href" select="concat($app_dir,$app_dir_lib,'/',$file)"/>
        </p:store>
      </p:for-each>
     
    </p:declare-step>
      
    <p:declare-step type="impl:get-package-from-depify-repo">
      <p:option name="depify-download-uri"/>
      <p:option name="app_dir"/>
      <p:option name="app_dir_lib"/>
      
      <p:variable name="repo-uri" select="$depify-download-uri"/>

      <cx:unzip name="container">
        <p:with-option name="href" select="$repo-uri"/>
      </cx:unzip>
      
      <p:for-each>
        <p:iteration-source select="//c:file"/>
        <p:variable name="file" select="c:file/@name"/>
        
        <cx:unzip content-type="*">
          <p:with-option name="href" select="$repo-uri"/>
          <p:with-option name="file" select="$file"/>
        </cx:unzip>
        
        <p:add-attribute match="/c:data" 
                       attribute-name="encoding" 
                       attribute-value="base64"/>
        
        <p:store cx:decode="true">
          <p:with-option name="href" select="concat($app_dir,'/',$app_dir_lib,'/',$file)"/>
        </p:store>
      </p:for-each>
      
    </p:declare-step>

    <p:declare-step type="impl:get-package-from-bower-repo">
      <p:option name="bower-package"/>
      <p:option name="app_dir"/>
      <p:option name="app_dir_lib"/>
      
      <p:in-scope-names name="vars"/>

      <p:template>
        <p:input port="template">
          <p:inline>
            <c:request method="GET" href="https://bower.herokuapp.com/packages/{$bower-package}"/>
          </p:inline>
        </p:input>
        <p:input port="source">
          <p:empty/>
        </p:input>
        <p:input port="parameters">
          <p:pipe step="vars" port="result"/>
        </p:input>
      </p:template>

      <p:http-request/>
      
      <p:identity name="package-meta"/>

      <p:variable name="repo-uri"
                 select="concat('https:',
                                 substring-after(
                                 substring-before( /j:json/j:url,'.git')
                                 ,'git:'),
                                 '/archive/master.zip')">
      <p:pipe step="package-meta" port="result"/>
      </p:variable>
      
      <cx:unzip name="container">
        <p:with-option name="href" select="$repo-uri"/>
      </cx:unzip>

      <p:for-each>
        <p:iteration-source select="//c:file"/>
        <p:variable name="file" select="c:file/@name"/>
        
        <cx:unzip content-type="*">
          <p:with-option name="href" select="$repo-uri"/>
          <p:with-option name="file" select="$file"/>
        </cx:unzip>
        
        <p:add-attribute match="/c:data" 
                       attribute-name="encoding" 
                       attribute-value="base64"/>
        
        <p:store cx:decode="true">
          <p:with-option name="href" select="concat($app_dir,$app_dir_lib,'/',$file)"/>
        </p:store>
      </p:for-each>
            
      
    </p:declare-step>
    

</p:library>
