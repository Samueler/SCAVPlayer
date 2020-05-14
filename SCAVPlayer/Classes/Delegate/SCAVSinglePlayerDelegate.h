//
//  SCAVSinglePlayerDelegate.h
//  SCAVPlayer
//
//  Created by 妈妈网 on 2020/5/14.
//

#import <Foundation/Foundation.h>

@class SCAVSinglePlayer;

@protocol SCAVSinglePlayerDelegate <NSObject>

@optional

- (void)singlePlayerItemsDidPlayToEndTime:(SCAVSinglePlayer *)singlePlayer;

- (void)singlePlayerDidEnterBackground:(SCAVSinglePlayer *)singlePlayer;

- (void)singlePlayerWillEnterForeground:(SCAVSinglePlayer *)singlePlayer;

- (void)singlePlayer:(SCAVSinglePlayer *)singlePlayer currentStatusChanged:(SCAVPlayerStatus)status;

- (void)singlePlayer:(SCAVSinglePlayer *)singlePlayer bufferedDuration:(NSTimeInterval)bufferedDuration;

- (void)singlePlayer:(SCAVSinglePlayer *)singlePlayer currentDuration:(NSTimeInterval)currentDuration totalDuration:(NSTimeInterval)totalDuration;

@end
