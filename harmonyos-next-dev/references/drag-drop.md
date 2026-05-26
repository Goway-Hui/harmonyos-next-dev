# 拖拽 (Drag & Drop) 参考

## 概述

ArkUI 支持应用内和跨应用的拖拽交互，包括列表排序、文本/图片拖拽等场景。

## 拖拽源（发起拖拽）

```typescript
import { UnifiedData } from '@kit.ArkUI';

@Entry
@Component
struct DragSource {
  @State items: string[] = ['Item 1', 'Item 2', 'Item 3'];

  build() {
    Column() {
      ForEach(this.items, (item: string, index: number) => {
        Text(item)
          .width('100%')
          .height(50)
          .padding(10)
          .backgroundColor('#f5f5f5')
          .borderRadius(8)
          .margin({ bottom: 8 })
          // 拖拽方向：GridDrag.DRAG_NONE | DRAG_X | DRAG_Y | DRAG_XY
          .dragBehavior({ dragDirection: DragDirection.VERTICAL })
          .onDragStart((event: DragEvent, extraParams: string) => {
            // 创建拖拽数据
            let dragData = new UnifiedData();
            let record = new UnifiedRecord(UnifiedDataType.PLAIN_TEXT);
            record.setData(item);  // 设置拖拽数据
            dragData.addRecord(record);
            return dragData;
          })
      }, (item: string) => item)
    }
    .width('100%')
    .padding(16)
  }
}
```

## 拖拽目标（接收拖放）

```typescript
@Entry
@Component
struct DropTarget {
  @State dropResult: string = '';

  build() {
    Column() {
      // 拖放目标区域
      Text(this.dropResult || '将内容拖到这里')
        .width('100%')
        .height(100)
        .backgroundColor('#e8f4fd')
        .borderRadius(8)
        .textAlign(TextAlign.Center)
        // 允许拖放
        .allowDrop(true)
        .onDrop((event: DragEvent, extraParams: string) => {
          // 接收拖放数据
          let data = event.getData();
          let records = data.getRecords();
          records.forEach(record => {
            if (record.getType() === UnifiedDataType.PLAIN_TEXT) {
              this.dropResult = record.getData();
            }
          });
        })
        .onDragEnter((event: DragEvent, extraParams: string) => {
          console.log('Drag entered');
        })
        .onDragLeave((event: DragEvent, extraParams: string) => {
          console.log('Drag left');
        })
        .onDragMove((event: DragEvent, extraParams: string) => {
          console.log('Drag moving');
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}
```

## 列表拖拽排序

```typescript
@Entry
@Component
struct DraggableList {
  @State items: string[] = ['A', 'B', 'C', 'D', 'E'];

  build() {
    List({ space: 8 }) {
      ForEach(this.items, (item: string, index: number) => {
        ListItem() {
          Text(`${index + 1}. ${item}`)
            .width('100%')
            .height(50)
            .padding(12)
            .backgroundColor('#fff')
            .borderRadius(8)
            .shadow({ radius: 2, color: '#ccc' })
        }
        .draggable(true)
        .onDragStart(() => {
          return new UnifiedData();  // 返回拖拽数据
        })
        .onDrop((event: DragEvent) => {
          // 交换位置
          let fromIndex = this.getDragFromIndex(event);
          let toIndex = index;
          if (fromIndex !== undefined && fromIndex !== toIndex) {
            let temp = this.items.splice(fromIndex, 1)[0];
            this.items.splice(toIndex, 0, temp);
          }
        })
      }, (item: string) => item)
    }
    .width('100%')
    .padding(16)
  }

  getDragFromIndex(event: DragEvent): number | undefined {
    // 实际项目中通过 UnifiedData 传递原始位置
    return undefined;
  }
}
```

## 跨应用拖拽

```typescript
// 跨应用拖拽使用 UnifiedData 传输
// 需要声明权限

import { UnifiedData, UnifiedRecord, UnifiedDataType } from '@kit.ArkUI';

// 拖出（拖到其他应用）
.onDragStart(() => {
  let dragData = new UnifiedData();
  let record = new UnifiedRecord(UnifiedDataType.PLAIN_TEXT);
  record.setData('Shared text content');
  dragData.addRecord(record);
  return dragData;
})

// 拖入（从其他应用接收）
.allowDrop(true)
.onDrop((event: DragEvent) => {
  let data = event.getData();
  let records = data.getRecords();
})
```

## 拖拽事件回调

| 事件 | 说明 |
|------|------|
| `onDragStart` | 拖拽开始，返回拖拽数据 |
| `onDragEnter` | 拖拽进入目标区域 |
| `onDragMove` | 拖拽在目标区域移动 |
| `onDragLeave` | 拖拽离开目标区域 |
| `onDrop` | 拖放完成，接收数据 |
| `onDragEnd` | 拖拽结束（目标外释放） |
