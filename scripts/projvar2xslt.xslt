<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:    	projvar2xslt.xslt
    # Purpose:		Generate a XSLT that takes the project.txt file and make var in there into param. Also includes list.tsv and keyvalue.tsv as includes in project.xslt 
    # Part of: 	Xrunner - 
    # Author:   	Ian McQuay <ian_mcquay.org>
    # Created:  	2018-03-01
    # Copyright:  (c) 2018 SIL International
    # Licence:  	<MIT>
    ################################################################-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions">
    <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
    <xsl:output method="text" encoding="utf-8" name="cmd"/>
    <xsl:include href="inc-file2uri.xslt"/>
    <xsl:include href="inc-lookup.xslt"/>
    <xsl:include href="xrun.xslt"/>
    <xsl:param name="projectpath"/>
    <!-- <xsl:param name="unittest"/> -->
    <xsl:param name="USERPROFILE"/>
    <xsl:variable name="projectsource" select="concat($projectpath,'\project.txt')"/>
    <xsl:variable name="projecttask" select="f:file2lines($projectsource)"/>
    <xsl:variable name="projecttext" select="f:file2text($projectsource)"/>
    <xsl:variable name="section" select="tokenize($projecttext,'\[')"/>
    <xsl:variable name="project2source" select="concat($projectpath,'\project2.txt')"/>
    <xsl:variable name="project2task" select="f:file2lines($project2source)"/>
    <xsl:variable name="project2text" select="f:file2text($project2source)"/>
    <xsl:variable name="section2" select="tokenize($project2text,'\[')"/>
    <xsl:variable name="cd" select="substring-before($projectpath,'\data\')"/>
    <xsl:variable name="varparser" select="'^([^;]+);([^ ]+)[ \t]+([^ \t]+)[ \t]+(.+)'"/>
    <xsl:variable name="projectcmd" select="f:file2uri(concat($projectpath,'\tmp\project.cmd'))"/>
    <xsl:variable name="taskgroupprefix" select="''"/>
    <xsl:variable name="lists" select="'_semicolon-list|_list|_underscore-list|_equal-list|_file-list'"/>
    <xsl:variable name="list-separator-kv_list" select="'semicolon-list=;|list= |underscore-list=_|tilde-list=~|equal-list=|file-list=&#10;'"/>
    <xsl:variable name="list-separator-kv" select="tokenize($list-separator-kv_list,'\|')"/>
    <!-- <xsl:variable name="nonunique" select="tokenize('t xt ut b button label com',' ')"/> -->
    <!--<xsl:variable name="var" select="tokenize('var xvar',' ')"/>
      <xsl:variable name="button-or-label" select="tokenize('button label',' ')"/>

      <xsl:variable name="unittestlabel" select="tokenize('ut utt',' ')"/>
      <xsl:variable name="nontasksection" select="tokenize('variables project proj',' ')"/>
      <xsl:variable name="tasklabel" select="tokenize('t',' ')"/>
      <xsl:variable name="batchsection" select="'variables project proj'"/>
        -->
    <xsl:variable name="sq">
        <xsl:text>'</xsl:text>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:element name="xsl:stylesheet">
            <xsl:attribute name="version">
                <xsl:text>2.0</xsl:text>
            </xsl:attribute>
            <xsl:namespace name="f" select="'myfunctions'"/>
            <xsl:attribute name="exclude-result-prefixes">
                <xsl:text>f</xsl:text>
            </xsl:attribute>
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
            <xsl:for-each select="$projecttask">
                <!-- handle each line of the file with = sign in it -->
                <xsl:if test="matches(.,'=')">
                    <xsl:call-template name="parseline">
                        <xsl:with-param name="line" select="."/>
                        <xsl:with-param name="curpos" select="position()"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
            <xsl:call-template name="listhandling">
                <xsl:with-param name="listsource" select="'keyvalue.tsv'"/>
            </xsl:call-template>
            <xsl:call-template name="listhandling">
                <xsl:with-param name="listsource" select="'lists.tsv'"/>
            </xsl:call-template>
            <!-- <xsl:if test="unparsed-text-available(f:file2uri($project2source))">
                        <xsl:for-each select="$project2task"> -->
            <!-- handle each line of the file with = sign in it -->
            <!-- <xsl:if test="matches(.,'=')">
                                    <xsl:call-template name="parseline">
                                          <xsl:with-param name="line" select="."/>
                                          <xsl:with-param name="curpos" select="position()"/>
                                    </xsl:call-template>
                              </xsl:if>
                        </xsl:for-each>
                  </xsl:if> -->
        </xsl:element>
        <!-- <xsl:call-template name="projectcmd"/> -->
        <!-- <xsl:call-template name="taskgroup"/> -->
        <!-- <xsl:call-template name="include"/> -->
    </xsl:template>
    <xsl:template name="parseline">
        <xsl:param name="line"/>
        <xsl:param name="curpos"/>
        <!-- parse into name and data -->
        <xsl:variable name="varname" select="tokenize($line,'=')[1]"/>
        <xsl:variable name="vardata" select="substring-after($line,'=')"/>
        <xsl:choose>
            <xsl:when test="matches($line,'^#')"/>
            <!-- when a task t= then ignore -->
            <xsl:when test="$varname = $nonunique"/>
            <!-- when a button or label ignore -->
            <xsl:when test="$varname = $button-or-label"/>
            <!-- <xsl:when test="matches($varname,'^\[.*$')"> -->
            <xsl:otherwise>
                <xsl:text>&#10;</xsl:text>
                <xsl:call-template name="writeparam">
                    <xsl:with-param name="varname" select="$varname"/>
                    <xsl:with-param name="iscommand">
                        <xsl:choose>
                            <xsl:when test="matches($vardata,'%[\w\d\-_]*%')">
                                <xsl:text>true</xsl:text>
                            </xsl:when>
                            <xsl:when test="matches($vardata,'%[\w\d\-_]+[:\w\d=~,]*%')">
                                <xsl:text></xsl:text>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="vardata">
                        <xsl:value-of select="f:handlevar($vardata)"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="writeparam">
        <xsl:param name="varname"/>
        <xsl:param name="vardata"/>
        <xsl:param name="iscommand"/>
        <xsl:element name="xsl:param">
            <xsl:attribute name="name">
                <xsl:value-of select="$varname"/>
            </xsl:attribute>
            <xsl:attribute name="select">
                <xsl:if test="string-length($iscommand) = 0">
                    <xsl:text>'</xsl:text>
                </xsl:if>
                <xsl:value-of select="$vardata"/>
                <xsl:if test="string-length($iscommand) = 0">
                    <xsl:text>'</xsl:text>
                </xsl:if>
            </xsl:attribute>
        </xsl:element>
        <xsl:if test="matches($varname,'_list$')">
            <!-- space (\s+) delimited list -->
            <xsl:element name="xsl:variable">
                <xsl:attribute name="name">
                    <xsl:value-of select="replace($varname,'_list','')"/>
                </xsl:attribute>
                <xsl:attribute name="select">
                    <xsl:value-of select="concat('tokenize($',$varname,',',$sq,'\s+',$sq,')')"/>
                </xsl:attribute>
            </xsl:element>
            <xsl:if test="matches($vardata,'=')">
                <xsl:call-template name="write-key-var">
                    <xsl:with-param name="name" select="$varname"/>
                    <xsl:with-param name="separator" select="' '"/>
                </xsl:call-template>
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
        <xsl:if test="matches($varname,'_underscore-list$')">
            <!-- unerescore delimied list -->
            <xsl:element name="xsl:variable">
                <xsl:attribute name="name">
                    <xsl:value-of select="replace($varname,'_underscore-list','')"/>
                </xsl:attribute>
                <xsl:attribute name="select">
                    <xsl:value-of select="concat('tokenize($',$varname,',',$sq,'_',$sq,')')"/>
                </xsl:attribute>
            </xsl:element>
            <xsl:if test="matches($vardata,'=')">
                <xsl:call-template name="write-key-var">
                    <xsl:with-param name="name" select="$varname"/>
                    <xsl:with-param name="separator" select="'_'"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
        <xsl:if test="matches($varname,'_equal-list$')">
            <!-- equals delimited list -->
            <xsl:element name="xsl:variable">
                <xsl:attribute name="name">
                    <xsl:value-of select="replace($varname,'_equal-list','')"/>
                </xsl:attribute>
                <xsl:attribute name="select">
                    <xsl:value-of select="concat('tokenize($',$varname,',',$sq,'=',$sq,')')"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
        <xsl:if test="matches($varname,'_semicolon-list$')">
            <!-- semicolon delimited list -->
            <xsl:element name="xsl:variable">
                <xsl:attribute name="name">
                    <xsl:value-of select="replace($varname,'_semicolon-list','')"/>
                </xsl:attribute>
                <xsl:attribute name="select">
                    <xsl:value-of select="concat('tokenize($',$varname,',',$sq,';',$sq,')')"/>
                </xsl:attribute>
            </xsl:element>
            <!--  now test if there are = in the list and make a key list -->
            <xsl:if test="matches($vardata,'=')">
                <xsl:call-template name="write-key-var">
                    <xsl:with-param name="name" select="$varname"/>
                    <xsl:with-param name="separator" select="';'"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template name="write-key-var">
        <xsl:param name="name"/>
        <xsl:param name="separator"/>
        <xsl:element name="xsl:variable">
            <xsl:attribute name="name">
                <xsl:value-of select="replace($name,concat('(',$lists,')$'),'-key')"/>
            </xsl:attribute>
            <xsl:attribute name="select">
                <xsl:value-of select="concat('tokenize($',$name,',',$sq,'=[^',$separator,']*[',$separator,']?',$sq,')')"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
    <xsl:template name="listhandling">
        <xsl:param name="listsource"/>
        <!-- <xsl:param name="comment"/> -->
        <xsl:variable name="list" select="concat($projectpath,'\',$listsource)"/>
        <xsl:variable name="listtext" select="f:file2lines($list)"/>
        <!-- <xsl:variable name="listuri" select="f:file2uri($list)"/> -->
        <!-- <xsl:variable name="test" select="unparsed-text-available($listuri)"/> -->
        <xsl:if test="not(matches($listtext[1],'text not imported'))">
            <!-- get variable values from listsource tsv in the project folder -->
            <xsl:comment select="concat('  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ',$listsource,' variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ')"/>
            <xsl:variable name="lists-data">
                <xsl:for-each select="$listtext">
                    <xsl:variable name="cell" select="tokenize(.,'&#9;')"/>
                    <xsl:variable name="countfields" select="count(tokenize(.,'&#9;'))"/>
                    <xsl:choose>
                        <xsl:when test="matches(.,'^#')"/>
                        <!-- This is a coment line starting with a hash # -->
                        <xsl:when test="string-length($cell[1]) gt 0">
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
                <xsl:variable name="shortname" select="substring-before($varname,'_list')"/>
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
                <xsl:if test="matches($varname,'_.*list$')">
                    <!-- any delimited list like: _list, _semicolon-list, etc -->
                    <xsl:call-template name="arrayvar">
                        <xsl:with-param name="vardata" select="'='"/>
                        <xsl:with-param name="varname" select="$varname"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:if>
    </xsl:template>
    <xsl:template name="arrayvar">
        <xsl:param name="vardata"/>
        <xsl:param name="varname"/>
        <xsl:variable name="listtype" select="replace($varname,'^.+_([^_]+)$','$1')"/>
        <!-- <xsl:param name="listname"/> -->
        <xsl:variable name="listdelim" select="f:listdelim($listtype)"/>
        <xsl:variable name="varnewname" select="replace($varname,'^(.+)_[^_]+$','$1')"/>
        <!-- delimited list -->
        <xsl:choose>
            <xsl:when test="matches($varname,'_decimal$')">
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
            </xsl:when>
            <xsl:when test="matches($varname,'_file-list$')">
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
                <!-- Write key var for any _file-list -->
                <xsl:element name="xsl:variable">
                    <xsl:attribute name="name">
                        <xsl:value-of select="concat($varnewname,'-key')"/>
                    </xsl:attribute>
                    <xsl:attribute name="select">
                        <xsl:value-of select="concat('tokenize($',$varname,',',$sq,'=[^',$listdelim,']*[',$listdelim,']?',$sq,')')"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="xsl:variable">
                    <xsl:attribute name="name">
                        <xsl:value-of select="$varnewname"/>
                    </xsl:attribute>
                    <xsl:attribute name="select">
                        <xsl:value-of select="concat('tokenize($',$varname,',',$sq,$listdelim,$sq,')')"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
        <!--  now test if there are = in the list and make a key list -->
        <xsl:if test="matches($vardata,'=')">
            <xsl:if test="$listdelim ne '='">
                <xsl:call-template name="write-key-var">
                    <xsl:with-param name="name" select="$varname"/>
                    <xsl:with-param name="varnewname" select="$varnewname"/>
                    <xsl:with-param name="separator" select="$listdelim"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
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
                <!-- <xsl:if test="$onevar = 'onevar'"> -->
                <!-- This is incase there is only one variable passed to another variable, rare but possible -->
                <!-- <xsl:text>,''</xsl:text> -->
                <!-- </xsl:if> -->
                <xsl:text>,'')</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace($string,'&#34;','')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="f:listdelim">
        <xsl:param name="listtype"/>
        <xsl:value-of select="if($listtype = 'equal-list') then '=' else f:keyvalue($list-separator-kv,$listtype)"/>
    </xsl:function>
    <xsl:template name="scrap">
        <xsl:text> </xsl:text>
    </xsl:template>
</xsl:stylesheet>
