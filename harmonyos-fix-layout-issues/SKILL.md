---
name: harmonyos-fix-layout-issues
description: 诊断并修复 ArkUI 布局错误（溢出、无限约束、组件变形）。适用于处理 Flex/Row/Column 溢出、List 在 Column 中无高度、TextInput 在 Row 中无宽度、布局组件使用错误等问题。当用户提到布局问题、溢出、显示不全、组件被截断、布局报错时触发。
---

# 修复 ArkUI 布局问题

## 目录
- [布局约束诊断](#布局约束诊断)
- [布局错误解决流程](#布局错误解决流程)
- [常见场景与修复方案](#常见场景与修复方案)

## 布局约束诊断

ArkUI 布局遵循"父组件传递约束 → 子组件计算尺寸 → 父组件决定位置"的规则。当约束传递链断裂时出现布局错误。

### 常见错误信号

| 错误现象 | 根本原因 | 典型场景 |
|----------|----------|----------|
| **List 不显示或被截断** | `List` 放在 `Column` 中未指定高度约束 | Column > List 嵌套，List 获得无限高度无法确定自身尺寸 |
| **Text 文字被省略号截断** | `Text` 在 `Row` 中宽度超出剩余空间 | Row > [Icon + 长文本]，Text 无 `.layoutWeight()` 约束 |
| **组件超出屏幕/溢出** | `Row`/`Flex` 子组件总宽超出父容器 | Row 中放了太多固定宽度的组件 |
| **TextInput 宽度异常** | `TextInput` 在 `Row` 中未获得确定宽度 | Row > [Label + TextInput]，TextInput 默认尝试占满 |
| **组件不按预期拉伸** | 缺少 `.layoutWeight()` 或 `.flexGrow()` | 希望子组件均分剩余空间但未设置弹性属性 |
| **Scroll 嵌套 Column 高度异常** | `Scroll` + `Column` 中 Column 高度未确定 | Scroll > Column 需要 Column 有明确高度或内容撑开 |

### 核心约束属性速查

| 属性 | 作用 | 使用位置 |
|------|------|----------|
| `.layoutWeight(N)` | 按权重分配 **Flex 主轴方向** 剩余空间 | `Row`/`Column`/`Flex` 的直接子组件 |
| `.flexShrink(N)` | 空间不足时按比例压缩（默认 0 = 不压缩） | Flex 容器直接子组件 |
| `.flexGrow(N)` | 空间富余时按比例扩展（默认 0 = 不扩展） | Flex 容器直接子组件 |
| `.constraintSize({ minWidth?, maxWidth?, minHeight?, maxHeight? })` | 设置组件尺寸约束 | 任何组件 |
| `.width('100%')` / `.height(100)` | 设置绝对尺寸或百分比 | 任何组件 |
| `.alignSelf(ItemAlign.Stretch)` | 覆盖父容器对齐方式 | Flex 子组件 |

## 布局错误解决流程

按以下检查清单逐步排查：

- [ ] **步骤 1：确认问题所在。** 使用 DevEco Studio 的 Previewer 或真机运行，精确定位出问题的组件区域。
- [ ] **步骤 2：识别错误类型。** 根据上述「错误信号」表格判断属于哪类布局问题。
- [ ] **步骤 3：应用对应修复方案：**
  - **List/Scroll 在 Column 中不显示** → 给 List 外层加 `.layoutWeight(1)` 或 `.height(X)` 明确约束
  - **Row 子组件溢出** → 给溢出组件加 `.layoutWeight(1)` 或 `.flexShrink(1)`
  - **TextInput 在 Row 中异常** → 给 TextInput 加 `.layoutWeight(1)`
  - **组件不拉伸** → 加 `.layoutWeight(1)` 或确认父容器是 Flex/Row/Column
  - **Scroll + Column 嵌套问题** → Column 内部内容由 Scroll 管理，Column 无需 `.layoutWeight()`
- [ ] **步骤 4：热重载验证。** DevEco Studio 支持 Previewer 即时预览（`Ctrl+S` 保存即刷新）。
- [ ] **步骤 5：回归检查。** 确认修复后不同屏幕尺寸下均正常显示（可使用 Previewer 的多设备切换功能）。

## 常见场景与修复方案

### 场景 1：List 在 Column 中不显示/被截断

**错误代码：**
```typescript
// ❌ List 在 Column 中获得无限高度，导致不显示或布局异常
Column() {
  Text('标题').fontSize(20)
  List() {
    ForEach(this.items, (item: string) => {
      ListItem() { Text(item) }
    })
  }
}
.width('100%')
.height('100%')
```

**修复方案（推荐）：**
```typescript
// ✅ 给 List 外层加 .layoutWeight(1) 使其占满 Column 剩余空间
Column() {
  Text('标题').fontSize(20)
  List() {
    ForEach(this.items, (item: string) => {
      ListItem() { Text(item) }
    })
  }
  .layoutWeight(1)  // ← 关键修复：占满剩余高度
}
.width('100%')
.height('100%')
```

**备选方案（固定高度）：**
```typescript
// ✅ 指定固定高度
List() { ... }
.height(400)
```

### 场景 2：Row 中文本溢出被截断

**错误代码：**
```typescript
// ❌ 长文本超出 Row 宽度，显示省略号或溢出
Row({ space: 8 }) {
  Image($r('app.media.icon')).width(24).height(24)
  Text('这是一段非常长的文本内容，会超出屏幕宽度导致显示不全')
  Button('操作')
}
.width('100%')
```

**修复方案：**
```typescript
// ✅ 给 Text 加 .layoutWeight(1) + .flexShrink(1) 使其自适应宽度
Row({ space: 8 }) {
  Image($r('app.media.icon')).width(24).height(24)

  Text('这是一段非常长的文本内容，会超出屏幕宽度导致显示不全')
    .layoutWeight(1)   // 占满剩余空间
    .flexShrink(1)     // 空间不足时压缩（触发省略号）
    .textOverflow({ overflow: TextOverflow.Ellipsis })
    .maxLines(1)

  Button('操作')
    .flexShrink(0)     // 按钮不压缩
}
.width('100%')
```

### 场景 3：TextInput 在 Row 中宽度失控

**错误代码：**
```typescript
// ❌ TextInput 默认尝试占满宽度，挤掉同行其他组件
Row({ space: 8 }) {
  Text('搜索').width(60)
  TextInput({ placeholder: '请输入关键字' })
  Button('确定')
}
.width('100%')
```

**修复方案：**
```typescript
// ✅ 给 TextInput 加 .layoutWeight(1) 使其自适应
Row({ space: 8 }) {
  Text('搜索').width(60)
  TextInput({ placeholder: '请输入关键字' })
    .layoutWeight(1)   // ← 关键修复
  Button('确定')
}
.width('100%')
```

### 场景 4：多个子组件需要均分宽度

**错误代码：**
```typescript
// ❌ 三个 Button 使用固定宽度，不同屏幕适配差
Row({ space: 8 }) {
  Button('取消').width(100)
  Button('保存').width(100)
  Button('提交').width(100)
}
```

**修复方案：**
```typescript
// ✅ 使用 layoutWeight 均分
Row({ space: 8 }) {
  Button('取消').layoutWeight(1)
  Button('保存').layoutWeight(1)
  Button('提交').layoutWeight(1)
}
.width('100%')
```

### 场景 5：Column 中多个 Scroll 组件问题

**错误代码：**
```typescript
// ❌ 两个 Scroll 在 Column 中都需要高度，互相竞争
Column() {
  Scroll() {
    // 上半部分内容...
  }

  Scroll() {
    // 下半部分内容...
  }
}
.height('100%')
```

**修复方案：**
```typescript
// ✅ 使用 Flex + layoutWeight 分配比例
Flex({ direction: FlexDirection.Column }) {
  Scroll() {
    Column() { /* 上半部分内容 */ }
  }
  .layoutWeight(1)   // 占 1 份

  Scroll() {
    Column() { /* 下半部分内容 */ }
  }
  .layoutWeight(1)   // 占 1 份（均分）
}
.height('100%')
```

### 场景 6：Scroll 内 Column 内容不撑开

**错误代码：**
```typescript
// ❌ 给 Scroll 内的 Column 设置了 .layoutWeight(1)
Scroll() {
  Column() {
    // 很多内容...
  }
  .layoutWeight(1)   // ← 无效！Scroll 不是 Flex 容器
}
```

**修复方案：**
```typescript
// ✅ Scroll 内的 Column 靠内容自然撑开，不要加 layoutWeight
Scroll() {
  Column() {
    // 很多内容...
  }
  // ← 去掉 .layoutWeight()，Scroll 会自动管理滚动
}
.height('100%')  // Scroll 本身需要高度约束
```

## 核心原则

1. **Flex 子组件才用弹性属性：** `.layoutWeight()`、`.flexShrink()`、`.flexGrow()` 只在 `Row`/`Column`/`Flex` 的直接子组件上生效。
2. **Scroll 不是 Flex：** `Scroll` 内的子组件不能用 `.layoutWeight()`，改用内容自然撑开。
3. **优先百分比：** 能用 `.width('100%')` / `.height('100%')` 的优先用百分比，其次用 `.layoutWeight(1)`。
4. **TextInput 必约束：** 只要 `TextInput` 放在 `Row` 中，必须给 `.layoutWeight(1)`。
5. **多设备验证：** DevEco Studio Previewer 支持切换手机/平板/折叠屏，每个修复后都应多设备验证。
