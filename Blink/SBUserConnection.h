//
//  SBUserConnection.h
//  Blink
//
//  Created by Joe Newbry on 3/5/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBUser.h"
#import "SBUserDiscovery.h"

enum SBNextUserBy {
    SBNextUserByNewest,
    SBNextUserByOldest
};

typedef enum SBNextUserBy SBNextUserBy;

@protocol SBUserConnectionDelegate

@optional
- (void)userDidConnect:(SBUser *)user;

// used to bring app out of the background state ???
// TODO implement these other delegate methods
- (void)userDidConnectWithobjectId:(NSString *)objectId;
- (void)userDidDisconnect:(SBUser *)user;
- (void)userDidDisconnectObjectId:(NSString *)objectId;

// user proximity measure
- (float) distanceFromUser;

@end

@interface SBUserConnection : NSObject <SBUserDiscoveryDelegate>

@property (weak, nonatomic) id<SBUserConnectionDelegate, NSObject> delegate;
@property (strong, nonatomic) NSMutableArray *sbUsers;

// creating singleton instance
+ (SBUserConnection *)createUserConnection;
+ (SBUserConnection *)currentUserConnection;

// specific user distance metrics
- (void)trackDistanceFromUser:(SBUser *)sbUser;
- (void)stopTrackDistanceFromUser;

// information on users in group ordered by SBNextUserBy
- (SBUser *)nextUserBy:(SBNextUserBy)nextUserBy;
- (NSMutableArray *)allUsersBy:(SBNextUserBy)allUserBy;

@end
