<?php

declare(strict_types=1);

include_once(dirname(__DIR__, 2) . '/php/autoload.php');

use Psr\Log\LogLevel;
use Oeuvres\Kit\{Log, LoggerWeb, Http, Route};
use Oeuvres\Teinte\Format\Markdown;

Log::setLogger(new LoggerWeb(LogLevel::DEBUG));
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
  <!-- Messages used by teinte_site.js -->
</head>

<body>
  <div id="win">
    <header id="header">
      <a href="."><i>Teinte</i>, shades of TEI, the converter</a>
    </header>
    <div id="row">
      <div id="upload">
        <header>
          <div id="icons">
            <div class="format tei" title="TEI : XML document (Text Encoding Initiative)"></div>

            <div class="format docx" title="DOCX : office document (LibreOffice, Microsoft.Word…)"></div>

            <div class="todo format epub" title="EPUB : open ebook (to be done)"></div>

            <div class="todo format html" title="HTML : internet page (to be done)"></div>

            <div class="todo format markdown (to be done)" title="MarkDown : formatted text"></div>

          </div>
        </header>
        <div id="dropzone" class="card">
          <h3>Upload</h3>
          <img width="64" class="back" src="<?= Route::home_href() ?>upload.svg" />
          <template id="uploadFile">
            <div class="filename">{your file}</div>
            <div class="format {format}"></div>
          </template>
          <template id="uploadDrag">Drag your file here</template>
          <template id="uploadOver"><big>Drop for upload</big></template>

          <output></output>
          <div class="bottom">
            <button>or search for file…</button>
            <input type="file" hidden />
          </div>
        </div>


      </div>
      <div id="preview">
        <template id="waiting">
          <p class="center">Processing {your file}… (may take some seconds, depending on format and size)</p>
          <img width="80%" class="waiting" src="<?= Route::home_href() ?>waiting.svg" />
        </template>
        <output>
          <?php
$source = new Markdown();
$source->load(dirname(__DIR__, 2).'/README.md');
echo $source->html();
          ?>
        </output>
      </div>
      <div id="download">
        <header>
          <div id="icons">
            <div class="format tei" title="TEI : XML document (Text Encoding Initiative)"></div>

            <div class="format docx" title="DOCX : office document (LibreOffice, Microsoft.Word…)"></div>

            <div class="todo format epub" title="EPUB : open ebook (to be done)"></div>

            <div class="format html" title="HTML : internet page"></div>

            <div class="format markdown" title="MarkDown : formatted text"></div>

          </div>
        </header>
        <img width="64" class="back" src="<?= Route::home_href() ?>download.svg" />
        <div class="card inactive" id="downzone">
          <h3>Download</h3>
          <output id="exports"></output>
          <template id="downloadFile">
            <a class="download" href="download?format={0}">
              <div class="format {0}"></div>
              <div class="filename">{1}</div>
            </a>
          </template>
        </div>
      </div>
    </div>
  </div>
  <script type="module" type="text/javascript" src="<?= Route::home_href() ?>teinte_site.js"> </script>
</body>

</html>