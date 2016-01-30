# Teinte

Teinte should give all tools to work TEI files efficiently (validation, transformation).

## Local install for TEI work

Get last version of the Teinte folder
```bash
  oeuvres$ git clone https://github.com/oeuvres/Teinte.git
```
(you can also dowload the [zip](https://github.com/oeuvres/Teinte/archive/gh-pages.zip) if you are not familiar with git, but you will have to download it for next update).

Put your XML/TEI folder as a brother of Teinte/ 

* Teinte/
  * tei2html.xsl
  * teinte.rng
  * …
* mytei/
  * opus.xml
  * …

Link your TEI files to RNG/schema validation, and XSLT transformation, CSS author, by processing instruction in XML prolog
```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <?xml-model href="../Teinte/teinte.rng" type="application/xml" 
      schematypens="http://relaxng.org/ns/structure/1.0"?>
    <?xml-stylesheet type="text/css" href="../Teinte/opentei.css"?>
    <?xml-stylesheet type="text/xsl" href="../Teinte/tei2html.xsl"?>
    <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:lang="fr">
    …
```

`<?xml-model` is recognized by Oxygen XML Editor
<br/>`<?xml-stylesheet type="text/css"` is for author view (no tranformation, so no toc nor footnotes)
<br/>`<?xml-stylesheet type="text/xsl"` is recognized by xsltproc, and browsers, but, for security reasons (*same origin policy*), there are some config tweaks to make it work (see below). See transformation in browser allow to work very efficiently, change XML in editor, reload browser to see changes. It works for example here on line http://oeuvres.github.io/textes/andersen_contes.xml

## Firefox, allow local XSLT path with ../

1. Type `about:config` in adress bar
2. Accept security warning (and be careful :-))
3. Look for security.fileuri.strict_origin_policy
4. Set it to false

Explanations: https://developer.mozilla.org/en-US/docs/Same-origin_policy_for_file:_URIs


# Remote linking to some resources

Teintre is visible as Github pages (branch gh-pages) to allow Internet linking.

```bash
  $ xsltproc http://oeuvres.github.io/Teinte/tei2html.xsl mytei.xml > mytei.html
```
