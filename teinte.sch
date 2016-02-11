<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <sch:title>Teinte validation des références</sch:title>
    <sch:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <xsl:key name="id" match="*" use="@xml:id"/>
    <xsl:key name="pb" match="tei:pb" use="concat(normalize-space(@ed), normalize-space(@n))"/>
    <sch:pattern>
        <sch:rule context="@target[starts-with(., '#')] | @corresp[starts-with(., '#')]">
            <sch:assert test="key('id', substring-before(concat(substring(., 2), ' '), ' '))"><sch:value-of select="."/> : l’identifiant (@xml:id) de la cible ne semble pas exister dans ce document</sch:assert>
        </sch:rule>
        <sch:rule context="tei:pb">
            <sch:report test="normalize-space(@n) = '' or not(@n)">Numéro de page manquant</sch:report>
            <sch:report test="count(key('pb', concat(normalize-space(@ed), normalize-space(@n)))) &gt; 1"><sch:value-of select="@n"/>, ce numéro de page semble dupliqué</sch:report>
            <sch:report test="local-name(following-sibling::*[1]) = 'div'">Il est conseillé de mettre un saut de page au début d’un div (plutôt qu’en dehors), de manière à faciliter le retour à la page</sch:report>
        </sch:rule>
        <sch:rule context="@target">
            <sch:report test="contains(., '. ') or contains(., ' ?') or contains(., ' :')">URL incorrecte, autour des signes de ponctuation</sch:report>
        </sch:rule>
    </sch:pattern>
</sch:schema>
