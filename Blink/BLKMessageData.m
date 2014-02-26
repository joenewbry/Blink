//
//  BLKMessageData.m
//  Blink
//
//  Created by Joe Newbry on 2/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKMessageData.h"

@implementation BLKMessageData

static BLKMessageData *instance = nil;
+ (BLKMessageData *)instance {
    @synchronized(self) {
        if (instance == nil) instance = [[BLKMessageData alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self ) {

    }
    return self;
}

- (void)searchForMessagesIncluding:(PFUser *)currentUser
{
    PFQuery *messageQuery = [PFQuery queryWithClassName:@"Chat"];
    [messageQuery whereKey:@"recipientsArrayPFUser" containsAllObjectsInArray:@[currentUser]];
    [messageQuery includeKey:@"recipientsArrayPFUser"];
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!self.messages) self.messages = [[NSMutableArray alloc] init];
        for (PFObject *message in objects){
            [self.messages addObject:message];
        }
        if ([self.delegate respondsToSelector:@selector(newMessageRecievedAllMessages:)]){
            [self.delegate newMessageRecievedAllMessages:self.messages];
        }
    }];
}

@end
