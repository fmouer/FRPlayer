//
//  FRRecordViewController.m
//  FRPlayer
//
//  Created by huangzhimou on 2019/6/20.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import "FRRecordViewController.h"
#import "FRCameraViewController.h"
#import "FRAudioPlayer.h"
#import "FRMusicModel.h"
#import "FRMediaMeuxer.h"
#import "FRFileManager.h"
#import <Masonry.h>

@interface FRRecordViewController ()

@property (nonatomic, strong) FRCameraViewController *cameraViewController;

@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UISegmentedControl *rateSegmentedControl;

@property (nonatomic, strong) FRAudioPlayer *audioPlayer;
@property (nonatomic, strong) FRMusicModel *musicModel;
@property (nonatomic, assign) CGFloat playRate;

@property (nonatomic, strong) FRMediaMeuxer *mediaMeuxer;

@end

@implementation FRRecordViewController

- (instancetype)initWithMusicModel:(FRMusicModel *)musicModel {
    self = [super init];
    if (self) {
        self.musicModel = musicModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self drawViews];
    
    [self currentDeviceOrientation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 打开相机
    [self.cameraViewController startRunning];
}

- (void)drawViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self addChildViewController:self.cameraViewController];
    [self.view addSubview:self.cameraViewController.view];
    
    [self.view addSubview:self.recordButton];
    
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
    }];
    
    [self.recordButton addTarget:self action:@selector(recordEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.backButton];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.top.equalTo(@25);
        make.size.mas_equalTo(CGSizeMake(40, 25));
    }];
    
    [self.view addSubview:self.rateSegmentedControl];
    
    [self.rateSegmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.recordButton.mas_bottom);
        make.leading.equalTo(self.recordButton.mas_trailing).offset(10);
    }];
}

- (FRCameraViewController *)cameraViewController {
    if (!_cameraViewController) {
        _cameraViewController = [[FRCameraViewController alloc] init];
    }
    return _cameraViewController;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordButton.backgroundColor = [UIColor redColor];
        [_recordButton setTitle:@"开始录制" forState:UIControlStateNormal];
        _recordButton.layer.masksToBounds = YES;
        _recordButton.layer.cornerRadius = 50.f;
    }
    return _recordButton;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (void)recordEvent:(UIButton *)button {
    if ([self.cameraViewController isRecording]) {
        NSString *name1 = [FRFileManager getVideoPathCache];
        NSString *namePath = [name1 stringByAppendingPathComponent:@"201908271111.mp4"];
        
        __weak typeof(self) weakSelf = self;
        [self.cameraViewController stopCapture:^(NSURL * _Nonnull url, NSError * _Nonnull error) {
            [weakSelf.mediaMeuxer mediaMeuxerVideoPath:url.absoluteString audioPath:weakSelf.musicModel.path outPath:namePath];
//            [FRMediaMeuxer inputPath1:url.absoluteString inputPath2:self.musicModel.path outPath:namePath];
        }];
        
        [_recordButton setTitle:@"开始录制" forState:UIControlStateNormal];
        [self.audioPlayer stop];
        
    } else {
        [self.cameraViewController startCapture];
        [_recordButton setTitle:@"录制中.." forState:UIControlStateNormal];
        [self.audioPlayer player:self.musicModel.path rate:self.playRate];
    }
}

- (void)rateValueChange:(UISegmentedControl *)segmentedControl {
    NSString *valueTitle = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
    self.playRate = [valueTitle floatValue];
}

- (void)backEvent {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)currentDeviceOrientation {
    UIDevice *device = [UIDevice currentDevice] ;
    switch (device.orientation) {
            case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
            case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
            case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
            case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左橫置");
            break;
            case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            break;
            case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            break;
            case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
    }
}

#pragma mark - getter

- (FRAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        _audioPlayer = [[FRAudioPlayer alloc] init];
    }
    return _audioPlayer;
}

- (UISegmentedControl *)rateSegmentedControl {
    if (!_rateSegmentedControl) {
        _rateSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"0.5", @"1.0", @"2.0"]];
        _rateSegmentedControl.selectedSegmentIndex = 1;
        _rateSegmentedControl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        _rateSegmentedControl.layer.cornerRadius = 4;
        
        [_rateSegmentedControl addTarget:self action:@selector(rateValueChange:) forControlEvents:UIControlEventValueChanged];
        
        [_rateSegmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
    }
    return _rateSegmentedControl;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (FRMediaMeuxer *)mediaMeuxer {
    if (!_mediaMeuxer) {
        _mediaMeuxer = [[FRMediaMeuxer alloc] init];
    }
    return _mediaMeuxer;
}

@end
