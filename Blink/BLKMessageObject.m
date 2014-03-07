//
//  BLKMessageObject.m
//  Blink
//
//  Created by Joe Newbry on 3/5/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKMessageObject.h"

@implementation BLKMessageObject
@dynamic message;
@dynamic sender;
@dynamic senderName;

+ (NSString *)parseClassName
{
    return @"Message";
}

+ (void)registerSubclass
{
    [super registerSubclass];
}

@end