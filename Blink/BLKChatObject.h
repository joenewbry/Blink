//
//  BLKChatObject.h
//  Blink
//
//  Created by Joe Newbry on 3/6/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "BLKUser.h"

@interface BLKChatObject : PFObject <PFSubclassing>

+(NSString *)parseClassName;

@property (retain) NSArray *messages;
@property (retain) NSArray *participants;
@property (retain) NSString *mostRecentMessage;
@property (retain) BLKUser *sender;


@end
