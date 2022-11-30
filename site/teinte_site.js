const extensions = {
    "docx": "docx",
    "epub": "epub",
    "htm": "html",
    "html": "html",
    "md": "md",
    "txt": "md",
    "xhtml": "html",
    "xml": "tei",
}

const conversions = {
    "docx": ["tei", "epub", "html", "md"],
    // "tei": ["docx", "epub", "html", "md"],
}


function dropInit() {
    const dropZone = document.querySelector("#dropzone");
    const dropOutput = dropZone.querySelector("output");
    const dropBut = dropZone.querySelector("button");
    const dropInput = dropZone.querySelector("input");
    const dropPreview = document.getElementById('preview');

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
        dropZone.classList.add("inactive");
        let ext = file.name.split('.').pop();
        format = extensions[ext];
        if (!(format in conversions)) {
            dropOutput.innerHTML = '<b>“' + format + '” format<br/>is not  supported</b><br/>' + file.name;
            return;
        }
        dropOutput.innerHTML = '<div class="filename">' + file.name + '</div>' 
        + '<div class="format ' + format + '"></div>';
        upload();
    }
    async function upload() {
        dropPreview.classList.add("active");
        dropPreview.classList.remove("inactive");
        dropPreview.innerHTML = '<img align="center" width="80%" class="waiting" src="site/img/waiting.svg"/>';
        let formData = new FormData();
        formData.append("file", file);
        fetch('site/upload.php', {
            method: "POST",
            body: formData
        }).then((response) => {
            return response.text();
        }).then((html) => {
            dropPreview.innerHTML = html;
            Tree.load();
        });
    }
}
dropInit();
/*
function dropFile(e) {
  e.preventDefault();
  console.log(e.dataTransfer);
  if (e.dataTransfer.items) {
    // Use DataTransferItemList interface to access the file(s)
    [...e.dataTransfer.items].forEach((item, i) => {
      // If dropped items aren't files, reject them
      if (item.kind === 'file') {
        const file = item.getAsFile();
        console.log(`… file[${i}].name = ${file.name}`);
      }
    });
  } else {
    // Use DataTransfer interface to access the file(s)
    [...e.dataTransfer.files].forEach((file, i) => {
      console.log(`… file[${i}].name = ${file.name}`);
    });
  }
}
*/

function dropDrag(e) {
    e.preventDefault();
}
