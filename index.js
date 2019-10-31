// insantiate wasm module
let data = new Uint8Array([
  0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00, 0x01, 0x19, 0x05, 0x60, 0x00, 0x00, 0x60, 0x03,
  0x7f, 0x7f, 0x7f, 0x01, 0x7f, 0x60, 0x02, 0x7f, 0x7f, 0x00, 0x60, 0x01, 0x7f, 0x00, 0x60, 0x01,
  0x7f, 0x01, 0x7f, 0x03, 0x09, 0x08, 0x00, 0x01, 0x02, 0x03, 0x04, 0x02, 0x03, 0x03, 0x05, 0x03,
  0x01, 0x00, 0x06, 0x07, 0x10, 0x02, 0x03, 0x6d, 0x65, 0x6d, 0x02, 0x00, 0x06, 0x75, 0x70, 0x64,
  0x61, 0x74, 0x65, 0x00, 0x07, 0x08, 0x01, 0x00, 0x0a, 0xbe, 0x02, 0x08, 0x23, 0x01, 0x01, 0x7f,
  0x41, 0xbf, 0x02, 0x21, 0x00, 0x03, 0x40, 0x20, 0x00, 0x41, 0x01, 0x3a, 0x00, 0x00, 0x20, 0x00,
  0x41, 0x01, 0x6b, 0x22, 0x00, 0x0d, 0x00, 0x0b, 0x20, 0x00, 0x41, 0x01, 0x3a, 0x00, 0x00, 0x0b,
  0x0a, 0x00, 0x20, 0x00, 0x20, 0x01, 0x6a, 0x20, 0x02, 0x70, 0x0b, 0x5e, 0x01, 0x03, 0x7f, 0x41,
  0x00, 0x21, 0x02, 0x20, 0x00, 0x41, 0xc0, 0x02, 0x6c, 0x21, 0x03, 0x20, 0x03, 0x41, 0xc0, 0x02,
  0x6b, 0x41, 0x01, 0x6a, 0x21, 0x04, 0x20, 0x03, 0x20, 0x04, 0x41, 0x01, 0x6b, 0x2d, 0x00, 0x00,
  0x3a, 0x00, 0x00, 0x03, 0x40, 0x20, 0x03, 0x41, 0x01, 0x6a, 0x20, 0x03, 0x2d, 0x00, 0x00, 0x20,
  0x04, 0x2d, 0x00, 0x00, 0x20, 0x01, 0x10, 0x01, 0x3a, 0x00, 0x00, 0x20, 0x02, 0x41, 0x01, 0x6a,
  0x21, 0x02, 0x20, 0x03, 0x41, 0x01, 0x6a, 0x21, 0x03, 0x20, 0x04, 0x41, 0x01, 0x6a, 0x21, 0x04,
  0x20, 0x02, 0x41, 0xbf, 0x02, 0x49, 0x0d, 0x00, 0x0b, 0x0b, 0x20, 0x01, 0x01, 0x7f, 0x41, 0x00,
  0x21, 0x01, 0x03, 0x40, 0x20, 0x01, 0x41, 0x01, 0x6a, 0x21, 0x01, 0x20, 0x01, 0x20, 0x00, 0x10,
  0x02, 0x20, 0x01, 0x41, 0xc7, 0x01, 0x49, 0x0d, 0x00, 0x0b, 0x0b, 0x09, 0x00, 0x20, 0x00, 0x2d,
  0x00, 0x80, 0xc4, 0x13, 0x0b, 0x46, 0x01, 0x04, 0x7f, 0x20, 0x00, 0x10, 0x04, 0x21, 0x02, 0x20,
  0x00, 0x41, 0x01, 0x6a, 0x10, 0x04, 0x21, 0x03, 0x20, 0x00, 0x41, 0x01, 0x6a, 0x10, 0x04, 0x21,
  0x04, 0x41, 0xff, 0x01, 0x21, 0x05, 0x20, 0x01, 0x20, 0x02, 0x3a, 0x00, 0x00, 0x20, 0x01, 0x41,
  0x01, 0x6a, 0x20, 0x03, 0x3a, 0x00, 0x00, 0x20, 0x01, 0x41, 0x02, 0x6a, 0x20, 0x04, 0x3a, 0x00,
  0x00, 0x20, 0x01, 0x41, 0x03, 0x6a, 0x20, 0x05, 0x3a, 0x00, 0x00, 0x0b, 0x31, 0x01, 0x02, 0x7f,
  0x41, 0x00, 0x21, 0x01, 0x41, 0x80, 0xf4, 0x03, 0x21, 0x02, 0x03, 0x40, 0x20, 0x01, 0x2d, 0x00,
  0x00, 0x20, 0x02, 0x10, 0x05, 0x20, 0x01, 0x41, 0x01, 0x6a, 0x21, 0x01, 0x20, 0x02, 0x41, 0x04,
  0x6a, 0x21, 0x02, 0x20, 0x01, 0x41, 0xff, 0xf3, 0x03, 0x49, 0x0d, 0x00, 0x0b, 0x0b, 0x0a, 0x00,
  0x20, 0x00, 0x10, 0x03, 0x20, 0x00, 0x10, 0x06, 0x0b
]);

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

let update = (mod) => {
  instance.exports.update(mod);
  imageData.data.set(canvasData);
  context.putImageData(imageData, 0, 0);
};
update(3);