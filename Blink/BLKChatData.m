//
//  BLKMessageData.m
//  Blink
//
//  Created by Joe Newbry on 2/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKChatData.h"
#import <JSMessagesViewController/JSMessage.h>

@implementation BLKChatData

static BLKChatData *instance = nil;
+ (BLKChatData *)instance {
    @synchronized(self) {
        if (instance == nil) instance = [[BLKChatData alloc] init];
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
            BLKMessageObject *aChat = [[BLKMessageObject alloc] init];
            aChat.message = chat[@"message"];
            aChat.sender = chat[@"sender"];
            aChat.senderName = chat[@"senderName"];
            [self.chats addObject:aChat];
        }
        if ([self.delegate respondsToSelector:@selector
             (newMessageRecievedAllMessages:)]){
            [self.delegate newMessageRecievedAllMessages:self.chats];
        }
    }];
}

@end
