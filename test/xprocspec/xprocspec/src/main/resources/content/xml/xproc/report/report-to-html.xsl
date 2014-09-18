<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all"
    xmlns:x="http://www.daisy.org/ns/xprocspec" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:template match="html">
        <xsl:variable name="descriptions" select="body/x:description[not(x:scenario/@pending)]"/>
        <xsl:variable name="pending-descriptions" select="body/x:description[x:scenario/@pending]"/>
        <xsl:variable name="errors" select="body/c:errors"/>
        <xsl:variable name="test-base-uri" select="string((body/*/@test-base-uri)[1])"/>
        <xsl:variable name="tests" select="$descriptions/x:test-result"/>
        <xsl:variable name="scripts" select="distinct-values($descriptions/@script)"/>
        <xsl:variable name="scripts-short" select="for $uri in ($scripts) return replace($uri,'^.*/','')"/>
        <xsl:variable name="passed" select="count($tests[@result='passed'])"/>
        <xsl:variable name="pending" select="count($tests[@result='skipped'] | $pending-descriptions)"/>
        <xsl:variable name="failed" select="count($tests[@result='failed'])"/>
        <xsl:variable name="error-count" select="count($errors)"/>
        <xsl:variable name="total" select="count($tests) + count($pending-descriptions) + $error-count"/>
        <xsl:variable name="log" select="body/c:log"/>

        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="head">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <title>Test Report for <xsl:value-of select="$test-base-uri"/> (passed:<xsl:value-of select="$passed"/> / pending:<xsl:value-of select="$pending"/> / failed:<xsl:value-of select="$failed"/> / errors:<xsl:value-of
                            select="$error-count"/> / total:<xsl:value-of select="$total"/>)</title>
                    <xsl:copy-of select="node()"/>
                </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="body">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <h1>Test Report</h1>
                    <p>Script: <a href="{$test-base-uri}"><xsl:value-of select="$test-base-uri"/></a></p>
                    <p>Tested: <xsl:value-of select="current-dateTime()"/><!-- TODO: prettier time: 10 July 2013 at 18:42 --></p>
                    <h2>Contents</h2>
                    <table class="xspec">
                        <col width="75%"/>
                        <col width="5%"/>
                        <col width="5%"/>
                        <col width="5%"/>
                        <col width="5%"/>
                        <col width="5%"/>
                        <thead>
                            <tr>
                                <th/>
                                <th class="result">passed:<xsl:value-of select="$passed"/></th>
                                <th class="result">pending:<xsl:value-of select="$pending"/></th>
                                <th class="result">failed:<xsl:value-of select="$failed"/></th>
                                <th class="result">errors:<xsl:value-of select="$error-count"/></th>
                                <th class="result">total:<xsl:value-of select="$total"/></th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:if test="$errors">
                                <tr class="error label">
                                    <th>
                                        <a href="#errors">Errors</a>
                                    </th>
                                    <th class="result">0</th>
                                    <th class="result">0</th>
                                    <th class="result">0</th>
                                    <th class="result">
                                        <xsl:value-of select="$error-count"/>
                                    </th>
                                    <th class="result">
                                        <xsl:value-of select="$error-count"/>
                                    </th>
                                </tr>
                            </xsl:if>

                            <!-- for each distinct step -->
                            <xsl:for-each select="distinct-values($descriptions/x:step-declaration/*/@x:type)">
                                <xsl:variable name="type" select="."/>
                                <xsl:variable name="stepid" select="concat('step',position())"/>
                                <xsl:variable name="step-descriptions" select="$descriptions[x:step-declaration/*/@x:type=$type]"/>
                                <xsl:variable name="step-shortname" select="($step-descriptions/x:step-declaration/*/@type,$type)[1]"/>
                                <xsl:variable name="passed" select="count($step-descriptions//x:test-result[@result='passed'])"/>
                                <xsl:variable name="pending" select="count($step-descriptions//x:test-result[@result='skipped'])"/>
                                <xsl:variable name="failed" select="count($step-descriptions//x:test-result[@result='failed'])"/>
                                <xsl:variable name="total" select="count($step-descriptions//x:test-result)"/>
                                <xsl:variable name="scenario-class" select="if ($failed) then 'failed' else if ($pending) then 'pending' else if ($passed) then 'successful' else ''"/>
                                <tr class="{$scenario-class} label">
                                    <th>
                                        <a href="#{$stepid}">
                                            <xsl:value-of select="$step-shortname"/>
                                        </a>
                                    </th>
                                    <th class="result">
                                        <xsl:value-of select="$passed"/>
                                    </th>
                                    <th class="result">
                                        <xsl:value-of select="$pending"/>
                                    </th>
                                    <th class="result">
                                        <xsl:value-of select="$failed"/>
                                    </th>
                                    <th class="result">0</th>
                                    <th class="result">
                                        <xsl:value-of select="$total"/>
                                    </th>
                                </tr>
                            </xsl:for-each>

                            <xsl:for-each select="distinct-values($pending-descriptions/(x:step-declaration/*/@type,resolve-uri(@script,base-uri()))[1])">
                                <xsl:variable name="title" select="."/>
                                <xsl:variable name="pending-script-descriptions" select="$pending-descriptions[(x:step-declaration/*/@type,resolve-uri(@script,base-uri()))[1] = $title]"/>
                                <xsl:variable name="script-base" select="($pending-script-descriptions/resolve-uri(@script,base-uri()))[1]"/>
                                <tr class="pending label">
                                    <th>
                                        <a href="#pending-{count($pending-script-descriptions[1]/preceding::x:description)}">Not calling: <xsl:value-of select="$title"/></a>
                                    </th>
                                    <th class="result">0</th>
                                    <th class="result">
                                        <xsl:value-of select="count($pending-script-descriptions)"/>
                                    </th>
                                    <th class="result">0</th>
                                    <th class="result">0</th>
                                    <th class="result">
                                        <xsl:value-of select="count($pending-script-descriptions)"/>
                                    </th>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>

                    <xsl:if test="$errors">
                        <div id="errors">
                            <h2 class="error">Errors<span class="scenario-totals">passed:0 / pending:0 / failed:0 / errors:<xsl:value-of select="$error-count"/> / total:<xsl:value-of select="$error-count"/></span></h2>
                            <table class="xspec">
                                <col width="80%"/>
                                <col width="20%"/>
                                <tbody>
                                    <!-- for each static error group -->
                                    <xsl:for-each select="$errors">
                                        <xsl:variable name="error-location" select="@error-location"/>
                                        <xsl:variable name="test-base-uri" select="@test-base-uri"/>
                                        <xsl:variable name="test-grammar" select="@test-grammar"/>
                                        <xsl:variable name="errors" select="c:error"/>

                                        <tr class="error label">
                                            <th>
                                                <xsl:value-of select="$error-location"/>
                                                <br/>
                                                <br/>
                                            </th>
                                            <th class="nobr">Error</th>
                                        </tr>

                                        <!-- for each step error in current error group -->
                                        <xsl:for-each select="$errors">
                                            <xsl:variable name="name" select="@name"/>
                                            <xsl:variable name="type" select="@type"/>
                                            <xsl:variable name="code" select="@code"/>
                                            <xsl:variable name="href" select="@href"/>
                                            <xsl:variable name="line" select="@line"/>
                                            <xsl:variable name="column" select="@column"/>
                                            <xsl:variable name="offset" select="@offset"/>
                                            <xsl:variable name="content" select="node()"/>

                                            <tr class="error">
                                                <td colspan="2">
                                                    <xsl:value-of select="if ($href) then concat($href,' ') else ''"/>
                                                    <xsl:value-of select="if ($line) then concat('line:',$line,' ') else ''"/>
                                                    <xsl:value-of select="if ($column) then concat('column:',$column,' ') else ''"/>
                                                    <xsl:value-of select="if ($offset) then concat('offset:',$offset,' ') else ''"/>
                                                    <xsl:value-of select="if ($code) then concat('code:',$code,' ') else ''"/>
                                                    <xsl:value-of select="if ($type) then concat('type:',$type,' ') else ''"/>
                                                    <xsl:if test="* or normalize-space(string-join(node(),''))">
                                                        <pre><code><xsl:copy-of select="node()"/></code></pre>
                                                    </xsl:if>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                        </div>
                    </xsl:if>

                    <!-- for each distinct step -->
                    <xsl:for-each select="distinct-values($descriptions/x:step-declaration/*/@x:type)">
                        <xsl:variable name="type" select="."/>
                        <xsl:variable name="stepid" select="concat('step',position())"/>
                        <xsl:variable name="step-descriptions" select="$descriptions[x:step-declaration/*/@x:type=$type]"/>
                        <xsl:variable name="step-shortname" select="($step-descriptions/x:step-declaration/*/@type,$type)[1]"/>
                        <xsl:variable name="passed" select="count($step-descriptions/x:test-result[@result='passed'])"/>
                        <xsl:variable name="pending" select="count($step-descriptions/x:test-result[@result='skipped'])"/>
                        <xsl:variable name="failed" select="count($step-descriptions/x:test-result[@result='failed'])"/>
                        <xsl:variable name="total" select="count($step-descriptions/x:test-result)"/>
                        <xsl:variable name="step-class" select="if ($failed) then 'failed' else if ($pending) then 'pending' else if ($passed) then 'successful' else ''"/>
                        <xsl:variable name="script-base" select="($step-descriptions/resolve-uri(@script,base-uri()))[1]"/>

                        <div id="{$stepid}">
                            <h2 class="{$step-class}">Calling: <a href="{$script-base}"><xsl:value-of select="$step-shortname"/></a><span class="scenario-totals">passed:<xsl:value-of select="$passed"/> / pending:<xsl:value-of select="$pending"/> /
                                        failed:<xsl:value-of select="$failed"/> / errors:0 / total:<xsl:value-of select="$total"/></span></h2>
                            <table class="xspec">
                                <col width="80%"/>
                                <col width="20%"/>
                                <tbody>
                                    <!-- for each step scenario -->
                                    <xsl:for-each select="$step-descriptions">
                                        <xsl:variable name="scenario-description" select="."/>
                                        <xsl:variable name="scenario-contexts" select="x:scenario/x:context"/>
                                        <xsl:variable name="scenario-tests" select="x:test-result"/>
                                        <xsl:variable name="scenarioid" select="concat($stepid,'-scenario',position())"/>
                                        <xsl:variable name="passed" select="count($scenario-description/x:test-result[@result='passed'])"/>
                                        <xsl:variable name="pending" select="count($scenario-description/x:test-result[@result='skipped'])"/>
                                        <xsl:variable name="failed" select="count($scenario-description/x:test-result[@result='failed'])"/>
                                        <xsl:variable name="total" select="count($scenario-description/x:test-result)"/>
                                        <xsl:variable name="scenario-class" select="if ($failed) then 'failed' else if ($pending) then 'pending' else if ($passed) then 'successful' else ''"/>

                                        <tr class="{$scenario-class} label">
                                            <th class="scenario-label">
                                                <xsl:value-of select="$scenario-description/x:scenario/@label"/>
                                            </th>
                                            <th class="nobr">passed:<xsl:value-of select="$passed"/> / pending:<xsl:value-of select="$pending"/> / failed:<xsl:value-of select="$failed"/> / errors:0 / total:<xsl:value-of select="$total"/></th>
                                        </tr>

                                        <!-- for each step scenario context -->
                                        <xsl:for-each select="$scenario-contexts">
                                            <xsl:variable name="id" select="@id"/>
                                            <xsl:variable name="context-tests" select="$scenario-tests[@contextref=$id]"/>
                                            <xsl:variable name="contextid" select="concat($scenarioid,'-context',position())"/>
                                            <xsl:variable name="passed" select="count($context-tests[@result='passed'])"/>
                                            <xsl:variable name="pending" select="count($context-tests[@result='skipped'])"/>
                                            <xsl:variable name="failed" select="count($context-tests[@result='failed'])"/>
                                            <xsl:variable name="total" select="count($context-tests)"/>
                                            <xsl:variable name="context-class" select="if ($failed) then 'failed' else if ($pending) then 'pending' else if ($passed) then 'successful' else ''"/>
                                            <tr class="{$context-class} label">
                                                <th class="context-label">
                                                    <xsl:value-of select="@label"/>
                                                </th>
                                                <th class="nobr">passed:<xsl:value-of select="$passed"/> / pending:<xsl:value-of select="$pending"/> / failed:<xsl:value-of select="$failed"/> / errors:0 / total:<xsl:value-of select="$total"/></th>
                                            </tr>
                                            <xsl:if test="$context-class='failed'">
                                                <tr class="was">
                                                    <td colspan="2">Was:</td>
                                                </tr>
                                                <xsl:variable name="context-documents" select="$scenario-description/x:scenario/x:context[@id=$id]/x:document"/>
                                                <xsl:choose>
                                                    <xsl:when test="count($context-documents)=0">
                                                        <tr class="was">
                                                            <td colspan="2">
                                                                <pre><code>(empty sequence)</code></pre>
                                                            </td>
                                                        </tr>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <tr class="was">
                                                            <td colspan="2">
                                                                <pre><code><xsl:copy-of select="node()"/></code></pre>
                                                            </td>
                                                        </tr>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:if>

                                            <!-- for each step scenario context test -->
                                            <xsl:for-each select="$context-tests">
                                                <xsl:variable name="test-class" select="if (@result='failed') then 'failed' else if (@result='skipped') then 'pending' else if (@result='passed') then 'successful' else ''"/>
                                                <xsl:variable name="test-result" select="if (@result='failed') then 'Failed' else if (@result='skipped') then 'Pending' else if (@result='passed') then 'Success' else '[Unknown]'"/>
                                                <tr class="{$test-class} label">
                                                    <td class="test-label">
                                                        <xsl:value-of select="@label"/>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="$test-result"/>
                                                    </td>
                                                </tr>
                                                <xsl:if test="$test-class='pending'">
                                                    <tr class="pending">
                                                        <td class="pending-label">
                                                            <xsl:value-of select="@pending"/>
                                                        </td>
                                                        <td> </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="$test-class='failed'">
                                                    <tr class="expected">
                                                        <td colspan="2">
                                                            <xsl:if test="x:was">
                                                                <div>Test: <pre><code><xsl:copy-of select="x:was/node()"/></code></pre></div>
                                                            </xsl:if>
                                                            <xsl:if test="x:expected">
                                                                <div>Equals: <pre><code><xsl:copy-of select="x:expected/node()"/></code></pre></div>
                                                            </xsl:if>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:for-each>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                        </div>
                    </xsl:for-each>

                    <!-- for each script with pending scenarios -->
                    <!--<xsl:for-each select="distinct-values($pending-descriptions/resolve-uri(@script,base-uri()))">-->
                    <xsl:for-each select="distinct-values($pending-descriptions/(x:step-declaration/*/@type,resolve-uri(@script,base-uri()))[1])">
                        <xsl:variable name="title" select="."/>
                        <xsl:variable name="pending-script-descriptions" select="$pending-descriptions[(x:step-declaration/*/@type,resolve-uri(@script,base-uri()))[1] = $title]"/>
                        <xsl:variable name="script-base" select="($pending-script-descriptions/resolve-uri(@script,base-uri()))[1]"/>
                        <div id="pending-{count($pending-script-descriptions[1]/preceding::x:description)}">
                            <h2 class="pending">Not calling: <a href="{$script-base}"><xsl:value-of select="$title"/></a><span class="scenario-totals">passed:0 / pending:<xsl:value-of select="count($pending-script-descriptions)"/> / failed:0 /
                                    errors:0 / total:<xsl:value-of select="count($pending-script-descriptions)"/></span></h2>
                            <table class="xspec">
                                <col width="80%"/>
                                <col width="20%"/>
                                <tbody>
                                    <!-- for each pending scenario for the current script -->
                                    <xsl:for-each select="$pending-script-descriptions">
                                        <tr class="pending label">
                                            <th class="scenario-label">
                                                <xsl:value-of select="x:scenario/@label"/>
                                            </th>
                                            <th class="nobr">passed:0 / pending:1 / failed:0 / errors:0 / total:1</th>
                                        </tr>
                                        <tr class="pending">
                                            <td>
                                                <xsl:value-of select="x:scenario/@pending"/>
                                            </td>
                                            <td>Pending</td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                        </div>
                    </xsl:for-each>

                    <xsl:if test="$log">
                        <h2>Execution log</h2>
                        <table>
                            <thead>
                                <tr>
                                    <th>Time</th>
                                    <th>Severity</th>
                                    <th>Message</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select="$log/c:line">
                                    <tr
                                        style="{if (@severity='DEBUG') then 'color:#696969;' else if (@severity='INFO') then '' else if (@severity='WARN') then 'background-color:#FFD700;' else if (@severity='ERROR') then 'background-color:#FF6347;' else ''}">
                                        <td>
                                            <xsl:variable name="t" select="replace(string(xs:dateTime(@time)-xs:dateTime($log/c:line[1]/@time)),'[^\d\.]','')"/>
                                            <xsl:variable name="t" select="tokenize($t,'\.')"/>
                                            <xsl:variable name="t" select="if (count($t)=1) then concat($t,'.000') else concat($t[1],'.',$t[2], string-join(for $pad in (string-length($t[2]) to 2) return '0', ''))"/>
                                            <xsl:value-of select="$t"/>
                                        </td>
                                        <td style="padding-left:0%;">
                                            <xsl:value-of select="@severity"/>
                                        </td>
                                        <td>
                                            <code>
                                                <pre><xsl:value-of select="./text()"/></pre>
                                            </code>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table>
                    </xsl:if>

                    <!--<script src="https://google-code-prettify.googlecode.com/svn/loader/run_prettify.js?autoload=true&amp;lang=xml">;</script>-->
                    <link rel="stylesheet" href="http://yandex.st/highlightjs/7.3/styles/default.min.css"/>
                    <script type="text/javascript" src="http://yandex.st/highlightjs/7.3/highlight.min.js" xml:space="preserve"> </script>
                    <script type="text/javascript">hljs.initHighlightingOnLoad();</script>
                </xsl:copy>
            </xsl:for-each>

        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
