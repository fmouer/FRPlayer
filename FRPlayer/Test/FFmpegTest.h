//
//  FFmpegTest.h
//  Dream_20171122_FFmpeg_Video_Decode
//
//  Created by Dream on 2017/11/22.
//  Copyright © 2017年 Tz. All rights reserved.
//

#import <Foundation/Foundation.h>
//导入头文件
//核心库
#include "libavcodec/avcodec.h"
//封装格式处理库
#include "libavformat/avformat.h"
//工具库
#include "libavutil/imgutils.h"
//视频像素数据格式库
#include "libswscale/swscale.h"

@interface FFmpegTest : NSObject

//视频解码
+(void) ffmepgVideoDecode:(NSString*)inFilePath outFilePath:(NSString*)outFilePath;

@end
