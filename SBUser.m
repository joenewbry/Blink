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
        self.userName = userName;
    }
    return self;
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
