 <schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:depx="https://github.com/xquery/depx">
    <ns uri="https://github.com/xquery/depx" prefix="depx"/>
    <pattern id="basic">
      <rule context="/depx:package">
        <assert test="@name">Requires a fully qualified name for package.</assert>
        <assert test="@version">Requires version number for package.</assert>
        <assert test="depx:repo">Requires repo for package.</assert>           
      </rule>
      <rule context="/depx:package/depx:license">
        <assert test="@type eq 'GNU-LGPL' or @type eq 'OTHER'">License type must refer to either GNU-LGPL, MPL2, OTHER</assert>
        <assert test="@type eq 'OTHER' and depx:uri ne ''">If license type is OTHER it must refer to a uri</assert>
      </rule>
      <rule context="/depx:package/depx:repo">
        <assert test="@type eq 'git' or @type eq 'svn'">Repo type must be either git, svn</assert>
        <assert test="@uri">Repo requires a publically accessible scm uri</assert>
      </rule>
    </pattern>    
    <pattern id="entrypoint">
      <rule context="/depx:package">
        <assert test="depx:xquery or depx:xslt or depx:schema or depx:xproc or depx:css or depx:js or depx:app">Requires at least one entry point</assert>
      </rule>
      <rule context="/depx:package/depx:xquery">
        <assert test="depx:prefix ne ''">XQuery entrypoint requires namespace prefix</assert>
        <assert test="depx:namespace ne ''">XQuery entrypoint requires valid namespace</assert>
        <assert test="depx:uri ne ''">XQuery entrypoint requires valid uri</assert>
      </rule>
      <rule context="/depx:package/depx:xslt">
        <assert test="depx:prefix ne ''">XSLT entrypoint requires namespace prefix</assert>
        <assert test="depx:namespace ne ''">XSLT entrypoint requires valid namespace</assert>
        <assert test="depx:uri ne ''">XSLT entrypoint requires valid uri</assert>
      </rule>
      <rule context="/depx:package/depx:xproc">
        <assert test="depx:prefix ne ''">XPROC entrypoint requires namespace prefix</assert>
        <assert test="depx:namespace ne ''">XPROC entrypoint requires valid namespace</assert>
        <assert test="depx:uri ne ''">XPROC entrypoint requires valid uri</assert>
      </rule>
      <rule context="/depx:package/depx:schema">
        <assert test="@type eq 'xmlschema' or @type eq 'schematron' or @type eq 'relaxng' or @type eq 'nvdl'">Schema entrypoint requires a type</assert>
        <assert test="depx:prefix ne ''">Schema entrypoint requires namespace prefix</assert>
        <assert test="depx:namespace ne ''">Schema entrypoint requires valid namespace</assert>
        <assert test="depx:uri ne ''">Schema entrypoint requires valid uri</assert>
      </rule>
      <rule context="/depx:package/depx:css">
        <assert test="depx:uri ne ''">CSS entrypoint requires valid uri</assert>
      </rule>
      <rule context="/depx:package/depx:js">
        <assert test="depx:uri ne ''">JS entrypoint requires valid uri</assert>
      </rule>
      <rule context="/depx:package/depx:app">
        <assert test="depx:uri ne ''">APP entrypoint requires valid uri</assert>
      </rule>
    </pattern>
    <pattern id="deps">
      <rule context="/depx:package/depx:dep">
        <assert test="@name ne ''">Dependency requires fully qualified name ex. xquery.1.functx</assert>
        <assert test="matches(@version,'^(\d*)(\.?)(\d*)(\.?)(\d*)$')">Dependency requires valid version ex. 1.0.0 </assert>
        <assert test="@version ne ''">Dependency requires non-empty version</assert>
      </rule>
    </pattern>
    <pattern id="optional">
      <rule context="/depx:package">
        <assert test="depx:title">Title will be used for depx.org listing.</assert>
        <assert test="depx:desc">Description will be used for depx.org listing.</assert>
        <assert test="depx:license">Description will be used for depx.org listing.</assert>
        <assert test="depx:author" >Author will be used for depx.org listing.</assert>
        <assert test="depx:website">Website will be used for depx.org listing.</assert>
        <assert test="depx:author">Description will be used for depx.org listing.</assert>    
      </rule>
    </pattern>    
</schema>
