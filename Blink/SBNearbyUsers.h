//
//  SBNearbyUsers.h
//  Blink
//
//  Created by Joe Newbry on 2/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBUserModel.h"
#import "SBUserDiscovery.h"

@protocol SBNearbyUsersDelegate <NSObject>
@optional
- (void)userConnected:(SBUserModel *)userModel;
- (void)userConnectedWithNewArray:(NSMutableArray *)newArray;
- (void)userDisconnected:(SBUserModel *)userModel;
- (void)userDisconnectedWithNewArray:(NSMutableArray *)newArray;

@end


@interface SBNearbyUsers : NSObject <SBUserDiscoveryDelegate>

@property (weak, nonatomic) id<SBNearbyUsersDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *nearbyUsers;
@property (strong, nonatomic) NSMutableSet *nearbyUserUUIDs;

+ (SBNearbyUsers *)instance;

- (void)searchForUsers;
- (SBUserModel *)nextUser;
- (NSMutableArray *)allUsers;
- (BOOL)isUserDiscovered;

@end

int currentUser;