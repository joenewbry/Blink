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

- (void)searchForMessagesIncluding:(BLKUser *)currentUser
{
    PFQuery *chatQuery = [PFQuery queryWithClassName:@"Chat"];
    [chatQuery whereKey:@"participants" containsAllObjectsInArray:@[currentUser]];
    [chatQuery includeKey:@"messages"];
    [chatQuery includeKey:@"participants"];
    [chatQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];

    // search for chats
    [chatQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // always reset so that cache and network don't stack
        if (error)  {
        }
        self.chats = [[NSMutableArray alloc] init];

        // for each Chat, find all the messages in the chat and notify delegate
        // also add each Chat (series of messages) to a Chat array
        for (PFObject *chat in objects){
            NSMutableArray *messages = [NSMutableArray new];
            for (BLKMessageObject *message in chat[@"messages"]) {
                [messages addObject:message];
                if([self.delegate respondsToSelector:@selector(newMessageRecieved:)]){
                    [self.delegate newMessageRecieved:message];
                }
            }
            if ([self.delegate respondsToSelector:@selector(newMessageRecievedAllMessages:)]) {
                [self.delegate newMessageRecievedAllMessages:messages];
            }
        [self.chats addObject:chat];
        }
    }];
}

- (NSMutableArray *)messagesForConversationBetween:(NSArray *)users
{
    for (NSDictionary *aChat in self.chats){
        if ([[aChat objectForKey:@"participants"] isEqualToArray:users]){
            return [aChat objectForKey:@"messages"];
        }
    }
    return nil;
}

- (void)refresh
{
    [self searchForMessagesIncluding:[BLKUser currentUser]];
}

@end
