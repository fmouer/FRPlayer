//
//  FRCameraViewController.h
//  FRPlayer
//
//  Created by huangzhimou on 2019/6/20.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FRCameraViewController : UIViewController

@property (nonatomic, assign) BOOL isRecording;


-(void)startRunning;
-(void)stopRunning;

- (void)startCapture;
- (void) stopCapture:(void(^)(NSURL *url, NSError *error))handle;



@end

NS_ASSUME_NONNULL_END
