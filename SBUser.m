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

+ (SBUser *)currentUser
{
    static SBUser *currentUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentUser = [[self alloc] init];
    });
    return currentUser;
}

+ (SBUser *)createUserWithName:(NSString *)user
{
    static SBUser *mySBUser = nil;
    @synchronized(self) {
        if (mySBUser == nil) mySBUser = [[self alloc] init];
        mySBUser.userName = user;
    }
    return mySBUser;
}

- (BOOL)shouldBroadcastProfile
{
#warning how to crash app if user profile there isn't an instance of this class?
    return true;
}

- (void)shouldEndProfileBroadcast
{
    
}

@end
