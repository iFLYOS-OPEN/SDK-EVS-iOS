# EVS SDK For iOS

### 版本：1.0.3

| 版本  | 更新内容                                                     | 支持设备    | 支持OS版本   |
| ----- | ------------------------------------------------------------ | ----------- | ------------ |
| 1.0.0 | 1.EVS授权,连接,重连接 <br>2.tap唤醒<br/> 3.打断 <br/>4.结束<br/> 5.暂停<br/> 6.恢复<br/> 7.下一首<br/> 8.上一首 <br/>9.tts合成 <br/>10.文本识别 | iphone,ipad | iOS 10.1以上 |
| 1.0.3 | 1.新增视频播放器 <br>2.新增语音操作app action 打开第三方应用<br>3.优化焦点管理<br>4.修复部分bug | iphone,ipad | iOS 10.1以上 |

### SDK文件

- include

​	- EvsSDKForiOS

​	- ……

- libEvsSDKForiOS.a



## 工程配置

### 引入SDK

1. 把libEvsSDKForiOS.a 和 include拖到工程
2. target->build settings->Library Search Paths 设置SDK静态库路径
3. target->build settings->Header Search Paths 设置头文件路径
4. 若提示bitcode错误，则在buid settings搜索Enable Bitcode，然后设置为NO
5. Other Linker Flags -> -ObjC



### 依赖库

pod 'FMDB'

pod 'SocketRocket'

pod 'MJExtension'

pod 'AFNetworking'

pod 'WebViewJavascriptBridge'



### profile

```
platform :ios, '10.1'
workspace 'evs_sdk_ios.xcworkspace'
inhibit_all_warnings!
use_frameworks!

target 'EvsSDKForiOS' do
    project 'EvsSDKForiOS/EvsSDKForiOS.xcodeproj'
    pod 'FMDB'
    pod 'SocketRocket'
    pod 'MJExtension'
    pod 'AFNetworking'
    pod 'WebViewJavascriptBridge'
end
```



### 头文件引入

```
#import <EvsSDKForiOS/EvsSDKForiOS.h>
```



## 使用说明

### 实例化EVS SDK

```
[EvsSDKForiOS create:@"clientId" deviceId:@"设备唯一ID" wsURL:@"wss://ivs.iflyos.cn/embedded/v1"]
```

- clientId ：设备的client_id
- deviceId : 设备唯一的ID，若设置为nil，SDK自动创建唯一的ID（可通过getDeviceId获取SDK生成的唯一ID）
- wsURL：EVS websocket连接地址，地址以官网的文档中心为准

ps: 

```
create:deviceId:wsURL 与 [[EvsSDKForiOS shareInstance] restoreEVS:deviceId:wsURL]作用一样
```



### EVS调用方法

#### 1.连接 connect

| 参数 | 类型 | 说明    | 备注                         |
| ---- | ---- | ------- | ---------------------------- |
| -    | -    | 连接EVS | 未授权情况下会要求先获取授权 |

#### 2. 重连接 reconnect

| 参数 | 类型 | 说明        | 备注 |
| ---- | ---- | ----------- | ---- |
| -    | -    | 重新连接EVS |      |

#### 3. 断开连接disconnect

| 参数 | 类型 | 说明        | 备注 |
| ---- | ---- | ----------- | ---- |
| -    | -    | 断开EVS连接 |      |

#### 4. 出厂化 restoreEVS

| 参数 | 类型 | 说明          | 备注                                                         |
| ---- | ---- | ------------- | ------------------------------------------------------------ |
| -    | -    | 出厂化EVS SDK | 慎用，会清除设备所有的数据，需要调用recreateEVS重新创建实例或重新启动<br/>(调用后，若需要马上设置新的参数，则调用recreateEVS:deviceId:wsURL) |

#### 5. 唤醒 tap

| 参数 | 类型 | 说明 | 备注     |
| ---- | ---- | ---- | -------- |
| -    | -    | 唤醒 | 开始录音 |

#### 6.结束 end

| 参数 | 类型 | 说明     | 备注                                  |
| ---- | ---- | -------- | ------------------------------------- |
| -    | -    | 结束对话 | 不使用云端VAD情况下，需要手工结束对话 |

#### 7.打断 cancel

| 参数 | 类型 | 说明     | 备注               |
| ---- | ---- | -------- | ------------------ |
| -    | -    | 打断对话 | 打断后需要重新唤醒 |

#### 8. 暂停播放 pause

| 参数 | 类型 | 说明     | 备注 |
| ---- | ---- | -------- | ---- |
| -    | -    | 暂停播放 |      |

#### 9. 恢复播放 resume

| 参数 | 类型 | 说明     | 备注 |
| ---- | ---- | -------- | ---- |
| -    | -    | 继续播放 |      |

#### 10. 下一首 next

| 参数 | 类型 | 说明   | 备注 |
| ---- | ---- | ------ | ---- |
| -    | -    | 下一首 |      |

