//
//  FRMp4TransToMov.m
//  FRPlayer
//
//  Created by huangzhimou on 2019/6/24.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import "FRMp4TransToMov.h"
//导入头文件
//核心库
#include "libavcodec/avcodec.h"
//封装格式处理库
#include "libavformat/avformat.h"

#include "libavutil/avutil.h"
#include "libavutil/mathematics.h"

//视频像素数据格式库
#include "libswscale/swscale.h"

/*
 #pragma comment(lib,"avformat.lib")
 #pragma comment(lib,"avcodec.lib")
 #pragma comment(lib,"avutil.lib")

 */

@implementation FRMp4TransToMov

+(void) ffmepgVideoTrans:(NSString*)inFilePath outFilePath:(NSString*)outFilePath {
    const char *infile = [inFilePath UTF8String];
    const char *outfile = [outFilePath UTF8String];
//    char outfile[] = "test.mov";
    //muxer,demuters
    av_register_all();
    
    //1 open input file
    AVFormatContext *ic = NULL;
    avformat_open_input(&ic, [inFilePath UTF8String], 0,0);
    if (!ic)
    {
        NSLog(@"avformat_open_input failed!");
        
        return;
    }
    
    ///2 create output context
    AVFormatContext *oc = NULL;
    avformat_alloc_output_context2(&oc, NULL, NULL, [outFilePath UTF8String]);
    if (!oc)
    {
        NSLog(@"avformat_alloc_output_context2 %@ failed", outFilePath);
        return ;
    }
    
    ///3 add the stream
//    AVStream *videoStream = avformat_new_stream(oc, NULL);
//    AVStream *audioStream = avformat_new_stream(oc, NULL);
//
//
//
//    ///4 copy para 参数配置
//    // streams[0] 是视频信息
//    int videoIndex = av_find_best_stream(ic, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
//
//    avcodec_parameters_copy(videoStream->codecpar, ic->streams[videoIndex]->codecpar);
//
//    int audioIndex = av_find_best_stream(ic, AVMEDIA_TYPE_AUDIO, -1, -1, NULL, 0);
//
//    avcodec_parameters_copy(audioStream->codecpar, ic->streams[audioIndex]->codecpar);
//
//    videoStream->codecpar->codec_tag = 0;
//    audioStream->codecpar->codec_tag = 0;
    
    for (int i = 0; i < ic->nb_streams; i++) {
        AVStream *out_stream;
        AVStream *in_stream = ic->streams[i];
        AVCodecParameters *in_codecpar = in_stream->codecpar;
        
        if (in_codecpar->codec_type != AVMEDIA_TYPE_AUDIO &&
            in_codecpar->codec_type != AVMEDIA_TYPE_VIDEO &&
            in_codecpar->codec_type != AVMEDIA_TYPE_SUBTITLE) {
            continue;
        }
        out_stream = avformat_new_stream(oc, NULL);
        int ret = avcodec_parameters_copy(out_stream->codecpar, in_codecpar);
        if (ret < 0) {
            NSLog(@"fail copy parameters");
        }
        out_stream->codecpar->codec_tag = 0;

        if (in_codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            AVDictionaryEntry *rotate_tag = av_dict_get(in_stream->metadata, "rotate", NULL, 0);
            if (rotate_tag) {
                ret = av_dict_set(&out_stream->metadata,"rotate", rotate_tag->value,0); //设置旋转角度
                if (ret < 0) {
                    NSLog(@"dddd");
                }
            }

        }

    }
    

    
    av_dump_format(ic, 0, infile, 0);
    NSLog(@"================================================");
    av_dump_format(oc, 0, outfile, 1);
    
//    AVStream *inVideoStream = ic->streams[0];
    
    //https://blog.csdn.net/veilling/article/details/52421930 视频角度旋转
    
//    AVDictionaryEntry *rotate_tag = av_dict_get(inVideoStream->metadata, "rotate", NULL, 0);
//
//    if (rotate_tag) {
//        int ret1 = av_dict_set(&videoStream->metadata,"rotate", rotate_tag->value,0); //设置旋转角度
//
//        if(ret1 < 0)
//        {
//            NSLog(@"=========NO=====set rotate fail != ");
//        } else {
//            NSLog(@"=========yes=====set rotate success != ");
//        }
//    }
    
    ///5 open out file io,write head
    int ret = avio_open(&oc->pb, outfile, AVIO_FLAG_WRITE);
    if (ret < 0)
    {
        NSLog(@"avio open failed!");
        return ;
    }
    ret = avformat_write_header(oc, NULL);
    if (ret < 0)
    {
        NSLog(@"avformat_write_header failed!");
        return;
    }
    
    AVPacket pkt;
    int current_index = 0;

    for (;;)
    {
        int re = av_read_frame(ic, &pkt);
        if (re < 0)
        break;
        pkt.pts = av_rescale_q_rnd(pkt.pts,
                                   ic->streams[pkt.stream_index]->time_base,
                                   oc->streams[pkt.stream_index]->time_base,
                                   (enum AVRounding)(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX)
                                   );
        pkt.dts = av_rescale_q_rnd(pkt.dts,
                                   ic->streams[pkt.stream_index]->time_base,
                                   oc->streams[pkt.stream_index]->time_base,
                                   (enum AVRounding)(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX)
                                   );
        // pos 是 pkt 在文件索引当中的位置，因为封装格式不一样，header 大小不一样，
        // 则picket的位置有可能不一样的，所以不能用输入的pos
        // 设置pos = -1，不采用之前pkt的位置，它内部重算
        pkt.pos = -1;
        pkt.duration = av_rescale_q_rnd(pkt.duration,
                                        ic->streams[pkt.stream_index]->time_base,
                                        oc->streams[pkt.stream_index]->time_base,
                                        (enum AVRounding)(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX)
                                        );
        
        av_write_frame(oc, &pkt);
        av_packet_unref(&pkt);
        
        NSLog(@"stream_index is %d", ++current_index);
    }
    
    av_write_trailer(oc);
    avio_close(oc->pb);
    NSLog(@"================end================");
    
    
    
}
@end
