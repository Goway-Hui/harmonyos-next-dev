/**
 * 表单页面模板 — 表单输入 + 校验 + 提交
 * 适用于 HarmonyOS NEXT (API 20+)
 */
import { promptAction } from '@kit.ArkUI';

// ==================== 表单数据模型 ====================
interface FormData {
  name: string;
  phone: string;
  email: string;
  gender: string;
  birthday: string;
  remark: string;
  agreeTerms: boolean;
}

interface FormErrors {
  name?: string;
  phone?: string;
  email?: string;
}

// ==================== 表单页面 ====================
@Entry
@Component
struct FormPage {
  @State form: FormData = {
    name: '',
    phone: '',
    email: '',
    gender: 'male',
    birthday: '',
    remark: '',
    agreeTerms: false
  };

  @State errors: FormErrors = {};
  @State isSubmitting: boolean = false;

  // 性别选项
  private genderOptions: { label: string; value: string }[] = [
    { label: '男', value: 'male' },
    { label: '女', value: 'female' },
    { label: '保密', value: 'secret' }
  ];

  build() {
    Column() {
      // 标题
      Text('个人信息登记')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      // 可滚动的表单
      Scroll() {
        Column({ space: 4 }) {
          // === 姓名 ===
          this.formField('姓名', true)
          TextInput({ text: this.form.name })
            .placeholder('请输入姓名')
            .maxLength(20)
            .onChange((value: string) => {
              this.form.name = value;
              this.validateField('name');
            })
          this.fieldError(this.errors.name)

          Blank().height(8)

          // === 手机号 ===
          this.formField('手机号', true)
          TextInput({ text: this.form.phone })
            .placeholder('请输入11位手机号')
            .type(InputType.PhoneNumber)
            .maxLength(11)
            .onChange((value: string) => {
              this.form.phone = value;
              this.validateField('phone');
            })
          this.fieldError(this.errors.phone)

          Blank().height(8)

          // === 邮箱 ===
          this.formField('邮箱', false)
          TextInput({ text: this.form.email })
            .placeholder('请输入邮箱地址（选填）')
            .type(InputType.Email)
            .maxLength(50)
            .onChange((value: string) => {
              this.form.email = value;
              this.validateField('email');
            })
          this.fieldError(this.errors.email)

          Blank().height(8)

          // === 性别 ===
          this.formField('性别', false)
          Row({ space: 16 }) {
            ForEach(this.genderOptions, (option) => {
              Row({ space: 4 }) {
                Radio({ value: option.value, group: 'gender' })
                  .checked(this.form.gender === option.value)
                  .onChange(() => { this.form.gender = option.value; })
                Text(option.label).fontSize(16)
              }
            })
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)

          Blank().height(8)

          // === 备注 ===
          this.formField('备注', false)
          TextArea({ text: this.form.remark })
            .placeholder('请输入备注信息（选填）')
            .maxLength(200)
            .height(100)
            .onChange((value: string) => {
              this.form.remark = value;
            })

          Blank().height(16)

          // === 同意条款 ===
          Row({ space: 8 }) {
            Checkbox()
              .select(this.form.agreeTerms)
              .onChange((selected: boolean) => {
                this.form.agreeTerms = selected;
              })
            Text('我已阅读并同意')
              .fontSize(14)
            Text('《用户协议》')
              .fontSize(14)
              .fontColor('#007DFF')
              .onClick(() => {
                promptAction.showToast({ message: '打开用户协议' });
              })
            Text('和')
              .fontSize(14)
            Text('《隐私政策》')
              .fontSize(14)
              .fontColor('#007DFF')
              .onClick(() => {
                promptAction.showToast({ message: '打开隐私政策' });
              })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          Blank().height(24)

          // === 提交按钮 ===
          Button(this.isSubmitting ? '提交中...' : '提交')
            .type(ButtonType.Capsule)
            .width('100%')
            .height(48)
            .backgroundColor(this.canSubmit() ? '#007DFF' : '#ccc')
            .enabled(this.canSubmit() && !this.isSubmitting)
            .onClick(() => this.handleSubmit())

          Blank().height(32)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  // ==================== 表单字段标签 ====================
  @Builder
  formField(label: string, required: boolean) {
    Row({ space: 4 }) {
      if (required) {
        Text('*').fontColor('#F44336').fontSize(16)
      }
      Text(label).fontSize(14).fontColor('#333')
    }
    .width('100%')
    .margin({ bottom: 4 })
  }

  // ==================== 错误提示 ====================
  @Builder
  fieldError(error: string | undefined) {
    if (error) {
      Text(error)
        .fontSize(12)
        .fontColor('#F44336')
        .width('100%')
        .margin({ top: 2 })
    }
  }

  // ==================== 表单校验 ====================
  validateField(field: keyof FormErrors): boolean {
    switch (field) {
      case 'name':
        if (!this.form.name.trim()) {
          this.errors.name = '请输入姓名';
          return false;
        }
        if (this.form.name.trim().length < 2) {
          this.errors.name = '姓名至少2个字符';
          return false;
        }
        this.errors.name = undefined;
        return true;

      case 'phone':
        let phone = this.form.phone.trim();
        if (!phone) {
          this.errors.phone = '请输入手机号';
          return false;
        }
        if (!/^1[3-9]\d{9}$/.test(phone)) {
          this.errors.phone = '请输入正确的11位手机号';
          return false;
        }
        this.errors.phone = undefined;
        return true;

      case 'email':
        let email = this.form.email.trim();
        if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
          this.errors.email = '请输入正确的邮箱地址';
          return false;
        }
        this.errors.email = undefined;
        return true;

      default:
        return true;
    }
  }

  validateAll(): boolean {
    let valid = true;
    valid = this.validateField('name') && valid;
    valid = this.validateField('phone') && valid;
    if (this.form.email) {
      valid = this.validateField('email') && valid;
    }
    return valid;
  }

  canSubmit(): boolean {
    return (
      this.form.name.trim().length > 0 &&
      this.form.phone.trim().length > 0 &&
      this.form.agreeTerms &&
      !this.errors.name &&
      !this.errors.phone
    );
  }

  // ==================== 提交流程 ====================
  async handleSubmit(): Promise<void> {
    if (!this.validateAll()) {
      promptAction.showToast({ message: '请检查表单填写' });
      return;
    }

    this.isSubmitting = true;

    try {
      // 模拟提交
      await new Promise(resolve => setTimeout(resolve, 1500));
      promptAction.showToast({ message: '提交成功！' });
      this.resetForm();
    } catch (err) {
      promptAction.showToast({ message: '提交失败，请重试' });
    } finally {
      this.isSubmitting = false;
    }
  }

  resetForm(): void {
    this.form = {
      name: '',
      phone: '',
      email: '',
      gender: 'male',
      birthday: '',
      remark: '',
      agreeTerms: false
    };
    this.errors = {};
  }
}
