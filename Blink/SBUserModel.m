//
//  SBUserModel.m
//  Blink
//
//  Created by Joe Newbry on 2/26/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "SBUserModel.h"

@implementation SBUserModel

- (id)initWithObjectId:(NSString *)objectId
           andUsername:(NSString *)username
 andRelationshipStatus:(NSString *)relationshipStatus
      andThumbnailFile:(PFFile *)thumbnailFile
        andProfileFile:(PFFile *)profileFile
              andQuote:(NSString *)quote
            andCollege:(NSString *)college
               andUser:(PFUser *)user;

{
    self.objectId = objectId;
    self.username = username;
    self.relationshipStatus = relationshipStatus;
    self.thumbnailImg = [UIImage imageWithContentsOfFile:@"user_circle"];
    [thumbnailFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) self.thumbnailImg = [UIImage imageWithData:data];
    }];
    self.profileImage = [UIImage imageWithContentsOfFile:@"user_circle"];
    [profileFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) self.profileImage = [UIImage imageWithData:data];
    }];
    self.quote = quote;
    self.college = college;
    self.user = user;
    return self;
}


@end
