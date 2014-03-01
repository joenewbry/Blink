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

+ (SBUser *)createUserWithName:(NSString *)user;
+ (SBUser *)currentUser;
+ (SBUser *)createUser;

@end
