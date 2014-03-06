//
//  BLKUserProfile.h
//  Blink
//
//  Created by Joe Newbry on 3/5/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Parse/PFUser.h>
#import <Parse/PFFile.h>

@interface BLKUser : PFUser <PFSubclassing>

@property (retain) NSString *profileName;
@property (retain) NSString *gender;
@property (retain) NSString *relationshipStatus;
@property (retain) NSString *college;
@property (retain) NSString *quote;
@property (retain) NSString *profilePictureURL;
@property (retain) PFFile *profilePicture;
@property (retain) PFFile *profilePictureThumbnail;

+ (BLKUser *)currentUser;

@end
