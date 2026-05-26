---
name: harmonyos-apply-architecture-best-practices
description: 使用推荐的分层架构（UI、Logic、Data）设计 HarmonyOS NEXT 应用。适用于新项目架构设计或重构现有项目以提升可扩展性。当用户提到架构、分层、MVVM、Repository、重构项目结构、可扩展性时触发。
---

# HarmonyOS NEXT 分层架构最佳实践

## 目录
- [架构分层](#架构分层)
- [项目结构](#项目结构)
- [工作流：实现一个新功能](#工作流实现一个新功能)
- [代码示例](#代码示例)

## 架构分层

严格遵循关注点分离原则，将应用划分为独立层次。禁止在 UI 组件中混合业务逻辑或数据获取代码。

### UI 层（表现层）
使用 MVVM（Model-View-ViewModel）模式管理 UI 状态和交互逻辑。
*   **Views（视图）：** 编写可复用的精简 `@ComponentV2` 组件。视图中仅允许 UI 相关的逻辑（如动画控制、布局约束、简单路由跳转）。所有数据由 ViewModel 通过 `@Param` 传入。
*   **ViewModels（视图模型）：** 管理 UI 状态并处理用户交互。使用 `@ObservedV2` + `@Trace` 暴露响应式状态。将 Repository 通过构造函数注入 ViewModel。对外暴露不可变的状态快照给 View。业务方法通过 `@Event` 回调或直接调用 ViewModel 方法触发。

### Data 层（数据层）
使用 Repository 模式隔离数据访问逻辑，建立单一数据源。
*   **Services（服务）：** 创建无状态工具类封装外部 API（HTTP 客户端、本地数据库、系统能力插件）。返回原始 API 模型或 `Result` 包装类型。
*   **Repositories（仓库）：** 消费一个或多个 Service。将原始 API 模型转换为干净的领域模型（Domain Model）。处理缓存、离线同步及重试逻辑。向 ViewModel 暴露领域模型。

### Logic 层（领域层 — 可选）
*   **Use Cases（用例）：** 仅当应用包含复杂业务逻辑导致 ViewModel 臃肿，或逻辑需要在多个 ViewModel 间复用时，才实现此层。将此类逻辑提取到独立的 UseCase（交互器）类中，置于 ViewModel 和 Repository 之间。

## 项目结构

采用混合组织方式：UI 组件按功能（feature）分组，Data/Domain 组件按类型分组。

```text
entry/src/main/ets/
├── data/
│   ├── models/            # API 模型（原始后端返回数据结构）
│   ├── repositories/      # Repository 实现
│   └── services/          # API 客户端、本地存储封装、系统能力封装
├── domain/
│   ├── models/            # 干净的领域模型（前端使用的数据结构）
│   └── use_cases/         # 可选的业务逻辑类（UseCase）
└── ui/
    ├── core/              # 共享组件、主题、样式常量、工具组件
    └── features/
        └── [feature_name]/
            ├── view_models/   # ViewModel 文件
            └── views/         # View 组件文件（.ets）
```

### 与标准 HarmonyOS 项目结构的对应关系

```
MyHarmonyApp/
├── AppScope/                    # 应用全局配置
│   ├── app.json5                # bundleName、icon、label、version
│   └── resources/               # 应用级资源
├── entry/                       # Entry HAP 包（主模块）
│   ├── src/main/
│   │   ├── ets/                 # ← 上述分层结构在此目录下
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   ├── ui/
│   │   │   └── entryability/    # UIAbility 入口
│   │   ├── resources/           # 模块级资源
│   │   └── module.json5         # 模块配置
│   ├── oh-package.json5
│   └── build-profile.json5
├── build-profile.json5          # 全局构建配置
└── hvigor/                      # 构建工具配置
```

## 工作流：实现一个新功能

遵循以下顺序工作流为应用添加新功能。可复制此清单跟踪进度。

### 任务进度
- [ ] **步骤 1：定义 Domain Models。** 使用 `@ObservedV2` + `@Trace` 创建不可变数据类。Domain Model 只包含前端业务所需字段，与后端 API 返回结构解耦。
- [ ] **步骤 2：实现 Services。** 创建或更新 Service 类处理外部 API 通信（HTTP、数据库、系统能力等）。
- [ ] **步骤 3：实现 Repositories。** 创建 Repository 消费 Service，返回 Domain Models。在此层处理缓存策略、数据转换和错误处理。
- [ ] **步骤 4：评估是否需要 Logic 层。**
  - *如果功能涉及复杂数据转换或跨 Repository 逻辑：* 创建 UseCase 类。
  - *如果是简单 CRUD 操作：* 跳过此步骤，直接进入步骤 5。
- [ ] **步骤 5：实现 ViewModel。** 创建使用 `@ObservedV2` + `@Trace` 的 ViewModel 类。注入所需 Repository/UseCase。暴露不可变状态与命令方法。
- [ ] **步骤 6：实现 View。** 创建 `@ComponentV2` UI 组件。使用 `@Param` 接收 ViewModel 数据，`@Event` 处理用户交互回调。
- [ ] **步骤 7：注入依赖。** 在合适位置（如 EntryAbility 或全局单例）注册新的 Service、Repository 和 ViewModel。
- [ ] **步骤 8：验证测试。** 运行单元测试验证 ViewModel 和 Repository 逻辑。
  - *反馈循环：* 运行测试 → 检查失败 → 修复逻辑 → 重新运行直至通过。

## 代码示例

### Data 层：Service 和 Repository

```typescript
// ==================== 1. API Model（后端原始数据结构）====================
// data/models/user_api_model.ts
export interface UserApiModel {
  id: number;
  full_name: string;      // 后端字段名
  avatar_url: string;
  created_at: number;
}

// ==================== 2. Domain Model（前端领域模型）====================
// domain/models/user.ts
@ObservedV2
export class User {
  @Trace id: number;
  @Trace name: string;        // 清洗后的字段名
  @Trace avatarUrl: string;
  @Trace createdAt: number;

  constructor(id: number, name: string, avatarUrl: string, createdAt: number) {
    this.id = id;
    this.name = name;
    this.avatarUrl = avatarUrl;
    this.createdAt = createdAt;
  }

  // 计算属性
  get displayName(): string {
    return `${this.name}（UID: ${this.id}）`;
  }
}

// ==================== 3. Service（原始 API 交互）====================
// data/services/api_client.ts
import { http } from '@kit.NetworkKit';

export class ApiClient {
  private baseUrl: string = 'https://api.example.com/v1';

  async fetchUser(id: number): Promise<UserApiModel> {
    let req = http.createHttp();
    try {
      let result = await req.request(`${this.baseUrl}/user/${id}`, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.OBJECT,
        connectTimeout: 15000,
        readTimeout: 15000
      });
      if (result.responseCode === 200) {
        return result.result as UserApiModel;
      }
      throw new Error(`请求失败: ${result.responseCode}`);
    } finally {
      req.destroy();
    }
  }
}

// ==================== 4. Repository（单一数据源，返回 Domain Model）====================
// data/repositories/user_repository.ts
import { User } from '../../domain/models/user';
import { ApiClient } from '../services/api_client';
import { UserApiModel } from '../models/user_api_model';

export class UserRepository {
  private apiClient: ApiClient;
  private cachedUser: User | null = null;

  constructor(apiClient: ApiClient) {
    this.apiClient = apiClient;
  }

  async getUser(id: number): Promise<User> {
    // 缓存策略：有缓存直接返回
    if (this.cachedUser !== null && this.cachedUser.id === id) {
      return this.cachedUser;
    }

    // 调用 Service 获取原始数据
    let apiModel: UserApiModel = await this.apiClient.fetchUser(id);

    // 转换为 Domain Model
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

### Logic 层：UseCase（可选）

```typescript
// domain/use_cases/get_user_profile_use_case.ts
import { UserRepository } from '../../data/repositories/user_repository';
import { User } from '../models/user';

/**
 * 当获取用户信息需要组合多个 Repository 数据，
 * 或包含复杂业务规则时，使用 UseCase 封装。
 */
export class GetUserProfileUseCase {
  private userRepo: UserRepository;

  constructor(userRepo: UserRepository) {
    this.userRepo = userRepo;
  }

  async execute(userId: number): Promise<User> {
    // 可以在这里添加业务规则校验
    if (userId <= 0) {
      throw new Error('无效的用户 ID');
    }

    return this.userRepo.getUser(userId);
  }
}
```

### UI 层：ViewModel 和 View

```typescript
// ==================== 5. ViewModel（状态管理与表现逻辑）====================
// ui/features/profile/view_models/profile_view_model.ts
import { User } from '../../../../domain/models/user';
import { UserRepository } from '../../../../data/repositories/user_repository';
import { GetUserProfileUseCase } from '../../../../domain/use_cases/get_user_profile_use_case';

@ObservedV2
export class ProfileViewModel {
  @Trace user: User | null = null;
  @Trace isLoading: boolean = false;
  @Trace errorMessage: string = '';

  private useCase: GetUserProfileUseCase;

  constructor(repository: UserRepository) {
    this.useCase = new GetUserProfileUseCase(repository);
  }

  async loadProfile(userId: number): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      this.user = await this.useCase.execute(userId);
    } catch (err) {
      this.errorMessage = (err as Error).message;
    } finally {
      this.isLoading = false;
    }
  }

  async refresh(): Promise<void> {
    if (this.user) {
      await this.loadProfile(this.user.id);
    }
  }
}

// ==================== 6. View（精简 UI 组件）====================
// ui/features/profile/views/profile_view.ets
@ComponentV2
export struct ProfileView {
  @Param viewModel: ProfileViewModel = new ProfileViewModel(new UserRepository(new ApiClient()));
  @Event onNavigateBack: () => void = () => {};

  aboutToAppear(): void {
    this.viewModel.loadProfile(1);
  }

  build() {
    Column({ space: 16 }) {
      // 导航栏
      Row() {
        Button('← 返回')
          .type(ButtonType.Capsule)
          .backgroundColor(Color.Transparent)
          .onClick(() => this.onNavigateBack())
        Text('个人主页')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ left: 8, right: 8 })

      // 加载状态
      if (this.viewModel.isLoading) {
        Column({ space: 8 }) {
          LoadingProgress().width(36).height(36)
          Text('加载中...').fontSize(14).fontColor('#999')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }

      // 错误状态
      if (this.viewModel.errorMessage) {
        Column({ space: 12 }) {
          Text(this.viewModel.errorMessage)
            .fontSize(14)
            .fontColor('#F44336')
            .textAlign(TextAlign.Center)
          Button('重试')
            .type(ButtonType.Capsule)
            .onClick(() => this.viewModel.refresh())
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }

      // 用户数据
      if (this.viewModel.user !== null) {
        Column({ space: 12 }) {
          // 头像
          Circle()
            .width(80)
            .height(80)
            .fill('#007DFF')

          Text(this.viewModel.user!.displayName)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)

          Text(`注册时间: ${new Date(this.viewModel.user!.createdAt).toLocaleDateString()}`)
            .fontSize(14)
            .fontColor('#666')

          Button('刷新')
            .type(ButtonType.Capsule)
            .margin({ top: 12 })
            .onClick(() => this.viewModel.refresh())
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#f5f5f5')
  }
}
```

### 依赖注入与使用入口

```typescript
// ==================== 7. 依赖注入（在 EntryAbility 或全局模块中组装）====================
// entryability/dependencies.ts
import { ApiClient } from '../data/services/api_client';
import { UserRepository } from '../data/repositories/user_repository';
import { ProfileViewModel } from '../ui/features/profile/view_models/profile_view_model';

// 全局单例 — 简单 DI 方案
class Dependencies {
  private static instance: Dependencies;

  // Services
  apiClient: ApiClient;

  // Repositories
  userRepository: UserRepository;

  private constructor() {
    // 组装依赖链：Service → Repository → ViewModel
    this.apiClient = new ApiClient();
    this.userRepository = new UserRepository(this.apiClient);
  }

  static getInstance(): Dependencies {
    if (!Dependencies.instance) {
      Dependencies.instance = new Dependencies();
    }
    return Dependencies.instance;
  }

  // 工厂方法：每次都创建新 ViewModel（避免状态污染）
  createProfileViewModel(): ProfileViewModel {
    return new ProfileViewModel(this.userRepository);
  }
}

export const deps = Dependencies.getInstance();
```

```typescript
// ==================== 在页面中使用 ====================
// pages/ProfilePage.ets
import { deps } from '../entryability/dependencies';
import { ProfileView } from '../ui/features/profile/views/profile_view';

@Entry
@ComponentV2
struct ProfilePage {
  @Local viewModel: ProfileViewModel = deps.createProfileViewModel();

  build() {
    Column() {
      ProfileView({
        viewModel: this.viewModel,
        onNavigateBack: () => {
          // Navigation 返回上一页
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
```

## 快速参考：Flutter → HarmonyOS 对照表

| 概念 | Flutter | HarmonyOS NEXT (ArkTS/ArkUI) |
|------|---------|------------------------------|
| 状态管理 | `ChangeNotifier` + `ListenableBuilder` | `@ObservedV2` + `@Trace` + `@ComponentV2` |
| 依赖注入 | `provider` / `get_it` | 手动 DI（单例模式）或 `@Provider` / `@Consumer` |
| 不可变模型 | `freezed` / `built_value` | `@ObservedV2` + `@Trace`（响应式属性追踪） |
| UI 组件 | `StatelessWidget` / `StatefulWidget` | `@ComponentV2` struct |
| 组件传参 | 构造函数参数 | `@Param`（父→子）+ `@Event`（子→父回调） |
| 网络请求 | `http` package | `@kit.NetworkKit`（`http.createHttp()`） |
| 本地存储 | `shared_preferences` | `@kit.ArkData`（`preferences`） |
| 关系数据库 | `sqflite` / `drift` | `@kit.ArkData`（`relationalStore`） |
| 导航路由 | `go_router` / `Navigator` | `Navigation` + `NavPathStack`（替代旧 `router` API） |
| JSON 序列化 | `json_serializable` | 手动 `JSON.parse` / `JSON.stringify` 或自建映射函数 |
| 列表构建 | `ListView.builder` | `List` + `ForEach` / `LazyForEach` |
| 响应式布局 | `LayoutBuilder` / `MediaQuery` | 断点系统 + `@State` 响应式（vp/px 单位） |

## 核心原则

1. **View 保持精简：** View 中不写业务逻辑，不直接调用 Service/Repository。只做布局和简单 UI 交互。
2. **数据单向流动：** Service → Repository → (UseCase) → ViewModel → View。View 通过 `@Event` 回调向上通知事件。
3. **单一数据源：** Repository 是数据的唯一入口，缓存策略在此层统一管理。
4. **按需引入 Logic 层：** UseCase 不是必需的——简单 CRUD 直接在 ViewModel 中调用 Repository 即可。
5. **DI 从简：** HarmonyOS 没有内置 DI 容器，使用单例工厂模式即可满足大多数场景。跨组件共享状态可使用 `@Provider` / `@Consumer`。
