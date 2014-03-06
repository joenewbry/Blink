//
//  SBUserConnection.h
//  Blink
//
//  Created by Joe Newbry on 3/5/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBUser.h"

enum SBNextUserBy {
    SBNextUserByNewest,
    SBNextUserByOldest
};

typedef enum SBNextUserBy SBNextUserBy;

@protocol SBUserConnectionDelegate <NSObject>

@optional

// user did enter or leave bluetooth range
- (SBUser *)userDidConnect;
- (NSString *)userDidConnectWithUUID;
- (SBUser *)userDidDisconnect;
- (NSString *)userDidDisconnectWithUUID;

// user proximity measure
- (float) distanceFromUser;

@end


@interface SBUserConnection : NSObject

// specific user distance metrics
- (void)trackDistanceFromUser:(SBUser *)sbUser;
- (void)stopTrackDistanceFromUser;

// information on users in group ordered by SBNextUserBy
- (SBUser *)nextUserBy:(SBNextUserBy)nextUserBy;
- (NSArray *)allUsersBy:(SBNextUserBy)allUserBy;

@end
