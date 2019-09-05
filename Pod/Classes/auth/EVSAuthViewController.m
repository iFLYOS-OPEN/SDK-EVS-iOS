//
//  EVSAuthViewController.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/24.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSAuthViewController.h"
#import "EVSHeader.h"
#import "EVSAuthManager.h"
#import <WebKit/WebKit.h>
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
@interface EVSAuthViewController ()
@property(strong,nonatomic) WKWebView *webView;
//bridge框架
@property (strong,nonatomic) WebViewJavascriptBridge* bridge;
@end

@implementation EVSAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [WebViewJavascriptBridge enableLogging];
    NSString *allJs = [NSString createUserScript];
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:allJs injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
    if (self.webView.configuration.userContentController) {
        [self.webView.configuration.userContentController addUserScript:wkUScript];
    }else{
        WKUserContentController *userContentController = [[WKUserContentController alloc]init];
        //        [userContentController addScriptMessageHandler:self name:AUTH_SUCCESS];
        //        [userContentController addScriptMessageHandler:self name:AUTH_FAIL];
        
        [userContentController addUserScript:wkUScript];
        configuration.userContentController = userContentController;
        self.webView.configuration.userContentController = userContentController;
    }
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:configuration];
    [self.view addSubview:self.webView];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self setJavascriptInterface];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.authUrl]]];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_close"] style:UIBarButtonItemStylePlain target:self action:@selector(closePage)];
    self.navigationController.navigationBar.backIndicatorImage = [[UIImage alloc] init];//去除下横线
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];//去除下横线
    
}

-(void) dealloc{
    EVSLog(@"释放授权页");
}

/**
 * 网页加载完成时，如果读取到页面内带有形如
 * <meta name="head-color">#FFFFFF</meta>
 * 的标签时，将回调颜色
 */
-(void) updateHeaderColor:(NSString *) color{
    self.navigationController.navigationBar.barTintColor = [EVSColorUtils colorWithHexString:color];
}

/**
 * 网页加载完成时，将回调标题
 */
-(void) updateTitle:(NSString *) title{
    self.navigationItem.title = title;
}

-(void) onAuthSuccess{
    EVSLog(@"授权成功");
}

-(void) onAuthFailed{
    EVSLog(@"授权失败");
}

-(void) closePage{
    [self dismissViewControllerAnimated:YES completion:^{
        EVSLog(@"关闭授权页");
        [EVSAuthManager shareInstance].isStopLoop = YES;
    }];
}

#pragma delegate
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    decisionHandler(WKNavigationActionPolicyAllow);//允许跳转
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
}
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    EVSLog(@"网页开始加载");
    EVSLog(@"Page loading start:%@",self.authUrl);
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    EVSLog(@"Page loading finish");
    
    __weak typeof(self) weakSelf = self;
    [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if ([weakSelf respondsToSelector:@selector(updateTitle:)]) {
            EVSLog(@"updateTitle : %@",response);
            [weakSelf performSelector:@selector(updateTitle:) withObject:response];
        }
    }];
    
    NSString *js = [NSString stringWithFormat:@"document.getElementsByName(\"%@\")[0].content",@"head-color"];
    [webView evaluateJavaScript:js completionHandler:^(id result, NSError *error) {
        if (result) {
            NSString *colorStr=result;
            EVSLog(@"updateTitle : %@",colorStr);
            if ([weakSelf respondsToSelector:@selector(updateHeaderColor:)]) {
                [weakSelf performSelector:@selector(updateHeaderColor:) withObject:colorStr];
            }
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void) webViewAppear{
    [self.bridge callHandler:WEBVIEW_APPEAR data:nil];
    [self.webView evaluateJavaScript:WEBVIEW_APPEAR_OLD completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"-------》错误:%@",error);
        //当然在这个setTing()返回的数据可以是个字典的数据形式。
    }];
}

-(void) webViewDisappear{
    [self.bridge callHandler:WEBVIEW_DISAPPEAR data:nil];
    [self.webView evaluateJavaScript:WEBVIEW_APPEAR_OLD completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"-------》错误:%@",error);
        //当然在这个setTing()返回的数据可以是个字典的数据形式。
    }];
}

//设置javascript接口
-(void) setJavascriptInterface{
    
    if (self.bridge == nil) {
        self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView ];  //初始化调用
        [self.bridge setWebViewDelegate:self];
    }
    
    EVSLog(@"EVS webView register javascript..");
    //打开新页面
    __weak typeof(self) weakSelf = self;
    [self.bridge registerHandler:CLOSE_PAGE handler:^(id data, WVJBResponseCallback responseCallback) {
        //关闭页面
        if ([weakSelf respondsToSelector:@selector(closePage)]) {
            [weakSelf performSelector:@selector(closePage) withObject:nil];
        }
    }];
    
    [self.bridge registerHandler:RELOAD_OLD_PAGE handler:^(id data, WVJBResponseCallback responseCallback) {
        //刷新页面
        if ([weakSelf respondsToSelector:@selector(reloadOldPage)]) {
            [weakSelf performSelector:@selector(reloadOldPage) withObject:nil];
        }
    }];
    
    //拒绝
    [self.bridge registerHandler:REJECT_LOGIN handler:^(id data, WVJBResponseCallback responseCallback) {
        EVSLog(@"authrization failed...");
        if ([weakSelf respondsToSelector:@selector(closePage)]) {
            [weakSelf performSelector:@selector(closePage) withObject:nil];
        }
    }];
    
    //授权成功
    [self.bridge registerHandler:AUTH_SUCCESS handler:^(id data, WVJBResponseCallback responseCallback) {
        EVSLog(@"authrization success...");
        if ([weakSelf respondsToSelector:@selector(onAuthSuccess)]) {
            [weakSelf performSelector:@selector(onAuthSuccess)];
        }
    }];
    //授权失败
    [self.bridge registerHandler:AUTH_FAIL handler:^(id data, WVJBResponseCallback responseCallback) {
        EVSLog(@"authrization failed...");
        
        NSInteger type = [data[@"type"] integerValue];
        if (type == 0) {
            EVSLog(@"authrization reject...");
            if ([weakSelf respondsToSelector:@selector(onAuthReject)]) {
                [weakSelf performSelector:@selector(onAuthReject) withObject:nil];
            }
        }else if (type == 2){
            EVSLog(@"authrization fail...");
            if ([weakSelf respondsToSelector:@selector(onAuthFailed)]) {
                [weakSelf performSelector:@selector(onAuthFailed)];
            }
        }
    }];
}
@end
