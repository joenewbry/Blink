//
//  SBUserDiscovery.h
//  Blink
//
//  Created by Joe Newbry on 2/12/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SBDiscoverUser

@optional
- (void)didReceiveObjectID:(NSString *)objectID;
- (void)didReceiveUserName:(NSString *)userName;
- (void)didReceiveQuote:(NSString *)quote;
- (void)didReceiveStatus:(NSString *)status;
- (void)didReceiveProfileImage:(UIImage *)profileImage;

@end

@interface SBUserDiscovery : NSObject

+ (BOOL)isBuilt;
+ (BOOL)isBroadcasting;

+ (SBUserDiscovery *)buildUserDiscoveryScaffold;
+ (SBUserDiscovery *)buildUserDiscoveryScaffoldWithLaunchOptions:(NSDictionary *)launchOptions;
+ (SBUserDiscovery *)userDiscoveryScaffold;

- (void)searchForUsers;
- (void)stopSearchForUsers;

@property (nonatomic, weak) id <SBDiscoverUser, NSObject> delegate;


@end


