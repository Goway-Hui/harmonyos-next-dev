# 开发工具参考

## DevEco Studio

### 基本操作

| 操作 | 快捷键 |
|------|--------|
| 格式化代码 | `Ctrl+Alt+L` |
| 快速修复 | `Alt+Enter` |
| 查找使用 | `Alt+F7` |
| 重构重命名 | `Shift+F6` |
| 全局搜索 | `Ctrl+Shift+F` |
| 运行应用 | `Shift+F10` |

### 配置签名

1. 点击 `File > Project Structure > Signing Config`
2. 勾选 `Automatically generate signing`
3. 配置 `Store Password` / `Key Alias` / `Key Password`

## hvigorw — 构建工具

```bash
# 清理
hvigorw clean

# 构建 HAP（debug）
hvigorw assembleHap -p buildMode=debug

# 构建 HAP（release）
hvigorw assembleHap -p buildMode=release

# 构建 APP（上架包）
hvigorw assembleApp -p buildMode=release

# 构建 HAR（静态库）
hvigorw assembleHar

# 构建 HSP（共享包）
hvigorw assembleHsp

# 构建指定模块
hvigorw assembleHap -p module=entry@default --mode module

# 运行测试
hvigorw onDeviceTest -p module=entry -p coverage=true

# CI/CD 推荐
hvigorw assembleApp -p buildMode=release --no-daemon
```

### 常用参数

| 参数 | 说明 |
|------|------|
| `-p buildMode={debug\|release}` | 构建模式 |
| `-p module={name}@{target}` | 指定模块 |
| `--mode module` | 单模块模式 |
| `--no-daemon` | 禁用守护进程（CI 推荐） |
| `--analyze=advanced` | 构建分析 |
| `--optimization-strategy=memory` | 内存优化构建 |
| `-p product={name}` | 指定产品 |

## hdc — 设备调试

```bash
# 连接设备
hdc list targets          # 列出设备
hdc shell                 # 进入设备 shell

# 安装/卸载
hdc install entry.hap      # 安装
hdc uninstall com.example.myapp  # 卸载
hdc uninstall -k com.example.myapp  # 卸载保留数据

# 调试
hdc hilog                 # 查看日志
hdc hilog -r               # 清除日志缓冲区
hdc file send src dst     # 推送文件到设备
hdc file recv src dst     # 从设备拉取文件

# 无线连接
hdc tmode port 12345       # 开启无线调试端口
hdc connect 192.168.1.100:12345  # 无线连接
```

## hilog — 日志

```typescript
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0001;
const TAG = 'MyApp';

hilog.info(DOMAIN, TAG, 'Hello World');
hilog.debug(DOMAIN, TAG, 'Debug: %s', 'detail');
hilog.warn(DOMAIN, TAG, 'Warning: count=%d', count);
hilog.error(DOMAIN, TAG, 'Error occurred: %{public}s', errorMsg);

// 使用 private 防止敏感信息泄露
hilog.info(DOMAIN, TAG, 'User: %{private}s', userName);
```

### 日志等级

| 方法 | 等级 | 说明 |
|------|------|------|
| `hilog.debug()` | DEBUG | 调试信息 |
| `hilog.info()` | INFO | 普通信息 |
| `hilog.warn()` | WARN | 警告 |
| `hilog.error()` | ERROR | 错误 |
| `hilog.fatal()` | FATAL | 致命错误 |

## ohpm — 包管理

```bash
# 基本命令
ohpm install                  # 安装所有依赖
ohpm install @ohos/camera     # 安装指定包
ohpm install --save-dev @ohos/hypium  # 开发依赖
ohpm uninstall @ohos/camera   # 卸载
ohpm list                     # 列出依赖
ohpm cache clean              # 清理缓存

# 发布包
ohpm publish                  # 发布到 ohpm 仓库
```

## 打包签名

```bash
# hvigor 自动签名（DevEco Studio 配置）
# 或命令行手动签名

# hap-sign-tool 工具
java -jar hap-sign-tool.jar sign-app \
  -keyAlias key1 \
  -keyPwd 123456 \
  -appCertFile ./cert.cer \
  -profileFile ./profile.p7b \
  -inFile ./entry-default-signed.hap \
  -outFile ./entry-signed.hap \
  -keyStoreFile ./keystore.p12 \
  -signAlg SHA256withECDSA
```

## 单元测试

```typescript
import { describe, it, expect } from '@ohos/hypium';

export default function calculatorTest() {
  describe('CalculatorTest', () => {
    it('should_add_correctly', 0, () => {
      let result = add(1, 2);
      expect(result).assertEqual(3);
    });

    it('should_handle_negative', 0, () => {
      let result = add(-1, -2);
      expect(result).assertEqual(-3);
    });
  });
}
```

## Profiler — 性能分析

DevEco Studio 内置 Profiler 工具：

1. 点击底部 `Profiler` 标签
2. 选择 `CPU` / `Memory` / `Network` 分析
3. 点击录制按钮开始分析
4. 分析完成后查看热点函数和内存分配

## 常见工具问题

| 问题 | 解决方案 |
|------|---------|
| `hdc list targets` 为空 | 检查 USB 连接，确保开发者模式 |
| 构建失败：签名错误 | 检查 `build-profile.json5` 签名配置 |
| ohpm install 超时 | 配置国内镜像源 |
| 设备日志过多 | 使用 `hilog -T MyApp` 按 TAG 过滤 |
| 无线调试断连 | 重置 hdc 服务：`hdc kill -> hdc start` |
