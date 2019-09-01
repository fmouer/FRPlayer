//
//  FRHomePageCollectionViewCell.h
//  FRPlayer
//
//  Created by huangzhimou on 2019/8/23.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRVideoDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FRHomePageCollectionViewCell : UICollectionViewCell

- (void)configVideoDetailModel:(FRVideoDetailModel *)videoDetailModel;

@end

NS_ASSUME_NONNULL_END
