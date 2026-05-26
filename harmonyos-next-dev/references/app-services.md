# 应用服务参考

## 定位

```typescript
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';

// 检查定位开关
let isEnabled = await geoLocationManager.isLocationEnabled();

// 单次定位
import { geoLocationManager } from '@kit.LocationKit';
try {
  let location = await geoLocationManager.getCurrentLocation({
    priority: geoLocationManager.LocationRequestPriority.ACCURACY,
    timeoutMs: 5000
  });
  console.log(`lat: ${location.latitude}, lng: ${location.longitude}`);
} catch (err) {
  console.error('Location failed', (err as BusinessError).code);
}

// 持续定位
let requestId = geoLocationManager.on('locationChange', {
  priority: geoLocationManager.LocationRequestPriority.FIRST_FIX
}, (location) => {
  console.log(`lat: ${location.latitude}, lng: ${location.longitude}`);
});
// 停止
geoLocationManager.off('locationChange', requestId);

// 地理编码
let geocodes = await geoLocationManager.getAddressesFromLocation({
  latitude: 39.90, longitude: 116.40
});
console.log(geocodes[0].locality); // 城市名
```

## 推送

```typescript
import { pushService } from '@kit.PushServiceKit';

// 获取推送 Token
pushService.getToken().then((token: string) => {
  console.log(`Push token: ${token}`);
  // 发送到后端
}).catch((err: BusinessError) => {
  console.error('Get token failed', err);
});

// 监听推送事件
pushService.on('pushMessage', (message) => {
  console.log(`Received: ${message.title}`);
});
```

## 网络请求

```typescript
import { http } from '@kit.NetworkKit';

// GET 请求
async function fetchData() {
  let req = http.createHttp();
  try {
    let res = await req.request('https://api.example.com/data', {
      method: http.RequestMethod.GET,
      header: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer token123'
      },
      connectTimeout: 10000,
      readTimeout: 10000
    });
    if (res.responseCode === 200) {
      let data = JSON.parse(res.result as string);
      return data;
    }
  } catch (err) {
    console.error('Request failed', err);
  } finally {
    req.destroy();
  }
}

// POST 请求
async function postData() {
  let req = http.createHttp();
  let res = await req.request('https://api.example.com/submit', {
    method: http.RequestMethod.POST,
    extraData: JSON.stringify({ name: 'test', value: 123 })
  });
  req.destroy();
}
```

## WebSocket

```typescript
import { webSocket } from '@kit.NetworkKit';

let ws = webSocket.createWebSocket();
ws.connect('wss://example.com/ws', (err, value) => {
  if (!err) {
    console.log('Connected');
    ws.send('Hello server!');
  }
});

ws.on('message', (data: string) => {
  console.log(`Received: ${data}`);
});

ws.on('close', () => {
  console.log('Connection closed');
});

// 关闭
ws.close();
```

## 上传下载

```typescript
import { request } from '@kit.NetworkKit';

// 上传
let uploadTask = await request.uploadFile(getContext(this), {
  url: 'https://api.example.com/upload',
  files: [{ filename: 'photo.jpg', name: 'file', uri: 'file://path/to/photo.jpg' }],
  data: [{ name: 'description', value: 'My photo' }]
});
uploadTask.on('progress', (bytes: number, total: number) => {
  console.log(`Upload: ${bytes}/${total}`);
});

// 下载
let downloadTask = await request.downloadFile(getContext(this), {
  url: 'https://example.com/file.zip',
  filePath: 'file://path/to/save/file.zip'
});
downloadTask.on('progress', (bytes: number, total: number) => {
  console.log(`Download: ${bytes}/${total}`);
});
```

## 数据持久化

### Preferences（轻量键值）

```typescript
import { preferences } from '@kit.ArkData';

let store = await preferences.getPreferences(getContext(this), 'my_store');
await store.put('user_name', 'Alice');
await store.flush();  // 立即写入

let name = await store.get('user_name', 'default');
await store.delete('user_name');
```

### KVStore（分布式键值）

```typescript
import { distributedKVStore } from '@kit.DistributedKVStoreKit';

let kvManager = distributedKVStore.createKVManager({
  context: getContext(this),
  bundleName: 'com.example.myapp'
});
let kvStore = await kvManager.getKVStore('store_id', {
  createIfMissing: true
});
await kvStore.put('key', 'value');
let value = await kvStore.get('key');
```

### RDB（关系型数据库）

```typescript
import { relationalStore } from '@kit.ArkData';

let store = await relationalStore.getRdbStore(getContext(this), {
  name: 'MyApp.db',
  securityLevel: relationalStore.SecurityLevel.S1
});

// 建表
await store.executeSql(
  'CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, age INTEGER)'
);

// 插入
await store.insert('users', { name: 'Alice', age: 30 });

// 查询
let predicates = new relationalStore.RdbPredicates('users');
predicates.greaterThan('age', 18);
let results = await store.query(predicates, ['id', 'name', 'age']);
while (results.goToNextRow()) {
  let id = results.getLong(results.getColumnIndex('id'));
  let name = results.getString(results.getColumnIndex('name'));
}
results.close();
```

## 文件读写

```typescript
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;

// 写文件
let file = fileIo.openSync(`${filesDir}/test.txt`, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
fileIo.writeSync(file.fd, 'Hello World');
fileIo.closeSync(file.fd);

// 读文件
let file2 = fileIo.openSync(`${filesDir}/test.txt`, fileIo.OpenMode.READ_ONLY);
let buf = new ArrayBuffer(1024);
let bytesRead = fileIo.readSync(file2.fd, buf);
console.log(fileIo.bufToString(buf, 0, bytesRead));
fileIo.closeSync(file2.fd);
```
