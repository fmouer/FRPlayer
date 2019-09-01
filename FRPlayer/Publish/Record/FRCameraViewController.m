//
//  FRCameraViewController.m
//  FRPlayer
//
//  Created by huangzhimou on 2019/6/20.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import "FRCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CCMotionManager.h"
#import "CCMovieManager.h"
#import "FRFileManager.h"

@interface FRCameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate,   AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession; //

@property (nonatomic, strong) AVCaptureDeviceInput *caputreDeviceInput; // 设备输入
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput; // 设备输出

@property (nonatomic, strong) AVCaptureVideoPreviewLayer  *previewLayer; // 设备视频预览

@property (strong,nonatomic) AVCaptureMovieFileOutput * captureMovieFileOutput;//视频输出流

@property (nonatomic, strong) AVCaptureConnection *movieOutConnection;
@property (nonatomic, strong) AVCaptureConnection *audioConnection;

@property (nonatomic, strong) CCMotionManager *motionManager;
@property (nonatomic, strong) CCMovieManager *movieManager;


@end

@implementation FRCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.motionManager = [[CCMotionManager alloc] init];
    
    [self initialSession];
    
//    self.movieOutConnection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    CGRect frame = self.view.frame;
    frame.size = CGSizeMake(frame.size.width, frame.size.height);
    self.previewLayer.frame = frame;
}

#pragma mark - 开始运行
-(void)startRunning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.captureSession startRunning];
    });
}

#pragma mark - 停止运行
-(void)stopRunning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.captureSession stopRunning];
    });
}

//开始录制
- (void)startCapture
{
    if (self.isRecording) {
        return;
    }
    NSString *defultPath = [FRFileManager getVideoPathCache];
    NSString *outputFielPath = [ defultPath stringByAppendingPathComponent:[self getVideoNameWithType:@"mp4"]];
    
    self.isRecording = YES;
    self.movieManager.currentDevice = self.caputreDeviceInput.device;
    self.movieManager.currentOrientation = [self currentVideoOrientation];
    
    [self.movieManager startMovieOutPath:outputFielPath error:^(NSError * _Nonnull error) {
        ;
    }];
    
    /*
    if(self.captureMovieFileOutput.isRecording){
        return;
    }
    
    NSLog(@"视频保存地址%@",outputFielPath);
    NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
    
    [self updateVideoOrientation];
    
    //设置录制视频流输出的路径
    [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
     */
}

//停止录制
- (void) stopCapture:(void(^)(NSURL *url, NSError *error))handle {
    if (self.isRecording) {
        self.isRecording = NO;
        
        [self.movieManager stopMoive:handle];
    }
    /*
    if ([self.captureMovieFileOutput isRecording]) {
        [self.captureMovieFileOutput stopRecording];//停止录制
    }*/
}

- (void) initialSession
{
    //这个方法的执行我放在init方法里了
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    [self setupSessionInputs:nil];
    [self setupSessionOutputs:nil];
    
    /*
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    self.caputreDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:nil];
    
    //[self fronCamera]方法会返回一个AVCaptureDevice对象，因为我初始化时是采用前摄像头，所以这么写，具体的实现方法后面会介绍
//    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
//    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
//    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }
    
    if ([self.captureSession canAddInput:self.caputreDeviceInput]) {
        [self.captureSession addInput:self.caputreDeviceInput];
    } else {
        NSLog(@"视频输入 添加失败");
    }

    
    // 音频输入
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *audioInError = nil;
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&audioInError];
    
    if ([_captureSession canAddInput:audioIn]){
        [_captureSession addInput:audioIn];
    } else {
        NSLog(@"音频输入 添加失败");
    }


    if ([self.captureSession canAddOutput:self.captureMovieFileOutput]) {
        [self.captureSession addOutput:self.captureMovieFileOutput];
    } else {
        NSLog(@"视频输出 添加失败");
    }
    */
//    if ([self.session canAddOutput:self.stillImageOutput]) {
//        [self.session addOutput:self.stillImageOutput];
//    }
    
}

- (void)updateVideoOrientation {
    if (self.movieOutConnection.isVideoOrientationSupported) {
        self.movieOutConnection.videoOrientation = [self currentVideoOrientation];
    }
}


