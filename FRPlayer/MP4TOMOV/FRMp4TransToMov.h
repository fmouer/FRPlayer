//
//  FRMp4TransToMov.h
//  FRPlayer
//
//  Created by huangzhimou on 2019/6/24.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FRMp4TransToMov : NSObject

+(void) ffmepgVideoTrans:(NSString*)inFilePath outFilePath:(NSString*)outFilePath;

@end

NS_ASSUME_NONNULL_END
