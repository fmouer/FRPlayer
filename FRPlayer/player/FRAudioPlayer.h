//
//  FRAudioPlayer.h
//  FRPlayer
//
//  Created by huangzhimou on 2019/8/21.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FRAudioPlayer : NSObject

- (void)player:(NSString *)filePath;
- (void)player:(NSString *)filePath rate:(float)rate;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
