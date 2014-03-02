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

//TODO: how to make it so both of these methods look at the same place?
+ (SBUser *)currentUser
{
    static SBUser *mySBUser = nil;
    @synchronized(self) {
        if (mySBUser == nil) mySBUser = [[self alloc] initWithUserName:@"Default User"];
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

+ (SBUser *)createUserWithName:(NSString *)user
{
    static SBUser *mySBUser = nil;
    @synchronized(self) {
        if (mySBUser == nil) mySBUser = [[self alloc] initWithUserName:user];
    }
    return mySBUser;
}

- (id)initWithUserName:(NSString *)userName
{
    if (self = [super init])
    {
        self.userModel = [SBUserModel new];
        self.userModel.username = userName;
    }
    return self;
}

@end
