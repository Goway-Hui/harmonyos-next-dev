# 专题参考

## 性能优化

### LazyForEach — 虚拟列表

```typescript
class MyDataSource implements IDataSource {
  private dataArray: Item[] = [];

  totalCount(): number {
    return this.dataArray.length;
  }

  getData(index: number): Item {
    return this.dataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {}
  unregisterDataChangeListener(listener: DataChangeListener): void {}
}

@Entry
@Component
struct LazyList {
  private dataSource = new MyDataSource();

  build() {
    List() {
      LazyForEach(this.dataSource, (item: Item) => {
        ListItem() {
          Text(item.name).fontSize(16)
        }
      }, (item: Item) => item.id)
    }
  }
}
```

### 避免不必要的重建

```typescript
// ❌ 每次 build 都创建新对象
build() {
  Column() {
    TextInput({ text: this.input })
      .onChange((v) => { this.input = v + Date.now(); }) // 每次创建新 lambda
  }
}

// ✅ 提取方法避免匿名 lambda
onInputChange(value: string) {
  this.input = value;
}
build() {
  Column() {
    TextInput({ text: this.input })
      .onChange((v) => this.onInputChange(v))
  }
}
```

### TaskPool — 耗时操作

```typescript
import { taskpool } from '@kit.AbilityKit';

@Concurrent
function heavyCompute(data: number[]): number {
  // CPU 密集型计算
  return data.reduce((a, b) => a + Math.sqrt(b), 0);
}

async function computeInBackground() {
  let task = new taskpool.Task(heavyCompute, [1, 2, 3, 4, 5]);
  let result = await taskpool.execute(task);
  console.log(`Result: ${result}`);
}
```

### 图片优化

```typescript
// 使用缩略图加载
Image($r('app.media.large_image'))
  .width(200)
  .height(200)
  .objectFit(ImageFit.Cover)
  // ArkUI 自动按显示尺寸解码

// 通过 PixelMap 预缩放
let imageSource = image.createImageSource('file://path/to/img.jpg');
let pixelMap = await imageSource.createPixelMap({
  desiredWidth: 200,   // 按需解码
  desiredHeight: 200,
  desiredPixelFormat: image.PixelMapFormat.RGBA_8888
});
```

## 加密

```typescript
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

// SHA-256 哈希
let encoder = cryptoFramework.createMd('SHA256');
await encoder.append(Uint8Array.from('Hello'));
let hash = await encoder.digest();
console.log(hash.data);

// AES 加密
let generator = cryptoFramework.createSymKeyGenerator('AES256');
let key = await generator.generateSymKey();
let cipher = cryptoFramework.createCipher('AES256|GCM|PKCS7');
let params: cryptoFramework.GcmParamsSpec = {
  iv: { data: new Uint8Array(12) },
  aad: { data: new Uint8Array(0) },
  authTag: { data: new Uint8Array(16) }
};
await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, key, params);
let plainText = { data: new Uint8Array([...]) };
let encrypted = await cipher.update(plainText);
let authTag = await cipher.doFinal(null);
```

## 多设备流转

```typescript
import { continuation } from '@kit.AbilityKit';

// 注册流转
continuation.registerForContinuation({
  deviceType: [continuation.DeviceType.PHONE, continuation.DeviceType.TABLET],
  reversible: true
});

// 开始流转
async function startContinuation() {
  let devices = await continuation.startContinuation({
    targetDevice: { networkId: 'device_network_id' }
  });
}
```

## Stage 模型适配（从 FA 迁移）

| FA 模型 | Stage 模型 |
|---------|------------|
| `Ability` | `UIAbility` |
| `getContext()` | `getContext(this)` 或 `this.context` |
| `@Entry` 多页面 | Navigation + NavPathStack |
| `featureAbility` | `UIAbilityContext` |
| `particleAbility` | `ExtensionAbility` |
| `dataAbility` | `DataShareExtensionAbility` |

## 常见错误码

| 错误码 | 说明 | 处理 |
|--------|------|------|
| 201 | 权限未声明 | 检查 module.json5 |
| 202 | 权限未授权 | 运行时弹窗授权 |
| 401 | 参数错误 | 检查 API 参数类型 |
| 801 | API 不支持 | 检查 targetAPIVersion |
| 100001 | 内部错误 | 重试或 catch |
| 100003 | 网络不可用 | 检查网络状态 |
| 20100000 | 数据库错误 | 检查 SQL/RDB 操作 |
