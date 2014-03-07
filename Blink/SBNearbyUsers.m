//
//  SBNearbyUsers.m
//  Blink
//
//  Created by Joe Newbry on 2/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "SBNearbyUsers.h"
#import <Parse/PFQuery.h>

@implementation SBNearbyUsers

static SBNearbyUsers *instance = nil;
+ (SBNearbyUsers *)instance
{
    @synchronized(self) {
        if (instance == nil) {
            instance = [[SBNearbyUsers alloc] init];
        }
    }
    return instance;
}

- (BOOL)isUserDiscovered
{
    return currentUser;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.nearbyUsers = [NSMutableArray new];

    }
    return self;
}

- (void)searchForUsers
{
    [SBUserDiscovery createUserDiscovery];
    [[SBUserDiscovery currentUserDiscovery] setDelegate:self];
    [[SBUserDiscovery currentUserDiscovery] searchForUsers];
}

- (SBUserModel *)nextUser
{
    if (!currentUser) return nil;
    if (currentUser < self.nearbyUsers.count) return self.nearbyUsers[++currentUser];
    return self.nearbyUsers[currentUser = 0];
}

- (NSMutableArray *)allUsers
{
    return self.nearbyUsers;
}

#pragma mark - SBUserDiscoverDelegate
- (void)didReceiveObjectID:(NSString *)objectID
{
    if (!self.nearbyUserUUIDs) self.nearbyUserUUIDs = [NSMutableSet new];
    // check to make sure object hasn't already been discovered
    if (![self.nearbyUserUUIDs containsObject:objectID]) {
        PFQuery *userWithUUID = [BLKUser query];

        [userWithUUID whereKey:@"objectId" equalTo:objectID];
        [userWithUUID findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            PFObject *firstObject = objects[0];
            SBUserModel *newUser = [[SBUserModel alloc] initWithObjectId:objectID andUsername:firstObject[@"profileName"] andRelationshipStatus:firstObject[@"relationship"] andThumbnailFile:firstObject[@"thumbnailImage"] andProfileFile:firstObject[@"profileImage"] andQuote:firstObject[@"quote"] andCollege:firstObject[@"college"] andUser:(BLKUser *)firstObject];
            [self.nearbyUsers addObject:newUser];
            if (!currentUser) currentUser = 0;

            if ([self.delegate respondsToSelector:@selector(userConnected:)]) {
                [self.delegate userConnected:newUser];
            }
            if ([self.delegate respondsToSelector:@selector(userConnectedWithNewArray:)]){
                [self.delegate userConnectedWithNewArray:self.nearbyUsers];
            }
        }];
    }
}

- (void)userDidDisconnectWithObjectID:(NSString *)objectID
{
    for (SBUserModel *user in self.nearbyUsers){
        if ([user.objectId isEqualToString:objectID]){
            [self.nearbyUsers removeObject:user];
            [self.nearbyUserUUIDs removeObject:objectID];
            if ([self.delegate respondsToSelector:@selector(userDisconnected:)]){
                [self.delegate userDisconnected:user];
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(userDisconnectedWithNewArray:)]){
        [self.delegate userDisconnectedWithNewArray:self.nearbyUsers];
    }
}

@end
