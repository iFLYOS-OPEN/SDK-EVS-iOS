//
//  ViewController.m
//  EvsSDKDemo
//
//  Created by 周经伟 on 2019/7/23.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "ViewController.h"
#import <EvsSDKForiOS/EvsSDKForiOS.h>
#include <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MJExtension/MJExtension.h>
#import <IMAKit/IMAKit.h>
#import "SCSiriWaveformView.h"
#define ws_url @"wss://staging-ivs.iflyos.cn/embedded/v1"
#define k_NOTIFICATION_WS_STATE @"notificationWsState"//全局通知
@interface ViewController ()<EvsSDKDelegate,IMAKitDelegate>
@property (weak, nonatomic) IBOutlet UITextField *clientIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *deviceIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *ttsTextField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *reconnectButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeSilder;
@property (weak, nonatomic) IBOutlet SCSiriWaveformView *delView;
@property (weak, nonatomic) IBOutlet UIButton *scanBLEAndConnectButton;

@property (strong,nonatomic) IMAManager *imaManager;
@property (strong,nonatomic) EvsSDKForiOS *evsSDK;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.evsSDK) {
        self.evsSDK = [EvsSDKForiOS create:self.clientIdTextField.text deviceId:nil wsURL:ws_url];
        self.evsSDK.delegate = self;
    }
    self.connectButton.enabled = true;
    self.reconnectButton.enabled = false;
    self.disconnectButton.enabled = false;
    self.restoreButton.enabled = true;
    
    self.deviceIdTextField.text = [self.evsSDK getDeviceId];
    
    self.volumeSilder.value = [self.evsSDK getVolume] / 100;
    [self.volumeSilder addTarget:self action:@selector(volume:) forControlEvents:UIControlEventTouchUpInside];
    
    [self createKeyboardButton];
    // Do any additional setup after loading the view.
}
- (IBAction)clearLog:(id)sender {
    self.textView.text = @"";
}

//搜索并连接蓝牙，开始搜索前，请先在设置->蓝牙->列表中匹配蓝牙耳机
- (IBAction)scanBLE:(id)sender {
    [self.imaManager startScan];
}

- (IBAction)stopScan:(id)sender {
    [self.imaManager stopScan];
}

#define logSize 20000
-(void) textLast:(UITextView *) textView text:(NSString *) text{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *beforeStr = [textView.text copy];
        beforeStr = [beforeStr stringByAppendingFormat:@"%@\n",text];
        
        if (beforeStr.length < logSize) {
            textView.text = beforeStr;
        }else{
            textView.text = [beforeStr substringFromIndex:logSize];
        }
        NSInteger count = textView.text.length;
        [textView scrollRangeToVisible:NSMakeRange(0, count)];
    });
    
}

-(void) volume:(UISlider *) slider{
    NSInteger volume = slider.value * 100;
    NSLog(@"当前音量：%li",volume);
    [self.evsSDK setVolume:volume];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    EVSConnectState state = self.evsSDK.state;
    NSLog(@">>>>>>>>>>>状态：%li",state);
    if (state == 1) {
        self.connectButton.enabled = false;
        self.reconnectButton.enabled = true;
        self.disconnectButton.enabled = true;
    }else if (state == 0 || state == 2){
        self.connectButton.enabled = true;
        self.reconnectButton.enabled = false;
        self.disconnectButton.enabled = false;
    }
}

- (IBAction)connect:(id)sender {
    [self.evsSDK connect];
    self.connectButton.enabled = false;
}
- (IBAction)reconnect:(id)sender {
    [self.evsSDK reconnect];
}
- (IBAction)disconnect:(id)sender {
    [self.evsSDK disconnect];
}

- (IBAction)restore:(id)sender {
    [self.evsSDK restoreEVS];
    self.connectButton.enabled = true;
    self.reconnectButton.enabled = false;
    self.disconnectButton.enabled = false;
    self.restoreButton.enabled = true;
    NSString *clientId = self.clientIdTextField.text;
    [self.evsSDK recreateEVS:clientId deviceId:nil wsURL:@"wss://ivs.iflyos.cn/embedded/v1"];
}
#pragma 语音
- (IBAction)tap:(id)sender {
    //发送语音
    [self.evsSDK tap];
}
- (IBAction)cancel:(id)sender {
    [self.evsSDK cancel];
}
- (IBAction)end:(id)sender {
    [self.evsSDK end];
}
- (IBAction)test:(id)sender {
    EVSRecognizer *recognizer = [[EVSRecognizer alloc] init];
    NSDictionary *dict = [recognizer getJSON];
    NSString *json = [dict mj_JSONString];
    [self.evsSDK command:json];
//    [self.evsSDK sendData:<音频数据>];
}

#pragma 操控

