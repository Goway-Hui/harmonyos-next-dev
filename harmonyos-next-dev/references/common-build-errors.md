# HarmonyOS NEXT 常见构建错误指南

## 概述

本文档总结了从零构建 HarmonyOS NEXT 项目时常见的错误及解决方案。

---

## 1. 配置文件缺失错误

### 1.1 hvigorfile.ts 缺失

**错误信息：**
```
hvigor ERROR: Hvigorfile not found. At file: xxx/hvigorfile.ts
```

**解决方案：**

项目根目录 `hvigorfile.ts`：
```typescript
import { appTasks } from '@ohos/hvigor-ohos-plugin';

export default {
  system: appTasks,
  plugins: []
}
```

模块目录 `entry/hvigorfile.ts`：
```typescript
import { hapTasks } from '@ohos/hvigor-ohos-plugin';

export default {
  system: hapTasks,
  plugins: []
}
```

### 1.2 build-profile.json5 缺失

**错误信息：**
```
hvigor ERROR: 00304056 Not Found
Error Message: Can not find build config file build-profile.json5 at 'entry'
```

**解决方案：** 创建 `entry/build-profile.json5`：
```json
{
  "apiType": "stageMode",
  "buildOption": {
    "resOptions": {
      "copyCodeResource": {
        "enable": false
      }
    }
  },
  "buildOptionSet": [
    {
      "name": "release",
      "arkOptions": {
        "obfuscation": {
          "ruleOptions": {
            "enable": false,
            "files": ["./obfuscation-rules.txt"]
          }
        }
      }
    }
  ],
  "targets": [
    { "name": "default" },
    { "name": "ohosTest" }
  ]
}
```

### 1.3 main_pages.json 缺失

**错误信息：** 页面路由配置找不到

**解决方案：** 创建 `entry/src/main/resources/base/profile/main_pages.json`：
```json
{
  "src": [
    "pages/Index"
  ]
}
```

并在 `module.json5` 中添加：
```json
{
  "module": {
    "pages": "$profile:main_pages"
  }
}
```

---

## 2. 资源引用错误

### 2.1 图标资源未定义

**错误信息：**
```
hvigor ERROR: Resource Pack Error
Error Message: The resource reference '$media:app_icon' is not defined.
```

**解决方案：**

1. 从模板项目复制资源文件到 `AppScope/resources/base/media/` 和 `entry/src/main/resources/base/media/`
2. 更新配置文件中的图标引用：
   - `app.json5`: `"icon": "$media:layered_image"`
   - `module.json5`: `"icon": "$media:layered_image"`, `"startWindowIcon": "$media:startIcon"`

---

## 3. ArkTS 编译错误

### 3.1 对象字面量类型错误

**错误信息：**
```
ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals)
```

**原因：** ArkTS 不允许未类型化的对象字面量

**错误示例：**
```typescript
const Colors = {
  bgPrimary: '#FFFFFF',
  textPrimary: '#111827'
}  // ❌ 错误
```

**解决方案：** 直接使用字面量值，不定义对象常量
```typescript
// ✅ 正确 - 直接使用值
.backgroundColor('#FFFFFF')
.fontColor('#111827')
```

### 3.2 FontWeight.SemiBold 不存在

**错误信息：**
```
Property 'SemiBold' does not exist on type 'typeof FontWeight'
```

**解决方案：** 使用有效的 FontWeight 值：
- `FontWeight.Normal` (400)
- `FontWeight.Medium` (500)
- `FontWeight.Bold` (700)
- `FontWeight.Bolder` (900)

### 3.3 FlexAlign.FlexEnd 不存在

**错误信息：**
```
Property 'FlexEnd' does not exist on type 'typeof FlexAlign'
```

**解决方案：** 使用 `FlexAlign.End` 替代

### 3.4 常用枚举值速查

| 类型 | 有效值 |
|------|--------|
| FontWeight | Normal, Medium, Bold, Bolder, Lighter, 100-900 |
| FlexAlign | Start, Center, End, SpaceBetween, SpaceAround, SpaceEvenly |
| TextAlign | Start, Center, End |
| TextDecorationType | None, Underline, LineThrough, Overline |
| GradientDirection | Left, Top, Right, Bottom |

---

## 4. 完整项目结构检查清单

```
MyApp/
├── AppScope/
│   ├── app.json5                    ✅ 必需
│   └── resources/base/
│       ├── element/string.json      ✅ app_name
│       └── media/                   ✅ layered_image.json, background.png, foreground.png
├── entry/
│   ├── build-profile.json5          ✅ 必需
│   ├── hvigorfile.ts                ✅ 必需 (使用 hapTasks)
│   ├── oh-package.json5             ✅ 必需
│   └── src/main/
│       ├── module.json5             ✅ 必需
│       ├── ets/
│       │   ├── entryability/EntryAbility.ts  ✅ 必需
│       │   └── pages/Index.ets               ✅ 必需
│       └── resources/base/
│           ├── element/
│           │   ├── string.json      ✅ 必需
│           │   └── color.json       ✅ 必需
│           ├── media/               ✅ layered_image.json, startIcon.png 等
│           └── profile/main_pages.json  ✅ 必需
├── build-profile.json5              ✅ 必需 (完整SDK配置)
├── oh-package.json5                 ✅ 必需
├── hvigorfile.ts                    ✅ 必需 (使用 appTasks)
└── hvigor/hvigor-config.json5       ✅ 必需
```

---

## 5. 配置文件版本对照

| 配置项 | 推荐值 |
|--------|--------|
| targetSdkVersion | "6.1.0(23)" |
| compatibleSdkVersion | "6.0.2(22)" |
| modelVersion (oh-package.json5) | "6.1.0" |
| @ohos/hypium | "1.0.25" |
| @ohos/hamock | "1.0.0" |

---

## 6. 快速创建项目步骤

1. 复制 `project-template` 目录
2. 修改 `AppScope/app.json5` 中的 `bundleName` 和 `app_name`
3. 修改 `entry/src/main/module.json5` 中的标签
4. 在 DevEco Studio 中打开项目
5. 等待依赖安装完成
6. 运行项目