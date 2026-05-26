/**
 * 通用页面模板 — 带 Navigation + NavPathStack
 * 适用于 HarmonyOS NEXT (API 20+)
 *
 * 使用方式：复制此文件，替换 struct 名称和页面内容即可
 */
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

// ==================== 类型定义 ====================
interface PageParams {
  id?: number;
  title?: string;
  [key: string]: object | string | number | boolean | undefined;
}

// ==================== 主页 — 带导航 ====================
@Entry
@Component
struct HomePage {
  private navStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    // 初始化数据
    this.loadData();
  }

  build() {
    Navigation(this.navStack) {
      Column() {
        // 页面标题
        Text('首页')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding(16)

        // 内容区域
        List({ space: 12 }) {
          ForEach(this.menuItems, (item: MenuItem) => {
            ListItem() {
              this.menuItemBuilder(item);
            }
          }, (item: MenuItem) => item.id.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .padding(16)
      }
      .width('100%')
      .height('100%')
    }
    .title('我的应用')
    .hideTitleBar(false)
    .navDestination(this.pageMap) // 注册目标页面
  }

  // ==================== 页面路由表 ====================
  @Builder
  pageMap(name: string, param: object) {
    if (name === 'Detail') {
      DetailPage({
        navStack: this.navStack,
        params: param as PageParams
      });
    } else if (name === 'Settings') {
      // SettingsPage({ navStack: this.navStack });
    }
  }

  // ==================== 菜单列表数据 ====================
  get menuItems(): MenuItem[] {
    return [
      { id: 1, title: '详情页面', icon: 'detail' },
      { id: 2, title: '设置', icon: 'setting' }
    ];
  }

  // ==================== 菜单项 UI ====================
  @Builder
  menuItemBuilder(item: MenuItem) {
    Row() {
      Text(item.title)
        .fontSize(16)
        .layoutWeight(1)

      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 2, color: '#10000000', offsetY: 1 })
    .onClick(() => {
      this.navStack.pushPath({
        name: item.id === 1 ? 'Detail' : 'Settings',
        param: { id: item.id, title: item.title }
      });
    })
  }

  // ==================== 数据加载 ====================
  loadData(): void {
    // 模拟网络请求
    // ...
  }
}

// ==================== 详情页面 ====================
@Component
struct DetailPage {
  private navStack: NavPathStack = new NavPathStack();
  @Param params: PageParams = {};

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Text(`详情页面 — ID: ${this.params.id}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)

        Text(`标题: ${this.params.title || '(无标题)'}`)
          .fontSize(16)
          .fontColor('#666')

        Button('返回')
          .type(ButtonType.Capsule)
          .onClick(() => {
            this.navStack.pop();
          })

        Button('返回首页')
          .type(ButtonType.Capsule)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .onClick(() => {
            this.navStack.clear();
          })
      }
      .width('100%')
      .height('100%')
      .padding(24)
      .justifyContent(FlexAlign.Center)
    }
    .title(`详情`)
    .onBackPressed(() => {
      this.navStack.pop();
      return true;
    })
  }
}

// ==================== 通用类型定义 ====================
interface MenuItem {
  id: number;
  title: string;
  icon?: string;
}
