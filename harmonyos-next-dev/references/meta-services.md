# 元服务参考

## 元服务概述

元服务（Atomic Service）是 HarmonyOS 的轻量级免安装应用，用户即用即走。通过万能卡片（Form）、快捷方式（Shortcut）等方式触达用户。

## 原子化服务

- 无 `entry` 类型 HAP，使用 `feature` 类型
- 免安装运行
- 通过卡片或快捷方式分发
- 包体积限制：最大 10MB

## 万能卡片

### 卡片配置

在 module.json5 中声明：

```json
{
  "abilities": [{
    "name": "EntryFormAbility",
    "srcEntry": "./ets/entryability/EntryFormAbility.ts",
    "type": "form"
  }],
  "forms": [{
    "name": "Widget",
    "displayName": "$string:widget_name",
    "description": "$string:widget_desc",
    "src": "./ets/pages/WidgetPage.ets",
    "window": {
      "designWidth": 320,
      "autoDesignWidth": true
    },
    "formConfigAbility": "ability://com.example.myapp.EntryAbility",
    "isDefault": true,
    "updateEnabled": true,
    "scheduledUpdateTime": "10:30",
    "updateDuration": 1,
    "defaultDimension": "2*2",
    "supportDimensions": ["1*2", "2*2", "2*4", "4*4"]
  }]
}
```

### FormExtensionAbility

```typescript
import { FormExtensionAbility } from '@kit.FormKit';
import { formBindingData } from '@kit.FormKit';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want) {
    let data = formBindingData.createFormBindingData({
      title: '我的卡片',
      content: '最新数据'
    });
    return data;
  }

  onUpdateForm(formId) {
    let data = formBindingData.createFormBindingData({
      content: '更新数据'
    });
    formProvider.updateForm(formId, data);
  }

  onRemoveForm(formId) {
    console.log(`Form ${formId} removed`);
  }

  onCastToNormalForm(formId) {
    // 临时卡片转常态
  }
}
```

### 卡片页面

```typescript
// WidgetPage.ets
@Entry
@Component
struct WidgetCard {
  @State title: string = '';
  @State content: string = '';

  build() {
    Column() {
      Text(this.title)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)

      Text(this.content)
        .fontSize(12)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
  }
}
```

### 数据更新

```typescript
import { formProvider } from '@kit.FormKit';
import { formBindingData } from '@kit.FormKit';

// 主动更新卡片
let data = formBindingData.createFormBindingData({
  content: '新消息'
});
formProvider.updateForm(formId, data);

// 定时更新（在配置中设置 updateDuration）
// updateDuration 单位：30 分钟，最小间隔 30 分钟
```

## 快捷方式

```typescript
import { shortcutManager } from '@kit.ShortcutManagerKit';

// 创建快捷方式
let shortcut: shortcutManager.ShortcutInfo = {
  id: 'quick_action',
  label: '快捷操作',
  icon: $media('shortcut_icon'),
  wants: [{
    bundleName: 'com.example.myapp',
    abilityName: 'EntryAbility',
    parameters: { action: 'quick' }
  }]
};

shortcutManager.createShortcut(shortcut).then(() => {
  console.log('Shortcut created');
}).catch((err) => {
  console.error('Failed', err);
});

// 禁用/启用
shortcutManager.disableShortcut('quick_action');
shortcutManager.enableShortcut('quick_action');
```

## CryptoKit（元服务加密）

```typescript
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

// 密钥生成
let generator = cryptoFramework.createAsyKeyGenerator('ECC256');
let keyPair = await generator.generateKeyPair();

// 签名
let signer = cryptoFramework.createSign('ECC256|SHA256');
await signer.init(keyPair.pubKey);
let signature = await signer.sign({ data: new Uint8Array([...]) });

// 验签
let verifier = cryptoFramework.createVerify('ECC256|SHA256');
await verifier.init(keyPair.priKey);
let isValid = await verifier.verify({ data: new Uint8Array([...]) }, signature);
```
