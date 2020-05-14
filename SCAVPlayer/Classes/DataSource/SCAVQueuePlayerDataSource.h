//
//  SCAVQueuePlayerDataSource.h
//  SCAVPlayer
//
//  Created by 妈妈网 on 2020/5/14.
//

#import <Foundation/Foundation.h>

@class SCAVQueuePlayer;

@protocol SCAVQueuePlayerDataSource <NSObject>

- (NSInteger)numberOfPlayerItemsInQueuePlayer:(SCAVQueuePlayer *)queuePlayer;

- (NSURL *)queuePlayer:(SCAVQueuePlayer *)queuePlayer URLForItemAtIndex:(NSInteger)index;

@end
