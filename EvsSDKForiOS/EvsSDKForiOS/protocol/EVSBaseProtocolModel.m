//
//  EVSBaseProtocolModel.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/31.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSBaseProtocolModel.h"
#import "EVSHeader.h"
@implementation EVSBaseProtocolModel
-(EVSHeaderProtocolModel *) iflyos_header{
    if (!_iflyos_header) {
        _iflyos_header = [[EVSHeaderProtocolModel alloc] init];
    }
    return _iflyos_header;
}

-(EVSContextProtocolModel *) iflyos_context{
    if (!_iflyos_context) {
        _iflyos_context = [[EVSContextProtocolModel alloc] init];
    }
    return _iflyos_context;
}

-(NSDictionary *) getJSON{
    NSDictionary *jsonDict = [self mj_keyValues];
    return jsonDict;
}
@end
