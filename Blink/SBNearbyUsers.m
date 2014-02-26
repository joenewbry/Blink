//
//  SBNearbyUsers.m
//  Blink
//
//  Created by Joe Newbry on 2/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "SBNearbyUsers.h"

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
    [SBUserDiscovery buildUserDiscoveryScaffold];
    [[SBUserDiscovery userDiscoveryScaffold] setDelegate:self];
    [[SBUserDiscovery userDiscoveryScaffold] searchForUsers];
}

- (SBUserModel *)nextUser
{
    return self.nearbyUsers[++currentUser];
}

- (NSMutableArray *)allUsers
{
    return self.nearbyUsers;
}

#pragma mark - SBUserDiscoverDelegate
- (void)didReceiveObjectID:(NSString *)objectID
{
    PFQuery *userWithObjectId = [PFQuery queryWithClassName:@"_User"];
    [userWithObjectId whereKey:@"objectId" equalTo:objectID];
    [userWithObjectId findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *firstObject = objects[0];
        SBUserModel *newUser = [[SBUserModel alloc] initWithObjectId:objectID AndUsername:firstObject[@"profileName"] andRelationshipStatus:firstObject[@"relationship"] andThumbnailFile:firstObject[@"thumbnailImage"] andProfileFile:firstObject[@"profileImage"] andQuote:firstObject[@"quote"] andCollege:firstObject[@"college"]];
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

@end
