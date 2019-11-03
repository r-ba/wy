const width = 1000;
const height = 500;
const canvasSize = width * height;
const canvasDataLength = 4 * canvasSize;
const palleteOffset = 5 * canvasSize;

let instance;
let instanceData;
let canvasData;
let memPages = 20;

let canvas = document.querySelector('canvas');
canvas.width = width;
canvas.height = height;
let context = canvas.getContext('2d');
let imageData = context.createImageData(width, height);

let modifierLowerBound = 2;
let modifierUpperBound = 255;
let modifier = 30;
let palleteSize = 0;

const generatePalette = (numColours) => {
  randomColor({
    count: properties.numColours,
  }).forEach(colour => {
    this.instanceData.set([
        parseInt("0x"+colour.slice(1,3)),
        parseInt("0x"+colour.slice(3,5)),
        parseInt("0x"+colour.slice(5,7))
      ],
      palleteOffset
    )
    palleteOffset += 3;
  });
};

const resizeMemory = (canvas, palette) => {
  let memBytes = memPages * 64000;
  memBytes -= (5*canvas + palette);
  if (memBytes < 0) {
    let extraPages = Math.ceil((-1*memBytes)/64000);
    instance.exports.mem.grow(extraPages);
    memPages += extraPages;
  };
};

const update = (n) => {
  instance.exports.update(width, height, n);
  imageData.data.set(canvasData);
  context.putImageData(imageData, 0, 0);
};

const init = (moduleName) => {
  WebAssembly.instantiateStreaming(fetch(`wasm/${moduleName}.wasm`), {}).then(obj => {
    instance = obj.instance;
    resizeMemory(canvasSize, palleteSize);
    instanceData = new Uint8Array(obj.instance.exports.mem.buffer);
    obj.instance.exports.setup(width);
    canvasData = new Uint8Array(obj.instance.exports.mem.buffer, canvasSize, canvasDataLength);
    update(modifier);
  });
};
init("eca");

// ui controller
const modifierInput = document.getElementById("mod-input");
const modifierIncrement = document.getElementById("mod-increment");
const modifierDecrement = document.getElementById("mod-decrement");
const optToggle = document.getElementById("option-toggle");
const optToggleImg = document.getElementById("option-toggle-img");
const options = document.getElementById("option-panel");

modifierInput.oninput = () => {
    let newMod = Number(modifierInput.value);
    if (newMod) {
      if (newMod > modifierUpperBound)  {
        modifier = modifierUpperBound;
        modifierInput.value = modifierUpperBound;
        update(modifier);
      } else if (newMod < modifierLowerBound) {
        modifier = modifierLowerBound;
        modifierInput.value = modifierLowerBound;
        update(modifier);
      } else {
        modifier = newMod;
        update(modifier);
      }
    } else {
      modifierInput.value = modifier;
    }
};

modifierIncrement.addEventListener("click", () => {
    if (modifier <= modifierUpperBound) {
        modifier += 1;
        modifierInput.value = modifier;
        update(modifier);
    }
});

modifierDecrement.addEventListener("click", () => {
    if (modifier > modifierLowerBound) {
        modifier -= 1;
        modifierInput.value = modifier;
        update(modifier);
    }
});

let optHidden = false;
optToggle.addEventListener("click", () => {
    if (optHidden) optToggleImg.src = "img/hide.png";
    else optToggleImg.src = "img/show.png";
    options.classList.toggle("hidden");
    optHidden = !optHidden;
});
