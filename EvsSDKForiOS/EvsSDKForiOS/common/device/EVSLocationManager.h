//
//  EVSLocationManager.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/29.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
NS_ASSUME_NONNULL_BEGIN

@interface EVSLocationManager : NSObject{
    CLLocationManager *locationmanager;//定位服务
}
/**
 *  单例
 */
+(instancetype) shareInstance;

//获取经伟度
-(void)getLocation;
@end

NS_ASSUME_NONNULL_END
