//
//  SCAVQueuePlayer.m
//  SCAVPlayer
//
//  Created by 妈妈网 on 2020/5/14.
//

#import "SCAVQueuePlayer.h"
#import "FBKVOController.h"

@interface SCAVQueuePlayer ()

@property (nonatomic, strong) FBKVOController *kvoController;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) AVQueuePlayer *queuePlayer;
@property (nonatomic, strong) NSMutableArray<AVPlayerItem *> *internalItems;

@end

@implementation SCAVQueuePlayer

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

- (instancetype)initWithDataSource:(id<SCAVQueuePlayerDataSource>)dataSource delegate:(id<SCAVQueuePlayerDelegate>)delegate {
    if (self = [self init]) {
        self->_dataSource = dataSource;
        self->_delegate = delegate;
        
        [self prepare];
    }
    return self;
}

+ (instancetype)queuePlayerWithDataSource:(id<SCAVQueuePlayerDataSource>)dataSource delegate:(id<SCAVQueuePlayerDelegate>)delegate {
    return [[self alloc] initWithDataSource:dataSource delegate:delegate];
}

#pragma mark - Public Functions

- (void)play {
    if (self.currentStatus == SCAVPlayerStatusPlaying) {
        return;
    }
    
    [self.queuePlayer play];
    [self setupCurrentStatus:SCAVPlayerStatusPlaying];
}

- (void)pause {
    if (self.currentStatus == SCAVPlayerStatusPause) {
        return;
    }
    
    [self.queuePlayer pause];
    [self setupCurrentStatus:SCAVPlayerStatusPause];
}

- (void)setupRate:(float)rate {
    self.queuePlayer.rate = rate;
}

- (void)setupVolumne:(float)volume {
    self.queuePlayer.volume = volume;
}

- (void)seekToSecond:(NSTimeInterval)second {
    [self.queuePlayer seekToTime:CMTimeMake(second, 1)];
}

- (void)seekToPercent:(float)percent {
    if (percent > 1 || percent < 0) {
        return;
    }
    
    [self seekToSecond:percent * self.totalDuration];
}

- (void)removeAllItems {
    [self.queuePlayer removeAllItems];
}

- (void)advanceToNextItem {
    if ([self.queuePlayer.currentItem isEqual:self.internalItems.lastObject]) {
        return;
    }
    [self.queuePlayer advanceToNextItem];
}

- (void)advanceToPreviousItem {
    AVPlayerItem *currentItem = self.queuePlayer.currentItem;
    NSInteger previousIndex = [self.internalItems indexOfObject:currentItem] - 1;
    if (previousIndex < 0 || previousIndex >= self.internalItems.count) {
        return;
    }
    
    AVPlayerItem *previousItem = self.internalItems[previousIndex];
    
    if ([self.queuePlayer canInsertItem:previousItem afterItem:currentItem]) {
        [self.queuePlayer insertItem:previousItem afterItem:currentItem];
    }
    
    [self.queuePlayer removeItem:currentItem];
    
    if ([self.queuePlayer canInsertItem:currentItem afterItem:previousItem]) {
        [self.queuePlayer insertItem:currentItem afterItem:previousItem];
    }
}

#pragma mark - Private Functions

- (void)prepare {
    [self reloadData];
    [self setupPlayer];
    [self setupTimeObserver];
    [self setupPlayerItemObserver];
}

- (void)commonInit {
    self.kvoController = [FBKVOController controllerWithObserver:self];
}

- (void)reloadData {
    [self.internalItems removeAllObjects];
    
    NSInteger numberCount = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfPlayerItemsInQueuePlayer:)]) {
        numberCount = [self.dataSource numberOfPlayerItemsInQueuePlayer:self];
    }
    
    for (NSInteger index = 0; index < numberCount; index++) {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(queuePlayer:URLForItemAtIndex:)]) {
            NSURL *URL = [self.dataSource queuePlayer:self URLForItemAtIndex:index];
            if (!URL || !URL.absoluteString.length) {
                NSString *tip = [NSString stringWithFormat:@"URL is nil at index: %zd", index];
                NSAssert(URL || URL.absoluteString.length, tip);
                [self.internalItems removeAllObjects];
                return;
            }
            
            AVPlayerItem *item = [AVPlayerItem playerItemWithURL:URL];
            [self.internalItems addObject:item];
        }
    }
}

