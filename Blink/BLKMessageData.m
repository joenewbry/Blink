//
//  BLKMessageData.m
//  Blink
//
//  Created by Joe Newbry on 2/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKMessageData.h"
#import <JSMessagesViewController/JSMessage.h>

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
    PFQuery *chatQuery = [PFQuery queryWithClassName:@"Chat"];
    [chatQuery whereKey:@"recipientsArrayPFUser" containsAllObjectsInArray:@[currentUser]];
    [chatQuery includeKey:@"recipientsArrayPFUser"];
    [chatQuery includeKey:@"messages"];
    [chatQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [chatQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // always reset so that cache and network don't stack
        if (error) NSLog(@"Error fetching message data is: %@", [error localizedDescription]);
        self.chats = [[NSMutableArray alloc] init];
        for (PFObject *chat in objects){
            [self.chats addObject:chat]; // FIX chats are retrieved as NSNULL, check how they're being saved/retrieved
        }
        if ([self.delegate respondsToSelector:@selector(newMessageRecievedAllMessages:)]){
            [self.delegate newMessageRecievedAllMessages:self.chats];
        }
    }];
}

@end
