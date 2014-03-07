//
//  BLKNSUserDefaultsHelper.h
//  Blink
//
//  Created by Chad Newbry on 3/7/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BLK_PROFILE_IMAGE @"profileImage"
#define BLK_NAME @"name"
#define BLK_QUOTE @"quote"
#define BLK_RELATIONSHIP_STATUS @"relationshipStatus"
#define BLK_COLLEGE @"college"


@interface BLKNSUserDefaultsHelper : NSObject

+(NSString*)getUserPropertyStringForKey:(NSString *)key;

+(void)setUserPropertyStringForKey:(id)property key:(NSString *)key;

@end
