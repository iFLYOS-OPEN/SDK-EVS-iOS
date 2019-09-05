//
//  AudioInput.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/26.
//  Copyright © 2019 iflytek. All rights reserved.
//
#import "AudioInput.h"
#import "EVSHeader.h"
#import <AVFoundation/AVFoundation.h>
#define dispatch_key "audioInput_dispatch"
#define kNumberBuffers 3  //定义了三个缓冲区
#define kDefaultBufferDurationSeconds 0.02   //20ms采样
#define kDefaultSampleRate 16000   //定义采样率为16000
#define kBufferSize 640 //缓冲区大小

//static iflytek::IFlytekWakeUp ins([[[NSBundle mainBundle] bundlePath] UTF8String]);
@interface AudioInput(){
    AudioStreamBasicDescription recordFormat;
    AudioQueueRef                mQueue;
    AudioQueueBufferRef          mBuffers[kNumberBuffers];
    AudioFileID                  mAudioFile;
    AudioComponentDescription outputUinitDesc;
    @public
    AudioUnit audioUnit;
}
@property(assign) BOOL openWakeupStream;//是否唤醒音频输入流
@property(assign) BOOL openAudioInputStream;//是否打开音频输入流
@end

void checkStatus(OSStatus status) {
    if(status!=0)
        printf("Error: %ld\n", status);
}
static OSStatus RecordCallback(void *inRefCon,
                               AudioUnitRenderActionFlags *ioActionFlags,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 inBusNumber,
                               UInt32 inNumberFrames,
                               AudioBufferList *ioData){
    // TODO:
    // 使用 inNumberFrames 计算有多少数据是有效的
    // 在 AudioBufferList 里存放着更多的有效空间
    
    AudioInput *audioInput = (__bridge AudioInput*) inRefCon;
    //bufferList里存放着一堆 buffers, buffers的长度是动态的。
    AudioBuffer buffer;
    
    buffer.mNumberChannels = 1;
    
    buffer.mDataByteSize = inNumberFrames * 2;
    
    buffer.mData = malloc( inNumberFrames * 2 );
    
    
    // 将数据放到缓冲队列
    
    AudioBufferList bufferList;
    
    bufferList.mNumberBuffers = 1;
    
    bufferList.mBuffers[0] = buffer;
    
    
    // 记录 samples
    
    
    OSStatus status;
    
    //根据设置的参数来渲染音频数据
    
    status = AudioUnitRender(audioInput->audioUnit,
                             
                             ioActionFlags,
                             
                             inTimeStamp,
                             
                             inBusNumber,
                             
                             inNumberFrames,
                             &bufferList);
    checkStatus(status);
    
    Byte *byte = (Byte *)buffer.mData;
    int16_t *buf = (int16_t *)buffer.mData;
    //写入唤醒输入
    if(audioInput.openWakeupStream){
//        auto ret = ins.detect((int16_t*)&buf[0], inNumberFrames);
//        if(ret >= 0){
//            EVSLog(@"===================== 【wake up】 =====================");
//            [[EvsSDKForiOS shareInstance] tap];
//        }
    }
    //写入音频输入
    if(audioInput.openAudioInputStream){
//        NSLog(@"[-]audioinput.stream------");
        //写入音频分贝数据
        NSString *pcmPath = [audioInput pcmPath];
        [audioInput writeBytes:byte len:buffer.mDataByteSize toPath:pcmPath];
        
        //发送服务器
        NSData *data = [NSData dataWithBytes:buffer.mData length:buffer.mDataByteSize];
        [[EVSWebscoketManager shareInstance] sendData:data];
    }
    
    return noErr;
}

@implementation AudioInput
+ (AudioInput *)sharedAudioManager {
    static AudioInput *sharedAudioManager;
    @synchronized(self) {
        if (!sharedAudioManager) {
            sharedAudioManager = [[AudioInput alloc] init];
        }
        return sharedAudioManager;
    }
}

-(NSString *) pcmPath{
    //1.创建database路径
    NSString *docuPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *pcmPath = [docuPath stringByAppendingPathComponent:[NSString stringWithFormat:@"recoder%@.pcm",[EVSDateUtils getCurrentTimes]]];
    return pcmPath;
}