- (IBAction)pause:(id)sender {
    [self.evsSDK pause];
}
- (IBAction)resume:(id)sender {
    [self.evsSDK resume];
}
- (IBAction)next:(id)sender {
    [self.evsSDK next];
}
- (IBAction)previous:(id)sender {
    [self.evsSDK previous];
}
- (IBAction)tts:(id)sender {
    NSString *tts = self.ttsTextField.text;
    [self.evsSDK tts:tts];
}
- (IBAction)textIn:(id)sender {
    NSString *tts = self.ttsTextField.text;
    [self.evsSDK text_in:tts];
}

#pragma EVS代理回调

/**
 *  EVS授权状态回调
 *  isAuth:是否授权成功
 *  errorCode : 错误代码
 *  error : 错误原因
 */
-(void) evs:(EvsSDKForiOS *) evsSDK isAuth:(BOOL)isAuth errorCode:(NSInteger) errorCode error:(NSError *) error{
   
    if(isAuth){
         [self textLast:_textView text:[NSString stringWithFormat:@"授权状态：授权成功!(%li)",errorCode]];
    }else{
         [self textLast:_textView text:[NSString stringWithFormat:@"授权状态：%@(%li)",error.localizedDescription,errorCode]];
    }
}

/**
 *  EVS连接状态回调
 *  connectState : 连接状态
 *  error : 错误原因
 */
-(void) evs:(EvsSDKForiOS *) evsSDK connectState:(EVSConnectState) connectState error:(NSError *) error{
   
     //0：可连接，1:已连接，2:可关闭，3:已关闭
    if (connectState == OPEN) {
        self.connectButton.enabled = false;
        self.reconnectButton.enabled = true;
        self.disconnectButton.enabled = true;
    }else if (connectState == CONNECTING || connectState == CLOSED || connectState == CLOSING){
        self.connectButton.enabled = true;
        self.reconnectButton.enabled = true;
        self.disconnectButton.enabled = false;
    }
    
    if(error){
        [self textLast:_textView text:[NSString stringWithFormat:@"连接状态：%@(%li)",error.localizedDescription,connectState]];
    }else{
        [self textLast:_textView text:[NSString stringWithFormat:@"连接状态：连接成功！(%li)",connectState]];
    }
    
}

/**
 *  EVS当前音量回调
 *  volume : 音量（1～100）
 */
-(void) evs:(EvsSDKForiOS *) evsSDK volume:(NSInteger) volume{
   
    [self textLast:_textView text:[NSString stringWithFormat:@"音量----%li",volume]];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.volumeSilder.value = volume/100.0f;
    });
}
-(void) evs:(EvsSDKForiOS *) evsSDK command:(NSString *)command{
    
    [self textLast:_textView text:command];
}

/**
 *  EVS录音分贝
 *  Command : 指令（json）
 */
-(void) evs:(EvsSDKForiOS *)evsSDK decibel:(float)decibel{
    
//    NSLog(@">_> decibel : %f",decibel);
}

/**
 *  EVS指令回调
 */
- (void)evs:(EvsSDKForiOS *)evsSDK requestMsg:(NSString *)requestMsg {
    [self textLast:_textView text:[NSString stringWithFormat:@"🔵 >>> %@",requestMsg]];
}


- (void)evs:(EvsSDKForiOS *)evsSDK responseMsg:(NSString *)responseMsg {
    [self textLast:_textView text:[NSString stringWithFormat:@"☑️ >>> %@",responseMsg]];
}

-(void) evs:(EvsSDKForiOS *)evsSDK progress:(float)progress{
//    NSLog(@"进度：%0.2f",progress);
}

-(void) evs:(EvsSDKForiOS *)evsSDK sessionStatus:(EVSSessionState)sessionStatus{
    switch (sessionStatus) {
        case IDLE:
            [self textLast:_textView text:[NSString stringWithFormat:@"-----------IDLE----------"]];
            break;
        case THINKING:
            [self textLast:_textView text:[NSString stringWithFormat:@"-----------THINKING----------"]];
            break;
        case SPEAKING:
            [self textLast:_textView text:[NSString stringWithFormat:@"-----------SPEAKING----------"]];
            break;
        case FINISHED:
            [self textLast:_textView text:[NSString stringWithFormat:@"-----------FINISHED----------"]];
            break;
        case LISTENING:
            [self textLast:_textView text:[NSString stringWithFormat:@"-----------LISTENING----------"]];
            break;
        default:
            break;
    }
}

/*******************键盘控件********************/
-(void) createKeyboardButton{
    self.connectButton.tag = 10086;
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [topView setBarStyle:UIBarStyleDefault];
    
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"收起键盘" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    
    [topView setItems:buttonsArray];
    
    [self.clientIdTextField setInputAccessoryView:topView];
    [self.deviceIdTextField setInputAccessoryView:topView];
    [self.ttsTextField setInputAccessoryView:topView];
    [self.textView setInputAccessoryView:topView];
}

