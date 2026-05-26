---
name: harmonyos-next-dev
description: 协助 HarmonyOS NEXT (API 20+) 应用开发，使用 ArkTS + ArkUI 声明式 UI 框架。覆盖应用框架(UIAbility/UIExtensionAbility/ExtensionAbility/页面路由Navigation/MultiNavigation)、系统能力(通知/弹窗/权限/传感器/蓝牙/Wi-Fi/NFC/设备信息)、媒体(音视频/相机/图片/AVRecorder/streamVolumeChange)、图形(Canvas/动画/XComponent)、应用服务(定位/推送/网络/数据持久化)、后台任务(workScheduler/长时短时任务)、安全认证(UserAuth/HUKS/生物识别)、AI(端侧AI推理/MindSpore Lite/AI Kit)、专题(性能优化/安全/多设备流转)、国际化(i18n/intl)、元服务(原子化服务/万能卡片/快捷方式)、电话与短信(通话/SMS/蜂窝网络)、实况窗(Live View)、分布式能力(设备发现/KVStore/RPC/文件)、数据共享(DataShare)、拖拽(Drag & Drop)、无障碍服务(Accessibility)、多设备适配(响应式布局/断点/折叠屏)及开发工具(DevEco Studio/hvigor/hdc/ohpm)。当用户提到鸿蒙、HarmonyOS、ArkTS、ArkUI、NEXT、API 20、元服务、万能卡片、Stage模型、DevEco Studio、UIExtensionAbility、WaterFlow、HUKS、UserAuth 等关键词时自动触发。
---

# HarmonyOS NEXT 开发指南

## 触发场景

以下场景应自动应用此 Skill：

- 用户询问鸿蒙开发相关问题（语法、API、架构、配置等）
- 用户要求编写或修改 ArkTS / ArkUI 代码
- 用户涉及元服务、万能卡片、原子化服务开发
- 用户需要排查鸿蒙项目编译/运行/签名问题
- 用户询问 DevEco Studio / hvigor / hdc 工具用法

## 快速开始

### 标准项目结构

```
MyHarmonyApp/
├── AppScope/                 # 应用全局配置
│   ├── app.json5             # 应用级配置：bundleName、icon、label、version
│   └── resources/            # 应用级资源
├── entry/                    # Entry 类型 HAP 包（主模块）
│   ├── src/main/
│   │   ├── ets/              # ArkTS 源代码
│   │   │   ├── entryability/ # UIAbility 生命周期入口
│   │   │   ├── pages/        # 页面组件（.ets 文件）
│   │   │   ├── viewmodel/    # 视图模型/数据层
│   │   │   └── utils/        # 工具函数
│   │   ├── resources/        # 模块级资源(base/en_US/zh_CN)
│   │   │   ├── base/         # 默认资源
│   │   │   ├── en_US/        # 英文资源
│   │   │   └── zh_CN/        # 中文资源
│   │   └── module.json5      # 模块配置（Ability声明、权限等）
│   ├── oh-package.json5      # 依赖声明（ohpm）
│   └── build-profile.json5   # 构建配置
├── feature/                  # Feature 类型 HAP（可选功能模块）
├── shared/                   # Shared 类型 HSP（共享包）
├── oh-package.json5          # 全局 ohpm 配置
├── hvigor/                   # 构建工具配置
│   └── hvigor-config.json5
├── build-profile.json5       # 全局构建配置
├── local.properties          # 本地 SDK 路径
└── hvigorw / hvigorw.bat    # 构建脚本
```

### app.json5 — 应用级配置

```json
{
  "app": {
    "bundleName": "com.example.myapp",
    "vendor": "example",
    "versionCode": 1000001,
    "versionName": "1.0.0",
    "icon": "$media:app_icon",
    "label": "$string:app_name",
    "targetAPIVersion": 20,
    "minAPIVersion": 20,
    "apiReleaseType": "Release",
    "debug": true,
    "multiAppMode": {
      "multiAppModeType": "appClone",
      "maxCount": 5
    }
  }
}
```

