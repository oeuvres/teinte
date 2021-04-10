Teinte est une librairie XSLT et PHP pour XML/TEI.
Elle peut s’utiliser dans plusieurs contextes : sur un serveur web, avec un éditeur XML et un navigateur, en ligne de commande. 

# Utiliser Teinte dans un serveur web

Teinte est utilisé pour la publication en ligne de fichiers XML-TEI. Le principe est de générer à l’avance différents formats (sous forme de fichiers), avec une petite base de données SQLite pour les métadonnées et la recherche plein texte. Les éléments sont agrégés par une page PHP libre, sans contraintes de *framework*. Un projet éditorial peut en effet agréger des types de documents très différents.

## Arbre des fichiers

Sur un serveur, une installation pour plusieurs corpus peut se présenter de cette manière. Teinte sert de librairie 

* www/
  * Livrable/ (pour epub, lecture seule, git clone https://github.com/oeuvres/Livrable.git)
  * Teinte/ (publication web, lecture seule, git clone https://github.com/oeuvres/Teinte)
  * critique/ (le corpus, accessible en écriture au serveur apache, ex: https://github.com/OBVIL/mythographie)
    * .htaccess (redirections Apache pour URL propres)
    * _conf.php (source du fichier de configuration)
    * conf.php (fichier de configuration modifié, avec le mot de passe)
    * index.php (page de publication agrégeant les éléments textuels)
    * pull.php (page d’administration)
    * manuels/*.xml (sources XML/TEI)
  * (dossiers générés par pull.php et agrégés par index.php)
    * article/ (les textes affichés)
    * toc/ (dossier généré, les tables des matières)
    * epub/ (livres électroniques ouvert, epub)
    * kindle/ (livres électroniques kindle, mobi)
    * xml/ (sources XML/TEI des textes)

## Procédure d’installation d’un corpus préparé

L’OBVIL a normalisé la publication de corpus XML/TEI avec Teinte, par exemple https://github.com/obvil/critique/.
Dans le principe, la procédure est élémentaire. Le seul point délicat est d’assurer une configuration des droits qui permettent au serveur web (ex : Apache) d’écrire dans le dossier du corpus, de créer des dossiers, tout en n’interdisant pas à un utilisateur d’y intervenir. La configuration des droits dépend de la politique du serveur, des habitudes des administrateurs. La procédure se présentera donc en deux parties : le principe, simple ; le réglage des droits, plus délicat.

```sh
# se placer dans le dossier de son serveur web
cd /var/www/ 
git clone https://github.com/obvil/critique/
cd critique
cp _conf.php conf.php
# modifier le mot de passe 
vi conf.php
```

Dans la ligne<br/>
"pass" => ""<br/>
mot de passe dans une chaîne entre guillemets<br/>
"pass" => "MonMotDePasseQueJeNeRetiensJamais"

Aller voir votre site dans un navigateur, ex:
<br/>http://obvil.paris-sorbonne.fr/corpus/corpus
<br/>Si aucun texte apparaît, c’est normal, vous êtes invité à visiter la page d’administration
<br/>http://obvil.paris-sorbonne.fr/corpus/corpus/pull.php

Avant que cela fonctionne (cf. erreurs possibles ci-dessosu), modifier les droits. Assurer que l’administrateur système appartient à un groupe avec le serveur http (ex: apache, www-data, _www).

```sh
# Dans le dossier de votre corpus
cd critique
# donner l’option +s à tous les dossiers (permet de propager le nom du groupe aux fichiers créés)
find . -type d -exec chmod g+s {} \;
# Attribuer récursivement tous les fichiers à ce groupe
chown -R :apache .
# Donner le droit d’écrire au groupe
chmod -R g+w .
```

## Erreurs possibles

Dans l’interface web de mise à jour

error: cannot open .git/FETCH_HEAD: Permission denied
<br/>Problème de droits, Apache ne peut pas écrire dans le dossier git
<br/>solution, dans le dossier :
<br/>sudo chown -R :apache .

article/ impossible à créer.
<br/>Problème de droits, Apache ne peut pas écrire dans le dossier git
<br/>solution, dans le dossier
<br/>sudo chown -R :apache .

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


# Utiliser Teinte pour éditer du XML/TEI

Obtenir la dernière version de Teinte
<br/>`oeuvres$ git clone https://github.com/oeuvres/Teinte.git`
<br/>Pour ceux qui ne sont pas familiers de git, le dossier peut être téléchargé, [zip](https://github.com/oeuvres/Teinte/archive/gh-pages.zip), mais il faudra retélécharger le dossier en cas de mise à jour de librairie.


* Teinte/
  * tei2html.xsl
  * teinte.rng
  * …
* corpus/
  * xml/
    * auteur_titre.xml
    * auteur_titre2.xml

Associer les fichiers XM/TEI aux ressources de Teinte, les liens relatifs dépendent de la structure des dossiers `../../`
```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <?xml-model href="http://oeuvres.github.io/teinte/teinte.rng" type="application/xml" 
      schematypens="http://relaxng.org/ns/structure/1.0"?>
    <?xml-stylesheet type="text/css" href="../../teinte/opentei.css"?>
    <?xml-stylesheet type="text/xsl" href="../../teinte/tei2html.xsl"?>
    <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:lang="fr">
    …
```

`<?xml-model` reconnu par Oxygen XML Editor, lié ici au schéma de validation Teinte exposé sur internet.
<br/>`<?xml-stylesheet type="text/css"` lien à une feuille de style CSS, pour la vue auteur (pas de tranformation, donc pas de table des matières ou de placement des notes en bas de page).
<br/>`<?xml-stylesheet type="text/xsl"` lien à une transformation XSL, reconnu par xsltproc, ou les navigateurs.

Transformation d’un fichier XML/TEI dans le navigateur, exemple : http://dramacode.github.io/bibdramatique/corneillet_camma.xml
En ligne, cela fonctionne dans la plupart des navigateurs. Pour des fichiers locaux, cela permet de travailler l’édition XML dans l’éditeur, et d’en voir l’effet directement dans le navigateur, en rechargeant. Toutefois, plusieurs navigateurs limitent cette poossibilité pour des raisons de sécurité (*same origin policy*). Cela fonctionne directement dans Safari et Internet Explorer, voir en annexe pour modifier la configuration de Firefox. Pour Chrome, Opera, ou Microsoft Edge, pas de hacks trouvés


# Utiliser teinte en ligne de commande

TODO

* available formats
 * html : complete html document with prolog, `<head>` and toc.
 * article : html fragment ready to be inserted, embed in an `<article>` element.
 * markdown : text/plain format in markdown syntax compatible with GitHub.
 * iramuteq : a text format used byt the Iramuteq software, a text analysis tool http://www.iramuteq.org/

## Remote linking to some resources

Teinte is visible as Github pages (branch gh-pages) to allow Internet linking.

XSL transformation 
```bash
  $ xsltproc http://oeuvres.github.io/teinte/tei2html.xsl corpus.xml > corpus.html
```

Validation avec Oxygen
```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://oeuvres.github.io/teinte/teinte.rng"
  type="application/xml"
  schematypens="http://relaxng.org/ns/structure/1.0"?>
```

# Annexes

## Installer php cli

PHP est un langage serveur, il peut aussi être utilisé en ligne de commande http://php.net/manual/features.commandline.introduction.php

* Ubuntu `sudo apt-get install php5-cli`
* Windows, ajouter php.exe à son path, more http://php.net/manual/install.windows.commandline.php

## Firefox, autoriser le lien relatif à une transformation XSLT (../)

1. Taper `about:config` dans la barre d’adresse
2. Accepter l4alerte de sécurité
3. Rechercher security.fileuri.strict_origin_policy
4. Le fixer à false

Explanations: https://developer.mozilla.org/en-US/docs/Same-origin_policy_for_file:_URIs
