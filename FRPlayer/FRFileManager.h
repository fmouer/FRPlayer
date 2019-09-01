//
//  FRFileManager.h
//  FRPlayer
//
//  Created by huangzhimou on 2019/6/21.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FRVideoDetailModel;

NS_ASSUME_NONNULL_BEGIN

@interface FRFileManager : NSObject

+ (NSString *)getVideoPathCache;
+ (NSArray *)localVideoSource;
+ (NSArray <FRVideoDetailModel *>*)detailVideoArray;

@end

NS_ASSUME_NONNULL_END
