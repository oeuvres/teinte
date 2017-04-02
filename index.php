<?php
/*
Teinte: publish tei files

Copyright © 2012, 2013, 2015, 2016 Frédéric Glorieux
license : APACHE 2.0 http://www.apache.org/licenses/LICENSE-2.0
<frederic.glorieux@fictif.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/

error_reporting(E_ALL);
include dirname(__FILE__).'/Web.php';
include dirname(__FILE__).'/Doc.php';

$format = "html";
if ( isset( $_REQUEST['format'] ) ) $format = $_REQUEST['format'];
// A file is submited, work
$upload = Teinte_Web::upload();
if ($upload) {
  $teinte = new Teinte_Doc( $upload['tmp_name'] );
  $teinte->filename( $upload['filename'] );
  $content = $teinte->export($format, null, array('theme'=>'../theme/'));
  header( 'Content-Type: '.Teinte_Web::$mime[$format] );
  if ( isset( $_REQUEST['download'] ) ) {
    header('Content-Disposition: attachment; filename="'.$upload['filename'].Teinte_Doc::$ext[$format].'"');
  }
  echo $content;
  exit();
}
$lang = Teinte_Web::lang();


?><!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <link rel="stylesheet" href="theme/html.css"/>
    <style>
body { font-family: 'Source Sans Pro', "Lucida Sans Unicode", "Lucida Grande", sans-serif ; }
    </style>
    <title><?php
if ($lang=='fr') echo'Teinte, transformer du TEI (HTML, txt…)';
else echo 'Teinte, transform TEI (HTML, txt…)'
    ?></title>
    </head>
  <body>
    <div id="center">
      <header id="header">
        <h1>
          <a href="../">Développements</a>
        </h1>
        <a class="logo" href="http://obvil.paris-sorbonne.fr/developpements/"><img class="logo" src="../theme/img/logo-obvil.png" alt="OBVIL"></a>
      </header>
      <div id="contenu">

<?php
if ($lang=='fr') echo '
  <p style="float: right">par Frédéric Glorieux. [ fr |<a href="?lang=en"> en </a>]</p>
  <h1>Teinte, transformer du TEI</h1>
';
else echo '
  <p style="float: right">by Frédéric Glorieux [ en |<a href="?lang=fr"> fr </a>]</p>
  <h1>Teinte, transform TEI</h1>
';
?>
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
      </div>
     </div>
  </body>
</html>
