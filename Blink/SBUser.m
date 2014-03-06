//
//  SBUser.m
//  Blink
//
//  Created by Joe Newbry on 2/11/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "SBUser.h"

@interface SBUser () {
}

@end

@implementation SBUser


// class methods to create a singleton instance of SBUser
// used to control social bluetooth controls and set what
// data gets shared out to other people
+ (SBUser *)currentUser
{
    static SBUser *mySBUser = nil;
    @synchronized(self) {
        if (mySBUser == nil) mySBUser = [[self alloc] init];
    }
    return mySBUser;
}

+ (SBUser *)createUser
{
    static SBUser *mySBUser = nil;
    @synchronized(self) {
        if (mySBUser == nil) mySBUser = [[self alloc] init];
    }
    return mySBUser;
}

+ (SBUser *)createUserWithObjectId:(NSString *)objectId
{
    static SBUser *mySBUser = nil;
    @synchronized(self) {
        if (mySBUser == nil) mySBUser = [[self alloc] initWithObjectId:objectId];
    }
    return mySBUser;
}

- (id)initWithObjectId:(NSString *)objectId
{
    if (self = [super init])
    {
        self.userModel = [SBUserModel new];
        self.userModel.objectId = objectId;
    }
    return self;
}

- (void)shareProfile
{
    
}

@end
