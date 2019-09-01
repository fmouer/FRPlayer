//
//  FRFFmpegCommon.m
//  FRPlayer
//
//  Created by huangzhimou on 2019/8/30.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import "FRFFmpegCommon.h"
#include "libavformat/avformat.h"

BOOL hasRegister = NO;

@implementation FRFFmpegCommon

+ (void)register_all {
    if (!hasRegister) {
        av_register_all();
        avcodec_register_all();
        hasRegister = YES;
    }
}

@end
