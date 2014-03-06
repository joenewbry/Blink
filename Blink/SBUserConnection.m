//
//  SBUserConnection.m
//  Blink
//
//  Created by Joe Newbry on 3/5/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "SBUserConnection.h"
#import "BLKUser.h"

@implementation SBUserConnection

int currentUser;

static SBUserConnection *instance = nil;
+ (SBUserConnection *)createUserConnection
{
    @synchronized(self) {
        if (instance == nil) {
            instance = [[SBUserConnection alloc] init];
        }
    }
    return instance;
}

+ (SBUserConnection *)currentUserConnection
{
    @synchronized(self) {
        if (instance == nil) {
            instance = [[SBUserConnection alloc] init];
        }
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.sbUsers = [NSMutableArray new];
        [SBUserDiscovery createUserDiscovery];
        [SBUserDiscovery currentUserDiscovery].delegate = self;
    }
    return self;
}

- (void)trackDistanceFromUser:(SBUser *)sbUser
{
    NSLog(@"track distance not implemented");
}

- (void)stopTrackDistanceFromUser
{
    NSLog(@"Stop track not implemented");
}

// TODO implement next user by functionality
- (SBUser *)nextUserBy:(SBNextUserBy)nextUserBy
{
    switch (nextUserBy) {
        case SBNextUserByNewest:
            return [self.sbUsers objectAtIndex:currentUser++];
            break;

        case SBNextUserByOldest:
            return [self.sbUsers objectAtIndex:currentUser++];
            break;
    }
}

- (NSMutableArray *)allUsersBy:(SBNextUserBy)allUserBy
{
    switch (allUserBy) {
        case SBNextUserByNewest:
            return self.sbUsers;
            break;

        case SBNextUserByOldest:
            return self.sbUsers;
            break;
    }
}

#pragma mark - SBUserDiscoveryDelegate methods
- (void)didReceiveObjectID:(NSString *)objectID
{
    PFQuery *queryForParseUser = [PFQuery queryWithClassName:@"_User"];
    [queryForParseUser whereKey:@"objectId" equalTo:objectID];
    [queryForParseUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        // TODO check if this casting works
        BLKUser *newUser = (BLKUser *)object;
        [self.sbUsers addObject:newUser];

        if ([self.delegate respondsToSelector:@selector(userDidConnect:)]){
            [self.delegate performSelector:@selector(userDidConnect:) withObject:newUser];
        }
    }];
}

- (void)didReceiveUserName:(NSString *)userName
{
    NSLog(@"didRecieveUserName not implemented");
}

- (void)didReceiveQuote:(NSString *)quote
{
    NSLog(@"didRecieveQuote not implemented");
}

- (void)didReceiveStatus:(NSString *)status
{
    NSLog(@"didReceiveStatus not implemented");
}

- (void)didReceiveProfileImage:(UIImage *)profileImage
{
    NSLog(@"didReceieveProfile Image not implemented");
}

- (void)didReceiveSBUser:(SBUser *)sbUser;
{
    NSLog(@"Did recieve object ID Not implemented");
}


@end
