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
#import "BLKMessageObject.h"
#import "BLKChatData.h"

@interface BLKChatViewController () <BLKChatDataDelegate>

@property (strong, nonatomic) NSMutableArray *PFUsersInChat;

@end

@implementation BLKChatViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    // check for new table data
    [BLKChatData instance].delegate = self;
    [[BLKChatData instance] refresh];
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self setBackgroundColor:[UIColor whiteColor]];

    // configure button font
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];

    // set title
    NSString *title = [self putUserNameTogether:self.PFUsersInChat];
    self.title = title;
    self.messageInputView.textView.placeHolder = @"New Message";
    self.sender = [BLKUser currentUser].profileName;
    [self.tableView reloadData];
}

- (NSString *)putUserNameTogether:(NSMutableArray *)users
{
    NSMutableString *userString = [[NSMutableString alloc] init];
    for (BLKUser *user in users){
        if (![user.username isEqual:[BLKUser currentUser].username]){
            if (user[@"profileName"]) {
                if (userString.length > 0)[userString appendString:@" "];
                [userString appendString:user[@"profileName"]];
            }
        }
    }
    return userString;
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

    BLKMessageObject *message = [[BLKMessageObject alloc] init];

    PFACL *acl = [PFACL ACL];
    for (BLKUser *user in self.PFUsersInChat){
        [acl setWriteAccess:TRUE forUser:user];
        [acl setReadAccess:TRUE forUser:user];
    }
    [message setACL:acl];
    message.message = text;
    message.sender = [BLKUser currentUser];
    message.senderName = [BLKUser currentUser][@"profileName"];

    // objects saved in relation must be saved to parse before being saved in relation
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // check for existing object, then update
        // else create a new chat object

        PFQuery *chatQuery = [PFQuery queryWithClassName:@"Chat"];

        // TODO figure out how to exact match rather than match and then filter results
        [chatQuery whereKey:@"participants" containsAllObjectsInArray:self.PFUsersInChat];
        [chatQuery includeKey:@"participants"];
        [chatQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                BOOL isSaved = false;
                for (PFObject *potentialChat in objects){
                    // is exact match
                    if ([potentialChat[@"participants"] count] == self.PFUsersInChat.count){
                        isSaved = true;
                        PFObject *chat = potentialChat; // only one
                        [chat addObject:message forKey:@"messages"];
                        [chat setValue:[BLKUser currentUser] forKey:@"sender"];
                        [chat setValue:text forKey:@"mostRecentMessage"];
                        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (error) NSLog(@"Error message: %@", [error localizedDescription]);
                            else {
                                NSLog(@"Save in background succeeded");
                            }
                        }];
                        return;
                    }

                }
                if (!isSaved) {
                    PFObject *chat = [PFObject objectWithClassName:@"Chat"];
                    [chat addObject:message forKey:@"messages"];
                    [chat addUniqueObjectsFromArray:self.PFUsersInChat forKey:@"participants"];
                    [chat setValue:text forKey:@"mostRecentMessage"];
                    [chat setValue:[BLKUser currentUser] forKey:@"sender"];
                    [chat saveInBackground];
                }
            }
        }];
    }];

}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage *myMessage = (JSMessage *)self.messages[indexPath.row];
    if ([[BLKUser currentUser].profileName isEqualToString:myMessage.sender]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSMessage *myMessage = (JSMessage *)self.messages[indexPath.row];
    if ([[BLKUser currentUser].profileName isEqualToString:myMessage.sender]) {
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

#pragma mark - new chat message data source
- (void)newMessageRecievedAllMessages:(NSMutableArray *)messages
{
    self.messages = [self messagesFromBLKMessages:messages];
    [self.tableView reloadData];
}

- (void)newMessageRecieved:(BLKMessageObject *)message
{
    [self.messages addObject:[self messageFromBLKMessageObject:message]];
    [self.tableView reloadData];
}

#pragma mark - Load in current message data
- (void)setupMessageDataWithUsers:(NSMutableArray *)users
{
    // for fetching the proper BLKMessageObjects
    NSMutableArray *chatMessages = [[BLKChatData instance] messagesForConversationBetween:users];

    self.messages = [NSMutableArray new];
    // use each BLKMessage Object to create JSMessage
    self.messages = [self messagesFromBLKMessages:chatMessages];

    //self.messages = [NSMutableArray new];
    self.PFUsersInChat = [[NSMutableArray alloc] initWithArray:users];

    self.avatars = [NSMutableDictionary new];
    [self setAvatarsForPFUsers:self.PFUsersInChat];
}

- (void)setAvatarsForPFUsers:(NSMutableArray *)blkUsers
{
    for (BLKUser *user in blkUsers){

        UIImage *placeholderImage = [UIImage imageNamed:@"user_circle"];

        [self.avatars setValue:[JSAvatarImageFactory avatarImage:placeholderImage croppedToCircle:YES] forKey:user.profileName];
        [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            BLKUser *refreshedUser = (BLKUser *)object;
            [refreshedUser.profilePictureThumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [self.avatars setValue:[JSAvatarImageFactory avatarImage:[UIImage imageWithData:data] croppedToCircle:YES] forKey:user.profileName];
                [self.tableView reloadData];
            }];
        }];

    }
}

#pragma mark - UTILS
- (JSMessage *)messageFromBLKMessageObject:(BLKMessageObject *)message
{
    return [[JSMessage alloc] initWithText:message.message sender:message.senderName date:message.createdAt];
}

- (NSMutableArray *)messagesFromBLKMessages:(NSMutableArray *)messages
{
    NSMutableArray *chatBubbles = [NSMutableArray new];
    for (BLKMessageObject *message in messages){
        [chatBubbles addObject:[[JSMessage alloc] initWithText:message.message sender:message.senderName date:message.createdAt]];
    }
    return chatBubbles;
}


@end
