//
//  FRVideoDetailModel.h
//  FRPlayer
//
//  Created by huangzhimou on 2019/8/23.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FRVideoDetailModel : NSObject

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, copy) NSString *videoName;
@property (nonatomic, copy) NSString *videoFilePath;

@end

