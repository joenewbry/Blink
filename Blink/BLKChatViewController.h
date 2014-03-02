//
//  BLKChatViewController.h
//  Blink
//
//  Created by Chad Newbry on 2/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSMessagesViewController/JSMessagesViewController.h>
#import <Parse/Parse.h>

@interface BLKChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableDictionary *avatars;

- (void)setupMessageData:(PFObject *)messageData;
- (void)setupNewMessage:(PFUser *)chatWithUser;

@end