-(id) init{
    if (self == [super init]) {
        outputUinitDesc.componentType = kAudioUnitType_Output;//输出类型
        outputUinitDesc.componentSubType = kAudioUnitSubType_RemoteIO;
        outputUinitDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
        outputUinitDesc.componentFlags = 0;
        outputUinitDesc.componentFlagsMask = 0;
        AudioComponent outComponent = AudioComponentFindNext(NULL, &outputUinitDesc);
        OSStatus status = AudioComponentInstanceNew(outComponent, &audioUnit);
        
        if (status != noErr)  {
            audioUnit = NULL;
            NSLog(@"初始化失败");
            [EVSSystemManager exception:@"audio_input" code:[NSString stringWithFormat:@"%i",(int)status] message:@"audio_input init fail"];
        }
        
        
        recordFormat.mSampleRate = kDefaultSampleRate;
        recordFormat.mFormatID = kAudioFormatLinearPCM;
        recordFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        recordFormat.mFramesPerPacket = 1;
        recordFormat.mChannelsPerFrame = 1;
        recordFormat.mBitsPerChannel = 16;
        recordFormat.mBytesPerFrame = recordFormat.mBytesPerPacket = 2;
        
        status = AudioUnitSetProperty(audioUnit,
                                      kAudioUnitProperty_StreamFormat,
                                      kAudioUnitScope_Output,
                                      1,
                                      &recordFormat,
                                      sizeof(recordFormat));
        
        checkStatus(status);
        
//                    // 去除回声开关
//                    UInt32 echoCancellation;
//                    status = AudioUnitSetProperty(audioUnit,
//                                         kAUVoiceIOProperty_BypassVoiceProcessing,
//                                         kAudioUnitScope_Global,
//                                         0,
//                                         &echoCancellation,
//                                         sizeof(echoCancellation));
        checkStatus(status);
        // AudioUnit输入端默认是关闭，需要将他打开
        UInt32 flag = 1;
        status = AudioUnitSetProperty(audioUnit,
                                      kAudioOutputUnitProperty_EnableIO,
                                      kAudioUnitScope_Input,
                                      1,
                                      &flag,
                                      sizeof(flag));
        checkStatus(status);
        
        UInt32 playFlag = 0;
        AudioUnitSetProperty(audioUnit,
                             kAudioOutputUnitProperty_EnableIO,
                             kAudioUnitScope_Output,
                             0,
                             &playFlag,
                             sizeof(playFlag));
        checkStatus(status);
        
        AURenderCallbackStruct recordCallback;
        recordCallback.inputProcRefCon = (__bridge void * _Nullable)(self);
        recordCallback.inputProc = RecordCallback;//回调函数
        status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 1, &recordCallback, sizeof(recordCallback));
        
        checkStatus(status);
        
        UInt32 close = 0;
        status = AudioUnitSetProperty(audioUnit,
                                      kAudioUnitProperty_ShouldAllocateBuffer,
                                      kAudioUnitScope_Output,
                                      1,
                                      &close,
                                      sizeof(close));
        checkStatus(status);
        
        UInt32 category = kAudioSessionCategory_PlayAndRecord;
        status = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
        checkStatus(status);
        status = 0;
        status = AudioSessionSetActive(YES);
        checkStatus(status);
        status = AudioUnitInitialize(audioUnit);
        checkStatus(status);
    }
    return self;
}

//始终录音
-(void) run{
    OSStatus status = AudioOutputUnitStart(audioUnit);
    checkStatus(status);
    if ([self wakeStart]) {
        self.openWakeupStream = YES;
    }else{
        EVSLog(@"evs wakeup is error");
    }
}

//停止录音
-(void) end{
    OSStatus status = AudioOutputUnitStop(audioUnit);
    checkStatus(status);
}

//开启 Audio Unit
- (void)start {
    [[AudioOutput shareInstance] setBackgroundVolume2Percent];
    self.openAudioInputStream = YES;
    [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] sessionStatus:LISTENING];
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    if (deviceId) {
        [[EVSSqliteManager shareInstance] update:@{@"session_status":@"LISTENING"} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
    }
}

//关闭 Audio Unit
- (void)stop {
    [[AudioOutput shareInstance] resumeBackgroundVolume];
    self.openAudioInputStream = NO;
    [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] sessionStatus:THINKING];
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    if (deviceId) {
        [[EVSSqliteManager shareInstance] update:@{@"session_status":@"THINKING"} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
    }
}
//结束 Audio Unit
- (void)finished {
    AudioComponentInstanceDispose(audioUnit);
}

//写入文件
- (void)writeBytes:(Byte *)bytes len:(NSUInteger)len toPath:(NSString *)path{
    NSData *pcmData = [NSData dataWithBytes:bytes length:len];
//    [self writeData:data toPath:path];
    //分贝大小
    if (!pcmData){
        return ;
    }else{
        long long pcmAllLenght = 0;
        
        short butterByte[pcmData.length/2];
        memcpy(butterByte, pcmData.bytes, pcmData.length);//frame_size * sizeof(short)
        
        // 将 buffer 内容取出，进行平方和运算
        for (int i = 0; i < pcmData.length/2; i++)
        {
            pcmAllLenght += butterByte[i] * butterByte[i];
        }
        // 平方和除以数据总长度，得到音量大小。
        float mean = pcmAllLenght / (float)pcmData.length;
        float volume =10*log10(mean);//volume为分贝数大小
        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] decibel:volume];
    }
}

- (void)writeData:(NSData *)data toPath:(NSString *)path{
    NSString *savePath = path;
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath] == false)
    {
        [[NSFileManager defaultManager] createFileAtPath:savePath contents:nil attributes:nil];
    }
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:savePath];
    [handle seekToEndOfFile];
    [handle writeData:data];
}

-(BOOL) wakeStart{
//    if(ins.start()){
//        return YES;
//    }
    return NO;
}
@end
