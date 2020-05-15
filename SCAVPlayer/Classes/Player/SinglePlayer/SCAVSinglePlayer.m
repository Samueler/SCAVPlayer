//
//  SCAVSinglePlayer.m
//  SCAVPlayer
//
//  Created by 妈妈网 on 2020/5/14.
//

#import "SCAVSinglePlayer.h"
#import "FBKVOController.h"

@interface SCAVSinglePlayer ()

@property (nonatomic, strong) FBKVOController *kvoController;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) NSInteger loopedCount;

@end

@implementation SCAVSinglePlayer

@synthesize mute = _mute;
@synthesize playerLayer = _playerLayer;
@synthesize totalDuration = _totalDuration;
@synthesize currentDuration = _currentDuration;
@synthesize bufferedDuration = _bufferedDuration;
@synthesize currentStatus = _currentStatus;

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
        [self commonNotifications];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithURL:URL loopCount:1];
}

- (instancetype)initWithURL:(NSURL *)URL loopCount:(NSInteger)loopCount {
    if (self = [self init]) {
        self->_URL = URL;
        if (loopCount < 0) {
            loopCount = 1;
        }
        self->_loopCount = loopCount;
        
        [self prepare];
    }
    return self;
}

+ (instancetype)singlePlayerWithURL:(NSURL *)URL {
    return [[self alloc] initWithURL:URL];
}

+ (instancetype)singlePlayerWithURL:(NSURL *)URL loopCount:(NSInteger)loopCount {
    return [[self alloc] initWithURL:URL loopCount:loopCount];
}

#pragma mark - Public Functions

- (void)play {
    if (self.currentStatus == SCAVPlayerStatusPlaying) {
        return;
    }
    
    [self.player play];
    [self setupCurrentStatus:SCAVPlayerStatusPlaying];
}

- (void)pause {
    if (self.currentStatus == SCAVPlayerStatusPause) {
        return;
    }
    
    [self.player pause];
    [self setupCurrentStatus:SCAVPlayerStatusPause];
}

- (void)setupRate:(float)rate {
    self.player.rate = rate;
}

- (void)setupVolumne:(float)volume {
    self.player.volume = volume;
}

- (void)seekToSecond:(NSTimeInterval)second {
    [self.player seekToTime:CMTimeMake(second, 1)];
}

- (void)seekToPercent:(float)percent {
    if (percent > 1 || percent < 0) {
        return;
    }
    
    [self seekToSecond:percent * self.totalDuration];
}

#pragma mark - Private Functions

- (void)commonInit {
    self.kvoController = [FBKVOController controllerWithObserver:self];
    self->_loopCount = 1;
    self->_loopedCount = 0;
}

- (void)prepare {
    self->_playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self setupTimeObserver];
    [self setupPlayerItemObserver];
}

- (void)setupTimeObserver {
    self.timeObserver = nil;
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSTimeInterval currentDuration = CMTimeGetSeconds(time);
        NSTimeInterval totalDuration = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        
        strongSelf->_currentDuration = currentDuration;
        strongSelf->_totalDuration = totalDuration;
        
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(singlePlayer:currentDuration:totalDuration:)]) {
            [strongSelf.delegate singlePlayer:strongSelf currentDuration:currentDuration totalDuration:totalDuration];
        }
    }];
}

- (void)setupPlayerItemObserver {
    __weak typeof(self) weakSelf = self;
    
    [self.kvoController observe:self.player.currentItem keyPath:@"status" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        SCAVPlayerStatus status = (SCAVPlayerStatus)[change[NSKeyValueChangeNewKey] integerValue];
        [weakSelf setupCurrentStatus:status];
    }];
    
    [self.kvoController observe:self.player.currentItem keyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSArray *loadedTimeRanges = weakSelf.player.currentItem.loadedTimeRanges;
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        NSTimeInterval bufferedDuration = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        
        strongSelf->_bufferedDuration = bufferedDuration;
        
        [strongSelf setupBufferedDuration:bufferedDuration];
    }];
}

- (void)setupCurrentStatus:(SCAVPlayerStatus)status {
    if (self.currentStatus == status) {
        return;
    }
    
    self->_currentStatus = status;
    if (self.delegate && [self.delegate respondsToSelector:@selector(singlePlayer:currentStatusChanged:)]) {
        [self.delegate singlePlayer:self currentStatusChanged:self.currentStatus];
    }
}

- (void)setupBufferedDuration:(NSTimeInterval)bufferedDuration {
    self->_bufferedDuration = bufferedDuration;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(singlePlayer:bufferedDuration:)]) {
        [self.delegate singlePlayer:self bufferedDuration:self.bufferedDuration];
    }
}

#pragma mark - Notifications

- (void)commonNotifications {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerItemDidPlayToEndTime) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)applicationWillEnterForeground {
    if (self.delegate && [self.delegate respondsToSelector:@selector(singlePlayerWillEnterForeground:)]) {
        [self.delegate singlePlayerWillEnterForeground:self];
    }
}

- (void)applicationDidEnterBackground {
    if (self.delegate && [self.delegate respondsToSelector:@selector(singlePlayerDidEnterBackground:)]) {
        [self.delegate singlePlayerDidEnterBackground:self];
    }
}

- (void)playerItemDidPlayToEndTime {
    self.loopedCount++;
    if (self.loopCount == 0 || self.loopedCount < self.loopCount) {
        [self setupCurrentStatus:SCAVPlayerStatusFinish];
        [self seekToSecond:0];
        [self play];
    }
}

#pragma mark - Getter

- (BOOL)isMute {
    return !self.player.volume;
}

#pragma mark - Lazy Load

- (AVPlayer *)player {
    if (!_player) {
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.URL];
        _player = [AVPlayer playerWithPlayerItem:item];
    }
    return _player;
}

#pragma mark - Dealloc

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    self.timeObserver = nil;
}

@end
