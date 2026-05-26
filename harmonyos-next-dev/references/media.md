# 媒体参考

## 音频管理

```typescript
import { audio } from '@kit.AudioKit';

// 获取 AudioManager
let audioManager = audio.getAudioManager();
let volumeGroup = await audioManager.getVolumeGroup(audio.DEFAULT_VOLUME_GROUP_ID);

// 获取音量
let volume = await volumeGroup.getVolume(audio.AudioVolumeType.MEDIA);
let maxVolume = await volumeGroup.getMaxVolume(audio.AudioVolumeType.MEDIA);

// 设置音量
await volumeGroup.setVolume(audio.AudioVolumeType.MEDIA, 10);

// 监听音量变化（API 20+ 使用 streamVolumeChange）
audioManager.on('streamVolumeChange', (event: audio.StreamVolumeChangeEvent) => {
  console.log(`Volume changed: ${event.volumeType} -> ${event.volume}`);
});
// 注意：旧 API volumeChange 已被 streamVolumeChange 替代
```

## 音频播放

```typescript
import { avPlayer } from '@kit.MultimediaKit';

let player = await avPlayer.createAvPlayer();
player.stateChangeCallback = (state: string, reason: avPlayer.StateChangeReason) => {
  switch (state) {
    case 'initialized':
      player.url = 'https://example.com/audio.mp3';
      player.prepare().then(() => player.play());
      break;
    case 'playing':
      console.log('Playing');
      break;
    case 'paused':
      console.log('Paused');
      break;
  }
};
player.src = 'https://example.com/audio.mp3';
```

## 音频录制

```typescript
import { avRecorder } from '@kit.MultimediaKit';

let recorder = await avRecorder.createAvRecorder();
let config: avRecorder.AVRecorderConfig = {
  audioCaptureDevice: avRecorder.AudioCaptureDevice.MIC,
  audioEncoder: avRecorder.AudioEncoder.AAC_LC,
  audioSampleRate: 44100,
  audioChannels: 2,
  audioBitrate: 192000,
  url: 'file://path/to/record.m4a'
};
await recorder.prepare(config);
await recorder.start();
// ... 录制中
await recorder.stop();
await recorder.release();
```

## 视频播放

```typescript
// 使用 Video 组件
Video({
  src: 'https://example.com/video.mp4',
  previewUri: $r('app.media.poster'),
  currentProgressRate: 1.0
})
.width('100%')
.height(300)
.controls(true)
.autoPlay(false)
.loop(false)
.onStart(() => {})
.onPause(() => {})
.onFinish(() => {})
.onError(() => {})

// 使用 AVPlayer（程序化控制）
let videoPlayer = await avPlayer.createAvPlayer();
videoPlayer.url = 'file://path/to/video.mp4';
await videoPlayer.prepare();
let duration = videoPlayer.duration;
await videoPlayer.play();
```

## 相机

```typescript
import { camera } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';

// 获取相机管理
let cameraManager = camera.getCameraManager(getContext(this));
let cameraDevices = await cameraManager.getSupportedCameras();

// 创建输入
let cameraInput = await cameraManager.createCameraInput(cameraDevices[0]);
await cameraInput.open();

// 创建输出
let photoOutput = await cameraManager.createPhotoOutput(camera.SurfaceType.PHOTO);
// 拍照
photoOutput.capture({
  quality: camera.QualityLevel.QUALITY_LEVEL_HIGH
}, (err, photo) => {
  if (err) { return; }
  // photo.main 为 PixelMap
});

// 创建预览
let previewOutput = await cameraManager.createPreviewOutput(
  camera.SurfaceType.VIDEO, surfaceId
);
await previewOutput.start();

// 释放
await cameraInput.close();
cameraManager.release();
```

## 图片处理

```typescript
import { image } from '@kit.ImageKit';

// 加载图片
let imageSource = image.createImageSource('file://path/to/image.jpg');
let pixelMap = await imageSource.createPixelMap({
  desiredWidth: 200,
  desiredHeight: 200,
  desiredPixelFormat: image.PixelMapFormat.RGBA_8888
});

// 裁剪
let region: image.Region = { x: 0, y: 0, width: 100, height: 100 };
let cropped = await pixelMap.crop(region);

// 缩放
await pixelMap.scale(0.5, 0.5);

// 保存
let packer = image.createImagePacker();
let packedData = await packer.packing(pixelMap, { format: 'image/jpeg', quality: 80 });
// packedData 可写为文件或上传
```
