//
//  FRMediaMeuxer.m
//  FRPlayer
//
//  Created by huangzhimou on 2019/8/14.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import "FRMediaMeuxer.h"
#include <stdio.h>
#import "FRFFmpegCommon.h"

#define __STDC_CONSTANT_MACROS

#include "libavformat/avformat.h"

@interface FRMediaMeuxer ()
{
    AVOutputFormat *outFormat;
    
    AVFormatContext *inputVideoContext;
    AVFormatContext *inputAudioContext;
    
    AVFormatContext *meuxerOutContext;

    int videoStreamindex_v;
    int videoStreamindex_out;
    int audioStreamindex_a;
    int audioStreamindex_out;
 
    int frame_index;
    
    int64_t currentVideoPts;
    int64_t currentAudioPts;
}


@end

@implementation FRMediaMeuxer

- (void)openInputContextVideoPath:(NSString *)videoPath audioPath:(NSString *)audioPath {
    const char *in_filename_v = [videoPath UTF8String];
    const char *in_filename_a = [audioPath UTF8String];
    
    //Input
    if (avformat_open_input(&inputVideoContext, in_filename_v, 0, 0) < 0) {
        NSLog(@"Could not open input file.");
    }
    
    // 检查是否有流数据
    if (avformat_find_stream_info(inputVideoContext, 0) < 0) {
        NSLog( @"Failed to retrieve input stream information");
        
    }
    
    if (avformat_open_input(&inputAudioContext, in_filename_a, 0, 0) < 0) {
        printf( "Could not open input file.");
    }
    
    // 检查是否有流数据
    if (avformat_find_stream_info(inputAudioContext, 0) < 0) {
        printf( "Failed to retrieve input stream information");
    }
    
}

- (void)createMeuxerOutContext:(NSString *)outPath {
    const char *out_filename = [outPath UTF8String];//Output file URL

    //Output
    avformat_alloc_output_context2(&meuxerOutContext, NULL, NULL, out_filename);
    if (!meuxerOutContext) {
        printf( "Could not create output context\n");
//        ret = AVERROR_UNKNOWN;
//        goto end;
    }
    outFormat = meuxerOutContext->oformat;
    
    for (int i = 0; i < inputVideoContext->nb_streams; i++) {
        //Create output AVStream according to input AVStream
        if(inputVideoContext->streams[i]->codecpar->codec_type==AVMEDIA_TYPE_VIDEO){
            AVStream *in_stream = inputVideoContext->streams[i];
            
            //            AVCodec *codec = avcodec_find_encoder(ifmt_ctx_v->video_codec_id);//音频为audio_codec
            
            AVStream *out_stream = avformat_new_stream(meuxerOutContext, NULL);
            videoStreamindex_v = i;
            if (!out_stream) {
                printf( "Failed allocating output stream\n");
//                ret = AVERROR_UNKNOWN;
//                goto end;
            }
            videoStreamindex_out = out_stream->index;
            //Copy the settings of AVCodecContext
            if (avcodec_parameters_copy(out_stream->codecpar, in_stream->codecpar) < 0) {
                printf( "Failed to copy context from input to output stream codec context\n");
//                goto end;
            }
            
            AVDictionaryEntry *rotate_tag = av_dict_get(in_stream->metadata, "rotate", NULL, 0);
            if (rotate_tag) {
                int ret = av_dict_set(&out_stream->metadata,"rotate", rotate_tag->value,0); //设置旋转角度
                if (ret < 0) {
                    printf("fail set metadata");
                }
            }
            
            out_stream->codecpar->codec_tag = 0;
            if (meuxerOutContext->oformat->flags & AVFMT_GLOBALHEADER)
                out_stream->codec->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;
            break;
        }
    }
    
    for (int i = 0; i < inputAudioContext->nb_streams; i++) {
        //Create output AVStream according to input AVStream
        if(inputAudioContext->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO){
            AVStream *in_stream = inputAudioContext->streams[i];
            AVStream *out_stream = avformat_new_stream(meuxerOutContext, NULL);
            audioStreamindex_a = i;
            if (!out_stream) {
                printf( "Failed allocating output stream\n");
//                ret = AVERROR_UNKNOWN;
//                goto end;
            }
            audioStreamindex_out = out_stream->index;
            //Copy the settings of AVCodecContext
            if (avcodec_parameters_copy(out_stream->codecpar, in_stream->codecpar) < 0) {
                printf( "Failed to copy context from input to output stream codec context\n");
//                goto end;
            }
            out_stream->codec->codec_tag = 0;
            if (meuxerOutContext->oformat->flags & AVFMT_GLOBALHEADER)
                out_stream->codec->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;
            
            break;
        }
    }
    
    printf("==========Output Information==========\n");
    av_dump_format(meuxerOutContext, 0, out_filename, 1);
    printf("======================================\n");
    
    //Open output file
    if (!(meuxerOutContext->flags & AVFMT_NOFILE)) {
        if (avio_open(&meuxerOutContext->pb, out_filename, AVIO_FLAG_WRITE) < 0) {
            printf( "Could not open output file '%s'", out_filename);
            
        }
    }
}

