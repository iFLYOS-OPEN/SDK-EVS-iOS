//
//  EVSLocationManager.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/29.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSLocationManager.h"
#import "EVSHeader.h"
@implementation EVSLocationManager
/**
 *  单例
 */
+(instancetype) shareInstance{
    static EVSLocationManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

//获取经伟度
-(void)getLocation{
    //判断定位功能是否打开
    if ([CLLocationManager locationServicesEnabled]) {
        EVSLog(@"start get location...");
        locationmanager = [[CLLocationManager alloc]init];
        locationmanager.delegate = self;
        [locationmanager requestAlwaysAuthorization];
        [locationmanager requestWhenInUseAuthorization];
        
        //设置寻址精度
        locationmanager.desiredAccuracy = kCLLocationAccuracyBest;
        locationmanager.distanceFilter = 5.0;
        [locationmanager startUpdatingLocation];
    }
}

#pragma mark CoreLocation delegate (定位失败)
//定位失败后调用此代理方法
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIViewController *topController = [EVSApplication presentingVC];
    //设置提示提醒用户打开定位服务
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"允许定位提示" message:@"请在设置中打开定位" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"打开定位" style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [topController presentViewController:alert animated:YES completion:nil];
}

#pragma mark 定位成功后则执行此代理方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [locationmanager stopUpdatingHeading];
    //旧址
    CLLocation *currentLocation = [locations lastObject];
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    //打印当前的经度与纬度
    EVSLog(@">>>%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    NSDictionary *locationDict = @{@"latitude":[NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude],@"longitude":[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude]};
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    [[EVSSqliteManager shareInstance] update:locationDict device_id:deviceId tableName:HEADER_TABLE_NAME];
    [locationmanager stopUpdatingLocation];
//    //反地理编码
//    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        if (placemarks.count > 0) {
//            CLPlacemark *placeMark = placemarks[0];
//
//            /*看需求定义一个全局变量来接收赋值*/
//            EVSLog(@"----%@",placeMark.country);//当前国家
//            EVSLog(@"%@",placeMark.locality);//当前的城市
//            EVSLog(@"%@",placeMark.subLocality);//当前的位置
//            EVSLog(@"%@",placeMark.thoroughfare);//当前街道
//            EVSLog(@"%@",placeMark.name);//具体地址
//
//        }
//    }];
    
}

@end
