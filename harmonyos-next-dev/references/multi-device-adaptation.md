# 多设备适配参考

## 概述

HarmonyOS 应用需要适配手机、平板、折叠屏、2in1 设备等多种屏幕形态。ArkUI 提供了断点系统、响应式布局、栅格策略等组件。

## 断点系统

```typescript
// 断点常量（通过 $breakpoint 获取）
// sm: 0-320vp（小屏手机）
// md: 321-600vp（大屏手机/小平板）
// lg: 601-840vp（平板/折叠屏展开）
// xl: 841+（2in1/大屏平板）

@Entry
@Component
struct AdaptiveLayout {
  // 监听断点变化
  @State currentBreakpoint: string = 'sm';

  aboutToAppear() {
    this.currentBreakpoint = this.getUIContext()?.getBpSync() || 'sm';
  }

  get isTablet(): boolean {
    return this.currentBreakpoint === 'lg' || this.currentBreakpoint === 'xl';
  }

  build() {
    Column() {
      // 根据断点选择布局
      if (this.isTablet) {
        this.tabletLayout();
      } else {
        this.phoneLayout();
      }

      Text(`当前断点: ${this.currentBreakpoint}`)
        .fontSize(12)
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .onBreakpointChange((bp: string) => {
      this.currentBreakpoint = bp;
    })
  }

  @Builder
  phoneLayout() {
    Column() {
      Text('Phone Layout')
      // 单列布局
    }
  }

  @Builder
  tabletLayout() {
    Row() {
      Text('Tablet Layout')
      // 多列布局
    }
  }
}
```

## 响应式布局

```typescript
// 1. 百分比宽度
Text('自适应宽度').width('50%')

// 2. layoutWeight 分配剩余空间
Row() {
  Text('左').layoutWeight(1)   // 1/3
  Text('中').layoutWeight(2)   // 2/3
  Text('右').layoutWeight(1)   // 1/3
}

// 3. constrainSize 约束
Flex() {
  Text('自适应')
}
.constraintSize({
  minWidth: 100,
  maxWidth: 400,
  minHeight: 40
})

// 4. AspectRatio 保持比例
Image($r('app.media.photo'))
  .width('100%')
  .aspectRatio(16 / 9)  // 保持 16:9
```

## Navigation 自适应

```typescript
@Entry
@Component
struct AdaptiveNavigation {
  private navStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.navStack) {
      // Navigation 自动适配
      // - 手机：全屏推入
      // - 平板/2in1：分栏显示（左侧导航、右侧内容）
      Column() {
        ForEach(this.menuItems, (item: MenuItem) => {
          Text(item.title)
            .width('100%')
            .height(48)
            .padding(12)
            .onClick(() => {
              this.navStack.pushPath({ name: 'Detail', param: item });
            })
        })
      }
    }
    .title('主菜单')
    .hideTitleBar(false)
    // 导航栏模式
    .navBarMode(this.getCurrentNavMode())
    // 支持分栏布局
    .navBarWidth(this.isWideScreen() ? 280 : '100%')
  }

  getCurrentNavMode(): NavigationMode {
    let bp = this.getUIContext()?.getBpSync() || 'sm';
    if (bp === 'xl' || bp === 'lg') {
      return NavigationMode.SPLIT;  // 分栏模式
    }
    return NavigationMode.STACK;    // 堆叠模式
  }

  isWideScreen(): boolean {
    return ['lg', 'xl'].includes(this.getUIContext()?.getBpSync() || 'sm');
  }
}
```

## 折叠屏适配

```typescript
@Entry
@Component
struct FoldableAdaptation {
  @State isFoldable: boolean = false;
  @State isFolded: boolean = true;

  aboutToAppear() {
    // 检测折叠屏
    let uiContext = this.getUIContext();
    // 折叠状态
    uiContext?.on('foldStatusChange', (foldStatus: FoldStatus) => {
      this.isFolded = foldStatus === FoldStatus.FOLDED;
      this.isFoldable = true;
    });
  }

  build() {
    Column() {
      if (this.isFoldable) {
        if (this.isFolded) {
          // 折叠态：单列布局
          this.singleColumnLayout();
        } else {
          // 展开态：双列布局
          this.dualColumnLayout();
        }
      } else {
        // 普通手机
        this.phoneLayout();
      }
    }
  }
}
```

## 栅格策略

```typescript
// GridCol / GridRow 响应式栅格
GridRow({
  columns: { sm: 4, md: 8, lg: 12, xl: 12 },
  gutter: { x: 12, y: 12 },
  breakpoints: {
    reference: BreakpointsReference.WINDOW,
    breakpoints: [320, 600, 840]  // sm/md/lg/xl 断点
  }
}) {
  // 每个 GridCol 自动适应列数
  GridCol({ span: { sm: 2, md: 4, lg: 3 } }) {
    Text('Item 1').height(100).backgroundColor('#f5f5f5')
  }
  GridCol({ span: { sm: 2, md: 4, lg: 3 } }) {
    Text('Item 2').height(100).backgroundColor('#eee')
  }
}
```

## 尺寸单位

| 单位 | 说明 | 使用场景 |
|------|------|---------|
| vp | 虚拟像素（推荐） | 字体、布局尺寸 |
| lpx | 逻辑像素（基于设计稿） | 屏幕适配 |
| px | 物理像素（不推荐） | 极少情况 |
| % | 百分比 | 宽度占比 |
| fr | 弹性因子 | layoutWeight / Grid |

## 开发建议

1. **默认用 vp**，不要硬编码 px
2. **使用百分比宽度** 而非固定值
3. **用断点 + 栅格** 实现自适布局
4. **测试覆盖** 手机/平板/折叠屏/2in1
5. **折叠屏监听** `foldStatusChange` 事件动态调整布局
