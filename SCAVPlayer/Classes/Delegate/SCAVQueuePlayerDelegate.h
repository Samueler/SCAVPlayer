//
//  SCAVQueuePlayerDelegate.h
//  SCAVPlayer
//
//  Created by 妈妈网 on 2020/5/14.
//

#import <Foundation/Foundation.h>

@class SCAVQueuePlayer;

@protocol SCAVQueuePlayerDelegate <NSObject>

@optional

- (void)queuePlayerItemsDidPlayToEndTime:(SCAVQueuePlayer *)queuePlayer;

- (void)queuePlayerDidEnterBackground:(SCAVQueuePlayer *)queuePlayer;

- (void)queuePlayerWillEnterForeground:(SCAVQueuePlayer *)queuePlayer;

- (void)queuePlayer:(SCAVQueuePlayer *)queuePlayer currentStatusChanged:(SCAVPlayerStatus)status;

- (void)queuePlayer:(SCAVQueuePlayer *)queuePlayer bufferedDuration:(NSTimeInterval)bufferedDuration;

- (void)queuePlayer:(SCAVQueuePlayer *)queuePlayer currentDuration:(NSTimeInterval)currentDuration totalDuration:(NSTimeInterval)totalDuration;

@end
