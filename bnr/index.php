<?php

// Soumission en post, lancer la transformation
if (isset($_POST['post'])) {
  include(dirname(dirname(__FILE__)).'/odette.php');
  Odette::doPost();
  exit;
}
?><!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <title>Teinte (TEI ▶ …), BNR (bibliothèque numérique romande)</title>
    <style>
#header {
  background-color: #000;
  color: #fff;
  background-image: url(https://ebhvpym3vod.exactdn.com/wp-content/uploads/2019/06/enteteneutre2.jpg?strip=all&lossy=1&ssl=1);

}
#header h1 {
  text-shadow: 0.15em 0.15em 0em #000000;
  font-size: 40px;
  font-weight: 700;
}
#header h2 {
  text-shadow: 0.15em 0.15em 0em #000000;
  font-size: 21px;
  font-weight: 700;
}
    </style>
  </head>
  <body>
    <div id="center">
    <header id="header">
      <div class="main">
        <h1><a href="https://github.com/oeuvres/teinte">Teinte</a>,
          pour la
          <a href=https://ebooks-bnr.com/">Bibliothèque numérique romande</a>
        </h1>
        <h2>
          Avec une source XML/TEI, générer des formats détachés
        </h2>
      </div>
      <div class="sub">
      (ePUB – PDF – PDF (Petits Écrans) – Kindle-MOBI – HTML – DOCX)
      </div>
    </header>
    <div id="contenu">
      <p>Hurlus, convertir les textes édités en traitement de textes vers XML/TEI</p>
    <?php
  if (isset($_REQUEST['format'])) $format=$_REQUEST['format'];
  else $format="tei";
    ?>
    <form class="gris" enctype="multipart/form-data" method="POST" name="odt" action="index.php">
      <input type="hidden" name="post" value="post"/>
      <input type="hidden" name="model" value="<?php echo basename(dirname(__FILE__)) ?>"/>
      <div style="margin: 50px 0 20px;">
        <b>1. Fichier odt</b> :
        <input type="file" size="70" name="odt" accept="application/vnd.oasis.opendocument.text"/>
      </div>

      <div style="margin: 20px 0 20px;">
        <b>2. Format d'export</b> :
            <label title="TEI"><input name="format" type="radio" value="tei" <?php if($format == 'tei') echo ' checked="checked"'; ?>/> tei</label>
          — <label title="OpenDocument Text xml"><input name="format" type="radio" value="html" <?php if($format == 'html') echo ' checked="checked"'; ?>/> html</label>
          <!--
          | <label title="Indiquer le mot clé d'un autre format">Autres formats <input name="local" size="10"/></label>
         -->
      </div>

      <div style="margin: 20px 0 40px;">
        <b>3. Résultat</b> :
        <input type="submit" name="view"  value="Voir"/> ou
          <input type="submit" name="download" onclick="this.form" value="Télécharger"/>
      </div>
    </form>
    <?php
    $odt = glob(dirname(__FILE__)."/*.odt");
    $count = count($odt);
    if ($count) {
      if ($count > 1) $mess = "Exemples de documents";
      else $mess = "Exemple de document";
      echo "<b>".$mess."</b>\n";
      echo "<ul>\n";
      foreach ($odt as $file) {
        $basename = basename($file);
        echo "<li><a href=\"".$basename."\">".$basename."</a></li>\n";
      }
      echo "</ul>\n";
    }
     ?>

    <p class="byline">Développement <a onmouseover="this.href='mailto'+'\x3A'+'frederic.glorieux'+'\x40'+'fictif.org'" href="#">Frédéric Glorieux</a></p>
      </div>
    </div>
  </body>
</html>
