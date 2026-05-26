# 安全与认证参考

## UserAuth — 生物识别认证

```typescript
import { userAuth } from '@kit.UserAuthKit';

// 检查认证能力
let authenticator = userAuth.getUserAuthInstance({
  challenge: new Uint8Array(32),  // 随机挑战值
  authType: [userAuth.UserAuthType.FINGERPRINT, userAuth.UserAuthType.FACE_ONLY]
});

let result = await authenticator.auth();
if (result.result === userAuth.UserAuthResultCode.SUCCESS) {
  console.log('认证成功');
} else {
  console.error('认证失败', result.result);
}

// 检查设备是否支持
let isSupported = await authenticator.getAvailableStatus();
console.log(`Bio auth available: ${isSupported}`);
```

### 认证类型

| 类型 | 说明 |
|------|------|
| `FINGERPRINT` | 指纹识别 |
| `FACE_ONLY` | 2D 人脸识别 |
| `FACE` | 3D 人脸识别 |
| `PIN` | 锁屏密码 |

## HUKS — 密钥管理

```typescript
import { huks } from '@kit.HuksKit';

// 生成密钥
let properties: huks.HuksParam[] = [
  { tag: huks.HuksTag.PURPOSE, value: huks.HuksPurpose.ENCRYPT },
  { tag: huks.HuksTag.ALGORITHM, value: huks.HuksAlg.AES },
  { tag: huks.HuksTag.KEY_SIZE, value: 256 }
];

let options: huks.HuksOptions = {
  properties: properties
};

await huks.generateKey('key_alias', options);

// 加密
import { huks } from '@kit.HuksKit';
let plainText = new Uint8Array([/* 明文数据 */]);
let encryptOptions: huks.HuksOptions = {
  properties: [{
    tag: huks.HuksTag.PURPOSE,
    value: huks.HuksPurpose.ENCRYPT
  }, {
    tag: huks.HuksTag.AUTH_STORAGE_LEVEL,
    value: huks.HuksAuthStorageLevel.ECE
  }],
  inData: plainText
};
let encryptedData = await huks.init('key_alias', encryptOptions);

// 解密
let decryptOptions: huks.HuksOptions = {
  properties: [{
    tag: huks.HuksTag.PURPOSE,
    value: huks.HuksPurpose.DECRYPT
  }],
  inData: encryptedData.outData
};
let decryptedData = await huks.init('key_alias', decryptOptions);

// 删除密钥
await huks.deleteKey('key_alias');
```

### HUKS 常见算法

| 算法 | 用途 |
|------|------|
| AES 256 | 对称加密 |
| RSA 2048/4096 | 非对称加密/签名 |
| ECC P256 | 数字签名 |
| HMAC SHA256 | 消息认证 |
| DSA | 数字签名 |

## 证书管理

```typescript
import { certManager } from '@kit.HuksKit';

// 安装证书
let certData = new Uint8Array([/* 证书 DER 数据 */]);
await certManager.installCertificate(
  certData,
  certManager.CertType.CERT_TYPE_CA
);

// 验证证书链
let isValid = await certManager.verifyCertificate(certData);
```

## 权限安全检查清单

| 检查项 | 说明 |
|--------|------|
| 敏感权限 | 必须在 module.json5 声明 |
| 运行时授权 | 敏感权限触发系统弹窗 |
| 权限撤销 | 用户在设置中可随时撤销 |
| 最小权限 | 只申请业务需要的权限 |
| HSP 权限隔离 | 共享包权限与宿主隔离 |

## 安全最佳实践

1. **敏感数据**：用 HUKS 加密存储，不要明文存本地文件
2. **网络通信**：使用 HTTPS，避免 HTTP
3. **日志**：不要打敏感信息日志（密码、Token）
4. **WebView**：谨慎加载外部 URL，避免 XSS
5. **Intent**：验证 Want 来源，防止恶意调用
6. **数据库**：设置合适的 securityLevel（S1-S4）
