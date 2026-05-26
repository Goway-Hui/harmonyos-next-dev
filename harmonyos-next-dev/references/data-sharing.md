# 数据共享 (DataShare) 参考

## 概述

DataShare 是 HarmonyOS 跨应用数据共享机制，基于 Provider-Consumer 模式的 URI 数据访问。

## DataShareExtensionAbility（服务端）

```typescript
import { DataShareExtensionAbility, DataShareHelper } from '@kit.DataShareKit';
import { relationalStore } from '@kit.ArkData';

export default class MyDataShare extends DataShareExtensionAbility {
  private rdbStore: relationalStore.RdbStore;

  async onCreate() {
    this.rdbStore = await relationalStore.getRdbStore(this.context, {
      name: 'shared.db',
      securityLevel: relationalStore.SecurityLevel.S1
    });
  }

  // 插入
  insert(uri: string, value: object): number {
    let id = this.rdbStore.insert('shared_table', value);
    return id;
  }

  // 查询
  query(uri: string, predicates: DataShareHelper.DataSharePredicates, columns: string[]): relationalStore.ResultSet {
    let result = this.rdbStore.query(predicates.toRdbPredicates('shared_table'), columns);
    return result;
  }

  // 更新
  update(uri: string, predicates: DataShareHelper.DataSharePredicates, value: object): number {
    let rows = this.rdbStore.update(value, predicates.toRdbPredicates('shared_table'));
    return rows;
  }

  // 删除
  delete(uri: string, predicates: DataShareHelper.DataSharePredicates): number {
    let rows = this.rdbStore.delete(predicates.toRdbPredicates('shared_table'));
    return rows;
  }
}
```

### module.json5 声明服务端

```json
{
  "abilities": [{
    "name": "MyDataShare",
    "srcEntry": "./ets/share/MyDataShare.ts",
    "type": "dataShare",
    "uri": "datashare://com.example.myapp/share",
    "exported": true
  }]
}
```

## DataShare 客户端（消费者）

```typescript
import { DataShareHelper } from '@kit.DataShareKit';
import { common } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';

let context = getContext(this) as common.UIAbilityContext;

// 创建 DataShareHelper
let helper = DataShareHelper.createDataShareHelper(
  context,
  'datashare://com.example.myapp/share'
);

// 插入
let id = await helper.insert('datashare://com.example.myapp/share/task', {
  'title': '买牛奶',
  'done': false
});

// 查询
let predicates = new DataShareHelper.DataSharePredicates();
predicates.equalTo('done', false);
let resultSet = await helper.query(
  'datashare://com.example.myapp/share/task',
  predicates,
  ['id', 'title', 'done']
);

while (resultSet.goToNextRow()) {
  let id = resultSet.getLong(resultSet.getColumnIndex('id'));
  let title = resultSet.getString(resultSet.getColumnIndex('title'));
  console.log(`Task: ${title} (${id})`);
}
resultSet.close();

// 更新
let updatePredicates = new DataShareHelper.DataSharePredicates();
updatePredicates.equalTo('id', id);
let rows = await helper.update(
  'datashare://com.example.myapp/share/task',
  updatePredicates,
  { 'done': true }
);

// 删除
let deletePredicates = new DataShareHelper.DataSharePredicates();
deletePredicates.equalTo('id', id);
let deletedRows = await helper.delete(
  'datashare://com.example.myapp/share/task',
  deletePredicates
);

// 释放
helper.release();
```

## URI 格式

```
datashare://{bundleName}/{moduleName}/{path}
datashare://com.example.myapp/share/task
datashare://com.example.myapp/share/task/{id}
```

## DataSharePredicates 常用条件

| API | 说明 |
|-----|------|
| `equalTo(field, value)` | 等于 |
| `notEqualTo(field, value)` | 不等于 |
| `greaterThan(field, value)` | 大于 |
| `lessThan(field, value)` | 小于 |
| `like(field, value)` | 模糊匹配 |
| `in(field, values[])` | IN 条件 |
| `orderByAsc(field)` | 升序 |
| `orderByDesc(field)` | 降序 |
| `limit(total, offset)` | 分页 |
| `beginWrap()` / `endWrap()` | 括号分组 |

## 权限声明

```json
{
  "requestPermissions": [{
    "name": "ohos.permission.READ_DATA_SHARE",
    "reason": "$string:read_share_reason"
  }, {
    "name": "ohos.permission.WRITE_DATA_SHARE",
    "reason": "$string:write_share_reason"
  }]
}
```
