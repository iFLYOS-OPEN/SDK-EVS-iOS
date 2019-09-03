//
//  EVS+EVSWebscoketManager.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/31.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVS+EVSWebscoketManager.h"
#import "EVSHeader.h"
#import "EVSRequestHeader.h"

@implementation EVSWebscoketManager(EVS_EVSWebscoketManagerCategory)
-(void) lastResponseProcessor:(EVSResponseModel *) responseModel{
    if (responseModel) {
        NSArray *responses = responseModel.iflyos_responses;
        for (EVSResponseItemModel *payloadItem in responses) {
            AudioOutputModel *model = [[AudioOutputModel alloc] init];
            model.offset = payloadItem.payload.offset;
            model.resource_id = payloadItem.payload.resource_id;
            model.url = payloadItem.payload.url;
            model.type = payloadItem.payload.type;
            model.behavior = payloadItem.payload.behavior;
            model.metadata.text = payloadItem.payload.metadata.text;
            model.metadata.title = payloadItem.payload.metadata.title;
            model.metadata.album = payloadItem.payload.metadata.album;
            model.metadata.duration = payloadItem.payload.metadata.duration;
            
            //根据 响应header
            NSString *headerName = payloadItem.header.name;
            if ([headerName isEqualToString:recognizer_stop_capture]) {
                //结束录音
                EVSLog(@"****************** recognizer.stop_capture ******************");
                [self sendStr:COMMAND_END];
                [[AudioInput sharedAudioManager] stop];
            }else if ([headerName isEqualToString:recognizer_expect_reply]) {
                EVSLog(@"****************** recognizer.expect_reply ******************");
                //追问
                NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
                if (deviceId && payloadItem.payload.reply_key) {
                    [[EVSSqliteManager shareInstance] update:@{@"reply_key":payloadItem.payload.reply_key} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
                }else{
                    [[EVSSqliteManager shareInstance] update:@{@"reply_key":@""} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
                }
            }else if ([headerName isEqualToString:audio_player_audio_out]) {
                EVSLog(@"****************** audio_player.audio_out ******************");
                /****************播放器状态*******************/
                if ([payloadItem.payload.type isEqualToString:@"PLAYBACK"]){
                    model.focusStatus = context_channel;
                    NSString *control = payloadItem.payload.control;//播放，暂停，继续播放
                    NSString *behavior = payloadItem.payload.behavior;//播放方式，立刻/延后
                    NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
                    
                    
                    /****************播放方式*******************/
                    if (!model.url||[model.url isEqualToString:@""]){
                        return;
                    }
                    if ([payloadItem.payload.behavior isEqualToString:@"UPCOMING"]) {
                        //延后播放（UPCOMING,再次收到时就清理之前队列的内容）
                        [[AudioOutputQueue shareInstance] clearUpcomingQueue];
                        [[AudioOutputQueue shareInstance] addAudioUpcomingQueue:model];
                    }else{
                        //立刻播放（IMMEDIATELY）
                        [[AudioOutputQueue shareInstance] addAudioQueue:model];
                    }
                }

            }else if([headerName isEqualToString:audio_player_audio_out_tts]){
                EVSLog(@"****************** audio_player.audio_out.tts ******************");

            }else if ([headerName isEqualToString:speaker_set_volume]) {
                EVSLog(@"****************** speaker.set_volume ******************");
                float volume = payloadItem.payload.volume;
                NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
                [[EVSSqliteManager shareInstance] update:@{@"speaker_volume":@(volume)} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
                [[EVSApplication shareInstance] setVolume:volume];
                [[AudioOutputQueue shareInstance] playQueue];
            }else if ([headerName isEqualToString:system_ping]) {
                EVSLog(@"****************** system.ping ******************");
                long timestamp = payloadItem.payload.timestamp;
                NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
                [[EVSSqliteManager shareInstance] update:@{@"timestamp":@(timestamp)} device_id:deviceId tableName:SYSTEM_TABLE_NAME];
            }else if ([headerName isEqualToString:system_error]) {
                EVSLog(@"****************** system.error ******************");
                [self sendStr:COMMAND_END];
                [[AudioInput sharedAudioManager] stop];
            }else if ([headerName isEqualToString:recognizer_intermediate_text]) {
                EVSLog(@"****************** recognizer.intermediate_text ******************");
                
            }
        }
    }
}

/**
 *  播放器信息同步（audio_player.playback.progress_sync）
 */
-(void) audioPlayerProgressSync:(EVSResponseItemModel *)payloadItem{
    EVSAudioPlayerPlaybackProgressSync *progressSync = [[EVSAudioPlayerPlaybackProgressSync alloc] init];
    progressSync.iflyos_request.payload.type = @"STARTED";
    progressSync.iflyos_request.payload.resource_id = payloadItem.payload.resource_id;
    progressSync.iflyos_request.payload.offset = payloadItem.payload.offset;
    
}

/**
 *  清理追问
 */
-(void) clearReplyKey{
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    [[EVSSqliteManager shareInstance] update:@{@"reply_key":@""} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
}
@end
