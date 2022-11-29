# Teinte

Useful resources for TEI.

* [teinte.rng](http://oeuvres.github.io/teinte/teinte.rng) A simplified TEI schema for books 
([documentation](http://oeuvres.github.io/teinte/teinte.html))
```
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://oeuvres.github.io/teinte/teinte.rng"
  type="application/xml"
  schematypens="http://relaxng.org/ns/structure/1.0"?>
```

* [tei2html.xsl](http://oeuvres.github.io/Teinte/tei2html.xsl) A generic TEI transformation, compatible php or python, handling all the teinte.rng specifications.
```
xsltproc http://oeuvres.github.io/Teinte/tei2html.xsl mytei.xml > mytei.html
```


