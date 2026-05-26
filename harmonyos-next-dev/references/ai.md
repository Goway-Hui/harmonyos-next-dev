# AI 能力参考

## 端侧 AI 推理 — MindSpore Lite

```typescript
import { mindSporeLite } from '@kit.MindSporeLiteKit';

// 加载模型
let model = new mindSporeLite.Model();
let context = new mindSporeLite.Context();
context.target = [mindSporeLite.DeviceType.CPU];
await model.loadModelFromFile('model.ms', context);

// 构建输入
let input = model.getInputs()[0];
let inputData = new Float32Array([/* 模型输入数据 */]);
input.setData(inputData.buffer);

// 推理
let start = performance.now();
await model.predict(model.getInputs(), model.getOutputs());
let end = performance.now();
console.log(`Inference time: ${end - start}ms`);

// 获取输出
let output = model.getOutputs()[0];
let outputData = output.getData();
```

## AI Kit — OCR 文字识别

```typescript
import { textRecognition } from '@kit.CoreVisionKit';

// 通用文字识别
async function recognizeText(pixelMap: image.PixelMap) {
  let result = await textRecognition.recognizeText(pixelMap);
  console.log(`Recognized: ${result.text}`);
  return result.text;
}

// 身份证识别
import { idCardRecognition } from '@kit.CoreVisionKit';
let idCard = await idCardRecognition.recognizeIdCard(pixelMap);
console.log(`Name: ${idCard.name}, ID: ${idCard.idNumber}`);
```

## AI Kit — 图像分割

```typescript
import { imageSegmentation } from '@kit.CoreVisionKit';

let result = await imageSegmentation.segmentImage(pixelMap);
// result: { foreground: PixelMap, background: PixelMap, mask: PixelMap }
```

## AI Kit — 图像分类

```typescript
import { imageClassification } from '@kit.CoreVisionKit';

let result = await imageClassification.classifyImage(pixelMap, {
  confidenceThreshold: 0.5
});
result.classes.forEach(cls => {
  console.log(`${cls.className}: ${cls.confidence}`);
});
```

## AI Kit — 语音识别 (ASR)

```typescript
import { speechRecognizer } from '@kit.SpeechRecognizerKit';

let recognizer = speechRecognizer.createRecognizer();
recognizer.on('result', (result) => {
  console.log(`Recognized: ${result.text}`);
  console.log(`Is final: ${result.isFinal}`);
});

recognizer.start({
  language: 'zh-CN',
  maxDuration: 30000
});

// 停止
recognizer.stop();
```

## AI Kit — 语音合成 (TTS)

```typescript
import { textToSpeech } from '@kit.SpeechKit';

let tts = textToSpeech.createEngine();
tts.speak('你好，欢迎使用 HarmonyOS 语音合成');
// 或带参数
await tts.speak('Hello World', {
  language: 'en-US',
  pitch: 1.0,
  speed: 1.0,
  volume: 1.0
});
```

## AI Kit — 人脸检测

```typescript
import { faceDetector } from '@kit.FaceKit';

let result = await faceDetector.detectFace(pixelMap);
result.faces.forEach(face => {
  console.log(`Face rect: ${face.rect.x},${face.rect.y},${face.rect.width}x${face.rect.height}`);
  console.log(`Confidence: ${face.confidence}`);
  if (face.landmarks) {
    face.landmarks.forEach(lm => {
      console.log(`Landmark ${lm.type}: (${lm.x}, ${lm.y})`);
    });
  }
});
```

## AI Kit — 条码扫描

```typescript
import { barcodeScanner } from '@kit.BarCodeKit';

// 单次扫描
let result = await barcodeScanner.scan(pixelMap);
console.log(`Barcode value: ${result.value}, type: ${result.type}`);

// 相机连续扫描（使用 BarcodeView 组件）
BarcodeView({
  types: [BarcodeType.QR_CODE, BarcodeType.CODE128],
  onResult: (result: BarcodeResult) => {
    console.log(`Scanned: ${result.value}`);
  }
})
.width('100%')
.height(300)
```

## AI Kit — 翻译

```typescript
import { translator } from '@kit.TranslationKit';

let result = await translator.translate({
  sourceLanguage: 'zh',
  targetLanguage: 'en',
  text: '你好世界'
});
console.log(`Translation: ${result.text}`);
```

## AI Kit — 关键点检测

```typescript
import { keypointDetection } from '@kit.CoreVisionKit';
let result = await keypointDetection.detectKeypoints(pixelMap, KeypointType.HUMAN_BODY);
result.keypoints.forEach(kp => {
  console.log(`Keypoint: (${kp.x}, ${kp.y}), confidence: ${kp.confidence}`);
});
```

## AI Kit — 场景检测

```typescript
import { sceneDetection } from '@kit.CoreVisionKit';
let result = await sceneDetection.detectScene(pixelMap);
console.log(`Scene: ${result.scene}, confidence: ${result.confidence}`);
```
