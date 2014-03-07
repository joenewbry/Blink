//
//  BLKMessageData.h
//  Blink
//
//  Created by Joe Newbry on 2/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "BLKMessageObject.h"
#import "BLKChatObject.h"

@protocol BLKChatDataDelegate
@optional
- (void)newMessageRecievedAllMessages:(NSMutableArray *)messages;
- (void)newMessageRecieved:(BLKMessageObject *)message;
- (void)newChatRecieved:(BLKChatObject *)chat;

@end

@interface BLKChatData : NSObject

@property (weak, nonatomic) id<BLKChatDataDelegate, NSObject> delegate;
@property (strong, nonatomic) NSMutableArray *chats;

+ (BLKChatData *)instance;
- (void)searchForMessagesIncluding:(BLKUser *)currentUser;
- (NSMutableArray *)messagesForConversationBetween:(NSArray *)users;
- (void)refresh;


@end
