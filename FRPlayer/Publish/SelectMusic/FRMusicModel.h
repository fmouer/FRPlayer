//
//  FRMusicModel.h
//  FRPlayer
//
//  Created by huangzhimou on 2019/8/26.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FRMusicModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path;

@property (nonatomic, assign) BOOL isMusic;

@end

NS_ASSUME_NONNULL_END
