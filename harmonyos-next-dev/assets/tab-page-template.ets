/**
 * Tabs 页面模板 — 多 Tab 切换 + 各自独立内容
 * 适用于 HarmonyOS NEXT (API 20+)
 */
import { promptAction } from '@kit.ArkUI';

// ==================== Tab 数据 ====================
interface TabItem {
  title: string;
  icon?: Resource;
  badge?: number;
}

// ==================== 主页 ====================
@Entry
@Component
struct TabPage {
  @State currentTabIndex: number = 0;
  @State unreadCounts: number[] = [3, 0, 5, 1];

  private tabs: TabItem[] = [
    { title: '首页', badge: 0 },
    { title: '消息', badge: 3 },
    { title: '发现', badge: 5 },
    { title: '我的', badge: 0 }
  ];

  build() {
    Column() {
      // 页面标题
      Text(this.tabs[this.currentTabIndex].title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // Tabs 组件
      Tabs({
        barPosition: BarPosition.Start,
        index: this.currentTabIndex
      }) {
        // Tab 1: 首页
        TabContent() {
          HomeTabContent()
        }
        .tabBar(this.tabBarBuilder(0))

        // Tab 2: 消息
        TabContent() {
          MessageTabContent()
        }
        .tabBar(this.tabBarBuilder(1))

        // Tab 3: 发现
        TabContent() {
          DiscoverTabContent()
        }
        .tabBar(this.tabBarBuilder(2))

        // Tab 4: 我的
        TabContent() {
          ProfileTabContent()
        }
        .tabBar(this.tabBarBuilder(3))
      }
      .scrollable(true)
      .barWidth('100%')
      .barHeight(50)
      .animationDuration(300)
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  // ==================== Tab Bar 构建 ====================
  @Builder
  tabBarBuilder(index: number) {
    let tab = this.tabs[index];
    Column({ space: 2 }) {
      // 带角标的图标
      Stack() {
        Image($r('app.media.ic_tab'))
          .width(24)
          .height(24)
          .fillColor(this.currentTabIndex === index ? '#007DFF' : '#999')

        // 角标
        if (tab.badge > 0) {
          Text(tab.badge > 99 ? '99+' : tab.badge.toString())
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor('#F44336')
            .borderRadius(8)
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
            .position({ top: -4, right: -12 })
        }
      }
      .width(30)
      .height(28)

      Text(tab.title)
        .fontSize(12)
        .fontColor(this.currentTabIndex === index ? '#007DFF' : '#999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

// ==================== Tab 1: 首页 ====================
@Component
struct HomeTabContent {
  build() {
    Scroll() {
      Column({ space: 12 }) {
        // 轮播图
        Swiper() {
          ForEach([1, 2, 3], (index: number) => {
            Text(`Banner ${index}`)
              .width('100%')
              .height(160)
              .backgroundColor(index === 1 ? '#007DFF' : index === 2 ? '#FF6600' : '#4CAF50')
              .fontColor(Color.White)
              .fontSize(24)
              .textAlign(TextAlign.Center)
          })
        }
        .autoPlay(true)
        .interval(3000)
        .indicator(true)
        .height(180)
        .borderRadius(12)

        // 快捷入口
        Row({ space: 12 }) {
          ForEach(['功能A', '功能B', '功能C', '功能D'], (name: string) => {
            Column() {
              Circle().width(44).height(44).fill('#E3F2FD')
              Text(name).fontSize(12).margin({ top: 4 })
            }
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)

        // 推荐列表
        Text('推荐内容').fontSize(18).fontWeight(FontWeight.Bold)

        ForEach(['推荐1', '推荐2', '推荐3'], (item: string, index: number) => {
          Row() {
            Text(item).fontSize(16)
          }
          .width('100%')
          .height(72)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
        })
      }
      .width('100%')
      .padding(16)
    }
  }
}

// ==================== Tab 2: 消息 ====================
@Component
struct MessageTabContent {
  build() {
    List({ space: 8 }) {
      ForEach(['系统通知', '评论回复', '点赞通知', '私信'], (item: string, index: number) => {
        ListItem() {
          Row() {
            Circle().width(40).height(40).fill(['#007DFF', '#FF6600', '#4CAF50', '#9C27B0'][index])
            Text(item).fontSize(16).margin({ left: 12 }).layoutWeight(1)
            Text('刚刚').fontSize(12).fontColor('#999')
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
        }
      })
    }
    .width('100%')
    .padding(16)
  }
}

// ==================== Tab 3: 发现 ====================
@Component
struct DiscoverTabContent {
  build() {
    Grid() {
      ForEach(Array.from({ length: 12 }, (_, i) => `Item ${i + 1}`), (item: string) => {
        GridItem() {
          Column() {
            Circle().width(60).height(60).fill('#E3F2FD')
            Text(item).fontSize(14).margin({ top: 4 })
          }
          .width('100%')
          .height(100)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
        }
      })
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(12)
    .columnsGap(12)
    .padding(16)
  }
}

// ==================== Tab 4: 我的 ====================
@Component
struct ProfileTabContent {
  build() {
    Column({ space: 12 }) {
      // 用户信息
      Row() {
        Circle().width(56).height(56).fill('#007DFF')
        Column({ space: 4 }) {
          Text('用户名').fontSize(18).fontWeight(FontWeight.Bold)
          Text('ID: 123456').fontSize(14).fontColor('#666')
        }
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      // 设置菜单
      ForEach(['我的订单', '收藏夹', '浏览历史', '设置'], (item: string) => {
        Row() {
          Text(item).fontSize(16)
          Blank()
          Image($r('app.media.ic_arrow_right')).width(16).height(16)
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .onClick(() => {
          promptAction.showToast({ message: `点击: ${item}` });
        })
      })
    }
    .width('100%')
    .padding(16)
  }
}
