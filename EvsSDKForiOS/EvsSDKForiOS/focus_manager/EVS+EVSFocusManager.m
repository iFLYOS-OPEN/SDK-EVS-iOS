//
//  EVS+EVSFocusManager.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/14.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVS+EVSFocusManager.h"
#import "EVSHeader.h"
#import "EVSRequestHeader.h"
#define sound_effect @"sound_effect"
#define auth_error @"auth_error"
#define power_on @"power_on"
#define power_off @"power_off"
#define volume @"volume"
#define wake_up_0 @"wake_up_0"
#define network_error_retry @"network_error_retry"
#define network_error_wait @"network_error_wait"

@implementation EVSFocusManager(EVS_EVSFocusManager)

-(void) playPowerOn{
    AudioOutputModel *model = [[AudioOutputModel alloc] init];
    model.type = sound_effect;
    model.focusStatus = sound_effect_channel;
    model.focusLevel = 100;
    model.behavior = @"SERIAL";
    model.localFileName = power_on;
    model.localFileType = @"mp3";
    
    [[AudioOutput shareInstance] openURLWithSoundEffectsChannel:model];
}
-(void) playPowerOff{
    AudioOutputModel *model = [[AudioOutputModel alloc] init];
    model.type = sound_effect;
    model.focusStatus = sound_effect_channel;
    model.focusLevel = 100;
    model.behavior = @"SERIAL";
    model.localFileName = power_off;
    model.localFileType = @"mp3";
    
    [[AudioOutput shareInstance] openURLWithSoundEffectsChannel:model];
}
-(void) playNetworkErrorRetry{
    AudioOutputModel *model = [[AudioOutputModel alloc] init];
    model.type = sound_effect;
    model.focusStatus = sound_effect_channel;
    model.focusLevel = 100;
    model.behavior = @"SERIAL";
    model.localFileName = network_error_retry;
    model.localFileType = @"m4a";
    
    [[AudioOutput shareInstance] openURLWithSoundEffectsChannel:model];
}
-(void) playNetworkErrorWait{
    AudioOutputModel *model = [[AudioOutputModel alloc] init];
    model.type = sound_effect;
    model.focusStatus = sound_effect_channel;
    model.focusLevel = 100;
    model.behavior = @"SERIAL";
    model.localFileName = network_error_wait;
    model.localFileType = @"m4a";
    
    [[AudioOutput shareInstance] openURLWithSoundEffectsChannel:model];
}
-(void) playVolume{
    AudioOutputModel *model = [[AudioOutputModel alloc] init];
    model.type = sound_effect;
    model.focusStatus = sound_effect_channel;
    model.focusLevel = 100;
    model.behavior = @"SERIAL";
    model.localFileName = volume;
    model.localFileType = @"mp3";
    
    [[AudioOutput shareInstance] openURLWithSoundEffectsChannel:model];
}
-(void) wakeUp0{
    AudioOutputModel *model = [[AudioOutputModel alloc] init];
    model.type = sound_effect;
    model.focusStatus = sound_effect_channel;
    model.focusLevel = 100;
    model.behavior = @"SERIAL";
    model.localFileName = wake_up_0;
    model.localFileType = @"mp3";
    
    [[AudioOutput shareInstance] openURLWithSoundEffectsChannel:model];
}

-(void) authError{
    AudioOutputModel *model = [[AudioOutputModel alloc] init];
    model.type = sound_effect;
    model.focusStatus = sound_effect_channel;
    model.focusLevel = 100;
    model.behavior = @"SERIAL";
    model.localFileName = auth_error;
    model.localFileType = @"mp3";
    
    [[AudioOutput shareInstance] openURLWithSoundEffectsChannel:model];
}
@end
