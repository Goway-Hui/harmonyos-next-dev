# 实况窗 (Live View) 参考

## 概述

实况窗（Live View）是锁屏和状态栏胶囊区域显示实时活动信息的功能，适用于外卖配送、打车、航班、音乐播放等场景。

- API 11+ 引入，API 20+ 增强事件类型
- 通过 `liveViewManager` 管理
- 支持锁屏卡片和状态栏胶囊两种展示形态

## 创建实况窗

```typescript
import { liveViewManager } from '@kit.LiveViewKit';
import { BusinessError } from '@kit.BasicServicesKit';

// 创建实况窗配置
let config: liveViewManager.LiveViewConfig = {
  bundleName: 'com.example.myapp',
  abilityName: 'EntryAbility',
  // 场景类型
  type: liveViewManager.LiveViewType.TAXI
};

// 创建实况窗
liveViewManager.create(config).then((data) => {
  console.log(`LiveView created: ${data}`);
}).catch((err: BusinessError) => {
  console.error('Failed to create', err);
});
```

## 场景类型

```typescript
// 支持的 LiveViewType
LiveViewType {
  TAXI,       // 打车
  DELIVERY,   // 外卖配送
  FLIGHT,     // 航班
  TRAIN,      // 火车
  BUS,        // 公交
  EXERCISE,   // 运动
  NAVIGATION, // 导航
  MUSIC,      // 音乐
  TIMER,      // 计时器
  OTHER       // 其他
}
```

## 更新实况窗

```typescript
// 更新实时数据
let updateData: liveViewManager.LiveViewData = {
  // API 20+ 支持更多 event 类型
  event: 'progress',
  data: {
    title: '司机正在赶来',
    description: '预计 5 分钟到达',
    status: 'driver_arriving',
    // 额外自定义数据
    eta: 300,
    driverName: '张师傅',
    plateNumber: '京B12345'
  }
};

liveViewManager.update(updateData).then(() => {
  console.log('LiveView updated');
}).catch((err) => {
  console.error('Update failed', err);
});
```

## 结束实况窗

```typescript
liveViewManager.destroy().then(() => {
  console.log('LiveView ended');
}).catch((err) => {
  console.error('Destroy failed', err);
});
```

## 完整示例：外卖配送

```typescript
import { liveViewManager } from '@kit.LiveViewKit';

export class DeliveryLiveViewManager {
  async createDeliveryLiveView() {
    // 创建
    await liveViewManager.create({
      bundleName: 'com.example.myapp',
      abilityName: 'EntryAbility',
      type: liveViewManager.LiveViewType.DELIVERY
    });

    // 更新：商家已接单
    await liveViewManager.update({
      event: 'confirmed',
      data: {
        title: '商家已接单',
        description: '预计 30 分钟送达',
        status: 'preparing'
      }
    });

    // 更新：骑手已取餐
    await liveViewManager.update({
      event: 'picked_up',
      data: {
        title: '骑手已取餐',
        description: '正在向您赶来',
        status: 'delivering'
      }
    });

    // 更新：即将送达
    await liveViewManager.update({
      event: 'arriving',
      data: {
        title: '骑手即将到达',
        description: '还有 3 分钟',
        status: 'nearby'
      }
    });

    // 完成
    await liveViewManager.destroy();
  }
}
```

## 监听实况窗事件

```typescript
// 监听用户点击实况窗
liveViewManager.on('click', (data) => {
  console.log('User clicked Live View');
  // 打开对应页面
});
```

## 权限声明

```json
{
  "requestPermissions": [
    { "name": "ohos.permission.LIVE_VIEW" }
  ]
}
```
