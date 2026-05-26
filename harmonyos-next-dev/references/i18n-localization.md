# 国际化与本地化参考

## 资源文件结构

```
resources/
├── base/              # 默认（fallback）资源
│   ├── element/       # 字符串、颜色、数值等
│   │   ├── string.json
│   │   └── color.json
│   ├── media/         # 图片资源
│   └── profile/       # 配置文件
├── en_US/             # 英文（美国）
│   ├── element/
│   │   └── string.json
│   └── media/
├── zh_CN/             # 简体中文
│   ├── element/
│   │   └── string.json
│   └── media/
├── zh_HK/             # 繁体中文（香港）
└── ja_JP/             # 日文
```

### string.json 示例

```json
// resources/base/element/string.json
{
  "string": [
    { "name": "app_name", "value": "MyApp" },
    { "name": "welcome", "value": "Welcome" },
    { "name": "greeting", "value": "Hello, %s" }
  ]
}

// resources/zh_CN/element/string.json
{
  "string": [
    { "name": "app_name", "value": "我的应用" },
    { "name": "welcome", "value": "欢迎" },
    { "name": "greeting", "value": "你好，%s" }
  ]
}
```

## 资源引用

```typescript
// 字符串
Text($r('app.string.welcome'))
Text($r('app.string.greeting', 'Alice'))  // 带参数

// 颜色
Text('Hello').fontColor($r('app.color.primary'))

// 图片
Image($r('app.media.icon'))

// 原始文件
// 放在 resources/rawfile/ 目录
Image($rawfile('logo.png'))
```

## intl 国际化 API

```typescript
import { intl } from '@kit.LocalizationKit';

// 日期格式化
let dateFormatter = new intl.DateTimeFormat('zh-CN', {
  dateStyle: 'full',
  timeStyle: 'medium'
});
let formattedDate = dateFormatter.format(new Date());
// 输出：2025年7月9日 星期三 14:30:00

// 数字格式化
let numberFormatter = new intl.NumberFormat('de-DE', {
  style: 'decimal',
  minimumFractionDigits: 2
});
let formattedNumber = numberFormatter.format(1234.5);
// 输出：1.234,50

// 货币格式化
let currencyFormatter = new intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD'
});
let price = currencyFormatter.format(29.99);
// 输出：$29.99

// 相对时间
let rtf = new intl.RelativeTimeFormat('zh-CN', { numeric: 'always' });
let relative = rtf.format(-2, 'day');
// 输出：2天前
```

## i18n 本地化 API

```typescript
import { i18n } from '@kit.LocalizationKit';

// 系统语言
let systemLang = i18n.System.getSystemLanguage(); // 'zh-CN'

// 判断是否为 RTL 语言
let isRTL = i18n.System.isRTL('ar');

// 获取系统区域
let region = i18n.System.getSystemRegion(); // 'CN'

// 时区
let timezone = i18n.System.getSystemTimezone();

// 历法
let calendar = new i18n.Calendar('zh-CN');
let firstDayOfWeek = calendar.getFirstDayOfWeek(); // 1（周一）
```

## 动态切换语言

```typescript
import { i18n } from '@kit.LocalizationKit';

// 获取应用语言
let appLang = i18n.System.getAppPreferredLanguage();

// 配置多语言文案
function getLocalizedText(key: string): string {
  return $r(`app.string.${key}`);
}

// 获取当前语言
function isChinese(): boolean {
  return i18n.System.getSystemLanguage().startsWith('zh');
}
```
