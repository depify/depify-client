<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:error" name="main" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:x="http://www.emc.com/documentum/xml/xproc"
    xmlns:pxi="http://www.daisy.org/ns/xprocspec/xproc-internal/" exclude-inline-prefixes="#all" version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p>Example usage:</p>
        <pre xml:space="preserve">
            &lt;px:error code="pxe:PEOU0001"&gt;
                &lt;p:with-param name="param1" select="$href"/&gt;
                &lt;p:input port="error-definitions"&gt;
                    &lt;p:inline&gt;
                        &lt;d:errors xmlns:pxe="..."&gt;
                            &lt;d:error code="pxe:PEOU0001" message="URI must be absolute and refer to the local file system: $1"
                                (...)
                        &lt;/d:errors&gt;
                    &lt;/p:inline&gt;
                &lt;/p:input&gt;
            &lt;/px:error&gt;
        </pre>
    </p:documentation>

    <p:output port="result" sequence="true">
        <p:pipe port="result" step="error"/>
    </p:output>

    <p:option name="code" required="true"/>
    <!-- QName -->
    <p:option name="code-prefix" select="''"/>
    <!-- NCName -->
    <p:option name="code-namespace" select="''"/>
    <!-- anyURI -->
    <p:option name="message" required="true"/>
    <!-- description of the error that occured. $1, $2 etc will be replaced with the contents of param1, param2 etc. -->
    <p:option name="param1" select="''"/>
    <p:option name="param2" select="''"/>
    <p:option name="param3" select="''"/>
    <p:option name="param4" select="''"/>
    <p:option name="param5" select="''"/>
    <p:option name="param6" select="''"/>
    <p:option name="param7" select="''"/>
    <p:option name="param8" select="''"/>
    <p:option name="param9" select="''"/>
    <!-- in the unlikely event that you need more parameters you'll have to format the message string yourself -->
    <p:option name="logfile" select="''"/>
    
    <p:import href="log.xpl"/>

    <p:string-replace match="/*/text()" name="message">
        <p:input port="source">
            <p:inline>
                <message>MESSAGE</message>
            </p:inline>
        </p:input>
        <p:with-option name="replace" use-when="p:system-property('p:xpath-version')='1.0'" select="concat('&quot;',$message,'&quot;')">
            <!-- replace(...) not supported in XPath 1.0 -->
            <p:inline>
                <irrelevant/>
            </p:inline>
        </p:with-option>
        <p:with-option name="replace" use-when="not(p:system-property('p:xpath-version')='1.0')"
            select="concat('&quot;',replace(replace(replace(replace(replace(replace(replace(replace(replace($message,'\$1',$param1),'\$2',$param2),'\$3',$param3),'\$4',$param4),'\$5',$param5),'\$6',$param6),'\$7',$param7),'\$8',$param8),'\$9',$param9),'&quot;')">
            <p:inline>
                <irrelevant/>
            </p:inline>
        </p:with-option>
    </p:string-replace>

    <p:group>
        <p:variable name="code-localName" use-when="p:system-property('p:xpath-version')='1.0'"
            select="concat(
            substring(substring-after($code,':'), 1, number(contains($code,':')) * string-length(substring-after($code,':'))),
            substring($code, 1, number(not(contains($code,':'))) * string-length($code))
            )"/>
        <p:variable name="code-localName" use-when="not(p:system-property('p:xpath-version')='1.0')" select="if (contains($code,':')) then substring-after($code,':') else $code"/>
        <p:variable name="prefix" select="concat(substring-before($code,':'),$code-prefix)"/>
        <pxi:log severity="ERROR">
            <p:with-option name="logfile" select="$logfile"/>
            <p:with-option name="message" select="concat(if ($code-prefix) then concat($code-prefix,':') else '', $code-localName, if ($code-namespace) then concat('{',$code-namespace,'}') else '', ': ', /*/text())">
                <p:pipe port="result" step="message"/>
            </p:with-option>
        </pxi:log>
        <p:choose>
            <p:when test="not($code-namespace='') and not($prefix='')">
                <p:error>
                    <p:input port="source">
                        <p:pipe port="result" step="message"/>
                    </p:input>
                    <p:with-option name="code" select="$code-localName"/>
                    <p:with-option name="code-namespace" select="$code-namespace"/>
                    <p:with-option name="code-prefix" select="$prefix"/>
                </p:error>
            </p:when>
            <p:when test="not($code-namespace='')">
                <p:error>
                    <p:input port="source">
                        <p:pipe port="result" step="message"/>
                    </p:input>
                    <p:with-option name="code" select="$code-localName"/>
                    <p:with-option name="code-namespace" select="$code-namespace"/>
                </p:error>
            </p:when>
            <p:when test="not($prefix='')">
                <p:error>
                    <p:input port="source">
                        <p:pipe port="result" step="message"/>
                    </p:input>
                    <p:with-option name="code" select="$code-localName"/>
                    <p:with-option name="code-prefix" select="$prefix"/>
                </p:error>
            </p:when>
            <p:otherwise>
                <p:error>
                    <p:input port="source">
                        <p:pipe port="result" step="message"/>
                    </p:input>
                    <p:with-option name="code" select="$code-localName"/>
                </p:error>
            </p:otherwise>
        </p:choose>
    </p:group>
    <p:identity name="error"/>

</p:declare-step>
