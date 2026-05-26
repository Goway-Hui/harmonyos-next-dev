/**
 * 状态管理 V2 模板 — @Local / @Param / @Event / @ObservedV2
 * 适用于 HarmonyOS NEXT (API 20+)
 */

// ==================== 数据模型（可观察类）====================
@ObservedV2
class UserProfile {
  @Trace name: string = '';
  @Trace age: number = 0;
  @Trace email: string = '';
  @Trace isVip: boolean = false;

  constructor(name: string, age: number, email: string) {
    this.name = name;
    this.age = age;
    this.email = email;
  }

  get displayName(): string {
    return `${this.name}（${this.age}岁）`;
  }
}

@ObservedV2
class AppSettings {
  @Trace theme: 'light' | 'dark' | 'system' = 'system';
  @Trace fontSize: number = 16;
  @Trace language: string = 'zh-CN';
}

// ==================== 父组件 — 使用 @Local 和 @Provider ====================
@Entry
@ComponentV2
struct ProfilePage {
  @Local user: UserProfile = new UserProfile('张三', 28, 'zhangsan@example.com');
  @Local settings: AppSettings = new AppSettings();

  // 跨组件共享
  @Provider('appSettings') appSettings: AppSettings = this.settings;

  build() {
    Column({ space: 16 }) {
      // 标题
      Text('个人主页 (V2)')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      // 用户信息卡片
      UserInfoCard({
        user: this.user,
        onUpdate: (newName: string) => {
          this.user.name = newName;
        }
      })

      // 编辑表单
      ProfileEditor({
        user: this.user
      })

      // 设置面板（通过 Provider / Consumer 通信）
      SettingsPanel()

      // 状态摘要
      StateSummary({ user: this.user })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#f5f5f5')
  }
}

// ==================== 子组件 — 使用 @Param + @Event ====================
@ComponentV2
struct UserInfoCard {
  @Param user: UserProfile = new UserProfile('', 0, '');
  @Event onUpdate: (name: string) => void = (name: string) => {};

  build() {
    Column() {
      // 头像占位
      Circle()
        .width(64)
        .height(64)
        .fill('#007DFF')

      Text(this.user.displayName)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 8 })

      Text(this.user.email)
        .fontSize(14)
        .fontColor('#666')

      // VIP 标识（@Trace 自动追踪）
      if (this.user.isVip) {
        Text('VIP 会员')
          .fontSize(12)
          .fontColor('#FF6600')
          .backgroundColor('#FFF3E0')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(4)
          .margin({ top: 4 })
      }

      // 调用父组件回调
      Button('改名')
        .type(ButtonType.Capsule)
        .margin({ top: 12 })
        .onClick(() => {
          this.onUpdate('李四(已改名)');
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .alignItems(HorizontalAlign.Center)
  }
}

// ==================== 编辑表单 ====================
@ComponentV2
struct ProfileEditor {
  @Param user: UserProfile = new UserProfile('', 0, '');

  build() {
    Column({ space: 12 }) {
      Text('编辑资料')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      // 姓名
      Row() {
        Text('姓名').width(60).fontColor('#666')
        TextInput({ text: this.user.name })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.user.name = value;
          })
      }

      // 年龄
      Row() {
        Text('年龄').width(60).fontColor('#666')
        TextInput({ text: this.user.age.toString() })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.user.age = parseInt(value) || 0;
          })
      }

      // 邮箱
      Row() {
        Text('邮箱').width(60).fontColor('#666')
        TextInput({ text: this.user.email })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.user.email = value;
          })
      }

      // VIP 开关
      Row() {
        Text('VIP 会员').fontColor('#666')
        Toggle({ isOn: this.user.isVip })
          .onChange((isOn: boolean) => {
            this.user.isVip = isOn;
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}

// ==================== 使用 @Consumer 消费共享状态 ====================
@ComponentV2
struct SettingsPanel {
  @Consumer('appSettings') settings: AppSettings = new AppSettings();

  build() {
    Column({ space: 12 }) {
      Text('应用设置 (跨组件共享)')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      // 主题选择
      Row() {
        Text('主题').fontColor('#666')
        Row({ space: 8 }) {
          this.themeButton('浅色', 'light')
          this.themeButton('深色', 'dark')
          this.themeButton('跟随系统', 'system')
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 字体大小
      Row() {
        Text('字体大小').fontColor('#666')
        Slider({
          value: this.settings.fontSize,
          min: 12,
          max: 24,
          step: 1
        })
        .width(150)
        .onChange((value: number) => {
          this.settings.fontSize = value;
        })
        Text(`${this.settings.fontSize}`)
          .fontSize(14)
          .fontColor('#999')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  @Builder
  themeButton(label: string, themeValue: string) {
    Text(label)
      .fontSize(14)
      .fontColor(this.settings.theme === themeValue ? '#007DFF' : '#666')
      .backgroundColor(this.settings.theme === themeValue ? '#E3F2FD' : '#f5f5f5')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .onClick(() => {
        this.settings.theme = themeValue as 'light' | 'dark' | 'system';
      })
  }
}

// ==================== 使用 @Monitor 监听变化 ====================
@ComponentV2
struct StateSummary {
  @Param user: UserProfile = new UserProfile('', 0, '');

  // @Monitor 监听属性变化
  @Monitor('user.name')
  onNameChanged(change: MonitorChange): void {
    console.log(`姓名从 "${change.value?.[0]}" 变为 "${change.value?.[1]}"`);
  }

  @Monitor('user.isVip')
  onVipChanged(change: MonitorChange): void {
    console.log(`VIP: ${change.value?.[0]} → ${change.value?.[1]}`);
  }

  build() {
    Column({ space: 8 }) {
      Text('状态摘要 (V2)')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)

      Text(`姓名: ${this.user.name}`)
      Text(`年龄: ${this.user.age}`)
      Text(`邮箱: ${this.user.email}`)
      Text(`VIP: ${this.user.isVip ? '是' : '否'}`)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#E8F5E9')
    .borderRadius(12)
  }
}
