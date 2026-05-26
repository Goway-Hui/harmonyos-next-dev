/**
 * 瀑布流页面模板 — WaterFlow + LazyForEach
 * 适用于 HarmonyOS NEXT (API 20+)
 */
import { image } from '@kit.ImageKit';

// ==================== 瀑布流数据 ====================
interface WaterfallItem {
  id: string;
  imageUrl: Resource;
  title: string;
  height: number; // 不同高度实现瀑布效果
  tag?: string;
}

class WaterfallDataSource implements IDataSource {
  private items: WaterfallItem[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.items.length;
  }

  getData(index: number): WaterfallItem {
    return this.items[index];
  }

  addItems(newItems: WaterfallItem[]): void {
    let start = this.items.length;
    this.items.push(...newItems);
    this.listeners.forEach(l => l.onDataAdd(start));
    this.listeners.forEach(l => l.onDataReloaded());
  }

  clear(): void {
    this.items = [];
    this.listeners.forEach(l => l.onDataReloaded());
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    let pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }
}

// ==================== 瀑布流页面 ====================
@Entry
@Component
struct WaterfallPage {
  private dataSource: WaterfallDataSource = new WaterfallDataSource();
  @State hasMore: boolean = true;
  private page: number = 1;

  aboutToAppear(): void {
    this.loadMoreData();
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('瀑布流')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text(`${this.dataSource.totalCount()} 个商品`)
          .fontSize(14)
          .fontColor('#999')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // WaterFlow 瀑布流
      WaterFlow() {
        LazyForEach(this.dataSource, (item: WaterfallItem) => {
          FlowItem() {
            Column() {
              // 图片
              Image(item.imageUrl)
                .width('100%')
                .height(item.height)
                .objectFit(ImageFit.Cover)
                .borderRadius({ topLeft: 8, topRight: 8 })

              // 信息
              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(14)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                if (item.tag) {
                  Text(item.tag)
                    .fontSize(10)
                    .fontColor('#007DFF')
                    .backgroundColor('#E3F2FD')
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .borderRadius(4)
                }
              }
              .padding(8)
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .shadow({ radius: 2, color: '#15000000', offsetY: 1 })
          }
        }, (item: WaterfallItem) => item.id)

        // 加载更多
        FlowItem() {
          Row() {
            if (this.hasMore) {
              LoadingProgress().width(16).height(16)
              Text('加载中...').fontSize(14).fontColor('#999').margin({ left: 8 })
            } else {
              Text('— 已经到底了 —').fontSize(14).fontColor('#ccc')
            }
          }
          .width('100%')
          .padding(16)
          .justifyContent(FlexAlign.Center)
        }
        .onAppear(() => {
          if (this.hasMore) {
            this.loadMoreData();
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .layoutWeight(1)
      .padding(16)
      .backgroundColor('#f5f5f5')
    }
    .width('100%')
    .height('100%')
  }

  // ==================== 加载数据 ====================
  async loadMoreData(): Promise<void> {
    // 模拟加载
    let mockData: WaterfallItem[] = [];
    for (let i = 0; i < 10; i++) {
      let index = this.dataSource.totalCount() + i;
      mockData.push({
        id: `waterfall_${index}`,
        imageUrl: $r('app.media.placeholder'),
        title: `商品 ${index + 1} — 这里是商品标题`,
        height: 120 + Math.random() * 120, // 随机高度
        tag: i % 3 === 0 ? '新品' : undefined
      });
    }

    // 延迟模拟网络
    await new Promise(resolve => setTimeout(resolve, 500));
    this.dataSource.addItems(mockData);
    this.page++;

    // 模拟没有更多
    if (this.page > 5) {
      this.hasMore = false;
    }
  }
}
