# Teinte

Teinte should give all tools to work XML/TEI files efficiently (validation, transformation).

## Local install for TEI work

Get last version of the Teinte folder
<br/>`oeuvres$ git clone https://github.com/oeuvres/Teinte.git`
<br/>(you can also dowload the [zip](https://github.com/oeuvres/Teinte/archive/gh-pages.zip) if you are not familiar with git, but you will have to download it for next update).
<br/>Put your XML/TEI folder as a brother of Teinte/ 

* Teinte/
  * tei2html.xsl
  * teinte.rng
  * …
* mytei/
  * opus.xml
  * …

Link your TEI files to Teinte resources
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
<br/>`<?xml-stylesheet type="text/css"` is for author view (no tranformation, so no toc, no footnotes)
<br/>`<?xml-stylesheet type="text/xsl"` is recognized by xsltproc, and browsers, but, for security reasons (*same origin policy*), there are limitations on local files. Transformation in browser allow to work very efficiently, change XML in editor, reload browser to see changes. It works on line on most modern browsers http://oeuvres.github.io/textes/andersen_contes.xml . On local files, it works with Safari and Internet Explorer with no extra config. For Firefox, see below. For Chrome, Opera, and Microsoft Edge, no hack found yet.

### Firefox, allow local XSLT path with ../

1. Type `about:config` in adress bar
2. Accept security warning (and be careful :-))
3. Look for security.fileuri.strict_origin_policy
4. Set it to false

Explanations: https://developer.mozilla.org/en-US/docs/Same-origin_policy_for_file:_URIs

## Generate some formats

See below to install php cli.

Generate html fragments from your TEI files (root node `<article>`) ready to include in your website. 
```bash
  $ php -f Teinte/Doc.php article "mytei/*/*.xml" mysite/
```
* The glob pattern is resolved by PHP, surround it by quotes to avoid system expansion on a linux box.
* available formats
 * html : complete html document with prolog, `<head>` and toc.
 * article : html fragment ready to be inserted, embed in an `<article>` element.
 * markdown : text/plain format in markdown syntax compatible with GitHub.
 * iramuteq : a text format used byt the Iramuteq software, a text analysis tool http://www.iramuteq.org/

## Remote linking to some resources

Teinte is visible as Github pages (branch gh-pages) to allow Internet linking.

XSL transformation 
```bash
  $ xsltproc http://oeuvres.github.io/Teinte/tei2html.xsl mytei.xml > mytei.html
```

Validation with Oxygen, edit your TEI files and see errors.
```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://oeuvres.github.io/Teinte/teinte.rng"
  type="application/xml"
  schematypens="http://relaxng.org/ns/structure/1.0"?>
```

## Install php cli

PHP is a server side language, it could also be used as command line http://php.net/manual/features.commandline.introduction.php

* Ubuntu `sudo apt-get install php5-cli`
* Windows, add php.exe to your path, more http://php.net/manual/install.windows.commandline.php
