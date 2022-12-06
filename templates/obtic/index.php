<?php

declare(strict_types=1);

include_once(dirname(__DIR__, 2) . '/php/autoload.php');

use \Oeuvres\Kit\{Http, Route};

?>
<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8" />
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Lato&amp;display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<?= Route::home_href() ?>theme/teinte.css" />
  <link rel="stylesheet" href="<?= Route::home_href() ?>theme/teinte.tree.css" />
  <script src="<?= Route::home_href() ?>theme/teinte.tree.js"></script>
  <link rel="stylesheet" href="<?= Route::home_href() ?>teinte_obtic.css" />
  <title>ObTiC, Teinte, conversion de livres</title>
</head>

<body>
  <div id="win">
    <header id="header">
      <a class="logo" href="."  rel="home"><img src="<?= Route::home_href() ?>obtic_logo.svg" class="custom-logo astra-logo-svg" alt="ObTIC"></a>
      <div class="moto"><a href="http://github.com/oeuvres/teinte">Teinte</a>, la conversion des livres (TEI, DOCX, HTML, EPUB, TXT)</div>
    </header>
    <div id="row">
      <div id="upload">
        <header>
          <div id="icons">
            <div class="format tei"
            title="TEI : texte XML (Text Encoding Initiative)"></div>

            <div class="format docx"
            title="DOCX : texte bureautique (LibreOffice, Microsoft.Word…)"></div>

            <div  class="todo format epub"
            title="EPUB : livre électronique ouvert" ></div>

            <div  class="todo format html"
            title="HTML : page internet"></div>

            <div class="todo format markdown"
            title="MarkDown : texte brut légèrement formaté"></div>

          </div>
        </header>
        <div id="dropzone" class="card">
          <h3>Votre fichier</h3>
          <output></output>
          <div class="bottom">
            <button>ou chercher sur votre disque…</button>
            <input type="file" hidden />
          </div>
        </div>
      </div>
      <div id="preview">
      <h1>Teinte</h1>
        <p>Convertissez vos livres électroniques, <b>de</b>, et <b>vers</b>, plusieurs formats : TEI, DOCX, HTML, EPUB, MARKDOWN.</p>

        <p>À gauche, déposez un de vos fichiers ; au centre, prévisualisez le contentu ; à droite, téléchargez un export dans le format de votre choix.</p>

        <p>Cette installation est en développement, certains chemins de conversion ne sont pas encore fonctionnels.</p>

        <p>Les feuilles de styles de cette installation ont été personnalisées pour l’<a href="https://obtic.sorbonne-universite.fr/">ObTiC</a>.</p>
        
        <p>Teinte est un logiciel libre développé par <a onmouseover="this.href='mailto'+'\x3A'+'frederic.glorieux'+'\x40'+'fictif.org'" href="#">Frédéric Glorieux</a> (cf <a href="http://github.com/oeuvres/teinte">github.com/oeuvres/teinte</a>). Vous pouvez librement l’utiliser. Vous pouvez aussi financer des développements supplémentaires pour mieux ajuster le logiciel à vos projets.</p> 

    </div>
      <div id="download">
        <header>
          <div id="icons">
            <div class="format tei"
            title="TEI : texte XML (Text Encoding Initiative)"></div>

            <div class="format docx"
            title="DOCX : texte bureautique (LibreOffice, Microsoft.Word…)"></div>

            <div  class="todo format epub"
            title="EPUB : livre électronique ouvert" ></div>

            <div  class="format html"
            title="HTML : page internet"></div>

            <div class="format markdown"
            title="MarkDown : texte brut légèrement formaté"></div>

          </div>
        </header>
        <div class="card inactive" id="downzone">
          <h3>Téléchargements</h3>
          <output id="exports"></output>
        </div>
      </div>
    </div>
    <footer id="footer">
      <div class="rule">
        <div class="monogram"></div>
      </div>
    </footer>
  </div>
  <script type="module" type="text/javascript" src="<?= Route::home_href() ?>teinte_obtic.js"> </script>
</body>

</html>
