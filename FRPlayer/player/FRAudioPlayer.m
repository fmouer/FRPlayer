//
//  FRAudioPlayer.m
//  FRPlayer
//
//  Created by huangzhimou on 2019/8/21.
//  Copyright © 2019 xiaopeng. All rights reserved.
//

#import "FRAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface FRAudioPlayer ()

@property(nonatomic, strong) AVAudioPlayer *avplayer;

@end

@implementation FRAudioPlayer

- (void)player:(NSString *)filePath {
    [self player:filePath rate:1.0];
}

- (void)player:(NSString *)filePath rate:(float)rate {
    NSError *playerError = nil;
    [self stop];
    
    self.avplayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:&playerError];
    
    self.avplayer.rate = rate;
    self.avplayer.enableRate = YES;
    
    if (self.avplayer == nil) {
        NSLog(@"ERror creating player: %@", [playerError description]);
    } else {
        [self.avplayer play];
    }
}

- (void)stop {
    if (self.avplayer) {
        [self.avplayer stop];
    }
}

@end
