# 应用框架参考

## Stage 模型

Stage 模型是 HarmonyOS 推荐的应用模型，UIAbility 为基本调度单元。

## UIAbility

```typescript
import { UIAbility, AbilityConstant, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  // 创建时
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // want: 启动参数
    // launchParam: 启动原因（cold/warm start）
  }

  // 窗口创建
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 加载页面
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        console.error('Failed to load content', err);
        return;
      }
    });
  }

  // 前台
  onForeground(): void {}

  // 后台
  onBackground(): void {}

  // 窗口销毁
  onWindowStageDestroy(): void {}

  // 销毁
  onDestroy(): void {}
}
```

### LaunchType

```json
{
  "launchType": "singleton"  // 单实例（默认）
  // "multiton"  // 多实例
  // "specified" // 按需指定
}
```

### Want — Ability 间通信

```typescript
// 启动 Ability
import { common, Want } from '@kit.AbilityKit';
let context = getContext(this) as common.UIAbilityContext;

// 启动另一个 Ability
let want: Want = {
  bundleName: 'com.example.target',
  abilityName: 'EntryAbility',
  parameters: { key: 'value' }
};
context.startAbility(want);

// 启动并获取结果
context.startAbilityForResult(want).then((result) => {
  let data = result.want?.parameters;
}).catch((err) => {
  console.error('Failed', err);
});
```

## UIExtensionAbility

用于嵌入其他应用的 UI（如元服务卡片、输入法等）：

```typescript
import { UIExtensionAbility, UIExtensionContentSession, Want } from '@kit.AbilityKit';

export default class MyExtension extends UIExtensionAbility {
  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    session.loadContent('pages/ExtensionPage');
  }

  onSessionDestroy(session: UIExtensionContentSession): void {
    console.log('Session destroyed');
  }
}
```

## ExtensionAbility（无界面）

```typescript
import { ExtensionAbility } from '@kit.AbilityKit';

export default class MyService extends ExtensionAbility {
  onCreate(): void {}
  onDestroy(): void {}
}
```

## Navigation — 页面路由

API 20+ 推荐使用 `UIContext` + `NavPathStack`：

```typescript
import { UIContext } from '@kit.ArkUI';

@Entry
@Component
struct MainPage {
  private navStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.navStack) {
      Column() {
        Button('Go to Detail')
          .onClick(() => {
            this.navStack.pushPath({ name: 'Detail', param: { id: 123 } });
          })
      }
    }
    .navDestination(this.pageMap)
  }

  @Builder
  pageMap(name: string, param: object) {
    if (name === 'Detail') {
      DetailPage({ id: (param as Record<string, number>).id });
    }
  }
}
```

### NavPathStack API

```typescript
// 推入页面
navStack.pushPath({ name: 'PageName', param: { key: value } });
navStack.pushPathByName('PageName', { key: value });

// 替换当前
navStack.replacePath({ name: 'NewPage', param: {} });

// 返回
navStack.pop();               // 返回上一页
navStack.popToName('Home');   // 返回到指定页
navStack.clear();             // 清空栈

// 获取
let params = navStack.getParamByName('PageName'); // 获取指定页参数
navStack.getPathInfo();       // 获取当前页信息
navStack.size();              // 栈大小
```

### 获取 UIContext 的 Navigation

```typescript
let uiContext: UIContext = this.getUIContext?.();
let router = uiContext.getRouter();
router.pushUrl({ url: 'pages/Detail', params: { id: 1 } });
```

## AbilityStage

```typescript
import { AbilityStage } from '@kit.AbilityKit';

export default class MyAbilityStage extends AbilityStage {
  onCreate(): void {
    // 模块初始化
  }

  onAcceptWant(want: Want): string {
    // launchType: specified 时调用
    return 'instanceKey';
  }
}
```

## Window 管理

```typescript
// 获取主窗口
let windowClass = window.getLastWindow(getContext(this));
await windowClass.setWindowLayoutFullScreen(true);
await windowClass.setWindowSystemBarEnable(['navigation']);

// 创建子窗口
let subWindow = await window.createWindow('sub', window.WindowType.TYPE_APP, getContext(this));
await subWindow.resize(500, 400);
await subWindow.moveTo(100, 100);
await subWindow.showWindow();
await subWindow.destroyWindow();
```

## BundleManager

```typescript
import { bundleManager } from '@kit.AbilityKit';
let bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
let versionName = bundleInfo.versionName;
let bundleName = bundleInfo.name;
```
