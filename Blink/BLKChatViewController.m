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

@interface BLKChatViewController ()

@property (strong, nonatomic) NSMutableArray *PFUsersInChat;

@end

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
    self.sender = [PFUser currentUser][@"profileName"];
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

//    PFQuery *findChatObject = [PFQuery queryWithClassName:@"Chat"];
//    [findChatObject se]

    PFObject *message = [PFObject objectWithClassName:@"Message"];
    message[@"message"] = text;
    message[@"sender"] = [PFUser currentUser];
    message[@"senderName"] = [PFUser currentUser][@"profileName"];
    [message saveInBackground];

    // check for existing object, then update
    // else create a new chat object

    PFQuery *chatQuery = [PFQuery queryWithClassName:@"Chat"];

    // TODO figure out how to exact match rather than match and then filter results
    [chatQuery whereKey:@"recipientsArrayPFUser" containsAllObjectsInArray:self.PFUsersInChat];
    [chatQuery includeKey:@"recipientsArrayPFUser"];
    [chatQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {

            for (PFObject *potentialChat in objects){
                // is exact match
                if ([potentialChat[@"recipientsArrayPFUser"] count] == self.PFUsersInChat.count){
                    PFObject *chat = potentialChat; // only one
                    PFRelation *messages = [chat relationForKey:@"messages"];
                    [messages addObject:message];
                    [chat setValue:[PFUser currentUser] forKey:@"sender"];
                    [chat setValue:text forKey:@"mostRecentMessage"];
                    [chat saveInBackground];
                    return;
                }
            }

            PFObject *chat = [PFObject objectWithClassName:@"Chat"];
            PFRelation *messages = [chat relationForKey:@"messages"];
            [messages addObject:message];
            [chat addUniqueObjectsFromArray:self.PFUsersInChat forKey:@"recipientsArrayPFUser"];
            [chat setValue:[PFUser currentUser] forKey:@"sender"];
            [chat saveInBackground];
        }
    }];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage *myMessage = (JSMessage *)self.messages[indexPath.row];
    if ([[PFUser currentUser][@"profileName"] isEqualToString:myMessage.sender]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage *myMessage = (JSMessage *)self.messages[indexPath.row];
    if ([[PFUser currentUser][@"profileName"] isEqualToString:myMessage.sender]) {
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
    return YES;
}

//
//  *** Implement to customize cell further
//
- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];

        // TODO change to underline not blue color
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
    JSMessage *myMessage = (JSMessage *)self.messages[indexPath.row];
    UIImage *image = [self.avatars objectForKey:myMessage.sender];
    return [[UIImageView alloc] initWithImage:image];
}

#pragma mark - Load in current message data
- (void)setupMessageData:(PFObject *)messageData
{
    // for fetching the proper Chat
    self.PFUsersInChat = [NSMutableArray arrayWithArray:messageData[@"recipientsArrayPFUser"]];


    // gets all previous chats
    self.messages = [NSMutableArray new];
    PFRelation *messages = messageData[@"messages"];
    PFQuery *messageQuery = [messages query];
    [messageQuery orderByAscending:@"createdAt"];
    [messageQuery includeKey:@"createdAt"];
    [messageQuery includeKey:@"updatedAt"];
    [messageQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) NSLog(@"You done gufffed");
        if (!error) {
            self.messages = [NSMutableArray new];
            for (PFObject *message in objects) {
                [self.messages addObject:[[JSMessage alloc] initWithText:message[@"message"] sender:message[@"senderName"] date:message.updatedAt]];
            }
            [self.tableView reloadData];
            [self scrollToBottomAnimated:NO];
        }
    }];

    self.avatars = [NSMutableDictionary new];
    for (PFUser *user in self.PFUsersInChat){
        PFFile *userThumbnail = user[@"thumbnailImage"];

        UIImage *placeholderImage = [UIImage imageNamed:@"user_circle"];

        [self.avatars setValue:[JSAvatarImageFactory avatarImage:placeholderImage croppedToCircle:YES] forKey:user[@"profileName"]];
        [userThumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [self.avatars setValue:[JSAvatarImageFactory avatarImage:[UIImage imageWithData:data] croppedToCircle:YES] forKey:user[@"profileName"]];
            [self.tableView reloadData];
        }];
    }
}


@end
