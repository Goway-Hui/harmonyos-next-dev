# 无障碍服务参考

## 概述

HarmonyOS 无障碍服务为视觉、听觉、行动等障碍用户提供辅助功能，包括 TalkBack 屏幕朗读、高对比度模式等。

## AccessibilityExtensionAbility

```typescript
import { AccessibilityExtensionAbility } from '@kit.AccessibilityKit';

export default class MyAccessibility extends AccessibilityExtensionAbility {
  onStart(): void {
    console.log('Accessibility service started');
  }

  onStop(): void {
    console.log('Accessibility service stopped');
  }

  onEvent(event: AccessibilityExtensionAbility.AccessibilityEvent): void {
    switch (event.eventType) {
      case 'pageStateUpdate':
        console.log('Page changed');
        break;
      case 'touchBegin':
        console.log('Touch start');
        break;
      case 'touchEnd':
        console.log('Touch end');
        break;
    }
  }
}
```

## 无障碍标签与属性

```typescript
@Entry
@Component
struct AccessibleApp {
  build() {
    Column() {
      // 无障碍标签
      Image($r('app.media.icon'))
        .width(48)
        .height(48)
        .accessibilityText('应用图标')

      // 按钮
      Button('发送')
        .accessibilityText('发送消息按钮')
        .accessibilityDescription('点击发送当前输入的消息')
        .accessibilityLevel('yes')  // yes / no / auto

      // 分组
      Column()
        .accessibilityGroup(true)
        .accessibilityText('用户信息区域')

      // 自定义组件
      Text('详细内容')
        .accessibilityText('详细内容')
        .accessibilityLevel('yes')
    }
  }
}
```

### 无障碍属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `.accessibilityText(text)` | string | 屏幕朗读文本（替代默认标签） |
| `.accessibilityDescription(text)` | string | 额外描述信息 |
| `.accessibilityLevel(level)` | 'yes' / 'no' / 'auto' | 无障碍层级 |
| `.accessibilityGroup(isGroup)` | boolean | 是否作为分组朗读 |

## 高对比度与字体适配

```typescript
@Entry
@Component
struct AdaptiveUI {
  @StorageProp('fontScale') fontScale: number = 1.0;

  build() {
    Column() {
      Text('自适应文本')
        .fontSize(16 * this.fontScale)  // 跟随系统字体缩放
        .accessibilityText('自适应文本')

      // 像素单位使用 vp（虚拟像素）
      Text('使用 vp 单位的布局')
        .width('80%')
        .height(48)
        .fontSize(16)
    }
    // 高对比度模式自动适配背景色
    .backgroundColor(Color.White)  // 系统会自动处理高对比度
  }
}
```

## TalkBack 适配最佳实践

```typescript
// 1. 自定义组件需要语义化标签
@Reusable
@Component
struct ProductCard {
  @Prop name: string;
  @Prop price: number;
  @Prop image: Resource;

  build() {
    Row() {
      Image(this.image)
        .width(60)
        .height(60)
        .accessibilityText(`${this.name} 商品图片`)

      Column() {
        Text(this.name)
          .fontSize(16)
          .accessibilityLevel('no')  // 父组件已读，子组件不再重复

        Text(`¥${this.price}`)
          .fontSize(14)
          .fontColor('#FF6600')
          .accessibilityLevel('no')
      }
      .padding({ left: 12 })
    }
    .accessibilityText(`${this.name}，价格${this.price}元`)  // 统一朗读
    .accessibilityGroup(true)
  }
}

// 2. 动态内容通知
import { accessibility } from '@kit.AccessibilityKit';

function announceForAccessibility(text: string) {
  accessibility.sendAccessibilityEvent({
    eventType: 'announceForAccessibility',
    content: text
  });
}

// 使用
this.announceForAccessibility('消息已发送');
```

## 字体缩放适配

| 场景 | 适配方式 |
|------|---------|
| 固定行数 | 使用 `.constraintSize` 限制最大/最小尺寸 |
| 弹性布局 | 用 `layoutWeight` 分配剩余空间 |
| 图片+文字 | 文字用百分比宽度，图片固定 vp |
| 弹窗/按钮 | 用 `padding` 而不用固定高度 |
| 多行文本 | 不要固定高度，用 `.maxLines` 控制 |

## 无障碍测试

```typescript
// 开发过程中检查：
// 1. TalkBack 模式下所有可交互元素都有无障碍标签
// 2. 图片有 accessibilityText 描述
// 3. 分组组件设置了 accessibilityGroup(true)
// 4. 自定义组件将子组件 accessibilityLevel 设为 'no'
// 5. 使用 hdc shell 检查无障碍树

// hdc shell 命令查看无障碍信息
// hdc shell aa dump --ability AccessibilityAbility
```
