---
name: harmonyos-add-integration-test
description: 为 HarmonyOS 应用编写端到端集成测试，使用 @ohos/hypium 配合 hdc 在真机/模拟器上运行。适用于验证完整用户流程（登录、列表浏览、表单提交）、跨 Ability 跳转、系统能力调用等场景。当用户提到集成测试、端到端测试、E2E、自动化测试流程、真机测试时触发。
---

# 编写 HarmonyOS 集成测试

## 目录
- [环境配置](#环境配置)
- [核心概念](#核心概念)
- [工作流：端到端集成测试](#工作流端到端集成测试)
- [测试编写指南](#测试编写指南)
- [代码示例](#代码示例)

## 环境配置

### 1. 添加测试依赖

```bash
cd entry
ohpm install --save-dev @ohos/hypium
```

### 2. 测试目录结构

```
entry/src/
├── main/
│   └── ets/              # 应用源代码
└── ohosTest/
    └── ets/
        └── test/         # 集成测试文件 (*.test.ets)
            ├── Ability.test.ets
            └── UserFlow.test.ets
```

### 3. 运行测试

```bash
# 运行指定模块的集成测试
hvigorw onDeviceTest -p module=entry

# 带覆盖率报告
hvigorw onDeviceTest -p module=entry -p coverage=true

# 指定测试套件（通过 filter 参数控制）
# 在测试代码中使用 it('name', 0, () => {})  — 0=运行
# 在测试代码中使用 it('name', 1, () => {})  — 1=跳过
```

### 4. hdc 设备管理

```bash
# 确认设备连接
hdc list targets

# 安装测试 HAP
hdc install entry-default-unsigned.hap

# 查看测试日志
hdc hilog -T hypium
```

## 核心概念

HarmonyOS 的集成测试运行在真机或模拟器上，可以直接调用系统 API 和 Ability。与 Flutter `integration_test` 不同，HarmonyOS 没有 Widget 级别的交互 API（如 `tester.tap()`），而是通过**直接调用组件方法 + 系统 API** 来验证完整流程。

### 集成测试 vs 单元测试

| 维度 | 单元测试 (`src/test/`) | 集成测试 (`src/ohosTest/`) |
|------|------------------------|---------------------------|
| 运行环境 | 本地 JS 引擎 | 真机/模拟器 |
| 系统 API 访问 | ❌ 不可用 | ✅ 完全可用 |
| 数据库操作 | Mock | 真实 RDB/Preferences |
| HTTP 请求 | Mock | 真实网络/可 Mock |
| UI 交互 | 直接测逻辑 | 可启动 Ability + 测完整流程 |
| 执行速度 | 快（毫秒级） | 慢（秒级，需设备通信） |

## 工作流：端到端集成测试

按以下清单实现并验证集成测试：

- [ ] **步骤 1：搭建测试环境。**
  - [ ] 安装 `@ohos/hypium` 到 `devDependencies`
  - [ ] 在 `src/ohosTest/ets/test/` 下创建测试文件
- [ ] **步骤 2：编写测试用例。**
  - [ ] 用 `describe()` 组织测试套件
  - [ ] 用 `it()` 编写具体测试
  - [ ] 使用 `beforeAll()` 初始化资源（数据库、网络等）
  - [ ] 使用 `afterAll()` 清理资源
- [ ] **步骤 3：运行测试。**
  - [ ] 连接真机或启动模拟器
  - [ ] 执行 `hvigorw onDeviceTest -p module=entry`
  - [ ] 查看 `hdc hilog` 输出的测试日志
- [ ] **步骤 4：反馈循环。**
  - [ ] 检查失败用例的错误消息
  - [ ] 修复业务逻辑或测试断言
  - [ ] 重新运行直到全部通过

## 测试编写指南

### 集成测试最适合的场景

| 场景 | 示例 |
|------|------|
| **数据库 CRUD 全流程** | 插入 → 查询 → 更新 → 删除 → 验证最终状态 |
| **Preferences 读写** | 写入配置 → 重启模拟 → 验证持久化 |
| **HTTP API 集成** | 发起请求 → 验证响应码 → 解析数据 → 验证字段 |
| **跨 Ability 跳转** | 启动 Ability → 验证 Want 参数传递 |
| **文件读写** | 写入文件 → 读取验证 → 删除清理 |
| **权限流程** | 请求权限 → 验证弹窗 → 确认授权状态 |

### 不适合集成测试的场景

- ❌ 纯逻辑验证（用单元测试）
- ❌ UI 样式验证（用 DevEco Studio Previewer）
- ❌ 第三方 SDK 集成（在 Demo 工程中手动验证）

### 数据准备与清理

```typescript
import { describe, it, expect, beforeAll, afterAll } from '@ohos/hypium';
import { relationalStore } from '@kit.ArkData';

let rdbStore: relationalStore.RdbStore | null = null;

beforeAll(async () => {
  // 初始化数据库连接
  rdbStore = await relationalStore.getRdbStore(getContext(), {
    name: 'test.db',
    securityLevel: relationalStore.SecurityLevel.S1
  });

  // 插入初始测试数据
  await rdbStore.insert('users', {
    name: 'TestUser',
    age: 25,
    email: 'test@example.com'
  });
});

afterAll(async () => {
  // 清理测试数据
  if (rdbStore) {
    await rdbStore.executeSql('DELETE FROM users');
    await rdbStore.close();
  }
});
```

## 代码示例

### 完整示例：用户登录 + 数据获取流程

```typescript
// ohosTest/ets/test/UserFlow.test.ets
import { describe, it, expect, beforeAll, afterAll } from '@ohos/hypium';
import { http } from '@kit.NetworkKit';
import { preferences } from '@kit.ArkData';

const API_BASE = 'https://jsonplaceholder.typicode.com'; // 测试用公共 API

export default function userFlowTest() {
  describe('UserFlow_Integration', () => {
    let token: string = '';

    afterAll(() => {
      token = '';
    });

    // ==================== 登录流程 ====================
    describe('Login_Flow', () => {
      it('should_login_and_receive_token', 0, async () => {
        // 模拟登录请求
        let req = http.createHttp();
        try {
          let result = await req.request(`${API_BASE}/posts/1`, {
            method: http.RequestMethod.GET,
            expectDataType: http.HttpDataType.OBJECT,
            connectTimeout: 10000,
            readTimeout: 10000
          });

          // 验证 HTTP 状态码
          expect(result.responseCode).assertEqual(200);

          // 验证返回数据结构
          let data = result.result as Record<string, Object>;
          expect(data['id']).assertEqual(1);
          expect(data['userId']).assertNotNull();

          // 模拟 token 存储
          token = 'mock_token_' + Date.now();
        } finally {
          req.destroy();
        }
      });

      it('should_persist_token_to_preferences', 0, async () => {
        // 保存到 Preferences
        let prefs = await preferences.getPreferences(
          getContext(), 'test_prefs'
        );
        await prefs.put('auth_token', token);
        await prefs.flush();

        // 重新读取验证
        let savedToken = await prefs.get('auth_token', '') as string;
        expect(savedToken).assertEqual(token);

        // 清理
        await prefs.delete('auth_token');
        await prefs.flush();
      });
    });

    // ==================== 数据获取流程 ====================
    describe('Data_Fetch_Flow', () => {
      it('should_fetch_list_with_pagination', 0, async () => {
        let req = http.createHttp();
        try {
          let result = await req.request(`${API_BASE}/posts`, {
            method: http.RequestMethod.GET,
            expectDataType: http.HttpDataType.ARRAY,
            connectTimeout: 10000,
            readTimeout: 10000
          });

          expect(result.responseCode).assertEqual(200);

          let list = result.result as Object[];
          expect(list.length).assertLarger(0);        // 列表非空

          // 验证列表项结构
          let first = list[0] as Record<string, Object>;
          expect(first['id']).assertNotNull();
          expect(first['title']).assertNotNull();
        } finally {
          req.destroy();
        }
      });

      it('should_handle_404_error', 0, async () => {
        let req = http.createHttp();
        try {
          let result = await req.request(`${API_BASE}/nonexistent`, {
            method: http.RequestMethod.GET,
            expectDataType: http.HttpDataType.OBJECT,
            connectTimeout: 10000,
            readTimeout: 10000
          });

          // 验证 404 状态码
          expect(result.responseCode).assertEqual(404);
        } finally {
          req.destroy();
        }
      });

      it('should_handle_network_timeout', 0, async () => {
        let req = http.createHttp();
        try {
          await req.request('https://10.255.255.1', {
            method: http.RequestMethod.GET,
            connectTimeout: 3000,  // 极短超时
            readTimeout: 3000
          });

          // 不应该到达这里
          expect(false).assertTrue();
        } catch (err) {
          // 预期超时或网络不可达
          expect(true).assertTrue();
        } finally {
          req.destroy();
        }
      });
    });

    // ==================== 端到端流程 ====================
    describe('E2E_Complete_Flow', () => {
      it('should_complete_full_login_and_fetch_flow', 0, async () => {
        // 1. 获取文章列表
        let req = http.createHttp();
        let posts: Object[] = [];
        try {
          let result = await req.request(`${API_BASE}/posts`, {
            method: http.RequestMethod.GET,
            expectDataType: http.HttpDataType.ARRAY,
            connectTimeout: 10000,
            readTimeout: 10000
          });
          posts = result.result as Object[];
        } finally {
          req.destroy();
        }

        expect(posts.length).assertLarger(0);

        // 2. 获取第一篇文章的详情
        let firstId = (posts[0] as Record<string, Object>)['id'] as number;
        let req2 = http.createHttp();
        try {
          let detail = await req2.request(`${API_BASE}/posts/${firstId}`, {
            method: http.RequestMethod.GET,
            expectDataType: http.HttpDataType.OBJECT,
            connectTimeout: 10000,
            readTimeout: 10000
          });

          expect(detail.responseCode).assertEqual(200);

          let data = detail.result as Record<string, Object>;
          expect(data['id']).assertEqual(firstId);
          expect(data['title']).assertNotNull();
          expect(data['body']).assertNotNull();
        } finally {
          req2.destroy();
        }
      });
    });
  });
}
```

**测试入口文件 (`Ability.test.ets`)：**
```typescript
// ohosTest/ets/test/Ability.test.ets
import { describe, it, expect } from '@ohos/hypium';
import abilityDelegatorRegistry from '@ohos.application.abilityDelegatorRegistry';
import userFlowTest from './UserFlow.test';
import databaseTest from './Database.test';

export default function testsuite() {
  // 注册所有集成测试套件
  userFlowTest();
  databaseTest();
}
```

## 调试技巧

### 查看测试日志

```bash
# 实时查看 hypium 测试日志
hdc hilog -T hypium

# 过滤应用日志
hdc hilog -T MyApp

# 仅显示 Error 级别
hdc hilog -L ERROR
```

### 常见问题

| 问题 | 解决方案 |
|------|---------|
| `onDeviceTest` 找不到设备 | `hdc list targets` 确认连接 |
| 测试超时 | 异步测试确保使用 `async/await`，避免回调地狱 |
| `getContext()` 不可用 | 仅在 `ohosTest` 目录下有 Context 访问权限 |
| 测试套件未加载 | 确认 `Ability.test.ets` 中正确导入并调用测试函数 |
| 覆盖率数据为空 | 添加 `-p coverage=true` 参数 |

## 快速参考

| 测试类型 | 目录 | 运行命令 | Context 可用 |
|----------|------|----------|-------------|
| 单元测试 | `src/test/` | `hvigorw onDeviceTest` | ❌ 需手动注入 |
| 集成测试 | `src/ohosTest/` | `hvigorw onDeviceTest` | ✅ `getContext()` |
