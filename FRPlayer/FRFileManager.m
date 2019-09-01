//
//  FRFileManager.m
//  FRPlayer
//
//  Created by huangzhimou on 2019/6/21.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import "FRFileManager.h"
#import "FRVideoDetailModel.h"
#import <AVFoundation/AVFoundation.h>

@implementation FRFileManager

+ (NSString *)getVideoPathCache
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * videoCache = [[paths firstObject] stringByAppendingPathComponent:@"videos"];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:videoCache isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:videoCache withIntermediateDirectories:YES attributes:nil error:nil];
    };
//    NSLog(@"VideoPathCache Path : %@", videoCache);
    return videoCache;
}

+ (NSArray *)localVideoSource {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *getVideoPathCache = [self getVideoPathCache];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:getVideoPathCache error:nil];
    NSMutableArray *videoFiles = [NSMutableArray arrayWithCapacity:0];
    
    for (NSString *name in files) {
        NSString *path = [getVideoPathCache stringByAppendingPathComponent:name];
        if ([fileManager fileExistsAtPath:path]) {
            [videoFiles addObject:name];
            NSLog(@"videoFile : %@", path);
        }
    }
    
    NSString *local = [[NSBundle mainBundle] pathForResource:@"01" ofType:@"mp4"];
    
    [videoFiles addObject:local];
    
    return [videoFiles copy];
}

+ (NSArray <FRVideoDetailModel *>*)detailVideoArray {
    NSMutableArray *detailVideoArray = [NSMutableArray arrayWithCapacity:0];
    
    NSArray *localVideoSource = [self localVideoSource];
    NSString *getVideoPathCache = [self getVideoPathCache];

    for (NSString *fileName in  localVideoSource) {
        FRVideoDetailModel *detailModel = [[FRVideoDetailModel alloc] init];
        
        NSString *path = [getVideoPathCache stringByAppendingPathComponent:fileName];
        
        UIImage *image = [self thumbnailImageForVideo:[NSURL fileURLWithPath:path] atTime:0];
        if (!image) {
            NSLog(@"path ：%@，无法获取封面", path);
            continue;
        }
        detailModel.videoName = fileName;
        detailModel.thumbnailImage = image;
        detailModel.videoFilePath = path;
        [detailVideoArray addObject:detailModel];
    }
    
    return [detailVideoArray copy];
}

//videoURL:本地视频路径    time：用来控制视频播放的时间点图片截取
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
//    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}
@end
