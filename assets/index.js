class Canvas {
  constructor(properties) {
    this.width = properties.width;
    this.height = properties.height;
    this.palleteSize = properties.numColours;
    this.memPages = 20;
    let canvasSize = properties.width * properties.height;
    let canvasDataLength = 4 * canvasSize;
    let palleteOffset = 5 * canvasSize;
    this.instance = new WebAssembly.Instance(new WebAssembly.Module(properties.module), {});
    this.resizeMemory = (canvas, palette) => {
      let memBytes = this.memPages * 64000;
      memBytes -= (5*canvas + palette);
      if (memBytes < 0) {
        let extraPages = Math.ceil((-1*memBytes)/64000);
        this.instance.exports.mem.grow(extraPages);
        this.memPages += extraPages;
      };
    };
    this.resizeMemory(canvasSize, this.palleteSize);
    this.instanceData = new Uint8Array(this.instance.exports.mem.buffer);
    this.instance.exports.setup(properties.width);
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
    this.canvas = document.querySelector('canvas');
    this.canvas.width = this.width;
    this.canvas.height = this.height;
    this.context = this.canvas.getContext('2d');
    this.imageData = this.context.createImageData(properties.width, properties.height);
    this.canvasData = new Uint8Array(this.instance.exports.mem.buffer, canvasSize, canvasDataLength);
    this.update = (mod) => {
      this.instance.exports.update(this.width, this.height, mod);
      this.imageData.data.set(this.canvasData);
      this.context.putImageData(this.imageData, 0, 0);
    };
    this.update(properties.modulus);
  }
  update(mod) {
    this.update(mod);
  }
}

let canvasProps = {
  modulus: 3,
  width: 1000,
  height: 500,
  module: new Uint8Array(sigma),
  numColours: 500
};
let canvas = new Canvas(canvasProps);

// ui controller
const modInput = document.getElementById("mod-input");
const modIncrement = document.getElementById("mod-increment");
const modDecrement = document.getElementById("mod-decrement");
const optToggle = document.getElementById("option-toggle");
const optToggleImg = document.getElementById("option-toggle-img");
const options = document.getElementById("option-panel");

modInput.oninput = () => {
    let newMod = Number(modInput.value);
    if (newMod) {
      if (newMod > 500)  {
        canvasProps.modulus = 500;
        modInput.value = 500;
        canvas.update(canvasProps.modulus);
      } else if (newMod < 2) {
        canvasProps.modulus = 2;
        modInput.value = 2;
        canvas.update(canvasProps.modulus);
      } else {
        canvasProps.modulus = newMod;
        canvas.update(canvasProps.modulus);
      }
    } else {
      modInput.value = canvasProps.modulus;
    }
};

modIncrement.addEventListener("click", () => {
    if (canvasProps.modulus <= 500) {
        canvasProps.modulus += 1;
        modInput.value = canvasProps.modulus;
        canvas.update(canvasProps.modulus);
    }
});

modDecrement.addEventListener("click", () => {
    if (canvasProps.modulus > 2) {
        canvasProps.modulus -= 1;
        modInput.value = canvasProps.modulus;
        canvas.update(canvasProps.modulus);
    }
});

let optHidden = false;
optToggle.addEventListener("click", () => {
    if (optHidden) optToggleImg.src = "assets/img/hide.png";
    else optToggleImg.src = "assets/img/show.png";
    options.classList.toggle("hidden");
    optHidden = !optHidden;
});
