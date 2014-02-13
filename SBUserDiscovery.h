//
//  SBUserDiscovery.h
//  Blink
//
//  Created by Joe Newbry on 2/12/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SBDiscoverUser;

@interface SBUserDiscovery : NSObject

+ (id)buildUserDiscoveryScaffold;
+ (id)buildUserDiscoveryScaffoldWithLaunchOptions:(NSDictionary *)launchOptions;
+ (id)userDiscoveryScaffold;

- (void)searchForUsers;
- (void)stopSearchForUsers;

@end

@protocol SBDiscoverUser

@optional
- (NSString *)didDiscoverUserWithName;
- (NSDictionary *)didDiscoverUserWithDictionary;

@end
