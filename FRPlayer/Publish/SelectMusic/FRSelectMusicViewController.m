//
//  FRSelectMusicViewController.m
//  FRPlayer
//
//  Created by fmouer on 2019/8/25.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import "FRSelectMusicViewController.h"
#import <Masonry.h>
#import "FRMusicTableViewCell.h"
#import "FRRecordViewController.h"
#import "FRAudioPlayer.h"

@interface FRSelectMusicViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *musicTableView;
@property (nonatomic, strong) NSArray *musicArray;
@property (nonatomic, strong) FRAudioPlayer *audioPlayer;
@property (nonatomic, strong) FRMusicModel *selectMusicModel;

@end

@implementation FRSelectMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.musicTableView];
    self.title = @"选择背景音乐";
    self.musicArray = [self localMusicArray];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.musicTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"录制视频" style:UIBarButtonItemStylePlain target:self action:@selector(recordViewControllerEvent:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.audioPlayer stop];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FRMusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[FRMusicTableViewCell description]];
    FRMusicModel *musicModel = [self.musicArray objectAtIndex:indexPath.row];
    [cell configMusicModel:musicModel];
    
    [cell selectType:self.selectMusicModel == musicModel];
    
    __weak typeof(self) weakSelf = self;
    
    [cell setSelectMusicBlock:^{
        // player music
        [weakSelf.audioPlayer player:musicModel.path];
        weakSelf.selectMusicModel = musicModel;
        [tableView reloadData];
    }];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.musicArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.f;
}

#pragma mark -

- (void)recordViewControllerEvent:(UIBarButtonItem *)btn {
    FRRecordViewController *recordViewController = [[FRRecordViewController alloc] initWithMusicModel:self.selectMusicModel];
    [self presentViewController:recordViewController animated:YES completion:nil];
}

#pragma mark - getter

- (UITableView *)musicTableView {
    if (!_musicTableView) {
        _musicTableView = [[UITableView alloc] init];
        _musicTableView.delegate = self;
        _musicTableView.dataSource = self;
        [_musicTableView registerClass:[FRMusicTableViewCell class] forCellReuseIdentifier:[FRMusicTableViewCell description]];
    }
    return _musicTableView;
}

- (FRAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        _audioPlayer = [[FRAudioPlayer alloc] init];
    }
    return _audioPlayer;
}

- (NSArray *)localMusicArray {
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"02" ofType:@"mp4"];
    FRMusicModel *musicModel = [[FRMusicModel alloc] init];
    musicModel.path = musicPath;
    musicModel.name = @"黄豆豆";
    musicModel.isMusic = NO;
    return @[musicModel];
}

@end
