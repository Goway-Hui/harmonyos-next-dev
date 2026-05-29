@Entry
@Component
struct Index {
  @State message: string = 'Hello HarmonyOS NEXT!';

  build() {
    Column() {
      Text(this.message)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)

      Button('点击改变')
        .type(ButtonType.Capsule)
        .margin({ top: 20 })
        .onClick(() => {
          this.message = '欢迎使用 HarmonyOS NEXT！';
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}