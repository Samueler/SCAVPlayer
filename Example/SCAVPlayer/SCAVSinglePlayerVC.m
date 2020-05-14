//
//  SCAVSinglePlayerVC.m
//  SCAVPlayer_Example
//
//  Created by 妈妈网 on 2020/5/14.
//  Copyright © 2020 ty.Chen. All rights reserved.
//

#import "SCAVSinglePlayerVC.h"
#import <SCAVSinglePlayer.h>

@interface SCAVSinglePlayerVC () <SCAVSinglePlayerDelegate>

@property (nonatomic, strong) SCAVSinglePlayer *player;

@end

@implementation SCAVSinglePlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.player = [SCAVSinglePlayer singlePlayerWithURL:[NSURL URLWithString:@"https://aweme.snssdk.com/aweme/v1/playwm/?video_id=v0200ff00000bdkpfpdd2r6fb5kf6m50&line=0.mp4"] loopCount:0];
    self.player.delegate = self;
    [self.view.layer addSublayer:self.player.playerLayer];
    self.player.playerLayer.frame = self.view.bounds;
    
    [self.player play];
}

#pragma mark - SCAVSinglePlayerDelegate

- (void)singlePlayerDidEnterBackground:(SCAVSinglePlayer *)singlePlayer {
    NSLog(@"queuePlayerDidEnterBackground");
}

- (void)singlePlayerWillEnterForeground:(SCAVSinglePlayer *)singlePlayer {
    NSLog(@"queuePlayerWillEnterForeground");
}

- (void)singlePlayer:(SCAVSinglePlayer *)singlePlayer currentStatusChanged:(SCAVPlayerStatus)status {
    NSLog(@"status:%lu", (unsigned long)status);
}

- (void)singlePlayer:(SCAVSinglePlayer *)singlePlayer bufferedDuration:(NSTimeInterval)bufferedDuration {
        NSLog(@"bufferedDuration:%f", bufferedDuration);
}

- (void)singlePlayer:(SCAVSinglePlayer *)singlePlayer currentDuration:(NSTimeInterval)currentDuration totalDuration:(NSTimeInterval)totalDuration {
        NSLog(@"currentDuration: %f, totalDuration:%f", currentDuration, totalDuration);
}

@end
