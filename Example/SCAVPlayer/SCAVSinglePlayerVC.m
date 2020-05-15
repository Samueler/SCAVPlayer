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
    
    self.player = [SCAVSinglePlayer singlePlayerWithURL:[NSURL URLWithString:@"https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4"] loopCount:0];
    self.player.delegate = self;
    [self.view.layer addSublayer:self.player.playerLayer];
    self.player.playerLayer.frame = self.view.bounds;
    
    [self.player play];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, 100, 44)];
    [btn setTitle:@"进5s" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, 100, 100, 44)];
    [backBtn setTitle:@"退5s" forState:UIControlStateNormal];
    backBtn.backgroundColor = [UIColor orangeColor];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}

- (void)btnClick {
    [self.player seekToSecond:self.player.currentDuration + 5];
}

- (void)backBtnClick {
    [self.player seekToSecond:self.player.currentDuration - 5];
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
