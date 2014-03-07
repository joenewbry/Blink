//
//  SBUserModel.h
//  Blink
//
//  Created by Joe Newbry on 2/26/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLKUser.h"

@interface SBUserModel : NSObject

@property NSString *objectId;
@property NSString *username;
@property NSString *relationshipStatus;
@property UIImage *thumbnailImg;
@property UIImage *profileImage;
@property NSString *quote;
@property NSString *college;
@property BLKUser *user;


-(id) initWithObjectId:(NSString *)objectId andUsername:(NSString *)username andRelationshipStatus:(NSString *)relationshipStatus andThumbnailFile:(PFFile *)thumbnailFile andProfileFile:(PFFile *)profileFile andQuote:(NSString *)quote andCollege:(NSString *)college andUser:(BLKUser *)user;

@end
