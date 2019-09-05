![](logo.svg)

  # 说明

  EVS SDK For iOS 是根据IFLYOS EVS协议为基础的语音助手SDK库，适用于iOS系统，它使用Objective-C开发语言，能方便接入oc和swift项目中。

  

  - 下载[EVS SDK](https://github.com/packyzhou/EVS-SDK-OPENSOURCE)并附带iOS App应用事例
  - 在IFLYOS官网上了解EVS协议，常见问题解答
  - 了解EVS SDK For iOS的使用方式

  

  # 联系

  AIUI 开发者交流一群： 431255925

  AIUI 开发者交流二群： 673450581（已满）

  AIUI 评估板交流群： 207343022

  技术支持： aiui_support@iflytek.com

  商务合作： aiui_support@iflytek.com

  

  # 安装

  - 静态库引入

    - include

    ​	- EvsSDKForiOS

    ​	- ……

    - libEvsSDKForiOS.a

      

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

    

    ### 头文件引入

    ```
    #import <EvsSDKForiOS/EvsSDKForiOS.h>
    ```

    

  - cocoapods 

    ```
    source 'https://github.com/packyzhou/EVS-SDK-OPENSOURCE.git'
    pod 'EVS-SDK-OPENSOURCE','~> 1.0.8'
    ```
  

  # 要求

| SDK版本 | 最小iOS版本 | xcode版本  |
| ------- | ----------- | ---------- |
| 1.X.X   | iOS 10.1    | xcode 10.2 |

  

  # 构建

  详细EVS协议请到：[EVS API v1介绍](https://doc.iflyos.cn/device/evs/)

  ### 协议类

  - protocol

    - EVSBaseProtocolModel.h（协议基类，含iflyos_header,iflyos_context）

      {

       "iflyos_header": {...},

       "iflyos_context": {...},

       "iflyos_request": {

         ...（自定义）

      }

      }

    - EVSRecognizer.h （recognizer.audio_in,recognizer.text_in）

    - EVSAudioPlayer.h（audio_player.playback.progress_sync,audio_player.playback.control_command,）

    - EVSAudioPlayerTTS.h（audio_player.tts.text_in,audio_player.tts.progress_sync）

    - EVSSystemException.h（system.exception,）

    - EVSSystemStateSync.h（system.state_sync）

    - EVSResponseModel.h（响应映射类）

  

  ### 播放器

  - AudioInput.h（音频输入）
  - AudioOutput.h（音频输出）
  - AudioOutputQueue.h（音频播放队列）

  

  ### 系统管理

  - EVSFocusManager.h（焦点管理类，响应指令处理，详细：[交互约定](https://doc.iflyos.cn/device/evs/appointment.html)）
  - EVS+EVSFocusManager.h（音效扩展，可自行合成：[TTS文件合成](https://www.iflyos.cn/tts-file)）
  - EVSSystemManager.h（系统管理类，检查心跳时间戳，系统信息同步等）

  

  ### 授权连接

  - EVSAuthManager.h（授权管理，详细：[授权认证](https://doc.iflyos.cn/device/evs/#授权认证)）
  - EVSWebscoketManager.h（websocket连接）

  

  # 用法

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

  

  #### 回调

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

  

  # 开源协议

  [iFLYOS开放平台服务协议](https://doc.iflyos.cn/device/development_agreement.html#概述)