- (void)meuxerWriteFile {
    
    //Write file header
    if (avformat_write_header(meuxerOutContext, NULL) < 0) {
        printf( "Error occurred when opening output file\n");
//        goto end;
    }
    
    
//    //FIX
#if USE_H264BSF
    AVBitStreamFilterContext* h264bsfc =  av_bitstream_filter_init("h264_mp4toannexb");
#endif
#if USE_AACBSF
    AVBitStreamFilterContext* aacbsfc =  av_bitstream_filter_init("aac_adtstoasc");
#endif
    
    AVPacket pkt;

    while (1) {
        AVFormatContext *ifmt_ctx;
        int stream_index=0;
        AVStream *in_stream, *out_stream;
        
        //Get an AVPacket
        if(av_compare_ts(currentVideoPts, inputVideoContext->streams[videoStreamindex_v]->time_base, currentAudioPts, inputAudioContext->streams[audioStreamindex_a]->time_base) <= 0){
            
            ifmt_ctx = inputVideoContext;
            stream_index = videoStreamindex_out;
            
            if(av_read_frame(ifmt_ctx, &pkt) >= 0){
                do{
                    in_stream  = ifmt_ctx->streams[pkt.stream_index];
                    out_stream = meuxerOutContext->streams[stream_index];
                    
                    if(pkt.stream_index == videoStreamindex_v){
                        //FIX£∫No PTS (Example: Raw H.264)
                        //Simple Write PTS
                        if(pkt.pts==AV_NOPTS_VALUE){
                            //Write PTS
                            AVRational time_base1=in_stream->time_base;
                            //Duration between 2 frames (us)
                            int64_t calc_duration=(double)AV_TIME_BASE/av_q2d(in_stream->r_frame_rate);
                            //Parameters
                            pkt.pts=(double)(frame_index*calc_duration)/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            pkt.dts=pkt.pts;
                            pkt.duration=(double)calc_duration/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            frame_index++;
                        } else {
//                            pkt.pts /= 2;
//                            pkt.dts /= 2;
                        }
                        NSLog(@"视频帧 index ：%d", frame_index);
                        currentVideoPts = pkt.pts;
                        break;
                    }
                }while(av_read_frame(ifmt_ctx, &pkt) >= 0);
            }else{
                break;
            }
        }else{
            ifmt_ctx = inputAudioContext;
            stream_index = audioStreamindex_out;
            if(av_read_frame(ifmt_ctx, &pkt) >= 0){
                do{
                    in_stream  = ifmt_ctx->streams[pkt.stream_index];
                    out_stream = meuxerOutContext->streams[stream_index];
                    
                    if(pkt.stream_index == audioStreamindex_a){
                        
                        //FIX£∫No PTS
                        //Simple Write PTS
                        if(pkt.pts==AV_NOPTS_VALUE){
                            //Write PTS
                            AVRational time_base1=in_stream->time_base;
                            //Duration between 2 frames (us)
                            int64_t calc_duration=(double)AV_TIME_BASE/av_q2d(in_stream->r_frame_rate);
                            //Parameters
                            pkt.pts= (double)(frame_index*calc_duration)/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            pkt.dts= pkt.pts;
                            
                            pkt.duration=(double)calc_duration/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            frame_index++;
                        } else {
                            //                            pkt.ate
                        }
                        currentAudioPts = pkt.pts;
                        
                        NSLog(@"音频帧 index ：%d", frame_index);
                        
                        break;
                    }
                }while(av_read_frame(ifmt_ctx, &pkt) >= 0);
            }else{
                break;
            }
            
        }
        
        //FIX:Bitstream Filter
#if USE_H264BSF
        av_bitstream_filter_filter(h264bsfc, in_stream->codec, NULL, &pkt.data, &pkt.size, pkt.data, pkt.size, 0);
#endif
#if USE_AACBSF
        av_bitstream_filter_filter(aacbsfc, out_stream->codec, NULL, &pkt.data, &pkt.size, pkt.data, pkt.size, 0);
#endif
        
        
        //Convert PTS/DTS
        pkt.pts = av_rescale_q_rnd(pkt.pts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
        pkt.dts = av_rescale_q_rnd(pkt.dts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
        pkt.duration = av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
        pkt.pos = -1;
        pkt.stream_index = stream_index;
        
        printf("Write 1 Packet. size:%5d\tpts:%lld\n",pkt.size,pkt.pts);
        //Write
        if (av_interleaved_write_frame(meuxerOutContext, &pkt) < 0) {
            printf( "Error muxing packet\n");
            break;
        }
        av_packet_unref(&pkt);
        
    }
    //Write file trailer
    av_write_trailer(meuxerOutContext);
    
}

- (void)closeFile {
//#if USE_H264BSF
//    av_bitstream_filter_close(h264bsfc);
//#endif
//#if USE_AACBSF
//    av_bitstream_filter_close(aacbsfc);
//#endif
    
//end:
    avformat_close_input(&inputVideoContext);
    avformat_close_input(&inputAudioContext);
    /* close output */
    if (meuxerOutContext && !(outFormat->flags & AVFMT_NOFILE))
        avio_close(meuxerOutContext->pb);
    avformat_free_context(meuxerOutContext);
}

- (void)mediaMeuxerVideoPath:(NSString *)videoPath audioPath:(NSString *)audioPath outPath:(NSString *)outPath {
    [FRFFmpegCommon register_all];
    
    [self openInputContextVideoPath:videoPath audioPath:audioPath];
    [self createMeuxerOutContext:outPath];
    [self meuxerWriteFile];
    [self closeFile];
}






/*
+ (void)inputPath1:(NSString *)inputPath inputPath2:(NSString *)inputPath2 outPath:(NSString *)outPath {
    NSLog(@"inputPath video : %@", inputPath);
    NSLog(@"inputPath audio : %@", inputPath2);
    NSLog(@"outPath : %@", outPath);

    AVOutputFormat *ofmt = NULL;
    //Input AVFormatContext and Output AVFormatContext
    AVFormatContext *ifmt_ctx_v = NULL, *ifmt_ctx_a = NULL,*ofmt_ctx = NULL;
    AVPacket pkt;
    int ret, i;
    int videoindex_v=-1,videoindex_out=-1;
    int audioindex_a=-1,audioindex_out=-1;
    int frame_index=0;
    int64_t cur_pts_v=0,cur_pts_a=0;
    
    const char *in_filename_v = [inputPath UTF8String];
    const char *in_filename_a = [inputPath2 UTF8String];
    
    const char *out_filename = [outPath UTF8String];//Output file URL
    av_register_all();
    //Input
    if ((ret = avformat_open_input(&ifmt_ctx_v, in_filename_v, 0, 0)) < 0) {
        printf( "Could not open input file.");
        goto end;
    }
    if ((ret = avformat_find_stream_info(ifmt_ctx_v, 0)) < 0) {
        printf( "Failed to retrieve input stream information");
        goto end;
    }
    
    if ((ret = avformat_open_input(&ifmt_ctx_a, in_filename_a, 0, 0)) < 0) {
        printf( "Could not open input file.");
        goto end;
    }
    if ((ret = avformat_find_stream_info(ifmt_ctx_a, 0)) < 0) {
        printf( "Failed to retrieve input stream information");
        goto end;
    }
    printf("===========Input Information==========\n");
    av_dump_format(ifmt_ctx_v, 0, in_filename_v, 0);
    av_dump_format(ifmt_ctx_a, 0, in_filename_a, 0);
    printf("======================================\n");
    //Output
    avformat_alloc_output_context2(&ofmt_ctx, NULL, NULL, out_filename);
    if (!ofmt_ctx) {
        printf( "Could not create output context\n");
        ret = AVERROR_UNKNOWN;
        goto end;
    }
    ofmt = ofmt_ctx->oformat;
    
    for (i = 0; i < ifmt_ctx_v->nb_streams; i++) {
        //Create output AVStream according to input AVStream
        if(ifmt_ctx_v->streams[i]->codecpar->codec_type==AVMEDIA_TYPE_VIDEO){
            AVStream *in_stream = ifmt_ctx_v->streams[i];
            
//            AVCodec *codec = avcodec_find_encoder(ifmt_ctx_v->video_codec_id);//音频为audio_codec

            AVStream *out_stream = avformat_new_stream(ofmt_ctx, NULL);
            videoindex_v=i;
            if (!out_stream) {
                printf( "Failed allocating output stream\n");
                ret = AVERROR_UNKNOWN;
                goto end;
            }
            videoindex_out=out_stream->index;
            //Copy the settings of AVCodecContext
            if (avcodec_parameters_copy(out_stream->codecpar, in_stream->codecpar) < 0) {
                printf( "Failed to copy context from input to output stream codec context\n");
                goto end;
            }
            
            AVDictionaryEntry *rotate_tag = av_dict_get(in_stream->metadata, "rotate", NULL, 0);
            if (rotate_tag) {
                ret = av_dict_set(&out_stream->metadata,"rotate", rotate_tag->value,0); //设置旋转角度
                if (ret < 0) {
                    printf("fail set metadata");
                }
            }
            
            out_stream->codecpar->codec_tag = 0;
            if (ofmt_ctx->oformat->flags & AVFMT_GLOBALHEADER)
                out_stream->codec->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;
            break;
        }
    }
    
    for (i = 0; i < ifmt_ctx_a->nb_streams; i++) {
        //Create output AVStream according to input AVStream
        if(ifmt_ctx_a->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO){
            AVStream *in_stream = ifmt_ctx_a->streams[i];
            AVStream *out_stream = avformat_new_stream(ofmt_ctx, in_stream->codec->codec);
            audioindex_a=i;
            if (!out_stream) {
                printf( "Failed allocating output stream\n");
                ret = AVERROR_UNKNOWN;
                goto end;
            }
            audioindex_out=out_stream->index;
            //Copy the settings of AVCodecContext
            if (avcodec_parameters_copy(out_stream->codecpar, in_stream->codecpar) < 0) {
                printf( "Failed to copy context from input to output stream codec context\n");
                goto end;
            }
            out_stream->codec->codec_tag = 0;
            if (ofmt_ctx->oformat->flags & AVFMT_GLOBALHEADER)
                out_stream->codec->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;
            
            break;
        }
    }
    
    printf("==========Output Information==========\n");
    av_dump_format(ofmt_ctx, 0, out_filename, 1);
    printf("======================================\n");
    //Open output file
    if (!(ofmt->flags & AVFMT_NOFILE)) {
        if (avio_open(&ofmt_ctx->pb, out_filename, AVIO_FLAG_WRITE) < 0) {
            printf( "Could not open output file '%s'", out_filename);
            goto end;
        }
    }
    //Write file header
    if (avformat_write_header(ofmt_ctx, NULL) < 0) {
        printf( "Error occurred when opening output file\n");
        goto end;
    }
    
    
    //FIX
#if USE_H264BSF
    AVBitStreamFilterContext* h264bsfc =  av_bitstream_filter_init("h264_mp4toannexb");
#endif
#if USE_AACBSF
    AVBitStreamFilterContext* aacbsfc =  av_bitstream_filter_init("aac_adtstoasc");
#endif
    
    while (1) {
        AVFormatContext *ifmt_ctx;
        int stream_index=0;
        AVStream *in_stream, *out_stream;
        
        //Get an AVPacket
        if(av_compare_ts(cur_pts_v,ifmt_ctx_v->streams[videoindex_v]->time_base,cur_pts_a,ifmt_ctx_a->streams[audioindex_a]->time_base) <= 0){
            ifmt_ctx=ifmt_ctx_v;
            stream_index=videoindex_out;
            
            if(av_read_frame(ifmt_ctx, &pkt) >= 0){
                do{
                    in_stream  = ifmt_ctx->streams[pkt.stream_index];
                    out_stream = ofmt_ctx->streams[stream_index];
                    
                    if(pkt.stream_index==videoindex_v){
                        //FIX£∫No PTS (Example: Raw H.264)
                        //Simple Write PTS
                        if(pkt.pts==AV_NOPTS_VALUE){
                            //Write PTS
                            AVRational time_base1=in_stream->time_base;
                            //Duration between 2 frames (us)
                            int64_t calc_duration=(double)AV_TIME_BASE/av_q2d(in_stream->r_frame_rate);
                            //Parameters
                            pkt.pts=(double)(frame_index*calc_duration)/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            pkt.dts=pkt.pts;
                            pkt.duration=(double)calc_duration/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            frame_index++;
                        } else {
                            pkt.pts /= 2;
                            pkt.dts /= 2;
                        }
                        NSLog(@"视频帧 index ：%d", frame_index);
                        cur_pts_v=pkt.pts;
                        break;
                    }
                }while(av_read_frame(ifmt_ctx, &pkt) >= 0);
            }else{
                break;
            }
        }else{
            ifmt_ctx=ifmt_ctx_a;
            stream_index=audioindex_out;
            if(av_read_frame(ifmt_ctx, &pkt) >= 0){
                do{
                    in_stream  = ifmt_ctx->streams[pkt.stream_index];
                    out_stream = ofmt_ctx->streams[stream_index];
                    
                    if(pkt.stream_index==audioindex_a){
                        
                        //FIX£∫No PTS
                        //Simple Write PTS
                        if(pkt.pts==AV_NOPTS_VALUE){
                            //Write PTS
                            AVRational time_base1=in_stream->time_base;
                            //Duration between 2 frames (us)
                            int64_t calc_duration=(double)AV_TIME_BASE/av_q2d(in_stream->r_frame_rate);
                            //Parameters
                            pkt.pts= (double)(frame_index*calc_duration)/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            pkt.dts= pkt.pts;
                            
                            pkt.duration=(double)calc_duration/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                            frame_index++;
                        } else {
//                            pkt.ate
                        }
                        cur_pts_a= pkt.pts;
                        
                        NSLog(@"音频帧 index ：%d", frame_index);

                        break;
                    }
                }while(av_read_frame(ifmt_ctx, &pkt) >= 0);
            }else{
                break;
            }
            
        }
        
        //FIX:Bitstream Filter
#if USE_H264BSF
        av_bitstream_filter_filter(h264bsfc, in_stream->codec, NULL, &pkt.data, &pkt.size, pkt.data, pkt.size, 0);
#endif
#if USE_AACBSF
        av_bitstream_filter_filter(aacbsfc, out_stream->codec, NULL, &pkt.data, &pkt.size, pkt.data, pkt.size, 0);
#endif
        
        
        //Convert PTS/DTS
        pkt.pts = av_rescale_q_rnd(pkt.pts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
        pkt.dts = av_rescale_q_rnd(pkt.dts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
        pkt.duration = av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
        pkt.pos = -1;
        pkt.stream_index=stream_index;
        
        printf("Write 1 Packet. size:%5d\tpts:%lld\n",pkt.size,pkt.pts);
        //Write
        if (av_interleaved_write_frame(ofmt_ctx, &pkt) < 0) {
            printf( "Error muxing packet\n");
            break;
        }
        av_packet_unref(&pkt);
        
    }
    //Write file trailer
    av_write_trailer(ofmt_ctx);
    
#if USE_H264BSF
    av_bitstream_filter_close(h264bsfc);
#endif
#if USE_AACBSF
    av_bitstream_filter_close(aacbsfc);
#endif
    
end:
    avformat_close_input(&ifmt_ctx_v);
    avformat_close_input(&ifmt_ctx_a);
    // close output
    if (ofmt_ctx && !(ofmt->flags & AVFMT_NOFILE))
        avio_close(ofmt_ctx->pb);
    avformat_free_context(ofmt_ctx);
    if (ret < 0 && ret != AVERROR_EOF) {
        printf( "Error occurred.\n");
    }
}
*/

@end

