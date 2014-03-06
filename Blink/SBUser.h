//
//  SBUser.h
//  Blink
//
//  Created by Joe Newbry on 2/11/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBUserModel.h"

@interface SBUser : NSObject {
}

@property (strong, nonatomic) SBUserModel *userModel;
/*
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *quote;
@property (strong, nonatomic) UIImage *profileImage;
@property (strong, nonatomic) NSString *status;
 **/

// class methods to create user and get currentUser
+ (SBUser *)createUserWithName:(NSString *)user;
+ (SBUser *)createUserWithUUID:(NSString *)name;
+ (SBUser *)currentUser;
+ (SBUser *)createUser;

// SBUser sharing controls
- (void)shareProfile;
- (void)shareProfileWithLaunchOptions:(NSDictionary *)launchOptions broadcastInBackground:(BOOL)shouldBroadcast;
- (void)shareUUID;
- (void)shareUUIDWithLaunchOptions:(NSDictionary *)launchOptions broadcastInBackground:(BOOL)shouldBoradcast;
- (void)stopShareProfile;
- (void)logout;

@end
