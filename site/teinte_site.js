const formats = {
    // "image/jpeg", "image/jpg", "image/png"
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "docx",
    // "application/epub+zip":"epub",
    // "text/html":"html",
    // "application/xhtml+xml":"html",
    // "text/xml":"tei",
}


function dropInit() {
    const dropZone = document.querySelector("#dropzone");
    const dropOutput = dropZone.querySelector("output");
    const dropBut = dropZone.querySelector("button");
    const dropInput = dropZone.querySelector("input");
    const message = {
        "default":"Déposer ici votre fichier",
        "over":"Lâcher pour téléverser",
    }
    let file; //this is a global variable and we'll use it inside multiple functions
    if (dropOutput) {
        dropOutput.textContent = message['default'];
    } 
    if (dropBut) {
        dropBut.onclick = () => {
            dropInput.click(); //if user click on the button then the input also clicked
        }
    }
    if (dropBut) {
        dropInput.addEventListener("change", function () {
            //getting user select file and [0] this means if user select multiple files then we'll select only the first one
            file = this.files[0];
            dropZone.classList.add("active");
            showFile(); //calling function
        });
    }
    //If user Drag File Over DropArea
    dropZone.addEventListener("dragover", (event) => {
        event.preventDefault(); //preventing from default behaviour
        dropZone.classList.add("active");
        dropOutput.textContent = message['default'];
    });
    //If user leave dragged File from DropArea
    dropZone.addEventListener("dragleave", () => {
        dropZone.classList.remove("active");
        dropOutput.textContent =  message['leave'];
    });
    //If user drop File on DropArea
    dropZone.addEventListener("drop", (event) => {
        event.preventDefault(); //preventing from default behaviour
        //getting user select file and [0] this means if user select multiple files then we'll select only the first one
        file = event.dataTransfer.files[0];
        showFile(); //calling function
    });

    function showFile() {
        let fileType = file.type; //getting selected file type
        // dropOutput.textContent = file.type;
        // TODO test inputr format
        if (true) { //if user selected file is an image file
            /*
            let fileReader = new FileReader(); //creating new FileReader object
            fileReader.onload = () => {
                let fileURL = fileReader.result; //passing user file source in fileURL variable
            }
            fileReader.readAsDataURL(file);
            */
           upload();
        } else {
           dropZone.classList.remove("active");
            dragText.textContent = "Drag & Drop to Upload File";
        }
    }
    async function upload() {
        let out = document.getElementById('html');
        let formData = new FormData();
        formData.append("file", file);
        fetch('site/upload.php', {
          method: "POST", 
          body: formData
        }).then((response) => {
            return response.text();
        }).then((html) => {
            out.innerHTML = html;
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
