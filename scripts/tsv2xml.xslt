<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">
      <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes"/>
      <!-- Incorporated this into css-class2attribset.xslt
  -->
      <xsl:include href="inc-file2uri.xslt"/>
      <xsl:include href="project.xslt"/>
      <xsl:variable name="sourcetexturi" select="f:file2uri($sourcetextpath)"/>
      <xsl:template match="/">
            <xsl:choose>
                  <xsl:when test="unparsed-text-available($sourcetexturi)">
                        <xsl:variable name="tsv" select="unparsed-text($sourcetexturi)"/>
                        <xsl:variable name="line" select="tokenize($tsv, '\n')"/>
                        <xsl:variable name="elename" select="tokenize(translate($line[1],' .&quot;',''),'&#9;')"/>
                        <root>
                              <xsl:for-each select="$line[position() gt 1]">
                                    <xsl:if test="string-length(.) gt 0">
                                          <row>
                                                <xsl:variable name="field" select="tokenize(.,'&#9;')"/>
                                                <xsl:for-each select="$elename">
                                                      <xsl:variable name="pos" select="position()"/>
                                                      <xsl:choose>
                                                            <xsl:when test="string-length(.) gt 0">
                                                                  <xsl:element name="{.}">
                                                                        <xsl:value-of select="replace($field[number($pos)],'&#xD;','&#10;')"/>
                                                                  </xsl:element>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                  <!--<xsl:variable name="createdname" select="concat('position',$pos)"/>
                                                                  <xsl:element name="{$createdname}">
                                                                        <xsl:choose>
                                                                              <xsl:when test="string-length($field[$pos]) gt 0">
                                                                                    <xsl:value-of select="$field[$pos]"/>
                                                                              </xsl:when>
                                                                              <xsl:otherwise>
                                                                                    <xsl:text>NULL</xsl:text>
                                                                              </xsl:otherwise>
                                                                        </xsl:choose>
                                                                  </xsl:element> -->
                                                            </xsl:otherwise>
                                                      </xsl:choose>
                                                </xsl:for-each>
                                          </row>
                                    </xsl:if>
                              </xsl:for-each>
                        </root>
                  </xsl:when>
                  <xsl:otherwise>
                        <xsl:text>Cannot locate : </xsl:text>
                        <xsl:value-of select="$sourcetexturi"/>
                  </xsl:otherwise>
            </xsl:choose>
      </xsl:template>
</xsl:stylesheet>
