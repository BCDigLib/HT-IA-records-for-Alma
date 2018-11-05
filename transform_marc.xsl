<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="1.0">
    <xsl:output method="xml" omit-xml-declaration="yes"/>

    <xsl:variable name="ia" select="document('ia-metadata.xml')"/>
    <xsl:param name="full_count"/>
    <xsl:param name="limited_count"/>
    <xsl:param name="full_vols"/>
    <xsl:param name="limited_vols"/>


    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>




    <xsl:template match="collection">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="datafield[@tag='HOL']">

        <xsl:choose>
            <xsl:when test="$limited_count = 0">
                <datafield tag="856" ind1="4" ind2="0">
                    <subfield code="3">
                        <xsl:text>Full view: </xsl:text>
                    </subfield>
                    <subfield code="u">
                        <xsl:text>https://catalog.hathitrust.org/Record/</xsl:text>
                        <xsl:value-of select="preceding-sibling::controlfield[@tag='001']"/>
                    </subfield>
                </datafield>
            </xsl:when>
            <xsl:otherwise>
                <datafield tag="856" ind1="4" ind2="0">
                    <subfield code="3">
                        <xsl:text>Full view: </xsl:text>
                        <xsl:if test="$full_vols != ''">
                            <xsl:value-of select="$full_vols"/>
                        </xsl:if>
                    </subfield>
                    <subfield code="u">
                        <xsl:text>https://catalog.hathitrust.org/Record/</xsl:text>
                        <xsl:value-of select="preceding-sibling::controlfield[@tag='001']"/>
                    </subfield>
                </datafield>
                <!--
                <datafield tag="856" ind1="4" ind2="0">
                    <subield code="3">
                        <xsl:text>Limited view: </xsl:text>
                        <xsl:if test="$limited_vols != ''">
                            <xsl:value-of select="$limited_vols"/>
                        </xsl:if>
                    </subield>
                    <subfield code="u">
                        <xsl:text>https://catalog.hathitrust.org/Record/</xsl:text>
                        <xsl:value-of select="preceding-sibling::controlfield[@tag='001']"/>
                    </subfield>
                </datafield>-->
                
                
            </xsl:otherwise>
        </xsl:choose>



        <xsl:if test="$limited_count &gt; 0">

            <xsl:for-each select="following-sibling::datafield[@tag='974']">
                <xsl:if
                    test="(subfield[@code='r']='ic' or subfield[@code='r']='und' or subfield[@code='r']='op' or subfield[@code='r']='nobody' or subfield[@code='r']='pd-pvt' or subfield[@code='r']='supp') and (subfield[@code='b']='MCHB')">
                    <xsl:variable name="ark">
                        <xsl:value-of select="substring(subfield[@code='u'],4)"/>
                    </xsl:variable>

                    <datafield tag="856" ind1="4" ind2="0">

                        <subfield code="3">
                            <xsl:text>Full view: </xsl:text>
                            <xsl:value-of select="subfield[@code='z']"/>
                        </subfield>

                        <subfield code="u">
                            <xsl:value-of
                                select="$ia//records/metadata[child::identifier-ark=$ark]/identifier-access"/>

                        </subfield>
                    </datafield>
                </xsl:if>
            </xsl:for-each>

        </xsl:if>
    </xsl:template>

    <xsl:template match="datafield[@tag='974']"/>




    <xsl:template match="datafield[@tag='974'][child::subfield[@code='b']='MCHB'][position()=1]">
        <xsl:variable name="ark">
            <xsl:value-of select="substring(subfield[@code='u'],4)"/>
        </xsl:variable>

        <xsl:if test="count($ia//records/metadata[child::identifier-ark=$ark]/collection) &gt; 3">
        <xsl:for-each select="$ia//records/metadata[child::identifier-ark=$ark]/collection">
            <xsl:if test="(. != 'americana') and (. != 'blc') and (. != 'Boston_College_Library')">
            <datafield tag="940" ind1="1" ind2=" ">
                <subfield code="a">
                    <xsl:value-of select="."/>
                </subfield>
            </datafield>
            </xsl:if>
        </xsl:for-each>
        </xsl:if>

    </xsl:template>
    <xsl:template match="datafield[@tag='035']">
        <xsl:if test="contains(., 'OCoLC')">
            <datafield tag="776" ind1="1" ind2=" ">
                <subfield code="c">Original</subfield>
                <subfield code="w">
                    <xsl:value-of select="."/>
                </subfield>
            </datafield>
            
        </xsl:if>
        
        
    </xsl:template>

    <xsl:template match="controlfield[@tag='004']"/>
    <xsl:template match="datafield[@tag='040']"/>
    <xsl:template match="datafield[@tag='049']"/>
    <xsl:template match="datafield[@tag='533']"/>




    <xsl:template match="datafield[@tag='DAT']"/>
    <xsl:template match="datafield[@tag='CAT']"/>
    <xsl:template match="datafield[@tag='CID']"/>
    <xsl:template match="datafield[@tag='FMT']"/>
    <xsl:template match="datafield[@tag='COM']"/>
    <xsl:template match="datafield[@tag='002']"/>

 













</xsl:stylesheet>
