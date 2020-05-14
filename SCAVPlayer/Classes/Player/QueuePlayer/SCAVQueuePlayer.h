//
//  SCAVQueuePlayer.h
//  SCAVPlayer
//
//  Created by 妈妈网 on 2020/5/14.
//

#import <Foundation/Foundation.h>
#import "SCAVPlayerProtocol.h"
#import "SCAVQueuePlayerDataSource.h"
#import "SCAVQueuePlayerDelegate.h"

@interface SCAVQueuePlayer : NSObject <SCAVPlayerProtocol>

@property (nonatomic, weak, readonly) id<SCAVQueuePlayerDelegate> delegate;
@property (nonatomic, weak, readonly) id<SCAVQueuePlayerDataSource> dataSource;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithDataSource:(id<SCAVQueuePlayerDataSource>)dataSource delegate:(id<SCAVQueuePlayerDelegate>)delegate;
+ (instancetype)queuePlayerWithDataSource:(id<SCAVQueuePlayerDataSource>)dataSource delegate:(id<SCAVQueuePlayerDelegate>)delegate;

- (void)removeAllItems;

- (void)advanceToNextItem;

- (void)advanceToPreviousItem;

@end
