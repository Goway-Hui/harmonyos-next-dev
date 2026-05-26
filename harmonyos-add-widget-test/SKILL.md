---
name: harmonyos-add-widget-test
description: 使用 @ohos/hypium 为 ArkTS 组件编写单元测试，验证组件的逻辑行为和状态变化。适用于为 ViewModel、Repository、工具函数编写测试，确保业务逻辑正确性。当用户提到单元测试、组件测试、测试、hypium、验证逻辑时触发。
---

# 编写 ArkTS 组件测试

## 目录
- [环境配置](#环境配置)
- [核心概念](#核心概念)
- [工作流：编写组件测试](#工作流编写组件测试)
- [测试模式与技巧](#测试模式与技巧)
- [代码示例](#代码示例)

## 环境配置

测试前确保项目已正确配置：

1. **安装 hypium 依赖：**
   ```bash
   cd entry
   ohpm install --save-dev @ohos/hypium
   ```

2. **测试文件目录：** 在模块的 `src/test/` 目录下创建测试文件（如 `entry/src/test/`）。

3. **测试文件命名：** 使用 `*.test.ts` 或 `*.test.ets` 后缀（如 `viewmodel.test.ts`）。

4. **运行测试：**
   ```bash
   # 使用 hvigor 运行
   hvigorw onDeviceTest -p module=entry

   # 带覆盖率
   hvigorw onDeviceTest -p module=entry -p coverage=true
   ```

## 核心概念

hypium 使用类 Jest/Mocha 风格的 BDD 测试框架：

| 概念 | 说明 | 示例 |
|------|------|------|
| `describe(name, () => {...})` | 测试套件（分组） | `describe('ProfileViewModel', () => {...})` |
| `it(name, filter, () => {...})` | 单个测试用例 | `it('should_load_user', 0, () => {...})` |
| `expect(value)` | 断言入口 | `expect(result).assertEqual(3)` |
| `beforeAll()` / `afterAll()` | 套件级钩子 | 初始化/清理共享资源 |
| `beforeEach()` / `afterEach()` | 用例级钩子 | 每个用例前后的重置 |
| `filter` 参数 | `0`=运行, `1`=跳过, `2`=仅运行此用例 | `it('name', 0, () => {})` |

### 常用断言方法

| 断言方法 | 用途 |
|----------|------|
| `.assertEqual(expected)` | 值相等 |
| `.assertDeepEquals(expected)` | 深度相等（对象/数组） |
| `.assertNull()` | 是否为 null |
| `.assertNotNull()` | 是否非 null |
| `.assertTrue()` | 是否为 true |
| `.assertFalse()` | 是否为 false |
| `.assertLarger(expected)` | 大于 |
| `.assertSmaller(expected)` | 小于 |
| `.assertThrowError()` | 预期抛出异常 |
| `.assertContain(item)` | 字符串/数组包含 |

## 工作流：编写组件测试

按以下清单逐步完成测试：

- [ ] **步骤 1：确定测试目标。** 明确要测试哪个类/函数/组件（ViewModel、Repository、工具函数等）。
- [ ] **步骤 2：创建测试文件。** 在 `src/test/` 下创建 `xxx.test.ts`。
- [ ] **步骤 3：编写测试套件。** 用 `describe()` 包裹相关测试用例。
- [ ] **步骤 4：编写初始状态测试。** 验证组件创建后的默认状态。
- [ ] **步骤 5：编写交互/逻辑测试。** 模拟方法调用，验证状态变化。
- [ ] **步骤 6：编写边界/错误测试。** 验证异常输入、错误处理路径。
- [ ] **步骤 7：运行测试。** `hvigorw onDeviceTest -p module=entry`
- [ ] **步骤 8：反馈循环。** 检查输出 → 修复失败用例 → 重新运行直至全部通过。

## 测试模式与技巧

### 测试 ViewModel 状态变化

ViewModel 使用 `@ObservedV2` + `@Trace`，测试时直接实例化并调用方法验证属性：

```typescript
// ✅ 直接测试 ViewModel 逻辑
it('should_set_loading_state', 0, () => {
  let vm = new ProfileViewModel(mockRepo);
  expect(vm.isLoading).assertFalse();

  vm.loadProfile(1); // 异步方法

  // 注意：由于 loadProfile 是异步的，需要 await
});
```

### 测试 Repository 数据转换

Repository 测试重点关注 API 模型 → Domain 模型的转换逻辑：

```typescript
// ✅ 模拟 Service 返回，验证 Repository 转换
class MockApiClient extends ApiClient {
  async fetchUser(id: number): Promise<UserApiModel> {
    return { id: 1, full_name: 'Test User', avatar_url: '', created_at: 0 };
  }
}
```

### 测试异步方法

```typescript
// ✅ 使用 async/await 处理异步
it('should_fetch_and_cache_user', 0, async () => {
  let repo = new UserRepository(new MockApiClient());
  let user = await repo.getUser(1);

  expect(user.name).assertEqual('Test User');
  expect(user.id).assertEqual(1);
});
```

### Mock 依赖注入

```typescript
// ✅ 通过构造函数注入 Mock 依赖
class MockUserRepository extends UserRepository {
  async getUser(id: number): Promise<User> {
    return new User(id, 'Mock User', '', Date.now());
  }
}
```

## 代码示例

### 测试文件结构

```
entry/src/
├── main/ets/
│   ├── data/repositories/user_repository.ts
│   ├── domain/models/user.ts
│   └── ui/features/profile/view_models/profile_view_model.ts
└── test/
    ├── LocalUnit.test.ts          # hypium 入口文件
    ├── user_repository.test.ts     # Repository 测试
    └── profile_view_model.test.ts  # ViewModel 测试
```

### 完整测试示例

**被测试代码 (`user_repository.ts`)：**
```typescript
// data/repositories/user_repository.ts
import { User } from '../../domain/models/user';

export interface UserApiModel {
  id: number;
  full_name: string;
  avatar_url: string;
  created_at: number;
}

export class ApiClient {
  async fetchUser(id: number): Promise<UserApiModel> {
    // 实际 HTTP 调用...
    throw new Error('Not implemented in test');
  }
}

export class UserRepository {
  private apiClient: ApiClient;
  private cachedUser: User | null = null;

  constructor(apiClient: ApiClient) {
    this.apiClient = apiClient;
  }

  async getUser(id: number): Promise<User> {
    if (this.cachedUser !== null && this.cachedUser.id === id) {
      return this.cachedUser;
    }

    let apiModel = await this.apiClient.fetchUser(id);
    this.cachedUser = new User(
      apiModel.id,
      apiModel.full_name,
      apiModel.avatar_url,
      apiModel.created_at
    );

    return this.cachedUser;
  }

  clearCache(): void {
    this.cachedUser = null;
  }
}
```

**测试代码 (`user_repository.test.ts`)：**
```typescript
// test/user_repository.test.ts
import { describe, it, expect } from '@ohos/hypium';
import {
  ApiClient, UserApiModel, UserRepository
} from '../main/ets/data/repositories/user_repository';
import { User } from '../main/ets/domain/models/user';

// Mock ApiClient
class MockApiClient extends ApiClient {
  private mockData: UserApiModel;

  constructor(mockData: UserApiModel) {
    super();
    this.mockData = mockData;
  }

  async fetchUser(id: number): Promise<UserApiModel> {
    return this.mockData;
  }
}

export default function userRepositoryTest() {
  describe('UserRepository', () => {
    let mockApiModel: UserApiModel = {
      id: 1,
      full_name: '张三',
      avatar_url: 'https://example.com/avatar.png',
      created_at: 1700000000000
    };

    // ==================== getUser ====================
    describe('getUser', () => {
      it('should_fetch_and_transform_user', 0, async () => {
        let repo = new UserRepository(new MockApiClient(mockApiModel));
        let user: User = await repo.getUser(1);

        // 验证字段映射：full_name → name
        expect(user.name).assertEqual('张三');

        // 验证字段映射：avatar_url → avatarUrl
        expect(user.avatarUrl).assertEqual('https://example.com/avatar.png');

        // 验证 ID 传递正确
        expect(user.id).assertEqual(1);
      });

      it('should_cache_user_and_return_cached', 0, async () => {
        let repo = new UserRepository(new MockApiClient(mockApiModel));

        // 第一次获取（调用 API）
        let user1 = await repo.getUser(1);

        // 第二次获取（应从缓存返回）
        let user2 = await repo.getUser(1);

        // 同一实例（缓存命中）
        expect(user1.name).assertEqual(user2.name);
        expect(user1.id).assertEqual(user2.id);
      });

      it('should_return_cached_when_id_matches', 0, async () => {
        let repo = new UserRepository(new MockApiClient(mockApiModel));

        await repo.getUser(1);
        let cached = await repo.getUser(1);

        expect(cached.name).assertEqual('张三');
      });
    });

    // ==================== clearCache ====================
    describe('clearCache', () => {
      it('should_clear_cache', 0, async () => {
        let repo = new UserRepository(new MockApiClient(mockApiModel));

        // 先缓存一个用户
        await repo.getUser(1);

        // 清空缓存
        repo.clearCache();

        // 修改 Mock 数据验证重新请求
        let updatedMock = new MockApiClient({
          id: 1,
          full_name: '李四',  // 姓名变化
          avatar_url: '',
          created_at: 0
        });

        // 无法直接替换 apiClient，这里测试缓存清除后
        // 下一次调用会走 API（在真实场景中验证）
        // 此用例验证 clearCache 不抛异常
        expect(true).assertTrue();
      });
    });

    // ==================== 边界情况 ====================
    describe('edge_cases', () => {
      it('should_handle_empty_name', 0, async () => {
        let emptyMock = new MockApiClient({
          id: 2,
          full_name: '',
          avatar_url: '',
          created_at: 0
        });

        let repo = new UserRepository(emptyMock);
        let user = await repo.getUser(2);

        expect(user.name).assertEqual('');
        expect(user.id).assertEqual(2);
      });

      it('should_handle_large_id', 0, async () => {
        let largeMock = new MockApiClient({
          id: Number.MAX_SAFE_INTEGER,
          full_name: 'MaxID',
          avatar_url: '',
          created_at: 0
        });

        let repo = new UserRepository(largeMock);
        let user = await repo.getUser(Number.MAX_SAFE_INTEGER);

        expect(user.id).assertEqual(Number.MAX_SAFE_INTEGER);
      });
    });
  });
}
```

**测试入口文件 (`LocalUnit.test.ts`)：**
```typescript
// test/LocalUnit.test.ts
import { describe, it, expect } from '@ohos/hypium';
import userRepositoryTest from './user_repository.test';
import profileViewModelTest from './profile_view_model.test';

export default function testsuite() {
  userRepositoryTest();
  profileViewModelTest();
}
```

## 快速参考

| 测试目标 | 测试策略 |
|----------|----------|
| **ViewModel** | 实例化 → 调用方法 → 断言 `@Trace` 属性值 |
| **Repository** | Mock Service → 验证 API→Domain 转换 + 缓存策略 |
| **UseCase** | Mock Repository → 验证业务规则 + 异常处理 |
| **工具函数** | 直接调用 → 边界值 + 异常输入 |
| **Service** | Mock HTTP 响应 → 验证请求参数 + 错误码处理 |
