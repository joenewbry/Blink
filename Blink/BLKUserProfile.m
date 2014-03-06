//
//  BLKUserProfile.m
//  Subclassing PFUser to make updating basic profile information faster
//
//  Created by Joe Newbry on 3/5/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKUserProfile.h"
#import <Parse/PFObject+Subclass.h>

@implementation BLKUserProfile

@dynamic profileName;
@dynamic gender;
@dynamic relationshipStatus;
@dynamic college;
@dynamic quote;
@dynamic profilePictureURL;
@dynamic profilePicture;
@dynamic profilePictureThumbnail;

+ (BLKUserProfile *)currentUser
{
    return (BLKUserProfile *)[PFUser currentUser];
}



@end
