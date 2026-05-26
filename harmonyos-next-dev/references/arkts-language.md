# ArkTS 语言参考

## 概述

ArkTS 是 HarmonyOS 应用开发的优选主语言，基于 TypeScript 扩展，增强静态类型和声明式 UI 开发能力。

## 核心语法

### 变量声明

```typescript
let count: number = 0;        // 可变变量
const PI: number = 3.14159;   // 常量（推荐）
// var 在 ArkTS 中禁止使用
```

### 类型系统

```typescript
// 基础类型
let str: string = 'hello';
let num: number = 42;
let bool: boolean = true;
let und: undefined = undefined;
let nul: null = null;

// 联合类型
let id: number | string = 123;

// 对象类型
interface User {
  name: string;
  age: number;
  email?: string;  // 可选
}
let user: User = { name: 'Alice', age: 30 };

// 数组
let arr1: number[] = [1, 2, 3];
let arr2: Array<string> = ['a', 'b'];

// 函数类型
type Handler = (event: string) => void;
let onClick: Handler = (e) => console.log(e);
```

### 类

```typescript
class Animal {
  private name: string;
  protected age: number = 0;

  constructor(name: string) {
    this.name = name;
  }

  public speak(): void {
    console.log(`${this.name} speaks`);
  }
}

class Dog extends Animal {
  constructor(name: string) {
    super(name);
  }

  speak(): void {
    console.log('Woof!');
    super.speak();
  }
}
```

### 装饰器

ArkTS 中装饰器是核心特性：

```typescript
@Entry          // 页面入口
@Component      // 自定义组件
struct MyComponent {
  @State data: string = 'hello';
  @Prop title: string;
  @Link value: number;
}
```

## ArkTS 与 TypeScript 的差异

| TypeScript | ArkTS | 原因 |
|------------|-------|------|
| `any` / `unknown` | 必须显式类型 | 类型安全 |
| `var` | 禁止，用 `let` / `const` | 块级作用域 |
| `obj['key']` 动态访问 | 固定对象结构 | 编译优化 |
| `for...in` | 用 `for...of` | 性能 |
| `delete` | 置 `undefined` | 不可变 |
| `#privateField` | `private` 关键字 | 标准 |
| 结构性类型 | 名义类型（implements） | 安全 |

## 并发模型

### TaskPool（推荐）

```typescript
import { taskpool } from '@kit.AbilityKit';

@Concurrent
function computeTask(data: number[]): number {
  return data.reduce((a, b) => a + b, 0);
}

async function runConcurrent() {
  const task = new taskpool.Task(computeTask, [1, 2, 3, 4, 5]);
  const result = await taskpool.execute(task);
  console.log(`Result: ${result}`);
}
```

### Worker

```typescript
// Main thread
import { worker } from '@kit.AbilityKit';
const workerInstance = new worker.ThreadWorker('entry/ets/workers/MyWorker.ts');
workerInstance.postMessage('hello');
workerInstance.onmessage = (e) => {
  console.log('Worker replied:', e.data);
};

// MyWorker.ts
import { worker } from '@kit.AbilityKit';
const parentPort = worker.workerPort;
parentPort.onmessage = (e) => {
  parentPort.postMessage('Hello from worker!');
};
```

## @Reusable / @BuilderParam

```typescript
@Reusable
@Component
struct ReusableItem {
  @State text: string = '';

  aboutToReuse(params: Record<string, object>): void {
    this.text = params.text as string;
  }

  build() {
    Text(this.text).fontSize(16);
  }
}
```

## $$ 语法 — 双向绑定

```typescript
@Entry
@Component
struct InputDemo {
  @State text: string = '';

  build() {
    TextInput({ text: $$this.text })
      .placeholder('输入...')
  }
}
```

## 参考

- 官方文档: https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-overview-0000001821000881-V5
