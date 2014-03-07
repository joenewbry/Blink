//
//  BLKChatObject.m
//  Blink
//
//  Created by Joe Newbry on 3/6/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKChatObject.h"

@implementation BLKChatObject

@dynamic messages;
@dynamic participants;
@dynamic mostRecentMessage;
@dynamic sender;

+ (NSString *)parseClassName
{
    return @"Chat";
}

+ (void)registerSubclass
{
    [super registerSubclass];
}

@end
