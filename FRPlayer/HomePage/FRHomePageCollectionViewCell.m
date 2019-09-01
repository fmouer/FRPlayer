//
//  FRHomePageCollectionViewCell.m
//  FRPlayer
//
//  Created by huangzhimou on 2019/8/23.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import "FRHomePageCollectionViewCell.h"

@interface FRHomePageCollectionViewCell ()

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *shadeView;

@end

@implementation FRHomePageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.thumbnailImageView];
        self.thumbnailImageView.frame = (CGRect){CGPointZero, frame.size};
        
        [self addSubview:self.shadeView];
        self.shadeView.frame = CGRectMake(0, frame.size.height - 50, frame.size.width, 50);
        
        [self addSubview:self.titleLabel];
        self.titleLabel.frame = CGRectMake(10, self.shadeView.frame.origin.y + 5, frame.size.width - 20, 40);
    }
    return self;
}

- (void)configVideoDetailModel:(FRVideoDetailModel *)videoDetailModel {
    self.thumbnailImageView.image = videoDetailModel.thumbnailImage;
    self.titleLabel.text = videoDetailModel.videoName;
}

- (UIImageView *)thumbnailImageView {
    if (!_thumbnailImageView) {
        _thumbnailImageView = [[UIImageView alloc] init];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
        _thumbnailImageView.backgroundColor = [UIColor blackColor];
    }
    return _thumbnailImageView;
}

- (UIView *)shadeView {
    if (!_shadeView) {
        _shadeView = [[UIView alloc] init];
        _shadeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
    
    return _shadeView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

@end
