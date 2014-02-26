//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "BLKChatViewController.h"
#import "JSMessage.h"
#import <Parse/Parse.h>

#define kSubtitleJobs @"Jobs"
#define kSubtitleWoz @"Steve Wozniak"
#define kSubtitleCook @"Mr. Cook"

@implementation BLKChatViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    [self setBackgroundColor:[UIColor whiteColor]];


    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];

    self.title = @"Messages";
    self.messageInputView.textView.placeHolder = @"New Message";
    self.sender = @"Jobs";

    self.avatars = [[NSDictionary alloc] initWithObjectsAndKeys:
                    [JSAvatarImageFactory avatarImageNamed:@"user_circle" croppedToCircle:YES], kSubtitleJobs,
                    [JSAvatarImageFactory avatarImageNamed:@"user_circle" croppedToCircle:YES], kSubtitleWoz,
                    [JSAvatarImageFactory avatarImageNamed:@"user_circle" croppedToCircle:YES], kSubtitleCook,
                    nil];
    self.messages = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
}

#pragma mark - Actions

- (void)buttonPressed:(UIBarButtonItem *)sender
{
    // Testing pushing/popping messages view
    BLKChatViewController *vc = [[BLKChatViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Messages view delegate: REQUIRED

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    [JSMessageSoundEffect playMessageSentSound];
    [self.messages addObject:[[JSMessage alloc] initWithText:text sender:sender date:date]];

    [self finishSend];
    [self scrollToBottomAnimated:YES];

    PFObject *message = [PFObject objectWithClassName:@"Message"];
    message[@"message"] = text;
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFObject *chat = [PFObject objectWithClassName:@"Chat"];
        PFRelation *messages = [chat relationForKey:@"messages"];
        [messages addObject:message];
        [chat addObject:[PFUser currentUser] forKey:@"recipientsArrayPFUser"];
        [chat setValue:[PFUser currentUser] forKey:@"sender"];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) NSLog(@"Error for saving chat message is : %@", [error localizedDescription]);
        }];
    }];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2) ? JSBubbleMessageTypeIncoming : JSBubbleMessageTypeOutgoing;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor colorWithRed:111.0/255.0 green:224.0/255.0 blue:240.0/255.0 alpha:1.0]];
    }

    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor colorWithRed:255.0/255.0 green:121.0/255.0 blue:51.0/255.0 alpha:1.0]];
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages view delegate: OPTIONAL

- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 3 == 0) {
        return YES;
    }
    return NO;
}

//
//  *** Implement to customize cell further
//
- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];

        if ([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];

            cell.bubbleView.textView.linkTextAttributes = attrs;
        }
    }

    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }

    if (cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
    }

#if TARGET_IPHONE_SIMULATOR
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
#else
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
#endif
}

//  *** Implement to use a custom send button
//
//  The button's frame is set automatically for you
//
//  - (UIButton *)sendButtonForInputView
//

//  *** Implement to prevent auto-scrolling when message is added
//
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

// *** Implemnt to enable/disable pan/tap todismiss keyboard
//
- (BOOL)allowsPanToDismissKeyboard
{
    return YES;
}

#pragma mark - Messages view data source: REQUIRED

- (JSMessage *)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.row];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    UIImage *image = [self.avatars objectForKey:sender];
    return [[UIImageView alloc] initWithImage:image];
}

@end
