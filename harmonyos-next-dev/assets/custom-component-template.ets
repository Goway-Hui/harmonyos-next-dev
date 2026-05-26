/**
 * 自定义组件模板 — @Builder + @BuilderParam + 插槽模式
 * 适用于 HarmonyOS NEXT (API 20+)
 */

// ==================== 1. 基础自定义组件 ====================
@Component
struct CardContainer {
  @Prop title: string = '';
  @Prop backgroundColor: string = '#FFFFFF';
  @Prop borderRadius: number = 12;

  build() {
    Column() {
      // 标题栏
      if (this.title) {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      }

      // 内容区域（通过 @BuilderParam 插槽）
      // 见下面的 SlotCard 实现

      // 默认尾巴（通过 @BuilderParam）
    }
    .width('100%')
    .backgroundColor(this.backgroundColor)
    .borderRadius(this.borderRadius)
    .shadow({ radius: 2, color: '#15000000', offsetY: 1 })
  }
}

// ==================== 2. 插槽模式组件（@BuilderParam）====================
@Component
struct SlotCard {
  @Prop title: string;
  // 声明插槽：内容区域
  @BuilderParam content: () => void = this.defaultContent;
  // 声明插槽：底部操作区
  @BuilderParam footer: () => void = this.defaultFooter;

  // 默认内容
  @Builder
  defaultContent() {
    Text('默认内容 — 请通过 @BuilderParam 传入自定义内容')
      .fontSize(14)
      .fontColor('#999')
      .padding(16)
  }

  // 默认底部
  @Builder
  defaultFooter() {
    // 默认无底部
  }

  build() {
    Column() {
      // 标题
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 8 })

      // 内容插槽
      this.content()

      Divider().margin({ top: 8, bottom: 8 })

      // 底部插槽
      this.footer()
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 2, color: '#10000000', offsetY: 1 })
    .padding({ bottom: 16 })
  }
}

// ==================== 3. 可复用函数式 Builder ====================
@Builder
function iconTextBuilder(icon: Resource, text: string) {
  Row({ space: 8 }) {
    Image(icon)
      .width(20)
      .height(20)
    Text(text)
      .fontSize(15)
  }
  .padding(8)
}

@Builder
function actionButtonBuilder(label: string, color: string, action: () => void) {
  Button(label)
    .type(ButtonType.Capsule)
    .height(36)
    .backgroundColor(color)
    .fontColor(Color.White)
    .fontSize(14)
    .onClick(action)
}

// ==================== 4. 泛型列表组件 ====================
@Component
struct GenericList<T> {
  @Prop items: T[] = [];
  @BuilderParam itemRender: (item: T, index: number) => void = () => {};
  @BuilderParam header: () => void = () => {};
  @BuilderParam footer: () => void = () => {};

  build() {
    Column() {
      // 头部
      this.header()

      // 列表
      List({ space: 8 }) {
        ForEach(this.items, (item: T, index: number) => {
          ListItem() {
            this.itemRender(item, index)
          }
        })
      }
      .width('100%')

      // 底部
      this.footer()
    }
    .width('100%')
  }
}

// ==================== 5. 使用示例 ====================
@Entry
@Component
struct CustomComponentDemo {
  @State numbers: number[] = [1, 2, 3, 4, 5];
  @State names: string[] = ['张三', '李四', '王五'];

  build() {
    Scroll() {
      Column({ space: 16 }) {
        // 标题
        Text('自定义组件示例')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)

        // === 使用 SlotCard（传入自定义内容）===
        SlotCard({
          title: '用户信息',
          content: () => {
            Column({ space: 8 }) {
              iconTextBuilder($r('app.media.icon'), '张三')
              iconTextBuilder($r('app.media.icon'), 'zhangsan@example.com')
            }
            .padding(16)
            .width('100%')
          },
          footer: () => {
            Row({ space: 12 }) {
              actionButtonBuilder('编辑', '#007DFF', () => {})
              actionButtonBuilder('删除', '#F44336', () => {})
            }
            .padding({ left: 16, right: 16 })
            .width('100%')
          }
        })

        // === 使用 SlotCard（默认内容）===
        SlotCard({ title: '空卡片' })

        // === 使用 GenericList 数字列表 ===
        Text('数字列表').fontSize(18).fontWeight(FontWeight.Bold)
        GenericList<number>({
          items: this.numbers,
          header: () => {
            Text(`共 ${this.numbers.length} 项`)
              .fontSize(14)
              .fontColor('#666')
              .padding({ bottom: 4 })
          },
          itemRender: (item: number, index: number) => {
            Row() {
              Text(`${index + 1}. 数字 ${item}`)
                .fontSize(16)
            }
            .width('100%')
            .height(44)
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
          }
        })

        // === 使用 GenericList 名字列表 ===
        Text('名字列表').fontSize(18).fontWeight(FontWeight.Bold)
        GenericList<string>({
          items: this.names,
          itemRender: (item: string, index: number) => {
            Row() {
              Circle().width(32).height(32).fill('#007DFF')
              Text(item).fontSize(16).margin({ left: 12 })
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
          }
        })
      }
      .width('100%')
      .padding(16)
    }
    .backgroundColor('#f5f5f5')
  }
}
