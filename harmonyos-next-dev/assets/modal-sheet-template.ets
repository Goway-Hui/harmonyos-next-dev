/**
 * 弹窗/Sheet 模板 — 对话框、底部弹窗、操作菜单
 * 适用于 HarmonyOS NEXT (API 20+)
 */
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ModalDemo {
  @State showSheet: boolean = false;
  @State showCustomDialog: boolean = false;
  @State selectedOption: string = '';

  build() {
    Column({ space: 16 }) {
      Text('弹窗示例')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)

      // ==================== AlertDialog ====================
      Button('确认对话框')
        .type(ButtonType.Capsule)
        .width('80%')
        .onClick(() => this.showAlertDialog())

      // ==================== 带有输入框的 AlertDialog ====================
      Button('输入对话框')
        .type(ButtonType.Capsule)
        .width('80%')
        .onClick(() => this.showPromptDialog())

      // ==================== 操作菜单（多按钮）====================
      Button('操作选择菜单')
        .type(ButtonType.Capsule)
        .width('80%')
        .onClick(() => this.showActionMenu())

      // ==================== 底部 Sheet ====================
      Button('底部弹窗 (bindSheet)')
        .type(ButtonType.Capsule)
        .width('80%')
        .onClick(() => { this.showSheet = true; })
        .bindSheet($$this.showSheet, this.sheetBuilder(), {
          height: SheetSize.LARGE,
          backgroundColor: '#FFFFFF',
          dragBar: true,
          showClose: true,
          title: '请选择操作'
        })

      // ==================== Toast 提示 ====================
      Button('Toast 提示')
        .type(ButtonType.Capsule)
        .width('80%')
        .onClick(() => {
          promptAction.showToast({
            message: '操作成功！',
            duration: 2000,
            bottom: 100
          });
        })

      // 选中结果
      if (this.selectedOption) {
        Text(`你选择了: ${this.selectedOption}`)
          .fontSize(16)
          .fontColor('#007DFF')
          .margin({ top: 8 })
      }
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .justifyContent(FlexAlign.Center)
  }

  // ==================== 确认对话框 ====================
  showAlertDialog(): void {
    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除这条记录吗？此操作不可撤销。',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      gridColumnCount: 2,
      primaryButton: {
        value: '取消',
        action: () => {
          promptAction.showToast({ message: '已取消' });
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#F44336',
        action: () => {
          promptAction.showToast({ message: '已删除' });
          this.selectedOption = '删除';
        }
      }
    });
  }

  // ==================== 带输入的对话框 ====================
  showPromptDialog(): void {
    // ArkUI 暂未原生支持输入对话框
    // 可通过自定义弹窗或 bindSheet 实现
    AlertDialog.show({
      title: '请输入',
      message: '当前版本请使用底部 Sheet 实现输入',
      confirm: {
        value: '好的'
      }
    });
  }

  // ==================== 操作菜单 ====================
  showActionMenu(): void {
    AlertDialog.show({
      title: '选择操作',
      message: '',
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -20 },
      primaryButton: {
        value: '编辑',
        action: () => {
          this.selectedOption = '编辑';
        }
      },
      secondaryButton: {
        value: '分享',
        action: () => {
          this.selectedOption = '分享';
        }
      }
    });
  }

  // ==================== 底部 Sheet 内容 ====================
  @Builder
  sheetBuilder() {
    Column({ space: 16 }) {
      // 标题
      Text('操作选项')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)

      Divider().margin({ top: 8 })

      // 选项列表
      ForEach(['拍照', '从相册选择', '从文件选择'], (option: string, index: number) => {
        Row() {
          Text(option).fontSize(16)
          Blank()
          if (index === 0) {
            Text('推荐').fontSize(12).fontColor('#007DFF')
          }
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.selectedOption = option;
          this.showSheet = false;
          promptAction.showToast({ message: `选择: ${option}` });
        })

        if (index < 2) {
          Divider().width('90%').opacity(0.3)
        }
      })

      Blank().height(16)

      // 取消按钮
      Button('取消')
        .type(ButtonType.Capsule)
        .width('100%')
        .backgroundColor('#f5f5f5')
        .fontColor('#666')
        .onClick(() => {
          this.showSheet = false;
        })
    }
    .width('100%')
    .padding(16)
    .margin({ bottom: 16 })
  }
}
