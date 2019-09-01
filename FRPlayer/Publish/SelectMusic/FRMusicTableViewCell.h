//
//  FRMusicTableViewCell.h
//  FRPlayer
//
//  Created by fmouer on 2019/8/25.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRMusicModel.h"

typedef  void(^SelectMusicBlock)(void);


NS_ASSUME_NONNULL_BEGIN

@interface FRMusicTableViewCell : UITableViewCell

@property (nonatomic, copy) SelectMusicBlock selectMusicBlock;

- (void)configMusicModel:(FRMusicModel *)musicModel;

- (void)selectType:(BOOL)selectType;

@end

NS_ASSUME_NONNULL_END
