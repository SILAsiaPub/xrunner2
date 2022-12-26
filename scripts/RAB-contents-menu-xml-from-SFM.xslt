<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:     RAB-make-contents-items.xslt
    # Purpose:	Take a Song file in SFM and generate a menu contents xml
    # Part of:      Vimod Pub - http://projects.palaso.org/projects/vimod-pub
    # Author:       Ian McQuay <ian_mcquay@sil.org>
    # Created:      2016-10-31
    # Copyright:    (c) 2016 SIL International
    # Licence:      <LGPL>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
      <xsl:include href="project.xslt"/>
      <xsl:variable name="tree" select="cGroup"/>
      <xsl:template match="/*">
            <contents>
                  <feature name="show-titles" value="true"/>
                  <feature name="show-subtitles" value="false"/>
                  <feature name="show-references" value="false"/>
                  <contents-items>
                        <!-- $home-menu is the menu items starting with the home menu -->
                        <xsl:for-each select="$home-menu">
                              <xsl:call-template name="submenu-item">
                                    <xsl:with-param name="title" select="."/>
                                    <xsl:with-param name="target" select="position()"/>
                              </xsl:call-template>
                        </xsl:for-each>
                        <xsl:call-template name="bulkitems"/>
                  </contents-items>
                  <contents-screens>
                        <contents-screen id="1">
                              <title lang="default">
                                    <xsl:value-of select="$home-menu[1]"/>
                              </title>
                              <items>
                                    <xsl:for-each select="$home-menu[position() gt 1]">
                                          <item id="{position() + 1}"/>
                                    </xsl:for-each>
                              </items>
                        </contents-screen>
                        <xsl:call-template name="listscreens"/>
                  </contents-screens>
            </contents>
      </xsl:template>
      <xsl:template match="*[local-name() = $page-group]" mode="items">
            <!-- What is the page-group defining -->
            <xsl:param name="seq"/>
            <xsl:variable name="thisfield" select="$field[number($seq)]"/>
            <xsl:if test="string-length(*[name() = $thisfield][1]) gt 0">
                  <contents-item id="{position() + 200 * number($seq)}">
                        <title lang="default">
                              <xsl:value-of select="replace(translate(*[name() = $thisfield][1],'()',''),'Tunu. ','')"/>
                              <xsl:text> - </xsl:text>
                              <xsl:choose>
                                    <xsl:when test="$thisfield = 'c'">
                                          <xsl:value-of select="s1[1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                          <xsl:value-of select="c[1]"/>
                                    </xsl:otherwise>
                              </xsl:choose>
                              <xsl:if test="c = $audio">
                                    <xsl:text> &#x2713;</xsl:text>
                              </xsl:if>
                        </title>
                        <link type="reference" target="Kanta2000.{position()}"/>
                  </contents-item>
            </xsl:if>
      </xsl:template>
      <xsl:template match="*[local-name() = $page-group]" mode="order">
            <xsl:param name="seq"/>
            <xsl:variable name="pos" select="count(preceding::cGroup) + 1 + 200 * number($seq)"/>
            <xsl:variable name="thisele" select="$field[number($seq)]"/>
            <xsl:if test="*[name() = $thisele][1] != ''">
                  <item id="{$pos}"/>
            </xsl:if>
      </xsl:template>
      <xsl:template name="submenu-item">
            <xsl:param name="title"/>
            <xsl:param name="target"/>
            <xsl:variable name="id" select="$target"/>
            <contents-item id="{$id}">
                  <title lang="default">
                        <xsl:value-of select="$title"/>
                  </title>
                  <link type="screen" target="{$target}"/>
            </contents-item>
      </xsl:template>
      <xsl:template name="bulkitems">
            <xsl:if test="$field[1] != ''">
                  <xsl:apply-templates select="*[local-name() = $page-group]" mode="items">
                        <xsl:with-param name="seq" select="1"/>
                  </xsl:apply-templates>
            </xsl:if>
            <xsl:if test="$field[2] != ''">
                  <xsl:apply-templates select="*[local-name() = $page-group]" mode="items">
                        <xsl:with-param name="seq" select="2"/>
                  </xsl:apply-templates>
            </xsl:if>
            <xsl:if test="$field[3] != ''">
                  <xsl:apply-templates select="*[local-name() = $page-group]" mode="items">
                        <xsl:with-param name="seq" select="3"/>
                  </xsl:apply-templates>
            </xsl:if>
            <xsl:if test="$field[4] != ''">
                  <xsl:apply-templates select="*[local-name() = $page-group]" mode="items">
                        <xsl:with-param name="seq" select="4"/>
                  </xsl:apply-templates>
            </xsl:if>
            <xsl:if test="$field[5] != ''">
                  <xsl:apply-templates select="*[local-name() = $page-group]" mode="items">
                        <xsl:with-param name="seq" select="5"/>
                  </xsl:apply-templates>
            </xsl:if>
            <xsl:if test="$field[6] != ''">
                  <xsl:apply-templates select="*[local-name() = $page-group]" mode="items">
                        <xsl:with-param name="seq" select="6"/>
                  </xsl:apply-templates>
            </xsl:if>
            <xsl:if test="$field[7] != ''">
                  <xsl:apply-templates select="*[local-name() = $page-group]" mode="items">
                        <xsl:with-param name="seq" select="7"/>
                  </xsl:apply-templates>
            </xsl:if>
            <xsl:if test="$field[8] != ''">
                  <xsl:apply-templates select="*[local-name() = $page-group]" mode="items">
                        <xsl:with-param name="seq" select="8"/>
                  </xsl:apply-templates>
            </xsl:if>
            <xsl:if test="$field[9] != ''">
                  <xsl:apply-templates select="*[local-name() = $page-group]" mode="items">
                        <xsl:with-param name="seq" select="9"/>
                  </xsl:apply-templates>
            </xsl:if>
            <xsl:if test="$field[10] != ''">
                  <xsl:apply-templates select="*[local-name() = $page-group]" mode="items">
                        <xsl:with-param name="seq" select="10"/>
                  </xsl:apply-templates>
            </xsl:if>
      </xsl:template>
      <xsl:template name="listscreens">
            <xsl:if test="$field[1] != ''">
                  <xsl:call-template name="listscreen">
                        <xsl:with-param name="seq" select="1"/>
                  </xsl:call-template>
            </xsl:if>
            <xsl:if test="$field[2] != ''">
                  <xsl:call-template name="listscreen">
                        <xsl:with-param name="seq" select="2"/>
                  </xsl:call-template>
            </xsl:if>
            <xsl:if test="$field[3] != ''">
                  <xsl:call-template name="listscreen">
                        <xsl:with-param name="seq" select="3"/>
                  </xsl:call-template>
            </xsl:if>
            <xsl:if test="$field[4] != ''">
                  <xsl:call-template name="listscreen">
                        <xsl:with-param name="seq" select="4"/>
                  </xsl:call-template>
            </xsl:if>
            <xsl:if test="$field[5] != ''">
                  <xsl:call-template name="listscreen">
                        <xsl:with-param name="seq" select="5"/>
                  </xsl:call-template>
            </xsl:if>
            <xsl:if test="$field[6] != ''">
                  <xsl:call-template name="listscreen">
                        <xsl:with-param name="seq" select="6"/>
                  </xsl:call-template>
            </xsl:if>
            <xsl:if test="$field[7] != ''">
                  <xsl:call-template name="listscreen">
                        <xsl:with-param name="seq" select="7"/>
                  </xsl:call-template>
            </xsl:if>
            <xsl:if test="$field[8] != ''">
                  <xsl:call-template name="listscreen">
                        <xsl:with-param name="seq" select="8"/>
                  </xsl:call-template>
            </xsl:if>
            <xsl:if test="$field[9] != ''">
                  <xsl:call-template name="listscreen">
                        <xsl:with-param name="seq" select="9"/>
                  </xsl:call-template>
            </xsl:if>
            <xsl:if test="$field[10] != ''">
                  <xsl:call-template name="listscreen">
                        <xsl:with-param name="seq" select="10"/>
                  </xsl:call-template>
            </xsl:if>
      </xsl:template>
      <xsl:template name="listscreen">
            <xsl:param name="seq"/>
            <xsl:variable name="thisele" select="$field[number($seq)]"/>
            <contents-screen id="{number($seq) + 1}">
                  <title lang="default">
                        <xsl:value-of select="$home-menu[number($seq) + 1]"/>
                  </title>
                  <items>
                        <xsl:apply-templates select="*[local-name() = $page-group]" mode="order">
                              <xsl:sort select="replace(replace(*[name() = $thisele][1],'Tunu. ',''),'\((.+)\)','$1')" data-type="{if($thisele = 'c') then 'number' else 'text'}"/>
                              <xsl:with-param name="seq" select="$seq"/>
                        </xsl:apply-templates >
                  </items>
            </contents-screen>
      </xsl:template>
</xsl:stylesheet>
