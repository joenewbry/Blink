//
//  BLKUserProfile.m
//  Subclassing BLKUser to make updating basic profile information faster
//
//  Created by Joe Newbry on 3/5/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKUser.h"
#import <Parse/PFObject+Subclass.h>

@implementation BLKUser

@dynamic profileName;
@dynamic gender;
@dynamic relationshipStatus;
@dynamic college;
@dynamic quote;
@dynamic profilePictureURL;
@dynamic profilePicture;
@dynamic profilePictureThumbnail;

+ (BLKUser *)currentUser
{
    return (BLKUser *)[PFUser currentUser];
}

+ (void)registerSubclass
{
    [super registerSubclass];
}


@end
