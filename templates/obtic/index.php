<?php

declare(strict_types=1);

include_once(dirname(__DIR__) . '/php/autoload.php');

use \Oeuvres\Kit\{Http, Route};

error_reporting(E_ALL);
// onload, destroy session, 
session_start();
$_SESSION = [];
// destroy session cookie
if (ini_get("session.use_cookies")) {
    $params = session_get_cookie_params();
    setcookie(session_name(), '', time() - 42000,
        $params["path"], $params["domain"],
        $params["secure"], $params["httponly"]
    );
}
session_destroy();
$lang = Http::lang();


?>
<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8" />
  <link rel="stylesheet" href="<?= Route::home_href() ?>theme/teinte.css" />
  <link rel="stylesheet" href="<?= Route::home_href() ?>theme/teinte.tree.css" />
  <script src="<?= Route::home_href() ?>theme/teinte.tree.js"></script>
  <link rel="stylesheet" href="<?= Route::home_href() ?>site/teinte_site.css" />
  <title><?php
          if ($lang == 'fr') echo 'Teinte, la conversion des livres';
          else echo 'Teinte, conversion of books'
          ?></title>
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
            src="<?= Route::home_href() ?>site/img/icon_tei.svg" />

            <img width="32" alt="DOCX" 
            title="DOCX : texte bureautique (LibreOffice, Microsoft.Word…)" 
            src="<?= Route::home_href() ?>site/img/icon_docx.svg" />

            <img class="todo" width="32" alt="EPUB"
            title="EPUB : livre électronique ouvert" 
            src="<?= Route::home_href() ?>site/img/icon_epub.svg" />

            <img class="todo" width="32" alt="HTML"
            title="HTML : page internet" 
            src="<?= Route::home_href() ?>site/img/icon_html.svg" />

            <img class="todo" width="32" alt="MD"
            title="MarkDown : texte brut légèrement formaté" 
            src="<?= Route::home_href() ?>site/img/icon_md.svg" />
          </div>
        </header>
        <div id="dropzone">
          <img width="64" class="back" src="<?= Route::home_href() ?>site/img/icon_upload.svg" />
          <output></output>
          <div class="bottom">
            <button>ou chercher sur votre disque…</button>
            <input type="file" hidden />
          </div>
        </div>
      </div>
      <div id="preview">
        <img id="banner" src="<?= Route::home_href() ?>site/img/teinte.png" />
      </div>
      <div id="download">
        <header>
          <h2>Téléchargements</h2>
        </header>
        <img width="64" class="back" src="<?= Route::home_href() ?>site/img/icon_download.svg" />
        <div id="exports">
        </div>
      </div>
    </div>
  </div>
  <script type="module" type="text/javascript" src="<?= Route::home_href() ?>site/teinte_site.js"> </script>
</body>

</html>


<?php
/*
      <form class="center"
        enctype="multipart/form-data" method="POST" name="upload" target="_blank"
        onsubmit="
var filename=this.tei.value;
var pos=filename.lastIndexOf('.');
if(pos>0) filename=filename.substring(0, pos);
var radios = document.getElementsByName('format');
var format = 'html';
for ( var i = 0, length = radios.length; i < length; i++) {
  if (radios[i].checked) format = radios[i].value;
  break;
}
var ext = '.html';
if ( format == 'markdown' ) ext = '.md';
else if ( format == 'iramuteq' ) ext = '.txt';
else if ( format == 'naked' ) ext = '.txt';
this.action = 'index.php/'+filename+ext;
      ">
        <?php
if ($lang=='fr') {
echo '<p>Choisir un fichiers XML/TEI
<input type="file" size="70" name="tei"/>
</p>

<p>Choisir un format :
<label><input name="format" type="radio" value="html"'.( ($format == 'html')?' checked="checked"':'' ).'/> HTML</label>
<label><input name="format" type="radio" value="markdown"'.( ($format == 'markdown')?' checked="checked"':'' ).'/> Markdown</label>
<label><input name="format" type="radio" value="iramuteq"'.( ($format == 'iramuteq')?' checked="checked"':'' ).'/> Iramuteq</label>
<label><input name="format" type="radio" value="naked"'.( ($format == 'naked')?' checked="checked"':'' ).'/> Texte nu</label>
</p>
<p>
<button name="view">Voir</button> ou
<button name="download">Télécharger</button>
</p>
';} else {
echo '<p>Choose an XML/TEI file
<input type="file" size="70" name="tei"/>
</p>
<p>Choose a format
<label><input name="format" type="radio" value="html"'.( ($format == 'html')?' checked="checked"':'' ).'/> HTML</label>
<label><input name="format" type="radio" value="markdown"'.( ($format == 'markdown')?' checked="checked"':'' ).'/> Markdown</label>
<label><input name="format" type="radio" value="iramuteq"'.( ($format == 'iramuteq')?' checked="checked"':'' ).'/> Iramuteq</label>
<label><input name="format" type="radio" value="naked"'.( ($format == 'naked')?' checked="checked"':'' ).'/> Texte nu</label>
</p>
<p>
<button name="view">See</button> or
<button name="download">Download</button>
</p>
';
}
        ?>
      </form>
      <?php
if ($lang=='fr') echo '
<div class="small">
      <p>
Teinte est une librairie XSLT1+php qui peut s‘intégrer à plus d’un contexte, par exemple <a href="https://github.com/oeuvres/Bookmeka">Omeka</a>.
Cette transformation est générique, elle ne supporte qu’une partie des balises TEI,
      dite “<a href="http://obvil-dev.paris-sorbonne.fr/developpements/teibook/">Teibook</a>”.
Si vous trouvez que vos balises ne sont pas transformées à votre convenance,
<a href="#" onmouseover="if(this.ok)return; this.href=\'mai\'+\'lt\'+\'o:frederic.glorieux\'+\'\\u0040\'+\'fictif.org\'; this.ok=true">écrivez-moi</a> (avec un fichier exemple).
      </p>
</div>
      ';
else echo '
<div class="small">
      <p>
Teinte is an XSLT1-php lib, free to embed in different contexts, for example <a href="https://github.com/oeuvres/Bookmeka">Omeka</a>.
We do not claim to support all TEI, but a profile called “<a href="http://obvil-dev.paris-sorbonne.fr/developpements/teibook/">Teibook</a>”.
If you think that your tags are not well rendered, fill free to <a href="#" onmouseover="if(this.ok)return; alert(\'\u064\'); this.href=\'mai\'+\'lt\'+\'o:frederic.glorieux\'+\'\\u0040\'+\'fictif.org\'; this.ok=true">send me a mail</a> (with a sample file).
      </p>
</div>
      ';


      ?>
*/