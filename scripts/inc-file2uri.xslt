<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:  	inc-file2uri.xslt
    # Purpose:	Include to get simplify Windows path\file into URI
    # Part of:  	Vimod Pub - http://projects.palaso.org/projects/vimod-pub
    # Author:  	Ian McQuay <ian_mcquay@sil.org>
    # Created:  	2015- -
    # Modified:	2023-12-14 file2uri stoped working 2 days ago. So reversed logic and added other whens. Also added encode to uri.
    # Copyright:	(c) 2015 SIL International
    # Licence:  	<LGPL>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions">
    <xsl:function name="f:file2uri">
        <xsl:param name="pathfile"/>
        <!-- 2023-12-14 Reversed logic (and added other when's that did not work in testing) but the default is absolute path, 
				Added encode-for-uri() after v1 stopped working 
				This actually encodes / as %2F and : as %3A but it works fine -->
        <xsl:variable name="baseuri" select="encode-for-uri(translate($pathfile,'\','/'))"/>
        <xsl:variable name="absoluteuri" select="concat('file:///',$baseuri)"/>
        <xsl:choose>
            <xsl:when test="not(substring($pathfile,2,1) = ':')">
                <!-- assumes that the path is relative -->
                <xsl:value-of select="$baseuri"/>
            </xsl:when>
            <xsl:when test="matches($pathfile,'^.:\\')">
                <xsl:value-of select="$absoluteuri"/>
            </xsl:when>
            <xsl:when test="contains($pathfile,':\')">
                <xsl:value-of select="$absoluteuri"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- matches drive:\path fromat -->
                <xsl:value-of select="$absoluteuri"/>
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
                <xsl:text>'text not imported, file not available'</xsl:text>
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
    <xsl:function name="f:file2uriabsolutepath">
        <xsl:param name="pathfile"/>
        <xsl:value-of select="concat('file:///',encode-for-uri(replace($pathfile,'\\','/')))"/>
    </xsl:function>
    <xsl:function name="f:file2uriv1">
        <xsl:param name="pathfile"/>
        <xsl:choose>
            <xsl:when test="substring($pathfile,2,2) = ':\'">
                <!-- matches drive:\path fromat 
						  but stopped working 2023-12-12 after 8 years of no issues -->
                <xsl:value-of select="concat('file:///',replace($pathfile,'\\','/'))"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- assumes that the path is relative -->
                <xsl:value-of select="replace($pathfile,'\\','/')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
