//
//  BLKMessageData.h
//  Blink
//
//  Created by Joe Newbry on 2/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol BLKMessageDataDelegate
@optional
- (void)newMessageRecievedAllMessages:(NSMutableArray *)messages;
- (void)newMessageRecieved:(PFObject *)message;

@end

@interface BLKMessageData : NSObject

@property (weak, nonatomic) id<BLKMessageDataDelegate, NSObject> delegate;
@property (strong, nonatomic) NSMutableArray *messages;

+ (BLKMessageData *)instance;
- (void)searchForMessagesIncluding:(PFUser *)currentUser;


@end