/// 输入
- (void)setupSessionInputs:(NSError **)error{
    // 视频输入
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]){
            [self.captureSession addInput:videoInput];
        }
    }
    self.caputreDeviceInput = videoInput;
    
    // 音频输入
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:error];
    if ([self.captureSession canAddInput:audioIn]){
        [self.captureSession addInput:audioIn];
    }
}

/// 输出
- (void)setupSessionOutputs:(NSError **)error{
    dispatch_queue_t captureQueue = dispatch_queue_create("com.cc.captureQueue", DISPATCH_QUEUE_SERIAL);
    
    // 视频输出
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    [videoOut setSampleBufferDelegate:self queue:captureQueue];
    if ([self.captureSession canAddOutput:videoOut]){
        [self.captureSession addOutput:videoOut];
    }
    _videoOutput = videoOut;
    self.movieOutConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    
    // 音频输出
    AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
    [audioOut setSampleBufferDelegate:self queue:captureQueue];
    if ([self.captureSession canAddOutput:audioOut]){
        [self.captureSession addOutput:audioOut];
    }
    
    _audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
    
    /*
    // 静态图片输出
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([self.captureSession canAddOutput:imageOutput]) {
        [self.captureSession addOutput:imageOutput];
    }
    _imageOutput = imageOutput;
    */
}

#pragma mark - 设置相机画布
-(AVCaptureVideoPreviewLayer *)previewLayer{
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

#pragma mark - 初始化设备输出对象，用于获得输出数据
- (AVCaptureMovieFileOutput *)captureMovieFileOutput
{
    if(_captureMovieFileOutput == nil)
    {
        _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc]init];
    }
    return _captureMovieFileOutput;
}

#pragma mark - 拼接视频文件名称
- (NSString *)getVideoNameWithType:(NSString *)fileType
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMdd_HHmmss"];
    NSDate * NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    NSString * timeStr = [formatter stringFromDate:NowDate];
    NSString *fileName = [NSString stringWithFormat:@"video_%@.%@",timeStr,fileType];
    return fileName;
}

#pragma mark - 视频输出代理开始录制
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    //    SHOWMESSAGE(@"开始录制");
}


#pragma mark - 录制完成回调
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    //    上传视频转换视频名称代码，不要直接干了就是
    //    SHOWMESSAGE(@"上传中");
        NSString * uploadAddress = [outputFileURL absoluteString];;
    //    uploadVideoObject * upload = [[uploadVideoObject alloc]init];
    //    NSMutableString * mString = [NSMutableString stringWithString:uploadAddress];
    //    NSString *strUrl = [mString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    //    [upload uploadVideo:strUrl];
    //    //视频录入完成之后在后台将视频存储到相
    
    NSLog(@"uploadAddress %@", uploadAddress);
}


#pragma mark - -其它方法
// 当前设备取向
- (AVCaptureVideoOrientation)currentVideoOrientation{
    AVCaptureVideoOrientation orientation = self.motionManager.videoOrientation;
    if (orientation == AVCaptureVideoOrientationPortrait) {
        NSLog(@"videoOrientation : AVCaptureVideoOrientationPortrait");
    } else if (orientation == AVCaptureVideoOrientationLandscapeLeft) {
        NSLog(@"videoOrientation : AVCaptureVideoOrientationLandscapeLeft");
    } else if (orientation == AVCaptureVideoOrientationPortraitUpsideDown) {
        NSLog(@"videoOrientation : AVCaptureVideoOrientationPortraitUpsideDown");
    } else if (orientation == AVCaptureVideoOrientationLandscapeRight) {
        NSLog(@"videoOrientation : AVCaptureVideoOrientationLandscapeRight");
    }

    return orientation;
}


- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.isRecording) {
        [self.movieManager writeData:connection video:self.movieOutConnection audio:self.audioConnection buffer:sampleBuffer];
    }
}


- (CCMovieManager *)movieManager {
    if (!_movieManager) {
        _movieManager = [[CCMovieManager alloc] init];
    }
    return _movieManager;
}

@end
