<?php

declare(strict_types=1);

include_once(dirname(__DIR__, 2) . '/php/autoload.php');

use \Oeuvres\Kit\{Http, Route};

?>
<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8" />
  <link rel="stylesheet" href="<?= Route::home_href() ?>theme/teinte.css" />
  <link rel="stylesheet" href="<?= Route::home_href() ?>theme/teinte.tree.css" />
  <script src="<?= Route::home_href() ?>theme/teinte.tree.js"></script>
  <link rel="stylesheet" href="<?= Route::home_href() ?>teinte_site.css" />
  <title>Teinte, la conversion des livres</title>
</head>

<body>
  <div id="win">
    <header id="header">
      <h1><a href="?refresh=<?= time() ?>">Teinte, la conversion des livres (TEI, DOCX, HTML, EPUB, TXT)</a></h1>
    </header>
    <div id="row">
      <div id="upload">
        <header>
          <h2>Votre fichier</h2>
          <div id="icons">
            <img width="32" alt="TEI"
            title="TEI : texte XML (Text Encoding Initiative)" 
            src="<?= Route::home_href() ?>doc/img/icon_tei.svg" />

            <img width="32" alt="DOCX" 
            title="DOCX : texte bureautique (LibreOffice, Microsoft.Word…)" 
            src="<?= Route::home_href() ?>doc/img/icon_docx.svg" />

            <img class="todo" width="32" alt="EPUB"
            title="EPUB : livre électronique ouvert" 
            src="<?= Route::home_href() ?>doc/img/icon_epub.svg" />

            <img class="todo" width="32" alt="HTML"
            title="HTML : page internet" 
            src="<?= Route::home_href() ?>doc/img/icon_html.svg" />

            <img class="todo" width="32" alt="MD"
            title="MarkDown : texte brut légèrement formaté" 
            src="<?= Route::home_href() ?>doc/img/icon_markdown.svg" />
          </div>
        </header>
        <div id="dropzone">
          <img width="64" class="back" src="<?= Route::home_href() ?>upload.svg" />
          <output></output>
          <div class="bottom">
            <button>ou chercher sur votre disque…</button>
            <input type="file" hidden />
          </div>
        </div>
      </div>
      <div id="preview">
        <img id="banner" src="<?= Route::home_href() ?>doc/img/teinte.png" />
      </div>
      <div id="download">
        <header>
          <h2>Téléchargements</h2>
        </header>
        <img width="64" class="back" src="<?= Route::home_href() ?>download.svg" />
        <div id="exports">
        </div>
      </div>
    </div>
  </div>
  <script type="module" type="text/javascript" src="<?= Route::home_href() ?>teinte_site.js"> </script>
</body>

</html>