- (void)setupPlayer {
    if (!self.internalItems.count) {
        return;
    }
    
    self.queuePlayer = [[AVQueuePlayer alloc] initWithItems:self.internalItems];
    self->_playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.queuePlayer];
}

- (void)setupTimeObserver {
    self.timeObserver = nil;
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.queuePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSTimeInterval currentDuration = CMTimeGetSeconds(time);
        NSTimeInterval totalDuration = CMTimeGetSeconds(weakSelf.queuePlayer.currentItem.duration);
        
        [weakSelf setupCurrentDuration:currentDuration totalDuration:totalDuration];
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(queuePlayer:currentDuration:totalDuration:)]) {
            [weakSelf.delegate queuePlayer:weakSelf currentDuration:currentDuration totalDuration:totalDuration];
        }
    }];
}

- (void)setupCurrentDuration:(NSTimeInterval)currentDuration totalDuration:(NSTimeInterval)totalDuration {
    self->_currentDuration = currentDuration;
    self->_totalDuration = totalDuration;
}

- (void)setupPlayerItemObserver {
    __weak typeof(self) weakSelf = self;
    
    [self.kvoController observe:self.queuePlayer.currentItem keyPath:@"status" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        SCAVPlayerStatus status = (SCAVPlayerStatus)[change[NSKeyValueChangeNewKey] integerValue];
        [weakSelf setupCurrentStatus:status];
    }];
    
    [self.kvoController observe:self.queuePlayer.currentItem keyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSArray *loadedTimeRanges = weakSelf.queuePlayer.currentItem.loadedTimeRanges;
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        NSTimeInterval bufferedDuration = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        
        [weakSelf setupBufferedDuration:bufferedDuration];
    }];
    
    [self.kvoController observe:self.queuePlayer keyPath:@"currentItem" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        AVPlayerItem *item = (AVPlayerItem *)change[NSKeyValueChangeNewKey];
        if (!item || [item isEqual:[NSNull null]]) {
            [weakSelf setupCurrentStatus:SCAVPlayerStatusFinish];
        }
    }];
}

- (void)setupCurrentStatus:(SCAVPlayerStatus)status {
    if (self.currentStatus == status) {
        return;
    }
    
    self->_currentStatus = status;
    if (self.delegate && [self.delegate respondsToSelector:@selector(queuePlayer:currentStatusChanged:)]) {
        [self.delegate queuePlayer:self currentStatusChanged:self.currentStatus];
    }
}

- (void)setupBufferedDuration:(NSTimeInterval)bufferedDuration {
    self->_bufferedDuration = bufferedDuration;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(queuePlayer:bufferedDuration:)]) {
        [self.delegate queuePlayer:self bufferedDuration:self.bufferedDuration];
    }
}

#pragma mark - Notifications

- (void)commonNotifications {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationWillEnterForeground {
    if (self.delegate && [self.delegate respondsToSelector:@selector(queuePlayerWillEnterForeground:)]) {
        [self.delegate queuePlayerWillEnterForeground:self];
    }
}

- (void)applicationDidEnterBackground {
    if (self.delegate && [self.delegate respondsToSelector:@selector(queuePlayerDidEnterBackground:)]) {
        [self.delegate queuePlayerDidEnterBackground:self];
    }
}

#pragma mark - Getter

- (BOOL)isMute {
    return !self.queuePlayer.volume;
}

#pragma mark - Lazy Load

- (NSMutableArray<AVPlayerItem *> *)internalItems {
    if (!_internalItems) {
        _internalItems = [NSMutableArray array];
    }
    return _internalItems;
}

#pragma mark - Dealloc

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    self.timeObserver = nil;
}

@end
