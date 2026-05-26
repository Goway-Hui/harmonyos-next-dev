/**
 * 列表页面模板 — LazyForEach + 下拉刷新 + 加载更多
 * 适用于 HarmonyOS NEXT (API 20+)
 */
import { promptAction } from '@kit.ArkUI';

// ==================== 数据源 ====================
class ListItemData {
  id: string = '';
  title: string = '';
  description: string = '';
  image?: Resource;
  timestamp: number = 0;
}

class ListDataSource implements IDataSource {
  private dataArray: ListItemData[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.dataArray.length;
  }

  getData(index: number): ListItemData {
    return this.dataArray[index];
  }

  addData(index: number, data: ListItemData): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  pushData(data: ListItemData): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  removeData(index: number): void {
    this.dataArray.splice(index, 1);
    this.notifyDataRemove(index);
  }

  clear(): void {
    this.dataArray = [];
    this.notifyDataReload();
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

  private notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    });
  }

  private notifyDataRemove(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }

  private notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }
}

// ==================== 列表页面 ====================
@Entry
@Component
struct ListPage {
  private dataSource: ListDataSource = new ListDataSource();

  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State hasMore: boolean = true;
  private page: number = 1;
  private readonly pageSize: number = 20;

  aboutToAppear(): void {
    this.loadData(true);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('列表页面')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // 列表
      List({ space: 10 }) {
        // 下拉刷新指示器
        ListItem() {
          if (this.isRefreshing) {
            Row() {
              LoadingProgress().width(20).height(20)
              Text('刷新中...').fontSize(14).fontColor('#999').margin({ left: 8 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding(12)
          }
        }
        .onAppear(() => {
          // 触顶自动刷新
          if (!this.isRefreshing && !this.isLoading) {
            this.refreshData();
          }
        })

        // 数据列表
        LazyForEach(this.dataSource, (item: ListItemData) => {
          ListItem() {
            this.listItemBuilder(item)
          }
        }, (item: ListItemData) => item.id)

        // 加载更多指示器
        ListItem() {
          Row() {
            if (this.isLoading) {
              LoadingProgress().width(16).height(16)
              Text('加载中...').fontSize(14).fontColor('#999').margin({ left: 8 })
            } else if (!this.hasMore) {
              Text('— 没有更多了 —').fontSize(14).fontColor('#ccc')
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding(16)
        }
        .onAppear(() => {
          if (this.hasMore && !this.isLoading) {
            this.loadMore();
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding(16)
      .edgeEffect(EdgeEffect.Spring)
      .sticky(StickyStyle.Header)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  // ==================== 列表项 UI ====================
  @Builder
  listItemBuilder(item: ListItemData) {
    Row() {
      // 左侧图片
      if (item.image) {
        Image(item.image)
          .width(56)
          .height(56)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .margin({ right: 12 })
      }

      // 右侧文字
      Column({ space: 4 }) {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(item.description)
          .fontSize(14)
          .fontColor('#666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(this.formatTime(item.timestamp))
          .fontSize(12)
          .fontColor('#999')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 2, color: '#10000000', offsetY: 1 })
    .onClick(() => {
      promptAction.showToast({ message: `点击: ${item.title}` });
    })
  }

  // ==================== 数据加载 ====================
  async loadData(isRefresh: boolean): Promise<void> {
    if (this.isLoading) return;
    this.isLoading = true;

    try {
      // 模拟网络请求
      let result = await this.mockFetch(this.page, this.pageSize);

      if (isRefresh) {
        this.dataSource.clear();
      }

      result.forEach(item => {
        this.dataSource.pushData(item);
      });

      this.hasMore = result.length >= this.pageSize;
      this.page++;
    } catch (err) {
      promptAction.showToast({ message: '加载失败，请重试' });
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  refreshData(): void {
    this.isRefreshing = true;
    this.page = 1;
    this.loadData(true);
  }

  loadMore(): void {
    if (!this.hasMore || this.isLoading) return;
    this.loadData(false);
  }

  // ==================== Mock 数据 ====================
  async mockFetch(page: number, size: number): Promise<ListItemData[]> {
    return new Promise((resolve) => {
      setTimeout(() => {
        let data: ListItemData[] = [];
        for (let i = 0; i < size; i++) {
          let index = (page - 1) * size + i;
          data.push({
            id: `item_${index}`,
            title: `列表项 ${index + 1}`,
            description: '这是列表项的描述文本，可以展示简要内容',
            timestamp: Date.now() - index * 3600000
          });
        }
        resolve(data);
      }, 800); // 模拟网络延迟
    });
  }

  // ==================== 工具函数 ====================
  formatTime(timestamp: number): string {
    let date = new Date(timestamp);
    let now = new Date();
    let diff = now.getTime() - date.getTime();

    if (diff < 60000) return '刚刚';
    if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`;
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`;
    return `${date.getMonth() + 1}/${date.getDate()}`;
  }
}
