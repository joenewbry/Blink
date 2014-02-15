//
//  SBUser.h
//  Blink
//
//  Created by Joe Newbry on 2/11/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBUser : NSObject {
}

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *objectId;
+ (SBUser *)createUserWithName:(NSString *)user;
+ (SBUser *)currentUser;

@end
