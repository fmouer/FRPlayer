//
//  FRMediaMeuxer.h
//  FRPlayer
//
//  Created by huangzhimou on 2019/8/14.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FRMediaMeuxer : NSObject

@property (nonatomic, assign) float rate;

- (void)mediaMeuxerVideoPath:(NSString *)videoPath audioPath:(NSString *)audioPath outPath:(NSString *)outPath;

//+ (void)inputPath1:(NSString *)inputPath inputPath2:(NSString *)inputPath2 outPath:(NSString *)outPath;

@end

NS_ASSUME_NONNULL_END
