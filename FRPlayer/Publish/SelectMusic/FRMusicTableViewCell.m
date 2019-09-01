//
//  FRMusicTableViewCell.m
//  FRPlayer
//
//  Created by fmouer on 2019/8/25.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import "FRMusicTableViewCell.h"
#import <Masonry.h>

@interface FRMusicTableViewCell ()

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIButton *selectButton;

@end


@implementation FRMusicTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.selectButton];
        [self drawViews];
        [self.selectButton addTarget:self action:@selector(selectButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)drawViews {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(@15);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.iconImageView.mas_trailing).offset(10);
        make.centerY.equalTo(self.iconImageView);
        make.trailing.lessThanOrEqualTo(self.selectButton.mas_leading).offset(-10);
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.trailing.equalTo(self.contentView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
}

- (void)configMusicModel:(FRMusicModel *)musicModel {
    self.nameLabel.text = musicModel.name;
}

- (void)selectType:(BOOL)selectType {
    if (selectType) {
        _selectButton.backgroundColor = [UIColor redColor];
    } else {
        _selectButton.backgroundColor = [UIColor clearColor];
    }
}

- (void)selectButtonEvent:(UIButton *)button {
    self.selectMusicBlock();
}

#pragma mark - getter

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.backgroundColor = [UIColor blackColor];
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
    }
    return _nameLabel;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.backgroundColor = [UIColor redColor];
    }
    return _selectButton;
}

@end
