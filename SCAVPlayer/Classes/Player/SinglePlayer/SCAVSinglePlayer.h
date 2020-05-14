//
//  SCAVSinglePlayer.h
//  SCAVPlayer
//
//  Created by 妈妈网 on 2020/5/14.
//

#import <Foundation/Foundation.h>
#import "SCAVPlayerProtocol.h"
#import "SCAVSinglePlayerDelegate.h"

@interface SCAVSinglePlayer : NSObject <SCAVPlayerProtocol>

@property (nonatomic, assign, readonly) NSInteger loopCount;
@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, weak) id<SCAVSinglePlayerDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithURL:(NSURL *)URL;
- (instancetype)initWithURL:(NSURL *)URL loopCount:(NSInteger)loopCount;
+ (instancetype)singlePlayerWithURL:(NSURL *)URL;
+ (instancetype)singlePlayerWithURL:(NSURL *)URL loopCount:(NSInteger)loopCount;

@end
