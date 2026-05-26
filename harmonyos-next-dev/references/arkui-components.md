# ArkUI 声明式 UI 参考

## 核心原则

ArkUI 是声明式 UI 框架，组件状态驱动 UI 更新。

## 常用组件

### 基础组件

```typescript
// Text
Text('Hello World')
  .fontSize(20)
  .fontWeight(FontWeight.Bold)
  .fontColor(Color.Blue)
  .textAlign(TextAlign.Center)
  .lineHeight(30)

// Button
Button('Click Me')
  .type(ButtonType.Capsule)
  .width(200)
  .height(48)
  .backgroundColor('#007DFF')
  .onClick(() => { /* handle click */ })

// Image
Image($r('app.media.icon'))
  .width(100)
  .height(100)
  .borderRadius(8)
  .objectFit(ImageFit.Cover)

// TextInput
TextInput({ text: $$this.inputValue })
  .placeholder('请输入...')
  .type(InputType.Normal)
  .maxLength(50)
  .onChange((value: string) => { this.inputValue = value; })
```

### 布局组件

```typescript
// Column（垂直布局）
Column({ space: 12 }) {
  Text('A')
  Text('B')
}
.width('100%')
.alignItems(HorizontalAlign.Center)

// Row（水平布局）
Row({ space: 12 }) {
  Button('A')
  Button('B')
}
.width('100%')
.justifyContent(FlexAlign.SpaceBetween)

// Stack（层叠）
Stack({ alignContent: Alignment.Center }) {
  Image($r('app.media.bg')).width('100%').height('100%')
  Text('Overlay').fontSize(20).fontColor(Color.White)
}

// Flex（弹性布局）
Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
  ForEach(this.items, (item: number) => {
    Text(`Item ${item}`).width(80).height(80).backgroundColor('#ccc')
  }, (item: number) => item.toString())
}
```

### 滚动与列表

```typescript
// Scroll
Scroll() {
  Column() {
    ForEach(this.items, (item: string) => {
      Text(item).height(60).width('100%')
    })
  }
}
.scrollable(ScrollDirection.Vertical)
.scrollBar(BarState.Off)

// List + ListItem（高性能列表）
List({ space: 10, initialIndex: 0 }) {
  LazyForEach(this.dataSource, (item: Item) => {
    ListItem() {
      Text(item.name).fontSize(16)
    }
    .swipeAction({ end: this.buildSwipeButton(item) })
  }, (item: Item) => item.id)
}
.divider({ strokeWidth: 1, color: '#eee' })
.onScrollIndex((start: number, end: number) => {
  console.log(`visible: ${start}-${end}`);
})
```

### Swiper（轮播）

```typescript
Swiper() {
  ForEach(this.images, (src: Resource) => {
    Image(src).width('100%').height(200)
  })
}
.autoPlay(true)
.interval(3000)
.indicator(true)
.loop(true)
```

### Tabs

```typescript
Tabs({ barPosition: BarPosition.Start }) {
  TabContent() {
    Text('Tab 1 Content')
  }
  .tabBar('Tab 1')

  TabContent() {
    Text('Tab 2 Content')
  }
  .tabBar('Tab 2')
}
.scrollable(true)
.barWidth('100%')
.onChange((index: number) => {
  console.log(`Tab changed to ${index}`);
})
```

### 弹窗

```typescript
// 提示弹窗
AlertDialog.show({
  title: '提示',
  message: '确定要删除吗？',
  autoCancel: true,
  alignment: DialogAlignment.Center,
  primaryButton: {
    value: '取消',
    action: () => {}
  },
  secondaryButton: {
    value: '确定',
    action: () => { this.deleteItem(); }
  }
});

// 底部弹窗
@Builder
paramsBuilder() {
  Column() {
    Text('选项1').onClick(() => {})
    Divider()
    Text('选项2').onClick(() => {})
  }
}
// 使用 bindSheet
.bindSheet($$this.isSheetVisible, this.paramsBuilder(), { height: SheetSize.MEDIUM })
```

### WaterFlow（瀑布流，API 12+）

```typescript
WaterFlow() {
  LazyForEach(this.dataSource, (item: Item) => {
    FlowItem() {
      Image(item.url).width('100%').borderRadius(8)
      Text(item.title).fontSize(14).margin({ top: 4 })
    }
    .width('100%')
    .backgroundColor('#f5f5f5')
    .borderRadius(8)
  }, (item: Item) => item.id)
}
.columnsTemplate('1fr 1fr')
.sections([{ itemCount: this.items.length }])
.nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
```

## 动画

```typescript
// 属性动画
Image($r('app.media.icon'))
  .rotate({ angle: this.rotated ? 180 : 0 })
  .animation({ duration: 300, curve: Curve.EaseInOut })

// 显式动画
animateTo({ duration: 500, curve: Curve.FastOutSlowIn }, () => {
  this.scale = 1.5;
  this.opacity = 0.5;
})

// 转场动画
.transition(
  TransitionEffect.OPACITY
    .combine(TransitionEffect.translate({ x: 100, y: 0 }))
    .animation({ duration: 300 })
)
```

## 状态管理 V1 速查

| 装饰器 | 用法 | 说明 |
|--------|------|------|
| `@State` | `@State count: number = 0` | 组件内部状态 |
| `@Prop` | `@Prop title: string` | 父→子单向 |
| `@Link` | `@Link value: number` | 双向绑定（使用 `$var`） |
| `@Provide` | `@Provide theme: string = 'light'` | 祖先提供 |
| `@Consume` | `@Consume theme: string` | 后代消费 |
| `@Observed` | `@Observed class Data {}` | 可观察类 |
| `@ObjectLink` | `@ObjectLink data: Data` | 嵌套对象监听 |

## 状态管理 V2 速查

| 装饰器 | 用法 | 说明 |
|--------|------|------|
| `@Local` | `@Local count: number = 0` | 内部状态（不可外部初始化） |
| `@Param` | `@Param title: string = ""` | 父→子单向（高效） |
| `@Event` | `@Event onChange: () => void` | 子→父回调 |
| `@ObservedV2` | `@ObservedV2 class Data {}` | 类级观察 |
| `@Trace` | `@Trace name: string` | 属性级追踪 |
| `@Computed` | `@Computed get total() {}` | 计算属性（缓存） |
| `@Monitor` | `@Monitor('prop') onFn(change) {}` | 监听变化 |
| `@Provider` | `@Provider data: Data` | 跨级提供 |
| `@Consumer` | `@Consumer data: Data` | 跨级消费 |
