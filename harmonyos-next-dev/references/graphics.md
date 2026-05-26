# 图形参考

## Canvas 2D 绘制

```typescript
@Entry
@Component
struct CanvasDemo {
  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();

  build() {
    Column() {
      Canvas(this.canvasCtx)
        .width(300)
        .height(300)
        .onReady(() => {
          this.draw();
        })
    }
  }

  draw() {
    let ctx = this.canvasCtx;
    // 绘制矩形
    ctx.fillStyle = '#007DFF';
    ctx.fillRect(50, 50, 100, 80);

    // 绘制圆
    ctx.beginPath();
    ctx.arc(200, 150, 40, 0, Math.PI * 2);
    ctx.fillStyle = '#FF6600';
    ctx.fill();

    // 绘制文本
    ctx.font = '20px sans-serif';
    ctx.fillStyle = '#333';
    ctx.textAlign = TextAlign.Center;
    ctx.fillText('Hello Canvas', 150, 250);

    // 绘制线条
    ctx.strokeStyle = '#FF0000';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(20, 280);
    ctx.lineTo(280, 280);
    ctx.stroke();
  }
}
```

## 属性动画

```typescript
@Entry
@Component
struct AnimationDemo {
  @State scale: number = 1;
  @State opacity: number = 1;
  @State rotation: number = 0;
  @State animate: boolean = false;

  build() {
    Column() {
      // 属性动画 —— 链式调用 .animation()
      Image($r('app.media.icon'))
        .width(100)
        .height(100)
        .scale({ x: this.scale, y: this.scale })
        .opacity(this.opacity)
        .rotate({ angle: this.rotation })
        .animation({ duration: 500, curve: Curve.EaseInOut })

      Button('开始动画')
        .onClick(() => {
          this.animate = !this.animate;
          this.scale = this.animate ? 1.5 : 1;
          this.opacity = this.animate ? 0.5 : 1;
          this.rotation = this.animate ? 180 : 0;
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

## 显式动画

```typescript
import { animateTo } from '@kit.ArkUI';

// 显式动画
animateTo({ duration: 300, curve: Curve.FastOutSlowIn, delay: 0 }, () => {
  this.x = 200;
  this.y = 300;
});

// 关键帧动画
animateTo({
  duration: 1000,
  curve: Curve.FastOutSlowIn,
  iterations: 3,
  playMode: PlayMode.Alternate
}, () => {
  this.opacity = 0;
});
```

## 转场动画

```typescript
// 页面转场
@Entry
@Component
struct PageTransitionDemo {
  build() {
    NavDestination() {
      Text('Page Content')
    }
    .transition(
      TransitionEffect.OPACITY
        .combine(TransitionEffect.translate({ x: 100 }))
        .animation({ duration: 300 })
    )
  }
}

// 组件出现/消失
if (this.showComponent) {
  Text('Animated Text')
    .transition(
      TransitionEffect.OPACITY
        .combine(TransitionEffect.scale({ x: 0, y: 0 }))
    )
}
```

## XComponent

用于高性能图形渲染（Native 集成）：

```typescript
XComponent({
  id: 'xcomponent1',
  type: XComponentType.SURFACE,
  libraryName: 'native_render'
})
.width(320)
.height(240)
.onLoad((context: object) => {
  // Native 侧接收 context 进行渲染
})
```

## 自定义组件绘图

```typescript
@Component
struct CustomShape extends View {
  build() {
    Path()
      .commands('M100 100 L200 100 L150 200 Z')
      .fill('#007DFF')
      .stroke('#333')
      .strokeWidth(2)
  }
}

// Shape 组件
Shape() {
  Rect().width(100).height(60).fill('#007DFF').radiusWidth(8)
  Circle().width(50).height(50).fill('#FF6600')
}
.width(200)
.height(150)
.viewPort({ x: 0, y: 0, width: 200, height: 150 })
```
