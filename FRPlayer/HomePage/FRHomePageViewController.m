//
//  FRHomePageViewController.m
//  FRPlayer
//
//  Created by huangzhimou on 2019/8/23.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import "FRHomePageViewController.h"
#import "FRVideoDetailModel.h"
#import "FRHomePageCollectionViewCell.h"
#import "FRFileManager.h"
#import "FRSelectMusicViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface FRHomePageViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray <FRVideoDetailModel *>*videoArray;

@end

@implementation FRHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoArray = [FRFileManager detailVideoArray];
    self.title = @"首页";
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(publishVideo:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.videoArray = [FRFileManager detailVideoArray];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FRHomePageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[FRHomePageCollectionViewCell description] forIndexPath:indexPath];
    FRVideoDetailModel *videoDetailModel = [self.videoArray objectAtIndex:indexPath.row];
    [cell configVideoDetailModel:videoDetailModel];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FRVideoDetailModel *videoDetailModel = [self.videoArray objectAtIndex:indexPath.row];
    [self playFile:videoDetailModel.videoFilePath];
}

- (void)publishVideo:(UIBarButtonItem *)buttonItem {
    FRSelectMusicViewController *selectMusicViewController = [[FRSelectMusicViewController alloc] init];
    [self.navigationController pushViewController:selectMusicViewController animated:YES];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(2, 15, 0, 15);
        float width = (kScreenWidth - flowLayout.sectionInset.left * 2 - 5) / 2;
        flowLayout.itemSize = CGSizeMake(width, kScreenHeight/kScreenWidth * width);
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing = 5;
        // CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[FRHomePageCollectionViewCell class] forCellWithReuseIdentifier:[FRHomePageCollectionViewCell description]];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = YES;
    }
    return _collectionView;
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

@end