### module.json5 — 模块级配置

```json
{
  "module": {
    "name": "entry",
    "type": "entry",
    "srcEntry": "./ets/entryability/EntryAbility.ts",
    "description": "$string:entry_desc",
    "mainElement": "EntryAbility",
    "deviceTypes": ["phone", "tablet", "2in1"],
    "abilities": [{
      "name": "EntryAbility",
      "srcEntry": "./ets/entryability/EntryAbility.ts",
      "description": "$string:EntryAbility_desc",
      "icon": "$media:icon",
      "label": "$string:EntryAbility_label",
      "startWindowIcon": "$media:icon",
      "startWindowBackground": "$color:start_window_background",
      "exported": true,
      "launchType": "singleton",
      "skills": [{
        "entities": ["entity.system.home"],
        "actions": ["action.system.home"]
      }]
    }],
    "requestPermissions": [
      { "name": "ohos.permission.INTERNET" },
      { "name": "ohos.permission.GET_NETWORK_INFO" }
    ]
  }
}
```

### Hello World

```typescript
// EntryAbility.ts
import { UIAbility, AbilityConstant, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {}

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index');
  }

  onForeground(): void {}
  onBackground(): void {}
  onDestroy(): void {}
}
```

```typescript
// pages/Index.ets
@Entry
@Component
struct Index {
  @State message: string = 'Hello HarmonyOS NEXT!';

  build() {
    Column() {
      Text(this.message)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)

      Button('点击改变')
        .type(ButtonType.Capsule)
        .margin({ top: 20 })
        .onClick(() => {
          this.message = '欢迎使用 HarmonyOS NEXT！';
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### oh-package.json5 — 依赖声明

```json
{
  "name": "entry",
  "version": "1.0.0",
  "main": "",
  "dependencies": {
    "@ohos/camera": "20.0.0",
    "@ohos/hypium": "1.0.17"
  }
}
```

安装依赖：在模块目录执行 `ohpm install`

## 模块参考导航

| 模块 | 文件 | 核心内容 |
|------|------|----------|
| 📘 ArkTS 语言 | [arkts-language.md](references/arkts-language.md) | 类型系统、装饰器、并发(TaskPool/Worker)、异步编程、类/接口/枚举、TS限制、$$绑定、@Reusable/@BuilderParam、@Monitor(V2) |
| 🎨 ArkUI 声明式 UI | [arkui-components.md](references/arkui-components.md) | 组件(Text/Button/Image/Input/List/Swiper/Tabs/Select/Sheet/Panel)、布局(RelativeContainer/Grid/WaterFlow)、动画、状态管理 V1+V2、MultiNavigation |
| 🏗 应用框架 | [application-framework.md](references/application-framework.md) | UIAbility、UIExtensionAbility、ExtensionAbility、Navigation(UIContext+getRouter 替代旧 router API)、NavPathStack、Want/Context、AbilityStage、Window管理、BundleManager |
| ⚙️ 系统能力 | [system-capabilities.md](references/system-capabilities.md) | 通知、弹窗、权限、剪贴板、传感器、电源管理、蓝牙、Wi-Fi、NFC、设备信息、电池信息 |
| 🎵 媒体 | [media.md](references/media.md) | 音频管理(AudioManager/streamVolumeChange 替代 volumeChange)、音频焦点、音频录制/播放、AVPlayer/AVRecorder、视频、相机、图片处理 |
| 🎨 图形 | [graphics.md](references/graphics.md) | Canvas 2D 绘制、属性动画、显式动画、XComponent、自定义组件 |
| 🛠 应用服务 | [app-services.md](references/app-services.md) | 定位、推送、HTTP/WebSocket/上传下载、数据持久化(KVStore/RDB/Preferences)、文件读写 |
| 🤖 AI | [ai.md](references/ai.md) | 端侧 AI 推理、MindSpore Lite、AI Kit(OCR/图像分割/分类/ASR/TTS/人脸/条码/翻译/关键点/场景) |
| 📚 专题 | [special-topics.md](references/special-topics.md) | 性能优化(LazyForEach/TaskPool)、加密、多设备流转、Stage 模型适配、常见错误码 |
| 📱 元服务 | [meta-services.md](references/meta-services.md) | 原子化服务、万能卡片(FormKit)、快捷方式、CryptoKit |
| 🕐 国际化 | [i18n-localization.md](references/i18n-localization.md) | intl(i18n)、字符串本地化、日期/数字/货币格式化、时区、历法 |
| 🛡 安全与认证 | [security-authentication.md](references/security-authentication.md) | UserAuth(指纹/人脸)、HUKS 密钥管理、证书管理 |
| 🏃 后台任务 | [background-tasks.md](references/background-tasks.md) | 短时任务(transientTask)、长时任务(continuousTask)、延迟任务(workScheduler)、效率资源 |
| 🔧 工具及更多 | [tools.md](references/tools.md) | DevEco Studio、hvigor、hdc 调试、hilog 日志、打包签名、ohpm、单元测试、Profiler |
| 📞 电话与短信 | [telephony.md](references/telephony.md) | 拨号、通话状态、SIM卡、短信收发、蜂窝网络、信号强度、IMS/VoLTE |
| 🪟 实况窗 | [live-view.md](references/live-view.md) | Live View API 11+、锁屏动态卡片、状态栏胶囊、liveViewManager、场景类型(TAXI/DELIVERY/FLIGHT等)、创建/更新/结束(API 20+ 支持更多 event 类型) |
| 🔄 分布式能力 | [distributed-capabilities.md](references/distributed-capabilities.md) | 设备发现、分布式KVStore、RPC远程调用、分布式文件、跨设备Ability启动、分布式RDB |
| 📋 数据共享 | [data-sharing.md](references/data-sharing.md) | DataShareExtensionAbility、Provider-Consumer、URI、DataSharePredicates、跨应用数据访问 |
| 🖱 拖拽能力 | [drag-drop.md](references/drag-drop.md) | 应用内/跨应用拖拽、列表排序、拖拽源/目标、UnifiedData、DragEvent |
| ♿ 无障碍服务 | [accessibility.md](references/accessibility.md) | AccessibilityExtensionAbility、accessibility标签/属性、高对比度/字体适配、TalkBack |
| 📱 多设备适配 | [multi-device-adaptation.md](references/multi-device-adaptation.md) | 断点系统、响应式布局、Navigation自适应、折叠屏、栅格策略、尺寸单位 |

## 核心要点速查

| 要点 | 说明 |
|------|------|
| 🌟 语言 | ArkTS（基于 TypeScript，增强静态类型和声明式 UI） |
| 🏗 模型 | **Stage 模型**（非 FA 模型），Ability 为基本调度单元 |
| 🎨 UI 框架 | ArkUI 声明式 UI，类似 SwiftUI / Jetpack Compose |
| 📦 包类型 | HAP（应用包）、HSP（共享包）、APP（上架包） |
| 📥 导包方式 | `import { xxx } from '@kit.ModuleName'`（API 20+ 部分模块有新增 Kit） |
| 🎨 资源引用 | `$r('app.string.xxx')`、`$media('icon')`、`$rawfile('xxx.json')` |
| 🧵 线程模型 | UI 线程（主线程）+ TaskPool（多线程）+ Worker（独立线程） |
| 🛡 权限模型 | 按需声明，敏感权限需弹窗授权 |

## 常用 @kit.* 模块路径速查

| 模块 | Kit 路径 | 主要功能 |
|------|---------|----------|
| AbilityKit | `@kit.AbilityKit` | UIAbility、ExtensionAbility、Want、Context、taskpool、worker |
| ArkUI | `@kit.ArkUI` | 所有 UI 组件、router、Navigation、动画、Canvas、promptAction |
| ArkData | `@kit.ArkData` | relationalStore（RDB）、preferences（偏好存储） |
| NetworkKit | `@kit.NetworkKit` | http、webSocket、request（上传下载）、connection（网络状态） |
| NotificationKit | `@kit.NotificationKit` | notificationManager 通知发送/管理 |
| MultimediaKit | `@kit.MultimediaKit` | AVPlayer、AVRecorder、AVMuxer、Video 组件 |
| AudioKit | `@kit.AudioKit` | AudioRenderer、AudioCapturer、AudioManager |
| CameraKit | `@kit.CameraKit` | camera 相机管理 |
| ImageKit | `@kit.ImageKit` | image 图片处理（PixelMap、ImageSource） |
| LocationKit | `@kit.LocationKit` | geoLocationManager 定位 |
| CoreFileKit | `@kit.CoreFileKit` | fileIo 文件读写 |
| DistributedKVStoreKit | `@kit.DistributedKVStoreKit` | distributedKVStore 分布式键值存储 |
| BackgroundTasksKit | `@kit.BackgroundTasksKit` | backgroundTaskManager、workScheduler |
| UserAuthKit | `@kit.UserAuthKit` | userAuth 生物识别认证 |
| HuksKit | `@kit.HuksKit` | huks 密钥管理 |
| LocalizationKit | `@kit.LocalizationKit` | intl（国际化）、i18n（本地化） |
| CoreVisionKit | `@kit.CoreVisionKit` | textRecognition 文字识别 |
| BarCodeKit | `@kit.BarCodeKit` | barcodeScanner 条码扫描 |
| SpeechRecognizerKit | `@kit.SpeechRecognizerKit` | speechRecognizer 语音识别 |
| SpeechKit | `@kit.SpeechKit` | textToSpeech 语音合成 |
| ConnectivityKit | `@kit.ConnectivityKit` | bluetooth、wifiManager、NFC |
| BasicServicesKit | `@kit.BasicServicesKit` | BusinessError、deviceInfo、batteryInfo |
| FormKit | `@kit.FormKit` | 万能卡片（FormExtensionAbility） |
| CryptoArchitectureKit | `@kit.CryptoArchitectureKit` | cryptoFramework 加解密 |
| PushServiceKit | `@kit.PushServiceKit` | pushService 推送服务 |
| PerformanceAnalysisKit | `@kit.PerformanceAnalysisKit` | hilog 日志 |
| PasteboardKit | `@kit.PasteboardKit` | pasteboard 剪贴板 |
| SensorServiceKit | `@kit.SensorServiceKit` | sensor 传感器 |
| PowerManagerKit | `@kit.PowerManagerKit` | brightness、runningLock、vibrator |
| AccountKit | `@kit.AccountKit` | account 账号管理 |
| DistributedServiceKit | `@kit.DistributedServiceKit` | deviceManager 设备发现 |
| MindSporeLiteKit | `@kit.MindSporeLiteKit` | mindSporeLite 端侧 AI 推理 |
| FaceKit | `@kit.FaceKit` | faceDetector 人脸检测 |
| TranslationKit | `@kit.TranslationKit` | translator 文本翻译 |
| TelephonyKit | `@kit.TelephonyKit` | call/telephony/radio/sms/data/ims 电话与短信 |
| DataShareKit | `@kit.DataShareKit` | dataShare 跨应用数据共享 |
| AccessibilityKit | `@kit.AccessibilityKit` | accessibility 无障碍服务 |
| ShortcutManagerKit | `@kit.ShortcutManagerKit` | shortcutManager 快捷方式 |
| LiveViewKit | `@kit.LiveViewKit` | liveViewManager 实况窗（锁屏卡片/状态栏胶囊） |
| RingtoneKit | `@kit.RingtoneKit` | ringtone 铃声管理（API 20+ 新增独立 Kit） |
| AvCastEngineKit | `@kit.AvCastEngineKit` | avCast 投屏能力 |
