<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:     	projectvariables-v3.xslt
    # Purpose:  	convert proj-var.xml into project.xslt, also brings in lists.tsv and keyvalue.tsv.
    # Part of:  	Xrunner - https://github.com/SILAsiaPub/xrunner
    # Author:   	Ian McQuay <ian_mcquay@sil.org>
    # Created:  	2022-12-25
    # Copyright:	(c) 2022 SIL International
    # Licence:  	<MIT>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">
    <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" name="xml"/>
    <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
    <xsl:include href="xrun.xslt"/>
    <xsl:param name="projectpath"/>
    <xsl:param name="USERPROFILE"/>
    <xsl:variable name="spacer" select="'  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ '"/>
    <xsl:variable name="listimporterror" select="f:file2uri(concat($projectpath,'/list-import-error.xml'))"/>
    <xsl:variable name="listsdoc" select="f:file2uri(concat($projectpath,'\tmp\lists.xml'))"/>
    <xsl:variable name="keyvaluedoc" select="f:file2uri(concat($projectpath,'\tmp\keyvalue.xml'))"/>
    <xsl:variable name="list-separator-kv_list" select="'semicolon-list=;|list= |underscore-list=_|tilde-list=~|equal-list=|file-list=&#10;'"/>
    <xsl:variable name="list-separator-kv" select="tokenize($list-separator-kv_list,'\|')"/>
    <xsl:variable name="sq">
        <xsl:text>'</xsl:text>
    </xsl:variable>
    <xsl:template match="/*">
        <xsl:element name="xsl:stylesheet">
            <xsl:attribute name="version">
                <xsl:text>2.0</xsl:text>
            </xsl:attribute>
            <xsl:namespace name="f" select="'myfunctions'"/>
            <xsl:attribute name="exclude-result-prefixes">
                <xsl:text>f</xsl:text>
            </xsl:attribute>
            <xsl:comment select="' Static variables '"/>
            <xsl:call-template name="static"/>
            <!-- <xsl:comment select="$projectpath"/>  -->
            <xsl:comment select="concat('  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ','project.txt',' variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ')"/>
            <xsl:apply-templates select="var"/>
            <xsl:call-template name="listhandle">
                <xsl:with-param name="listsource" select="$listsdoc"/>
                <xsl:with-param name="name" select="'lists.xml'"/>
            </xsl:call-template>
            <xsl:call-template name="listhandle">
                <xsl:with-param name="listsource" select="$keyvaluedoc"/>
                <xsl:with-param name="name" select="'keyvalue.xml'"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>
    <xsl:template match="var">
        <xsl:sequence select="f:writeparm(concat(@name,'=',text()))"/>
    </xsl:template>
    <xsl:template name="listhandle">
        <xsl:param name="listsource"/>
        <xsl:param name="name"/>
        <xsl:variable name="list" select="doc($listsource)"/>
        <xsl:choose>
            <xsl:when test="doc-available($listsource)">
                <xsl:comment select="concat($spacer,$name,$spacer)"/>
                <xsl:for-each-group select="$list//var" group-by="@name">
                    <xsl:variable name="varname" select="current-grouping-key()"/>
                    <xsl:variable name="shortname" select="tokenize($varname,'_')[1]"/>
                    <xsl:variable name="listtype" select="tokenize($varname,'_')[last()]"/>
                    <xsl:variable name="listdelim" select="f:listdelim($listtype)"/>
                    <xsl:element name="xsl:param">
                        <xsl:attribute name="name">
                            <xsl:value-of select="$varname"/>
                        </xsl:attribute>
                        <xsl:attribute name="select">
                            <xsl:text>'</xsl:text>
                            <xsl:for-each select="current-group()">
                                <xsl:variable name="pos" select="position()"/>
                                <xsl:if test="@key">
                                    <xsl:value-of select="./@key"/>
                                    <xsl:text>=</xsl:text>
                                </xsl:if>
                                <xsl:value-of select="./@value"/>
                                <xsl:value-of select="if ($pos ne last()) then $listdelim else ''"/>
                                <!-- <xsl:text> </xsl:text> -->
                            </xsl:for-each>
                            <xsl:text>'</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:if test="matches($varname,'[-_]list$') and not(matches($varname,'_file-list$'))">
                        <!-- <xsl:variable name="list" select="tokenize($varname,'_')"/> -->
                        <xsl:variable name="separator" select="f:keyvalue($list-separator-kv,$list[2])"/>
                        <xsl:sequence select="f:toklist($varname,$listdelim)"/>
                        <xsl:if test="@key">
                            <xsl:sequence select="f:var-key($varname,$listdelim)"/>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment select="concat($spacer,$name,' not available',$spacer)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="listhandling">
        <xsl:param name="listsource"/>
        <!-- <xsl:param name="comment"/> -->
        <xsl:variable name="list" select="concat($projectpath,'\',$listsource)"/>
        <xsl:variable name="listtext" select="f:file2lines($list)"/>
        <xsl:variable name="notimported" select="matches($listtext[1],'text not imported')"/>
        <xsl:variable name="importreport" select="if ($notimported) then 'not imported ' else 'imported '"/>
        <xsl:comment select="concat('  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ',$listsource,' variables ',$importreport,'~~~~~',if ($notimported) then $listtext[1] else '','~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ')"/>
        <xsl:if test="$notimported">
            <xsl:result-document href="{$listimporterror}" format="xml">
                <xsl:element name="report">
                    <xsl:value-of select="concat($listsource,' variables ',$importreport)"/>
                </xsl:element>
            </xsl:result-document>
        </xsl:if>
        <xsl:if test="not($notimported)">
            <!-- get variable values from listsource tsv in the project folder -->
            <xsl:variable name="lists-data">
                <xsl:for-each select="$listtext">
                    <xsl:variable name="cell" select="tokenize(.,'&#9;')"/>
                    <xsl:variable name="countfields" select="count(tokenize(.,'&#9;'))"/>
                    <xsl:choose>
                        <xsl:when test="matches(.,'^#')"/>
                        <!-- This is a coment line starting with a hash # -->
                        <xsl:when test="string-length($cell[1]) gt 0">.
                            <xsl:element name="row">
                                <xsl:attribute name="vname">
                                    <xsl:value-of select="$cell[1]"/>
                                </xsl:attribute>
                                <xsl:attribute name="{if (matches($listsource,'keyvalue')) then 'key' else 'value'}">
                                    <xsl:value-of select="$cell[2]"/>
                                </xsl:attribute>
                                <xsl:if test="matches($listsource,'keyvalue')">
                                    <xsl:attribute name="value">
                                        <xsl:value-of select="$cell[3]"/>
                                    </xsl:attribute>
                                </xsl:if>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                                 <!-- this should be an empty line or mal formed line with no variable name before the tab-->
                         </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:for-each-group select="$lists-data/row" group-by="@vname">
                <xsl:variable name="varname" select="current-grouping-key()"/>
                <xsl:variable name="shortname" select="tokenize($varname,'_')[1]"/>
                <xsl:variable name="listtype" select="tokenize($varname,'_')[last()]"/>
                <xsl:variable name="listdelim" select="f:listdelim($listtype)"/>
                <xsl:element name="xsl:param">
                    <xsl:attribute name="name">
                        <xsl:value-of select="$varname"/>
                    </xsl:attribute>
                    <xsl:attribute name="select">
                        <xsl:text>'</xsl:text>
                        <xsl:for-each select="current-group()">
                            <xsl:variable name="pos" select="position()"/>
                            <xsl:if test="@key">
                                <xsl:value-of select="./@key"/>
                                <xsl:text>=</xsl:text>
                            </xsl:if>
                            <xsl:value-of select="./@value"/>
                            <xsl:value-of select="if ($pos ne last()) then $listdelim else ''"/>
                            <!-- <xsl:text> </xsl:text> -->
                        </xsl:for-each>
                        <xsl:text>'</xsl:text>
                    </xsl:attribute>
                </xsl:element>
                <xsl:if test="matches($varname,'[-_]list$') and not(matches($varname,'_file-list$'))">
                    <!-- <xsl:variable name="list" select="tokenize($varname,'_')"/> -->
                    <xsl:variable name="separator" select="f:keyvalue($list-separator-kv,$list[2])"/>
                    <xsl:sequence select="f:toklist($varname,$listdelim)"/>
                    <xsl:if test="@key">
                        <xsl:sequence select="f:var-key($varname,$listdelim)"/>
                    </xsl:if>
                </xsl:if>
                <!-- <xsl:if test="matches($varname,'_.*list$')">
                 
                    <xsl:sequence select="f:writeparam()"/>
                    <xsl:call-template name="arrayvar">
                        <xsl:with-param name="vardata" select="'='"/>
                        <xsl:with-param name="varname" select="$varname"/>
                    </xsl:call-template>
                </xsl:if> -->
            </xsl:for-each-group>
        </xsl:if>
    </xsl:template>
    <xsl:function name="f:writeparm">
        <xsl:param name="line"/>
        <xsl:variable name="varname" select="tokenize(normalize-space($line),'=')[1]"/>
        <xsl:variable name="vardata" select="substring-after($line,'=')"/>
        <xsl:variable name="isnottext" select="if (matches($vardata,'%[\w\d\-_]*%')) then 1 else 0"/>
        <xsl:element name="xsl:param">
            <xsl:attribute name="name">
                <xsl:value-of select="$varname"/>
            </xsl:attribute>
            <xsl:attribute name="select">
                <xsl:if test="$isnottext = 0">
                    <xsl:text>'</xsl:text>
                </xsl:if>
                <xsl:value-of select="f:handlevar($vardata)"/>
                <xsl:if test="$isnottext = 0">
                    <xsl:text>'</xsl:text>
                </xsl:if>
            </xsl:attribute>
        </xsl:element>
        <!-- <xsl:variable name="islist" select="matches($varname,'list$')"/> -->
        <xsl:if test="matches($varname,'[-_]list$') and not(matches($varname,'_file-list$'))">
            <xsl:variable name="list" select="tokenize($varname,'_')"/>
            <xsl:variable name="separator" select="f:keyvalue($list-separator-kv,$list[2])"/>
            <xsl:sequence select="f:toklist($varname,$separator)"/>
            <xsl:if test="matches($vardata,'=')">
                <xsl:sequence select="f:var-key($varname,$separator)"/>
            </xsl:if>
        </xsl:if>
        <xsl:if test="matches($varname,'_file-list$')">
            <!-- adds a tokenized list from a file. Good for when the list is too long for batch line -->
            <xsl:element name="xsl:variable">
                <xsl:attribute name="name">
                    <xsl:value-of select="replace($varname,'_file-list','')"/>
                </xsl:attribute>
                <xsl:attribute name="select">
                    <xsl:text>f:file2lines($</xsl:text>
                    <xsl:value-of select="$varname"/>
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    <xsl:function name="f:var-key">
        <xsl:param name="name"/>
        <xsl:param name="separator"/>
        <xsl:element name="xsl:variable">
            <xsl:attribute name="name">
                <xsl:value-of select="concat(tokenize($name,'_')[1],'-key')"/>
            </xsl:attribute>
            <xsl:attribute name="select">
                <xsl:value-of select="concat('tokenize($',$name,',',$sq,'=[^',$separator,']*[',$separator,']?',$sq,')')"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:function>
    <xsl:template name="static">
        <xsl:element name="xsl:include">
            <xsl:attribute name="href">
                <xsl:text>inc-file2uri.xslt</xsl:text>
            </xsl:attribute>
        </xsl:element>
        <xsl:element name="xsl:include">
            <xsl:attribute name="href">
                <xsl:text>inc-lookup.xslt</xsl:text>
            </xsl:attribute>
        </xsl:element>
        <xsl:element name="xsl:param">
            <xsl:attribute name="name">
                <xsl:text>USERPROFILE</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="select">
                <xsl:text>'</xsl:text>
                <xsl:value-of select="$USERPROFILE"/>
                <xsl:text>'</xsl:text>
            </xsl:attribute>
        </xsl:element>
        <xsl:element name="xsl:variable">
            <!-- Define single quote -->
            <xsl:attribute name="name">
                <xsl:text>projectpath</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="select">
                <xsl:text>'</xsl:text>
                <xsl:value-of select="$projectpath"/>
                <xsl:text>'</xsl:text>
            </xsl:attribute>
        </xsl:element>
        <xsl:element name="xsl:variable">
            <!-- Define single quote -->
            <xsl:attribute name="name">
                <xsl:text>sq</xsl:text>
            </xsl:attribute>
            <xsl:text>'</xsl:text>
        </xsl:element>
        <xsl:element name="xsl:variable">
            <!-- Define double quote -->
            <xsl:attribute name="name">
                <xsl:text>dq</xsl:text>
            </xsl:attribute>
            <xsl:text>"</xsl:text>
        </xsl:element>
        <xsl:element name="xsl:variable">
            <xsl:attribute name="name">
                <xsl:text>true</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="select">
                <xsl:text>tokenize('true yes on 1','\s+')</xsl:text>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
    <xsl:function name="f:file2uri">
        <xsl:param name="pathfile"/>
        <xsl:choose>
            <xsl:when test="substring($pathfile,2,2) = ':\'">
                <!-- matches drive:\path fromat -->
                <xsl:value-of select="concat('file:///',replace($pathfile,'\\','/'))"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- assumes that the path is relative -->
                <xsl:value-of select="replace($pathfile,'\\','/')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="f:file2text">
        <xsl:param name="pathfile"/>
        <xsl:variable name="pathfileuri" select="f:file2uri($pathfile)"/>
        <xsl:choose>
            <xsl:when test="unparsed-text-available($pathfileuri)">
                <xsl:value-of select="unparsed-text($pathfileuri)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="f:keyvalue">
        <!-- generic lookup function with 6 parameters
				uses existing array as input not a string-->
        <xsl:param name="array"/>
        <xsl:param name="string"/>
        <!-- <xsl:param name="field-separator" /> -->
        <xsl:variable name="field-separator" select="'='"/>
        <!-- <xsl:param name="find-column"/> -->
        <xsl:variable name="find-column" select="1"/>
        <!-- <xsl:param name="return-column"/> -->
        <xsl:variable name="return-column" select="2"/>
        <!-- <xsl:param name="default"/> -->
        <xsl:variable name="searchvalues_list">
            <xsl:for-each select="$array">
                <xsl:variable name="subarray" select="tokenize(.,$field-separator)"/>
                <xsl:value-of select="concat($subarray[$find-column],$field-separator)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="searchvalues" select="tokenize($searchvalues_list,$field-separator)"/>
        <xsl:choose>
            <!-- make sure the item is in the set of data being searched, if not then return error message in output with string of un matched item -->
            <xsl:when test="$searchvalues = string($string)">
                <xsl:for-each select="$array">
                    <!-- loop through the known data to find a match -->
                    <xsl:variable name="subarray" select="tokenize(.,$field-separator)"/>
                    <xsl:if test="$subarray[number($find-column)] = $string">
                        <xsl:value-of select="$subarray[number($return-column)]"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="f:handlevar">
        <xsl:param name="string"/>
        <!-- parse the data part for variables -->
        <xsl:choose>
            <xsl:when test="matches($string,'^&#34;?%[\w\d\-_]+:.*=.*%&#34;?$')">
                <!-- Matches batch variable with a find and replace structure %name:find=replace% -->
                <xsl:variable name="re" select="'^&#34;?%([\w\d\-_]+):(.*)=(.*)%&#34;?$'"/>
                <xsl:text>replace(</xsl:text>
                <xsl:value-of select="replace($string,$re,'\$$1')"/>
                <xsl:text>,'</xsl:text>
                <xsl:value-of select="replace($string,$re,'$2')"/>
                <xsl:text>','</xsl:text>
                <xsl:value-of select="replace($string,$re,'$3')"/>
                <xsl:text>')</xsl:text>
            </xsl:when>
            <xsl:when test="matches($string,'%[\w\d\-_]+%')">
                <!-- variable % name1-more% -->
                <xsl:text>concat(</xsl:text>
                <xsl:analyze-string select="replace($string,'&#34;','')" regex="%[\w\d\-_]+%">
                    <!-- match variable string -->
                    <xsl:matching-substring>
                        <xsl:if test="position() gt 1">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                        <xsl:text>$</xsl:text>
                        <xsl:value-of select="replace(.,'%','')"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:choose>
                            <xsl:when test="position() = 1">
                                <xsl:text>'</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,'</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="."/>
                        <xsl:text>'</xsl:text>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
                <xsl:text>,'')</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace($string,'&#34;','')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="f:file2lines">
        <xsl:param name="pathfile"/>
        <xsl:variable name="pathfileuri" select="f:file2uri($pathfile)"/>
        <xsl:choose>
            <xsl:when test="unparsed-text-available($pathfileuri)">
                <xsl:variable name="text" select="unparsed-text($pathfileuri)"/>
                <xsl:variable name="lines" select="tokenize($text,'\r?\n')"/>
                <xsl:sequence select="$lines"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>'text not imported, file not available'</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="f:listdelim">
        <xsl:param name="listtype"/>
        <xsl:value-of select="if($listtype = 'equal-list') then '=' else f:keyvalue($list-separator-kv,$listtype)"/>
    </xsl:function>
    <xsl:function name="f:toklist">
        <xsl:param name="varname"/>
        <xsl:param name="separator"/>
        <xsl:element name="xsl:variable">
            <xsl:attribute name="name">
                <xsl:value-of select="tokenize($varname,'_')[1]"/>
            </xsl:attribute>
            <xsl:attribute name="select">
                <xsl:value-of select="concat('tokenize($',$varname,',',$sq,$separator,$sq,')')"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:function>
</xsl:stylesheet>
