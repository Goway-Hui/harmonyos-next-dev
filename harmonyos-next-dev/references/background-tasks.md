# 后台任务参考

## 概述

HarmonyOS 后台任务分为三类：

| 任务类型 | 适用场景 | 时长限制 |
|---------|---------|---------|
| 短时任务 | 保存状态、发送消息 | 约 3 分钟 |
| 长时任务 | 音乐播放、运动记录、导航 | 持续运行 |
| 延迟任务 | 后台同步、数据预取 | 按间隔触发 |

## 短时任务 (Transient Task)

```typescript
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';

// 申请短时任务
let requestId = backgroundTaskManager.requestSuspendDelay('saving_data', () => {
  // 即将超时的回调，需要紧急保存
  console.log('Time is running out!');
});

console.log(`剩余时间: ${requestId.actualDelayTime}ms`);

// 任务完成，释放
backgroundTaskManager.cancelSuspendDelay(requestId.requestId);
```

## 长时任务 (Continuous Task)

```typescript
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';

// 申请长时任务（必须在模块配置中声明）
let config: backgroundTaskManager.ContinuousTaskParam = {
  // 任务类型（需和 module.json5 一致）
  type: backgroundTaskManager.ContinuousTaskType.AUDIO_PLAYBACK,
  // 通知 ID（需先创建通知）
  notificationId: 1
};

try {
  await backgroundTaskManager.startBackgroundRunning(
    getContext(this),
    backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,
    config
  );
  console.log('Background running started');
} catch (err) {
  console.error('Failed to start', err);
}

// 停止
backgroundTaskManager.stopBackgroundRunning(
  getContext(this),
  backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK
);
```

### module.json5 声明

```json
{
  "module": {
    "name": "entry",
    "requestPermissions": [{
      "name": "ohos.permission.KEEP_BACKGROUND_RUNNING"
    }],
    "backgroundModes": ["audioPlayback", "location"]
  }
}
```

### 支持的 BackgroundMode

| 模式 | 说明 |
|------|------|
| `AUDIO_PLAYBACK` | 音频播放 |
| `LOCATION` | 定位导航 |
| `VOIP` | 音视频通话 |
| `TASK_KEEPING` | 任务处理 |
| `AUDIO_RECORDING` | 音频录制 |

## 延迟任务 (Work Scheduler)

```typescript
import { workScheduler } from '@kit.BackgroundTasksKit';

// 创建工作任务
let workInfo: workScheduler.WorkInfo = {
  workId: 1001,
  bundleName: 'com.example.myapp',
  // 触发条件
  triggerInfo: {
    // 1. 延迟触发（秒）
    delayTime: 3600,
    // 2. 网络条件
    networkType: workScheduler.NetworkType.NETWORK_TYPE_WIFI,
    // 3. 充电条件
    chargerType: workScheduler.ChargerType.CHARGING_TYPE_ANY,
    // 4. 空闲条件
    isIdle: true,
    // 5. 重复间隔（秒，0=不重复）
    repeatInterval: 86400
  }
};

// 申请任务
workScheduler.startWork(workInfo);

// 取消任务
workScheduler.stopWork(workInfo, true);

// 获取所有工作任务
workScheduler.obtainAllWorks().then(works => {
  works.forEach(w => console.log(`Work ${w.workId}`));
});

// 查询特定任务
workScheduler.isLastWorkTimeOut(1001).then(isTimeout => {
  console.log(`Work timeout: ${isTimeout}`);
});
```

### Work Scheduler 触发条件

| 条件 | 类型 | 说明 |
|------|------|------|
| `delayTime` | number | 延迟 N 秒后触发 |
| `networkType` | enum | 网络条件（WiFi/蜂窝/不限） |
| `chargerType` | enum | 充电条件 |
| `isIdle` | boolean | 设备空闲时 |
| `repeatInterval` | number | 重复间隔（秒） |
| `intervalRequest` | number | 最小间隔（毫秒） |
| `batteryLevel` | number | 电池电量阈值 |
| `storageLevel` | number | 存储空间阈值 |

## 效率资源

```typescript
import { effectResource } from '@kit.BackgroundTasksKit';

// 申请高效率资源（如 GPS 快速定位）
let resource = effectResource.createEffectResource(
  getContext(this),
  'work_scheduler'
);
resource.request({
  duration: 5000  // 5秒高效率
}).then(() => {
  console.log('Resource granted');
});
```
