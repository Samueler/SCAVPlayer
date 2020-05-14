//
//  SCAVQueuePlayerVC.m
//  SCAVPlayer_Example
//
//  Created by 妈妈网 on 2020/5/14.
//  Copyright © 2020 ty.Chen. All rights reserved.
//

#import "SCAVQueuePlayerVC.h"
#import <SCAVQueuePlayer.h>

@interface SCAVQueuePlayerVC () <
SCAVQueuePlayerDataSource,
SCAVQueuePlayerDelegate
>

@property (nonatomic, strong) SCAVQueuePlayer *queuePlayer;

@property (nonatomic, strong) NSArray<NSURL *> *URLs;

@end

@implementation SCAVQueuePlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.URLs = @[
        [NSURL URLWithString:@"https://aweme.snssdk.com/aweme/v1/playwm/?video_id=v0200ff00000bdkpfpdd2r6fb5kf6m50&line=0.mp4"],
        [NSURL URLWithString:@"https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4"],
        [NSURL URLWithString:@"https://aweme.snssdk.com/aweme/v1/playwm/?video_id=v0200ff00000bdkpfpdd2r6fb5kf6m50&line=0.mp4"],
        [NSURL URLWithString:@"https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4"],
    ];
    
    self.queuePlayer = [SCAVQueuePlayer queuePlayerWithDataSource:self delegate:self];
    [self.view.layer addSublayer:self.queuePlayer.playerLayer];
    self.queuePlayer.playerLayer.frame = self.view.bounds;
    [self.queuePlayer play];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, 120, 44)];
    [btn setTitle:@"下一个" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(140, 100, 120, 44)];
    [btn1 setTitle:@"上一个" forState:UIControlStateNormal];
    btn1.backgroundColor = [UIColor orangeColor];
    [btn1 addTarget:self action:@selector(btn1Click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
}

- (void)btnClick {
    [self.queuePlayer advanceToNextItem];
}

- (void)btn1Click {
    [self.queuePlayer advanceToPreviousItem];
}

#pragma mark - SCAVQueuePlayerDataSource

- (NSInteger)numberOfPlayerItemsInQueuePlayer:(SCAVQueuePlayer *)queuePlayer {
    return self.URLs.count;
}

- (NSURL *)queuePlayer:(SCAVQueuePlayer *)queuePlayer URLForItemAtIndex:(NSInteger)index {
    return self.URLs[index];
}

#pragma mark - SCAVQueuePlayerDelegate

- (void)queuePlayerDidEnterBackground:(SCAVQueuePlayer *)queuePlayer {
    NSLog(@"queuePlayerDidEnterBackground");
}

- (void)queuePlayerWillEnterForeground:(SCAVQueuePlayer *)queuePlayer {
    NSLog(@"queuePlayerWillEnterForeground");
}

- (void)queuePlayer:(SCAVQueuePlayer *)queuePlayer currentStatusChanged:(SCAVPlayerStatus)status {
    NSLog(@"status:%lu", (unsigned long)status);
}

- (void)queuePlayer:(SCAVQueuePlayer *)queuePlayer bufferedDuration:(NSTimeInterval)bufferedDuration {
        NSLog(@"bufferedDuration:%f", bufferedDuration);
}

- (void)queuePlayer:(SCAVQueuePlayer *)queuePlayer currentDuration:(NSTimeInterval)currentDuration totalDuration:(NSTimeInterval)totalDuration {
        NSLog(@"currentDuration: %f, totalDuration:%f", currentDuration, totalDuration);
}
@end
