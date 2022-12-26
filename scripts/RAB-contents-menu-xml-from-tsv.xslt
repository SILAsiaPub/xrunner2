<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:   		contents-menu-xml-from-tsv.xslt
    # Purpose:		Create a SAB/RAB contents menu from a TSV.
    # Part of:		Vimod Pub - https://github.com/SILAsiaPub/vimod-pub
    # Author:		Ian McQuay <ian_mcquay@sil.org>
    # Created:		2017- -
    # Copyright:  (c) 2017 SIL International
    # Licence:		<MIT>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">
      <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
      <xsl:include href="project.xslt"/>
      <xsl:include href="inc-file2uri.xslt"/>
      <xsl:include href="inc-lookup.xslt"/>
      <!-- <xsl:variable name="line" select="f:file2lines($inputfile)"/> -->
      <xsl:template match="/*">
            <contents>
                  <title lang="{$titlelanguage}">
                        <xsl:value-of select="$title"/>
                  </title>
                  <feature name="show-titles" value="{$show-titles}"/>
                  <feature name="show-subtitles" value="{$show-subtitles}"/>
                  <feature name="show-references" value="{$show-references}"/>
                  <feature name="launch-action" value="{$launch-action}"/>
                  <contents-items>
                        <xsl:for-each select="$home-menu-title">
                              <xsl:variable name="pos" select="position()"/>
                              <xsl:call-template name="item">
                                    <xsl:with-param name="title" select="."/>
                                    <xsl:with-param name="subtitle" select="$home-menu-subtitle[number($pos)]"/>
                                    <xsl:with-param name="item-numb" select="$pos"/>
                                    <xsl:with-param name="link-type" select="'screen'"/>
                                    <xsl:with-param name="link-target" select="position() + 1"/>
                              </xsl:call-template>
                        </xsl:for-each>
                        <xsl:for-each select="$line">
                              <xsl:variable name="pos" select="position() + 100"/>
                              <xsl:variable name="cell" select="tokenize(.,'\t')"/>
                              <xsl:variable name="collection" select="tokenize($cell[number($collection-cell)],' ')"/>
                              <xsl:call-template name="item">
                                    <xsl:with-param name="title" select="concat($cell[number($arabic-ref-cell)],' - ',$cell[number($arabic-title-cell)])"/>
                                    <xsl:with-param name="subtitle" select="$cell[number($latin-title-cell)]"/>
                                    <xsl:with-param name="item-numb" select="$pos"/>
                                    <xsl:with-param name="link-type" select="'reference'"/>
                                    <xsl:with-param name="link-target" select="concat($cell[number($bk-ref-cell)],'.',$cell[number($cha-ref-cell)],'.',$cell[number($ver-ref-cell)])"/>
                                    <xsl:with-param name="version" select="$cell[number($collection-cell)]"/>
                                    <xsl:with-param name="layout-mode" select="if (string-length($collection[2]) gt 0) then 'two' else 'single'"/>
                              </xsl:call-template>
                        </xsl:for-each>
                  </contents-items>
                  <contents-screens>
                        <xsl:for-each select="$screen-name">
                              <xsl:variable name="pos" select="position()"/>
                              <xsl:comment select="$screen-group-by[number($pos)]"/>
                              <xsl:call-template name="listscreen">
                                    <xsl:with-param name="title" select="."/>
                                    <xsl:with-param name="group" select="$screen-group-by[number($pos)]"/>
                                    <xsl:with-param name="seq" select="$pos"/>
                              </xsl:call-template>
                        </xsl:for-each>
                  </contents-screens>
            </contents>
      </xsl:template>
      <xsl:template name="item">
            <xsl:param name="title"/>
            <xsl:param name="subtitle"/>
            <xsl:param name="item-numb"/>
            <xsl:param name="link-type"/>
            <xsl:param name="link-target"/>
            <xsl:param name="version"/>
            <xsl:param name="layout-mode"/>
            <xsl:variable name="ver" select="tokenize($version,' ')"/>
            <contents-item id="{$item-numb}">
                  <title lang="{$titlelanguage}">
                        <xsl:value-of select="$title"/>
                  </title>
                  <xsl:if test="string-length($subtitlelanguage) gt 0">
                        <subtitle lang="{$subtitlelanguage}">
                              <xsl:value-of select="$subtitle"/>
                        </subtitle>
                  </xsl:if>
                  <link type="{$link-type}" target="{$link-target}"/>
                  <xsl:if test="$link-type = 'reference'">
                        <layout mode="{$layout-mode}">
                              <xsl:for-each select="$ver">
                                    <layout-collection id="{.}"/>
                              </xsl:for-each>
                        </layout>
                  </xsl:if>
            </contents-item>
      </xsl:template>
      <xsl:template name="listscreen">
            <xsl:param name="title"/>
            <xsl:param name="group"/>
            <xsl:param name="seq"/>
            <!-- <xsl:variable name="thisele" select="$field[number($seq)]"/> -->
            <contents-screen id="{number($seq)}">
                  <title lang="{$titlelanguage}">
                        <xsl:value-of select="$title"/>
                  </title>
                  <items>
                        <xsl:choose>
                              <xsl:when test="number($seq) = 1">
                                    <xsl:for-each select="$screen-name[position() gt 1]">
                                          <item id="{position() + 1}"/>
                                    </xsl:for-each>
                              </xsl:when>
                              <xsl:otherwise>
                                    <xsl:for-each select="$line">
                                          <xsl:variable name="line-numb" select="position() + 100"/>
                                          <xsl:variable name="cell" select="tokenize(.,'\t')"/>
                                          <xsl:if test="matches($cell[1],$group)">
                                                <item id="{$line-numb}"/>
                                          </xsl:if>
                                    </xsl:for-each>
                              </xsl:otherwise>
                        </xsl:choose>
                  </items>
            </contents-screen>
      </xsl:template>
</xsl:stylesheet>
