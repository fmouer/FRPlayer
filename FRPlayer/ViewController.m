//
//  ViewController.m
//  FRPlayer
//
//  Created by huangzhimou on 2019/6/20.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import "ViewController.h"
#import "FRRecordViewController.h"
#import "FRFileManager.h"
#import "FFmpegTest.h"
#import "FRMp4TransToMov.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FRMediaMeuxer.h"
#import "FRAudioPlayer.h"


@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) FRRecordViewController *recordViewController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSourceArray;

@property (nonatomic, strong) UIButton *recordButton;

@property (nonatomic, strong) FRAudioPlayer *audioPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"FRPlayer";
    [self drawViews];
    
//    [self mediaMuxer];
    
    self.audioPlayer = [[FRAudioPlayer alloc] init];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadVideoDataSource];
    
    [self.audioPlayer player:[[NSBundle mainBundle] pathForResource:@"01" ofType:@"mp4"]];
    
//    AudioQueueStart
}

#pragma mark -

- (void)drawViews {

    CGSize size = CGSizeMake(self.view.frame.size.width, 45);
    self.recordButton.frame = CGRectMake(0, self.view.frame.size.height - size.height, size.width, size.height);
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.recordButton.frame.origin.y);
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.recordButton];
}

- (void)reloadVideoDataSource {

    self.dataSourceArray = [FRFileManager localVideoSource];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate , UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell description]];
    NSString *pathName = [self.dataSourceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = pathName;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[UITableViewHeaderFooterView description]];
    headerFooterView.textLabel.text = @"本地视频";
    return headerFooterView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *localPathDirectory = [FRFileManager getVideoPathCache];

    NSString *pathName = [self.dataSourceArray objectAtIndex:indexPath.row];
    if ([pathName hasSuffix:@"mov"]) {
        if ([pathName hasPrefix:@"/var"]) {
            [self playFile:pathName];
        } else {
            NSString *localVideoPath = [localPathDirectory stringByAppendingPathComponent:pathName];
            [self playFile:localVideoPath];
        }
    } else {
        if ([pathName hasPrefix:@"/var"]) {
            [self trans:pathName];
        } else {
            NSString *localVideoPath = [localPathDirectory stringByAppendingPathComponent:pathName];
            [self trans:localVideoPath];
        }
        
        [self reloadVideoDataSource];
    }
}

#pragma mark -

- (void)recordViewControllerEvent:(UIButton *)btn {
    FRRecordViewController *recordViewController = [[FRRecordViewController alloc] init];
    [self presentViewController:recordViewController animated:YES completion:nil];
}

#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell description]];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:[UITableViewHeaderFooterView description]];
    }
    return _tableView;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordButton setTitle:@"录制一个视频吧～" forState:UIControlStateNormal];
        _recordButton.backgroundColor = [UIColor orangeColor];
        [_recordButton addTarget:self action:@selector(recordViewControllerEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordButton;
}

- (void)decodePath:(NSString *)inStr {
//    NSString *inStr= [NSString stringWithFormat:@"Video.bundle/%@",@"Test.mov"];
//    NSString *inPath=[[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:inStr];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//
//                                                         NSUserDomainMask, YES);
//    NSString *path = [paths objectAtIndex:0];
//    NSString *tmpPath = [path stringByAppendingPathComponent:@"temp"];
//    [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:NULL];
    NSString *tmpPath = [FRFileManager getVideoPathCache];

    NSString* tempPathFile = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Test.yuv"]];
    //输出文件，自己看一下可以了
    [FFmpegTest ffmepgVideoDecode:inStr outFilePath:tempPathFile];

}


- (void)trans:(NSString *)inStr {
    NSString *tmpPath = [FRFileManager getVideoPathCache];
    
    NSString *inFileName = [inStr lastPathComponent];
    
    NSString *pathExtension = [inStr pathExtension];
    
    NSString *transName = [inFileName stringByReplacingOccurrencesOfString:pathExtension withString:@"mov"];
    
    NSString* tempPathFile = [tmpPath stringByAppendingPathComponent:transName];

    [FRMp4TransToMov ffmepgVideoTrans:inStr outFilePath:tempPathFile];
}

- (void)playFile:(NSString *)localFilePath {
    //第一步:获取视频路径
    //本地视频
    NSURL *localVideoUrl = [NSURL fileURLWithPath:localFilePath];
    //在线视频
    //NSString *webVideoPath = @"http://api.junqingguanchashi.net/yunpan/bd/c.php?vid=/junqing/1115.mp4";
    //NSURL *webVideoUrl = [NSURL URLWithString:webVideoPath];
    
    //第二步:创建视频播放器
    MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:localVideoUrl];
    
    //第三步:设置播放器属性
    //通过moviePlayer属性设置播放器属性(与MPMoviePlayerController类似)
    playerViewController.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    
    //第四步:跳转视频播放界面
    [self presentViewController:playerViewController animated:YES completion:nil];
}

#pragma mark - muxer

- (void)mediaMuxer {
    NSString *localPathDirectory = [FRFileManager getVideoPathCache];
    NSString *newPath = [localPathDirectory stringByAppendingPathComponent:@"muxer.mov"];
    [FRMediaMeuxer inputPath1:[self videoPath] inputPath2:[self voicePath] outPath:newPath];
}

- (NSString *)videoPath {
    return [[NSBundle mainBundle] pathForResource:@"01" ofType:@"mp4"];
}

- (NSString *)voicePath {
    return [[NSBundle mainBundle] pathForResource:@"02" ofType:@"mp4"];
}

@end
