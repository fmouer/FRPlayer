//
//  CCMotionManager.m
//  CCCamera
//
//  Created by wsk on 16/8/29.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCMotionManager.h"
#import <CoreMotion/CoreMotion.h>

@interface CCMotionManager() 

@property(nonatomic, strong) CMMotionManager * motionManager;

@end

@implementation CCMotionManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1/15.0;
        if (!_motionManager.deviceMotionAvailable) {
            _motionManager = nil;
            return self;
        }
        __weak typeof(self)wealSelf = self;
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *motion, NSError *error){
            [wealSelf performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    }
    return self;
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x)) {
        if (y >= 0) {
            self.videoOrientation  = AVCaptureVideoOrientationPortraitUpsideDown;
        } else {
            self.videoOrientation  = AVCaptureVideoOrientationPortrait;

        }
    } else {
        if (x >= 0) {
            self.videoOrientation  = AVCaptureVideoOrientationLandscapeLeft;
        } else {
            self.videoOrientation  = AVCaptureVideoOrientationLandscapeRight ;
        }
    }
}

-(void)dealloc{
    NSLog(@"陀螺仪对象销毁了");
    [_motionManager stopDeviceMotionUpdates];
}

@end
