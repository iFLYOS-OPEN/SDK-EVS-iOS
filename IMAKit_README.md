![](logo.svg)

  # 说明

  IMAKit是IFLYOS和蓝牙外设数据通讯交换协议，适用于iOS系统和其他支持蓝牙的外设，它基于Objective-C和C开发语言，可接入OC和Swift项目中

  

  # 联系

  AIUI 开发者交流一群： 431255925

  AIUI 开发者交流二群： 673450581（已满）

  AIUI 评估板交流群： 207343022

  技术支持： aiui_support@iflytek.com

  商务合作： aiui_support@iflytek.com

  

  # 安装

  - 静态库引入

    - include

    ​	- IMAKit

    ​	-- ……

    - libIMAKit.a

      

    ### 引入SDK

    1. 把libIMAKit.a 和 include拖到工程
    2. target->build settings->Library Search Paths 设置SDK静态库路径
    3. target->build settings->Header Search Paths 设置头文件路径
    4. 若提示bitcode错误，则在buid settings搜索Enable Bitcode，然后设置为NO
    5. Other Linker Flags -> -ObjC

    

    ### 依赖库

    ​	pod 'opus-ios'

    ​    pod 'FMDB'

    ​    pod "Protobuf"

    ​    pod 'SocketRocket'

    ​    pod 'MJExtension'

    ​    pod 'AFNetworking'

    ​    pod 'WebViewJavascriptBridge'

    ​    pod 'KeychainItemWrapper-Copy'

    


    ### 头文件引入
    
    ```
    #import <IMAKit/IMAkit.h>
    ```



  # 要求

| SDK版本 | 最小iOS版本 | xcode版本  |
| ------- | ----------- | ---------- |
| 1.X.X   | iOS 10.1    | xcode 10.2 |

  

  # 构建

##通道

蓝牙耳机使用A2DP 通道（AVAudioSessionCategoryOptionAllowBluetoothA2DP），可录音和播放



##授权

鉴权流程：

App鉴权时作为参数提供：

1. sign_method: 签名方法，需要支持(SHA256, SHA1, MD5)
2. rand: 8位随机字符串
3. client_id: 设备client_id
4. device_id: 设备device_id
5. sign: 设备签名 sign_method(rand + secret + client_id + device_id)

服务端验证sign正确后，需要返回:

1. rand2: 8位随机字符串

2. sign2: sign_method(rand2 + rand + secret + client_id + device_id)

```
ps:保存rand2和 sign2本地，外设录音请求和状态需要鉴权
```



##音频格式

支持pcm和opus音频格式
| 参数      | size | 说明             |
| --------- | -------- | ---------------- |
| 采样率 | 16000     | 每秒钟采样次数，采样率越高越能表达高频信号的细节内容。 |
| 通道数 | 1     |  单通道为1， 双通道（立体声）为2|
| 位深度 | 16     | 每一个采样数据由多少位来表示 |
| 音频帧大小 | 320     |  |


##数据格式

使用protobuff进行数据交互

```
具体参考协议附件 ima.proto
```

  

  # 用法

  #### 1. 搜索蓝牙外设

| 方法      | 参数 | 说明             | 备注 |
| --------- | -------- | ---------------- | ---- |
| startScan | void     | 开始搜索蓝牙外设 |      |

  #### 2. 停止搜索搜索

| 方法      | 参数 | 说明             | 备注 |
| --------- | -------- | ---------------- | ---- |
| stopScan | void     | 停止搜索蓝牙外设 |      |

  #### 3. 停止搜索搜索

| 方法      | 参数 | 说明             | 备注 |
| --------- | -------- | ---------------- | ---- |
| startScanWithName | void     | 根据名字搜索并连接设备 |      |

  #### 4. 连接蓝牙

| 方法      | 参数 | 说明             | 备注 |
| --------- | -------- | ---------------- | ---- |
| connect: | peripheral：蓝牙BLE对象     | 根据名字搜索并连接设备 |      |

  #### 5. 断开蓝牙

| 方法      | 参数 | 说明             | 备注 |
| --------- | -------- | ---------------- | ---- |
| disconnect | void     | 断开当前连接的蓝牙 |      |

  #### 6. 写入蓝牙外设数据

| 方法      | 参数 | 说明             | 备注 |
| --------- | -------- | ---------------- | ---- |
| write: | data:写入蓝牙的数据，每次最大不超过20字节     | 写入蓝牙二进制数据 |      |

  #### 7. 开始录音

| 方法      | 参数 | 说明             | 备注 |
| --------- | -------- | ---------------- | ---- |
| startSpeech | void     | 开始录音 |      |

  #### 8. 停止录音

| 方法      | 参数 | 说明             | 备注 |
| --------- | -------- | ---------------- | ---- |
| stopSpeech | void     | 停止录音 |      |

  #### 回调

  #### EvsSDKDelegate

| 方法                                     | 参数                                                         | 说明                   | 备注                 |
| ---------------------------------------- | ------------------------------------------------------------ | ---------------------- | -------------------- |
| imaManager:isActive:                     | *  isActive:蓝牙是否可用                                     | 回调蓝牙是否可用       |                      |
| imaManager: peripheral: clientId:        | \*  peripheral :蓝牙对象<br/>*  clientId：设备clientId       | 回调返回蓝牙对象       |                      |
| imaManager: peripheral: isConnect:error: | *\*  peripheral :蓝牙对象<br/>*\**isConnect:是否连接<br/>*\* error : 连接失败返回错误信息 | 是否连接成功           |                      |
| onGetDeviceInfomation: clientId:         | * deviceId:设备ID<br/>* clientId:设备clientId                | 回调设备详细信息       | 连接成功后回调       |
| onVersionVerify:                         | *  isVersionExchange:版本是否可用                            | IMA协议是否匹配可用    |                      |
| onPairSuccess                            | -                                                            | 配对成功               |                      |
| onPairFail:msg:                          | * statusCode：错误码<br>* msg:错误信息                       | 配对失败               | 只对音乐进度进行计算 |
| onStartSpeech                            | -                                                            | 开始录音回调           |                      |
| onStopSpeech                             | -                                                            | 结束录音回调           |                      |
| onAudioData:length:                      | * data:二进制音频数据 <br>* length长度                       | 耳机录音二进制音频数据 |                      |

  # 开源协议
  [Apache License 2.0](https://github.com/iFLYOS-OPEN/SDK-EVS-iOS/blob/master/LICENSE)

  [iFLYOS开放平台服务协议](https://doc.iflyos.cn/device/development_agreement.html#概述)
