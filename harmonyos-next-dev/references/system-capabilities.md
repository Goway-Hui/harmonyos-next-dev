# 系统能力参考

## 通知

```typescript
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';

// 发布通知
let request: notificationManager.NotificationRequest = {
  id: 1,
  content: {
    contentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
    normal: {
      title: '通知标题',
      text: '通知内容'
    }
  },
  slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION
};

notificationManager.publish(request).then(() => {
  console.log('Notification published');
}).catch((err: BusinessError) => {
  console.error('Failed', err);
});

// 取消通知
notificationManager.cancel(1);
notificationManager.cancelAll();
```

## 弹窗

```typescript
import { promptAction } from '@kit.ArkUI';

// Toast
promptAction.showToast({ message: '操作成功', duration: 2000 });

// 对话框
promptAction.showDialog({
  title: '确认',
  message: '确定执行此操作？',
  buttons: [
    { text: '取消', color: '#666' },
    { text: '确定', color: '#007DFF' }
  ]
}).then((result) => {
  if (result.index === 1) { /* 确定 */ }
});
```

## 权限

```typescript
// module.json5 声明
{
  "requestPermissions": [
    { "name": "ohos.permission.CAMERA", "reason": "$string:camera_reason" },
    { "name": "ohos.permission.MICROPHONE", "reason": "$string:mic_reason" },
    { "name": "ohos.permission.LOCATION", "reason": "$string:location_reason" }
  ]
}

// 运行时弹窗授权（敏感权限自动弹窗）
// 检查权限
import { abilityAccessCtrl } from '@kit.AbilityKit';
let atManager = abilityAccessCtrl.createAtManager();
let grantStatus = await atManager.checkAccessToken(token, 'ohos.permission.CAMERA');
if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
  // 已授权
}
```

## 剪贴板

```typescript
import { pasteboard } from '@kit.PasteboardKit';
let pb = pasteboard.getSystemPasteboard();
// 写入
let data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, 'Hello');
await pb.setData(data);
// 读取
let text = (await pb.getData()).getPrimaryText();
```

## 传感器

```typescript
import { sensor } from '@kit.SensorServiceKit';

// 加速度计
sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
  console.log(`x:${data.x}, y:${data.y}, z:${data.z}`);
});

// 陀螺仪
sensor.on(sensor.SensorId.GYROSCOPE, (data: sensor.GyroscopeResponse) => {});

// 方向
sensor.on(sensor.SensorId.ORIENTATION, (data: sensor.OrientationResponse) => {
  console.log(`alpha:${data.alpha}, beta:${data.beta}, gamma:${data.gamma}`);
});

// 停止监听
sensor.off(sensor.SensorId.ACCELEROMETER);
```

## 蓝牙

```typescript
import { bluetooth } from '@kit.ConnectivityKit';

// 开启蓝牙
bluetooth.enableBluetooth();
// 搜索设备
bluetooth.startBluetoothDiscovery();
bluetooth.on('bluetoothDeviceFind', (devices: Array<bluetooth.BLEProfile.BLEDevice>) => {
  devices.forEach(device => {
    console.log(`Found: ${device.deviceName}, ${device.deviceId}`);
  });
});
// 停止搜索
bluetooth.stopBluetoothDiscovery();
```

## Wi-Fi

```typescript
import { wifiManager } from '@kit.ConnectivityKit';

// 获取 Wi-Fi 状态
let isActive = wifiManager.isWifiActive();
// 扫描
wifiManager.scan();
let scanResults = wifiManager.getScanResults();
// 连接
wifiManager.connectToNetwork('MyWiFi', 'password', wifiManager.WifiSecurityTag.WPA2);
```

## NFC

```typescript
import { tag } from '@kit.ConnectivityKit';

// 启动 NFC 标签读取
tag.on('tagDiscover', (tagInfo: tag.TagInfo) => {
  console.log(`Tag discovered: ${tagInfo.tagId}`);
});
```

## 设备信息

```typescript
import { deviceInfo } from '@kit.BasicServicesKit';

let brand = deviceInfo.brand;         // 品牌
let model = deviceInfo.model;         // 型号
let osVersion = deviceInfo.osVersion;  // 系统版本
let udid = deviceInfo.udid;            // 设备唯一标识
```
