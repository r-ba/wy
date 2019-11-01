// insantiate wasm module
let data = new Uint8Array(sigma);

let instance = new WebAssembly.Instance(new WebAssembly.Module(data), {});
let instanceData = new Uint8Array(instance.exports.mem.buffer);

// setup colour palette
const numColours = 100; // max = 64000
let palleteIndex = 320000;
randomColor({
  count: numColours
}).forEach(colour => {
  instanceData.set([
      parseInt("0x"+colour.slice(1,3)),
      parseInt("0x"+colour.slice(3,5)),
      parseInt("0x"+colour.slice(5,7))
    ],
    palleteIndex
  )
  palleteIndex += 3;
});

let canvas = document.querySelector('canvas');
let context = canvas.getContext('2d');
let imageData = context.createImageData(320, 200);
let canvasData = new Uint8Array(instance.exports.mem.buffer, 64000, 256000);

let modulus = 3;
let update = (mod) => {
  instance.exports.update(mod);
  imageData.data.set(canvasData);
  context.putImageData(imageData, 0, 0);
};
update(modulus);

// ui controller
const modInput = document.getElementById("mod-input");
const modIncrement = document.getElementById("mod-increment");
const modDecrement = document.getElementById("mod-decrement");
const optToggle = document.getElementById("option-toggle");
const optToggleImg = document.getElementById("option-toggle-img");
const options = document.getElementById("option-panel");

modInput.oninput = () => {
    let newMod = Number(modInput.value);
    if (newMod && (newMod != modulus) && (newMod <= 5000)) {
        modulus = newMod;
        update(modulus);
    };
};

modIncrement.addEventListener("click", () => {
    if (modulus < 5000) {
        modulus += 1;
        modInput.value = modulus;
        update(modulus);
    }
});

modDecrement.addEventListener("click", () => {
    if (modulus > 2) {
        modulus -= 1;
        modInput.value = modulus;
        update(modulus);
    }
});

let optHidden = false;
optToggle.addEventListener("click", () => {
    if (optHidden) {
        optToggleImg.src = "assets/img/hide.png";
    }
    else {
        optToggleImg.src = "assets/img/show.png";
    }
    options.classList.toggle("hidden");
    optHidden = !optHidden;
});
