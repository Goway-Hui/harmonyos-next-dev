/**
 * 登录表单模板 — 含表单验证和状态管理
 * 适用于 HarmonyOS NEXT (API 20+)
 */
import { promptAction } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';

// ==================== 登录页面 ====================
@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isPasswordVisible: boolean = false;
  @State isLoggingIn: boolean = false;
  @State rememberMe: boolean = false;

  // 表单验证状态
  @State usernameError: string = '';
  @State passwordError: string = '';

  aboutToAppear(): void {
    this.loadSavedCredentials();
  }

  build() {
    Column() {
      // 顶部 Logo 区域
      Column({ space: 8 }) {
        Image($r('app.media.app_logo'))
          .width(80)
          .height(80)
          .borderRadius(40)

        Text('欢迎回来')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 8 })

        Text('请登录您的账号')
          .fontSize(16)
          .fontColor('#666')
      }
      .width('100%')
      .padding({ top: 60, bottom: 40 })
      .alignItems(HorizontalAlign.Center)

      // 登录表单
      Column({ space: 4 }) {
        // 用户名
        Text('账号').fontSize(14).fontColor('#333')
        TextInput({ text: this.username })
          .placeholder('请输入用户名/手机号/邮箱')
          .maxLength(50)
          .onChange((value: string) => {
            this.username = value;
            this.validateUsername();
          })

        // 用户名错误提示
        if (this.usernameError.length > 0) {
          Text(this.usernameError)
            .fontSize(12)
            .fontColor('#F44336')
            .width('100%')
        }

        Blank().height(12)

        // 密码
        Text('密码').fontSize(14).fontColor('#333')
        Row() {
          TextInput({ text: this.password })
            .placeholder('请输入密码')
            .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
            .maxLength(32)
            .layoutWeight(1)
            .onChange((value: string) => {
              this.password = value;
              this.validatePassword();
            })

          // 密码可见切换
          Button() {
            Image($r(this.isPasswordVisible ? 'app.media.ic_eye_off' : 'app.media.ic_eye'))
              .width(20)
              .height(20)
          }
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.isPasswordVisible = !this.isPasswordVisible;
          })
        }

        // 密码错误提示
        if (this.passwordError.length > 0) {
          Text(this.passwordError)
            .fontSize(12)
            .fontColor('#F44336')
            .width('100%')
        }
      }
      .width('100%')
      .padding({ left: 24, right: 24 })

      // 记住密码 + 忘记密码
      Row() {
        Row({ space: 4 }) {
          Checkbox()
            .select(this.rememberMe)
            .onChange((selected: boolean) => {
              this.rememberMe = selected;
            })
          Text('记住密码').fontSize(14).fontColor('#666')
        }

        Text('忘记密码？')
          .fontSize(14)
          .fontColor('#007DFF')
          .onClick(() => {
            promptAction.showToast({ message: '跳转找回密码' });
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 24, right: 24, top: 16 })

      Blank().height(32)

      // 登录按钮
      Button(this.isLoggingIn ? '登录中...' : '登 录')
        .type(ButtonType.Capsule)
        .width('90%')
        .height(48)
        .backgroundColor(this.isFormValid() ? '#007DFF' : '#ccc')
        .enabled(this.isFormValid() && !this.isLoggingIn)
        .onClick(() => {
          this.handleLogin();
        })

      Blank().height(24)

      // 注册入口
      Row({ space: 4 }) {
        Text('还没有账号？').fontSize(14).fontColor('#666')
        Text('立即注册')
          .fontSize(14)
          .fontColor('#007DFF')
          .onClick(() => {
            promptAction.showToast({ message: '跳转注册页面' });
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Start)
  }

  // ==================== 表单验证 ====================
  validateUsername(): boolean {
    if (this.username.trim().length === 0) {
      this.usernameError = '请输入账号';
      return false;
    }
    if (this.username.trim().length < 3) {
      this.usernameError = '账号长度不能少于3位';
      return false;
    }
    this.usernameError = '';
    return true;
  }

  validatePassword(): boolean {
    if (this.password.length === 0) {
      this.passwordError = '请输入密码';
      return false;
    }
    if (this.password.length < 6) {
      this.passwordError = '密码长度不能少于6位';
      return false;
    }
    this.passwordError = '';
    return true;
  }

  isFormValid(): boolean {
    return this.validateUsername() && this.validatePassword();
  }

  // ==================== 登录逻辑 ====================
  async handleLogin(): Promise<void> {
    if (!this.isFormValid()) return;

    this.isLoggingIn = true;

    try {
      // 模拟登录请求
      let response = await this.mockLogin(this.username, this.password);

      // 保存登录状态
      if (this.rememberMe) {
        await this.saveCredentials(this.username, this.password);
      }

      promptAction.showToast({ message: '登录成功！' });
      // 跳转到主页
      // this.navStack.pushPath({ name: 'Home' });

    } catch (err) {
      promptAction.showToast({
        message: (err as Error).message || '登录失败，请重试',
        duration: 3000
      });
    } finally {
      this.isLoggingIn = false;
    }
  }

  // ==================== 记住密码 ====================
  async saveCredentials(username: string, password: string): Promise<void> {
    let store = await preferences.getPreferences(getContext(this), 'login_prefs');
    await store.put('saved_username', username);
    await store.put('saved_password', password);
    await store.flush();
  }

  async loadSavedCredentials(): Promise<void> {
    let store = await preferences.getPreferences(getContext(this), 'login_prefs');
    let savedUser = await store.get('saved_username', '');
    let savedPass = await store.get('saved_password', '');
    if (savedUser && savedPass) {
      this.username = savedUser as string;
      this.password = savedPass as string;
      this.rememberMe = true;
    }
  }

  // ==================== Mock 登录 ====================
  mockLogin(username: string, password: string): Promise<{ token: string }> {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        if (username && password) {
          resolve({ token: 'mock_token_' + Date.now() });
        } else {
          reject(new Error('用户名或密码错误'));
        }
      }, 1500);
    });
  }
}
