//
//  EVS+NSData.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/24.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVS+NSData.h"
#import "EVSHeader.h"
@implementation NSData(EVS_NSData)
-(NSDictionary *) JSONDataWithDictionary{
    if (self == nil) {
        return nil;
    }
    NSError * error;
    NSDictionary *dict = [NSJSONSerialization  JSONObjectWithData:self options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        EVSLog(@"json->dict error :%@",error);
        return nil;
    }
    
    if (dict){
        return dict;
    }
    return nil;
}
-(NSArray *) JSONDataWithArray{
    if (self == nil) {
        return nil;
    }
    NSError * error;
    NSArray *array = [NSJSONSerialization  JSONObjectWithData:self options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        EVSLog(@"json->dict error :%@",error);
        return nil;
    }
    
    if (array){
        return array;
    }
    return nil;
}

-(NSString *) JSONDataWithString{
    NSString *receiveStr = [[NSString alloc]initWithData:self encoding:NSUTF8StringEncoding];
    return receiveStr;
}

-(BOOL)saveAudioFile:(NSString *) fileName{
    NSString *audioPath = [NSString getDocumentAudioPath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp3", audioPath,[fileName stringByDeletingPathExtension]];
    BOOL isDir = TRUE;
    BOOL isDirExist = [[NSFileManager defaultManager] fileExistsAtPath:audioPath isDirectory:&isDir];
    if(!(isDirExist))
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    BOOL isSuccess = [self writeToFile:filePath atomically:YES];
    if (isSuccess) {
        return YES;
    }
    else{
        return NO;
    }
}

@end