-(void) dismissKeyBoard{
    [self.clientIdTextField resignFirstResponder];//收起键盘
    [self.deviceIdTextField resignFirstResponder];//收起键盘
    [self.ttsTextField resignFirstResponder];//收起键盘
    [self.textView resignFirstResponder];//收起键盘
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {//触摸事件中的触摸结束时会调用
    if (![self.clientIdTextField isExclusiveTouch] &&
        ![self.deviceIdTextField isExclusiveTouch] &&
        ![self.textView isExclusiveTouch] &&
        ![self.ttsTextField isExclusiveTouch] ){//判断点击是否在textfield和键盘以外
        [self dismissKeyBoard];
    }
}

#pragma IMAKitDelegate

/**
 * 蓝牙是否可用
 */
-(void) imaManager:(IMAManager *) imaManager isActive:(BOOL) isActive{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isActive) {
            [self textLast:_textView text:[NSString stringWithFormat:@"🔵 >>> %@",@"蓝牙可用"]];
        }else{
            [self textLast:_textView text:[NSString stringWithFormat:@"🔵 >>> %@",@"蓝牙不可用，请在控制中心打开蓝牙，并在设置->蓝牙->列表中匹配蓝牙设备"]];
        }
    });
}
/**
 * 回调返回蓝牙对象
 */
-(void) imaManager:(IMAManager *) imaManager peripheral:(CBPeripheral *)peripheral clientId:(NSString *) clientId{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (peripheral) {
            [self textLast:_textView text:[NSString stringWithFormat:@"🔵 搜索-> %@",@"蓝牙设备【%@】进行连接中...",peripheral.name]];
            [self.imaManager connect:peripheral];
        }
    });
}

/**
 * 是否连接成功
 */
-(void) imaManager:(IMAManager *) imaManager peripheral:(CBPeripheral *)peripheral isConnect:(BOOL) isConnect error:(NSError *) error{
    dispatch_async(dispatch_get_main_queue(), ^{
        [imaManager stopScan];
        if (isActive) {
            [self textLast:_textView text:[NSString stringWithFormat:@"🔵 >>> %@",@"蓝牙设备【%@】连接成功...",peripheral.name]];
        }else{
            [self textLast:_textView text:[NSString stringWithFormat:@"🔵 >>> %@",@"蓝牙设备【%@】连接失败，%@...",peripheral.name,error.localizedDescription]];
        }
    });
}

/**
 *  连接后返回设备信息
 */
-(void) onGetDeviceInfomation:(NSString *) deviceId clientId:(NSString *) clientId{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self textLast:_textView text:[NSString stringWithFormat:@"🔵 >>> %@",@"获取蓝牙设备clientId:%@ , deviceId:%@",clientId,deviceId]];
    });
}
/**
 * 版本是否可用
 */
-(void) onVersionVerify:(BOOL) isVersionExchange{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isVersionExchange) {
            [self textLast:_textView text:[NSString stringWithFormat:@"🔵 >>> %@",@"蓝牙设备版本可用"]];
        }else{
            [self textLast:_textView text:[NSString stringWithFormat:@"🔵 >>> %@",@"蓝牙设备版本不可用"]];
        }
    });
}

/**
*  配对成功
*/
-(void) onPairSuccess{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self textLast:_textView text:[NSString stringWithFormat:@"🔵 >>> %@",@"已成功匹配蓝牙设备"]];
    });
}
/**
*  配对失败
*/
-(void) onPairFail:(int)statusCode msg:(NSString *)msg{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self textLast:_textView text:[NSString stringWithFormat:@"🔵 >>> %@",@"匹配蓝牙设备失败，%@(%i),请在设置->蓝牙->列表中匹配蓝牙设备",msg,statusCode]];
    });
}

/**
 *  开始录音回调
 */
-(void) onStartSpeech{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self textLast:_textView text:[NSString stringWithFormat:@"🔵 >>> %@",@"蓝牙开始录音"]];
        [self.evsSDK tap];
    });
}

/**
 *  结束录音回调
 */
-(void) onStopSpeech{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self textLast:_textView text:[NSString stringWithFormat:@"🔵 >>> %@",@"蓝牙结束录音"]];
        [self.evsSDK end];
    });
}

/**
* 音频数据处理
* @param data
* @param length
*/
-(void)onAudioData:(NSData *) data length:(int) length{
    NSLog(@"[*]音频输入流线程 onAudioData:: - length(%i) - %@",length,[NSThread currentThread]);
    [self.evsSDK sendData:data];
}
@end
