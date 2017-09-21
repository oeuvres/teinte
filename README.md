Teinte est une librairie XSLT et PHP qui peut s’utiliser dans plusieurs contextes : dans un serveur web, avec un éditeur XML et un navigateur, en ligne de commande. 

# Utiliser Teinte dans un serveur web

Teinte est utilisé pour la publication en ligne de fichiers XML-TEI. Le principe est de générer à l’avance différents formats (sous forme de fichiers), avec une petite base de données SQLite pour les métadonnées et la recherche plein texte. Les éléments sont agrégés par une page PHP libre, sans contraintes de *framework*.

## Arbre des fichiers

Sur un serveur, une installation pour plusieurs corpus peut se présenter de cette manière (où corpus est le code d’un corpus XML-TEI).

* www/
  * Livrable/ (pour epub, lecture seule, git clone https://github.com/oeuvres/Livrable.git)
  * Teinte/ (publication web, lecture seule, git clone https://github.com/oeuvres/Teinte)
  * corpus/ (le corpus, accessible en écriture au serveur apache, ex: https://github.com/OBVIL/mythographie)
    * .htaccess (redirections Apache pour URL propres)
    * _conf.php (source du fichier de configuration)
    * conf.php (fichier de configuration modifié, avec le mot de passe)
    * index.php (page de publication agrégeant les éléments textuels)
    * pull.php (page d’administration)
    * (dossiers générés par pull.php et agrégés par index.php)
    * article/ (les textes affichés)
    * toc/ (dossier généré, les tables des matières)
    * epub/ (livres électroniques ouvert, epub)
    * kindle/ (livres électroniques kindle, mobi)
    * xml/ (sources XML/TEI des textes)

## Procédure d’installation
 
```sh
# Dans le dossier web de votre serveur hhtp.
# Créer à l’avance le dossier de destination avec les bons droits
mkdir corpus
# assurez-vous que le dossier appartient à un groupe où vous êtes
# donnez-vous les droits d’y écrire
# l’option +s permet de propager le nom du groupe dans le dossier
# plus facile à faire maintenant qu’après
chmod g+sw corpus
# Aller chercher les sources de cet entrepôt
git clone https://github.com/obvil/corpus
# rentrer dans le dossier
cd corpus
# donner des droits d’écriture à votre serveur sur ce dossier, ici, l’utilisateur apache
# . permet de toucher les fichiers cachés, et notamment, ce qui est dans .git
sudo chown -R apache .
# copier la conf par défaut 
cp _conf.php conf.php
# modifier le mot de passe 
vi conf.php
```

Dans la ligne<br/>
"pass" => ""<br/>
remplacer null par une chaîne entre guillemets<br/>
"pass" => "MonMotDePasseQueJeNeRetiensJamais"

Aller voir votre site dans un navigateur, ex:
<br/>http://obvil.paris-sorbonne.fr/corpus/corpus
<br/>Si aucun texte apparaît, c’est normal, vous êtes invité à visiter la page d’administration
<br/>http://obvil.paris-sorbonne.fr/corpus/corpus/pull.php


## Erreurs possibles

Dans l’interface web de mise à jour

error: cannot open .git/FETCH_HEAD: Permission denied
<br/>Problème de droits, Apache ne peut pas écrire dans le dossier git
<br/>solution, dans le dossier :
<br/>sudo chown -R apache .

article/ impossible à créer.
<br/>Problème de droits, Apache ne peut pas écrire dans le dossier git
<br/>solution, dans le dossier
<br/>sudo chown -R apache .

```
From https://github.com/OBVIL/corpus
   3d04adf..be29dad  gh-pages   -> origin/gh-pages
error: Your local changes to the following files would be overwritten by merge:
	.htaccess
Please, commit your changes or stash them before you can merge.
Aborting
Updating 3d04adf..be29dad
```
Vous avez changé vous même un fichier sur votre serveur, par FTP ou SSH, il n’est plus synchrone avec le Git, le supprimer du serveur et l’établir comme vous le souhaitez dans le git.


# Utiliser Teinte pour éditer du TEI

Get last version of the Teinte folder
<br/>`oeuvres$ git clone https://github.com/oeuvres/Teinte.git`
<br/>(you can also dowload the [zip](https://github.com/oeuvres/Teinte/archive/gh-pages.zip) if you are not familiar with git, but you will have to download it for next update).
<br/>Put your XML/TEI folder as a brother of Teinte/ 

* Teinte/
  * tei2html.xsl
  * teinte.rng
  * …
* corpus/
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

## Firefox, allow local XSLT path with ../

1. Type `about:config` in adress bar
2. Accept security warning (and be careful :-))
3. Look for security.fileuri.strict_origin_policy
4. Set it to false

Explanations: https://developer.mozilla.org/en-US/docs/Same-origin_policy_for_file:_URIs

# Utiliser Teinte en ligne de commande

See below to install php cli.

Generate html fragments from your TEI files (root node `<article>`) ready to include in your website. 
```bash
  $ php -f Teinte/Doc.php article "corpus/*/*.xml" mysite/
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
  $ xsltproc http://oeuvres.github.io/Teinte/tei2html.xsl corpus.xml > corpus.html
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
