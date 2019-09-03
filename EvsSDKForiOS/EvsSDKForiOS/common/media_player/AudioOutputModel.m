//
//  AudioOutputModel.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/1.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "AudioOutputModel.h"

@implementation AudioOutputModel
-(EVSResponsePayloadMetadataModel *) metadata{
    if (!_metadata) {
        _metadata = [[EVSResponsePayloadMetadataModel alloc] init];
    }
    return _metadata;
}
@end
