# 电话与短信参考

## 拨号

```typescript
import { call } from '@kit.TelephonyKit';

// 拨打电话
call.makeCall('10086').then(() => {
  console.log('Call initiated');
}).catch((err) => {
  console.error('Call failed', err);
});
```

## 通话状态

```typescript
import { call } from '@kit.TelephonyKit';

// 监听通话状态
call.on('callStateChange', (state: call.CallState, number: string) => {
  switch (state) {
    case call.CallState.CALL_STATE_IDLE:
      console.log('Idle');
      break;
    case call.CallState.CALL_STATE_ACTIVE:
      console.log('Active call with', number);
      break;
    case call.CallState.CALL_STATE_HOLDING:
      console.log('Call on hold');
      break;
    case call.CallState.CALL_STATE_DIALING:
      console.log('Dialing', number);
      break;
    case call.CallState.CALL_STATE_ALERTING:
      console.log('Alerting', number);
      break;
    case call.CallState.CALL_STATE_INCOMING:
      console.log('Incoming call from', number);
      break;
    case call.CallState.CALL_STATE_WAITING:
      console.log('Call waiting from', number);
      break;
    case call.CallState.CALL_STATE_DISCONNECTED:
      console.log('Call disconnected');
      break;
  }
});

// 停止监听
call.off('callStateChange');
```

## SIM 卡信息

```typescript
import { sim } from '@kit.TelephonyKit';

// 获取 SIM 卡信息
let slotId = 0;  // SIM 卡槽位
let simNumber = sim.getSimNumber(slotId);
let simIccId = sim.getSimIccId(slotId);
let simSpn = sim.getSimSpn(slotId);      // 运营商名称
let iso = sim.getIsoCountryCode(slotId);  // 国家码
let state = sim.getSimState(slotId);      // SIM 状态

// 检查是否有 SIM 卡
let isActive = sim.isSimActive(slotId);
```

## 短信

```typescript
import { sms } from '@kit.TelephonyKit';

// 发送短信
sms.sendMessage({
  destinationNumber: '10086',
  content: 'CXLL',
  destinationPort: 0
}).then(() => {
  console.log('SMS sent');
}).catch((err) => {
  console.error('SMS failed', err);
});

// 发送增强信息
sms.sendMessage({
  destinationNumber: '10086',
  content: 'Hello',
  destinationPort: 0,
  serviceId: 'com.example.service'
});

// 接收短信（需权限声明）
sms.on('receive', (event: sms.SmsEvent) => {
  console.log(`SMS received from ${event.number}: ${event.content}`);
});
```

## 蜂窝网络

```typescript
import { radio } from '@kit.TelephonyKit';

// 获取网络状态
let slotId = 0;
let radioTech = radio.getRadioTech(slotId);
// radioTech.psRadioTech: 4G/5G 等
// radioTech.csRadioTech: 2G/3G

// 获取信号强度
radio.getSignalInfo(slotId).then((signal) => {
  if (signal instanceof radio.GsmSignalInformation) {
    console.log(`GSM signal: ${signal.signalLevel}`);
  } else if (signal instanceof radio.LteSignalInformation) {
    console.log(`LTE RSSI: ${signal.rssi}, RSRP: ${signal.rsrp}`);
  } else if (signal instanceof radio.NrSignalInformation) {
    console.log(`NR RSRP: ${signal.rsrp}, SINR: ${signal.snr}`);
  }
});

// 监听信号变化
radio.on('signalInfoChange', (signals: radio.SignalInformation[]) => {
  signals.forEach(s => console.log(`Signal changed: ${s.signalType}`));
});

// 获取网络运营商
let operator = radio.getOperatorName(slotId);
console.log(`Network operator: ${operator}`);

// 获取网络状态
let networkState = radio.getNetworkState(slotId);
console.log(`Is roaming: ${networkState.isRoaming}`);
console.log(`Is emergency: ${networkState.isEmergency}`);
```

## 数据连接

```typescript
import { data } from '@kit.TelephonyKit';

// 获取数据连接状态
let isDataConnected = data.isDataConnected(slotId);

// 获取默认数据 SIM 卡
let defaultDataSlot = data.getDefaultDataSlotId();

// 监听数据连接变化
data.on('dataConnectionStateChange', (state: data.DataConnectState) => {
  switch (state) {
    case data.DataConnectState.DATA_STATE_DISCONNECTED:
      console.log('Data disconnected');
      break;
    case data.DataConnectState.DATA_STATE_CONNECTING:
      console.log('Data connecting...');
      break;
    case data.DataConnectState.DATA_STATE_CONNECTED:
      console.log('Data connected');
      break;
    case data.DataConnectState.DATA_STATE_SUSPENDED:
      console.log('Data suspended');
      break;
  }
});
```

## IMS / VoLTE

```typescript
import { ims } from '@kit.TelephonyKit';

// 获取 IMS 注册状态
let imsRegState = ims.getImsRegState(slotId);
console.log(`IMS registered: ${imsRegState.isRegistered}, tech: ${imsRegState.imsTech}`);
// imsTech: IMS_TECH_VOLTE, IMS_TECH_VOWIFI, IMS_TECH_VIDEO

// 监听 IMS 状态
ims.on('imsRegStateChange', (slotId: number, state: ims.ImsRegState) => {
  console.log(`IMS state changed for slot ${slotId}: registered=${state.isRegistered}`);
});
```

## 权限声明

```json
{
  "requestPermissions": [
    { "name": "ohos.permission.PLACE_CALL" },
    { "name": "ohos.permission.GET_TELEPHONY_STATE" },
    { "name": "ohos.permission.SEND_MESSAGES" },
    { "name": "ohos.permission.RECEIVE_SMS" },
    { "name": "ohos.permission.READ_CALL_LOG" },
    { "name": "ohos.permission.READ_CONTACTS" }
  ]
}
```
