//
//  FRRecordViewController.h
//  FRPlayer
//
//  Created by huangzhimou on 2019/6/21.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FRMusicModel;

NS_ASSUME_NONNULL_BEGIN

@interface FRRecordViewController : UIViewController

- (instancetype)initWithMusicModel:(FRMusicModel *)musicModel;

@end

NS_ASSUME_NONNULL_END
