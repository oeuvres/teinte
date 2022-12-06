const home_href = '';
let response;
response = await fetch(
    home_href + 'php/Oeuvres/Teinte/Format/ext2format.json',
    {cache: "no-cache"}
);
const ext2format = await response.json();
response = await fetch(
    home_href + 'php/Oeuvres/Teinte/Format/formats.json',
    {cache: "no-cache"}
);
const formats = await response.json();
const conversions = {
    "docx": ["tei", "epub", "html", "md"],
    "tei": ["docx", "epub", "html", "md"],
    "docx": ["tei", "html", "markdown"],
    "tei": ["html", "docx", "markdown"],
    "markdown": [],
}

function dropInit() {
    const dropZone = document.querySelector("#dropzone");
    const dropOutput = dropZone.querySelector("output");
    const dropBut = dropZone.querySelector("button");
    const dropInput = dropZone.querySelector("input");
    const dropPreview = document.getElementById('preview');
    const dropExports = document.getElementById('exports');

    const message = {
        "default": "Déposer ici votre fichier",
        "over": "<big>Lâcher pour téléverser</big>",
    }
    // shared variable
    let file;
    let format;
    if (dropOutput) {
        dropOutput.innerHTML = message['default'];
    }
    if (dropBut) {
        dropBut.onclick = () => {
            dropInput.click(); //if user click on the button then the input also clicked
        }
    }
    dropZone.onmousedown = () => {
        dropInput.click(); 
    }
    if (dropInput) {
        dropInput.addEventListener("change", function () {
            //getting user select file and [0] this means if user select multiple files then we'll select only the first one
            file = this.files[0];
            dropZone.classList.remove("inactive");
            dropZone.classList.add("active");
            dropPreview.classList.remove("active");
            dropPreview.classList.add("inactive");
            showFile(); //calling function
        });
    }
    //If user Drag File Over DropArea
    dropZone.addEventListener("dragover", (event) => {
        event.preventDefault(); //preventing from default behaviour
        dropZone.classList.remove("inactive");
        dropZone.classList.add("active");
        dropPreview.classList.remove("active");
        dropPreview.classList.add("inactive");
        dropOutput.innerHTML = message['over'];
    });
    //If user leave dragged File from DropArea
    dropZone.addEventListener("dragleave", () => {
        dropZone.classList.remove("inactive");
        dropZone.classList.remove("active");
        dropOutput.innerHTML = message['default'];
    });
    //If user drop File on DropArea
    dropZone.addEventListener("drop", (event) => {
        event.preventDefault(); //preventing from default behaviour
        //getting user select file and [0] this means if user select multiple files then we'll select only the first one
        file = event.dataTransfer.files[0];
        showFile(); //calling function
    });

    function showFile() {
        // user interrupt ?
        if (!file || !file.name) return;
        dropZone.classList.add("inactive");
        let ext = file.name.split('.').pop();
        format = ext2format[ext];
        if (!format) format = ext;
        if (!(format in conversions)) {
            dropOutput.innerHTML = '<b>“' + format + '” format<br/>is not  supported</b><br/>' + file.name;
            return;
        }
        dropOutput.innerHTML = '<div class="filename">' + file.name + '</div>' 
        + '<div class="format ' + format + '"></div>';
        upload();
    }
    async function upload() {
        dropPreview.classList.remove("inactive");
        dropPreview.innerHTML = '<p class="center">Fichier en cours de traitement… (jusqu’à plusieurs secondes selon le format et la taille du fichier)</p>'
        + '<img width="80%" class="waiting" src="waiting.svg"/>';
        let timeStart = Date.now();
        let formData = new FormData();
        formData.append("file", file);
        fetch('upload', {
            method: "POST",
            body: formData
        }).then((response) => {
            let downs = conversions[format];
            let html = "";
            const name = file.name.replace(/\.[^/.]+$/, "");
            for (let i = 0, length = downs.length; i < length; i++) {
                const format2 = downs[i];
                let ext = formats[format2].ext;
                html += '\n<a class="download" href="download?format=' + format2 + '">' 
                + '<div class="format ' + format2 + '"></div>'
                + '<div class="filename">' + name + ext + '</div>'
                + '</a>';
            }
            dropExports.innerHTML = html;
            dropPreview.classList.add("active");
            return response.text();
        }).then((html) => {
            dropPreview.innerHTML = html;
            Tree.load();
        });
    }
}
dropInit();

