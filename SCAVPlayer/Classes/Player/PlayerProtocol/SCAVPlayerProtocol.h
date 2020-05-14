//
//  SCAVPlayerProtocol.h
//  SCAVPlayer
//
//  Created by 妈妈网 on 2020/5/14.
//

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, SCAVPlayerStatus) {
    SCAVPlayerStatusUnknown,
    SCAVPlayerStatusReadyToPlay,
    SCAVPlayerStatusFail,
    SCAVPlayerStatusPlaying,
    SCAVPlayerStatusPause,
    SCAVPlayerStatusFinish
};

@protocol SCAVPlayerProtocol <NSObject>

@property (nonatomic, assign, getter=isMute, readonly) BOOL mute;
@property (nonatomic, strong, readonly) AVPlayerLayer *playerLayer;
@property (nonatomic, assign, readonly) NSTimeInterval totalDuration;
@property (nonatomic, assign, readonly) SCAVPlayerStatus currentStatus;
@property (nonatomic, assign, readonly) NSTimeInterval currentDuration;
@property (nonatomic, assign, readonly) NSTimeInterval bufferedDuration;

- (void)play;

- (void)pause;

- (void)setupRate:(float)rate;

- (void)setupVolumne:(float)volume;

- (void)seekToPercent:(float)percent;

- (void)seekToSecond:(NSTimeInterval)second;

@end
