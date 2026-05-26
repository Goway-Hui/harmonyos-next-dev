# 分布式能力参考

## 设备发现

```typescript
import { deviceManager } from '@kit.DistributedServiceKit';

// 监听设备状态
deviceManager.on('deviceStateChange', (state: deviceManager.DeviceStateInfo) => {
  console.log(`Device ${state.deviceName} ${state.state === 'online' ? '上线' : '下线'}`);
});

// 获取可信设备列表
let devices = deviceManager.getTrustedDeviceListSync();
devices.forEach(device => {
  console.log(`Device: ${device.deviceName}, id: ${device.networkId}, type: ${device.deviceType}`);
});

// 发现附近设备
deviceManager.startDiscovering();
deviceManager.on('discoverSuccess', (device: deviceManager.DeviceBasicInfo) => {
  console.log(`Discovered: ${device.deviceName}`);
});
deviceManager.stopDiscovering();
```

## 分布式 KVStore

```typescript
import { distributedKVStore } from '@kit.DistributedKVStoreKit';

async function setupDistributedKVStore(context) {
  // 创建 KVManager
  let kvManager = distributedKVStore.createKVManager({
    context: context,
    bundleName: 'com.example.myapp'
  });

  // 获取分布式 KVStore
  let kvStore = await kvManager.getKVStore('shared_data', {
    createIfMissing: true,
    // 安全等级
    securityLevel: distributedKVStore.SecurityLevel.S1,
    // 是否支持分布式同步
    kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION
  });

  // 写入
  await kvStore.put('key1', 'Hello from Device A');

  // 读取
  let value = await kvStore.get('key1');

  // 监听远程数据变更
  kvStore.on('dataChange', distributedKVStore.DataChangeType.ALL, (data) => {
    console.log(`Data changed: ${data.deviceId}, ${data.key}`);
  });

  // 同步到远端
  let devices = deviceManager.getTrustedDeviceListSync();
  kvStore.sync(devices.map(d => d.networkId), distributedKVStore.SyncMode.PULL);
}
```

## RPC 远程调用

```typescript
import { rpc } from '@kit.AbilityKit';

// ----- 服务端：注册 RPC 服务 -----
class MyRemoteObject extends rpc.RemoteObject {
  constructor(descriptor) {
    super(descriptor);
  }

  onRemoteRequest(code: number, data: rpc.MessageParcel, reply: rpc.MessageParcel, options: rpc.MessageOption): boolean {
    switch (code) {
      case 1: // 获取数据
        let input = data.readString();
        reply.writeString(`Server received: ${input}`);
        return true;
      case 2: // 计算
        let a = data.readInt();
        let b = data.readInt();
        reply.writeInt(a + b);
        return true;
      default:
        return false;
    }
  }
}

// 注册服务
let remoteObj = new MyRemoteObject('com.example.service');

// ----- 客户端：远程调用 -----
import { rpc } from '@kit.AbilityKit';

async function callRemoteService(networkId: string) {
  // 获取远端 Ability 的代理
  let proxy = await rpc.getProxy({
    deviceId: networkId,
    bundleName: 'com.example.myapp',
    abilityName: 'RemoteServiceAbility'
  });

  // 发起远程调用
  let data = rpc.MessageParcel.create();
  data.writeString('Hello from remote');

  let reply = rpc.MessageParcel.create();
  await proxy.sendRequest(1, data, reply, new rpc.MessageOption());
  let result = reply.readString();
  console.log(`Remote reply: ${result}`);
}
```

## 分布式文件

```typescript
import { fileIo } from '@kit.CoreFileKit';
import { distributedFile } from '@kit.DistributedServiceKit';

// 获取分布式文件路径
let distributedPath = distributedFile.getDistributedDir(getContext(this), {
  deviceId: 'target_device_network_id',
  sandboxPath: '/data/storage/el2/base/haps/entry/files/'
});

// 通过分布式路径读写文件（自动同步）
let file = fileIo.openSync(`${distributedPath}/shared.txt`, fileIo.OpenMode.READ_WRITE);
fileIo.writeSync(file.fd, 'Distributed content');
fileIo.closeSync(file.fd);
```

## 跨设备启动 Ability

```typescript
import { common, Want } from '@kit.AbilityKit';

let context = getContext(this) as common.UIAbilityContext;

let want: Want = {
  deviceId: 'target_device_network_id',  // 跨设备
  bundleName: 'com.example.myapp',
  abilityName: 'EntryAbility',
  parameters: { key: 'value' }
};

context.startAbility(want);
```

## 分布式 RDB

```typescript
import { distributedKVStore } from '@kit.DistributedKVStoreKit';
import { relationalStore } from '@kit.ArkData';

// 分布式 RDB 通过 RDBStore 的 sync 方法同步
let store = await relationalStore.getRdbStore(context, {
  name: 'distributed.db',
  securityLevel: relationalStore.SecurityLevel.S1
});

// 同步到设备列表
let devices = deviceManager.getTrustedDeviceListSync();
store.sync(devices.map(d => d.networkId), relationalStore.SyncMode.SYNC_MODE_PUSH);
```