#### 11. 上一首 previous

| 参数 | 类型 | 说明   | 备注 |
| ---- | ---- | ------ | ---- |
| -    | -    | 上一首 |      |

#### 12.合成 tts

| 参数    | 类型   | 说明    | 备注 |
| ------- | ------ | ------- | ---- |
| message | string | 合成TTS |      |

#### 13.文本识别 text_in

| 参数    | 类型   | 说明         | 备注 |
| ------- | ------ | ------------ | ---- |
| message | string | 文本audio_in |      |

#### 14. 设置音量 setVolume/getVolume

| 参数          | 类型 | 说明         | 备注   |
| ------------- | ---- | ------------ | ------ |
| 设置/获取音量 | int  | 文本audio_in | 1～100 |

#### 15. 自定义指令 command

| 参数    | 类型   | 说明           | 备注       |
| ------- | ------ | -------------- | ---------- |
| jsonStr | string | 自定义指令扩展 | json字符串 |

#### 16.设置setToken

| 参数  | 类型   | 说明        | 备注                             |
| ----- | ------ | ----------- | -------------------------------- |
| token | string | 自定义token | 手工设置token后，需要重新连接EVS |

#### 17.设置getToken

返回参数

| 参数  | 类型   | 说明 | 备注                 |
| ----- | ------ | ---- | -------------------- |
| token | string |      | 获取evs access Token |

#### 18.getAuthorization

返回参数

| 参数          | 类型   | 说明 | 备注                  |
| ------------- | ------ | ---- | --------------------- |
| authorization | string |      | 获取evs Authorization |

#### 视频管理器

#### EVSVideoPlayerManager<EVSVideoPlayerDelegate>

#### 1.创建视频窗口createVideoPlayer:offset:resource_id

| 参数        | 类型   | 说明        | 备注 |
| ----------- | ------ | ----------- | ---- |
| frame       | CGRect | 视图大小    |      |
| url         | String | 视频资源url |      |
| offset      | long   | 时间点      |      |
| resource_id | String | 资源ID      |      |

#### 2.播放新资源play:offset:resource_id

| 参数        | 类型   | 说明        | 备注 |
| ----------- | ------ | ----------- | ---- |
| url         | String | 视频资源url |      |
| offset      | long   | 时间点      |      |
| resource_id | String | 资源ID      |      |

#### 3.暂停pause

| 参数 | 类型 | 说明 | 备注 |
| ---- | ---- | ---- | ---- |
| -    | -    | -    | -    |

#### 4.恢复resume

| 参数 | 类型 | 说明 | 备注 |
| ---- | ---- | ---- | ---- |
| -    | -    | -    | -    |

#### 5.播放play:offset:

| 参数   | 类型 | 说明   | 备注 |
| ------ | ---- | ------ | ---- |
| offset | long | 时间点 |      |

#### 6.播放play

| 参数 | 类型 | 说明 | 备注 |
| ---- | ---- | ---- | ---- |
| -    | -    | -    | -    |

#### 7.全屏模式setNewOrientation:

| 参数       | 类型 | 说明     | 备注 |
| ---------- | ---- | -------- | ---- |
| fullscreen | Bool | 是否全屏 |      |

#### 8.清除资源clean

| 参数 | 类型 | 说明 | 备注 |
| ---- | ---- | ---- | ---- |
| -    | -    | -    | -    |

####  

### EVS 代理回调

#### EvsSDKDelegate

| 函数名                      | 参数                                                         | 说明            | 备注                                                         |
| --------------------------- | ------------------------------------------------------------ | --------------- | ------------------------------------------------------------ |
| evs:isAuth:errorCode:error: | *  isAuth:是否授权成功<br/>*  errorCode : 错误代码 （0:没错误）<br/>*  error : 错误原因 | EVS授权状态回调 |                                                              |
| evs:connectState:error      | \*  connectState : 连接状态<br/>*  error : 错误原因          | EVS连接状态回调 |                                                              |
| evs:volume:                 | \*  volume : 音量（1～100）                                  | EVS当前音量回调 |                                                              |
| evs:requestMsg:             | *  requestMsg : 请求回调JSON指令                             | EVS请求回调     |                                                              |
| evs:responseMsg:            | *  responseMsg : 响应回调JSON指令                            | EVS响应回调     |                                                              |
| evs:decibel:                | *  decibel : 分贝数                                          | EVS录音分贝回调 |                                                              |
| evs:progress:               | *  progress : 进度（百分比）                                 | 播放器进度      | 只对音乐进度进行计算                                         |
| evs:status:                 | *  status : SDK状态                                          | 对话状态        | IDLE = 0, //空闲<br>LISTENING = 1, //录音中<br>THINKING = 2, //响应中<br>SPEAKING = 3, //播放中<br>FINISHED = 4 //播放完毕 |

