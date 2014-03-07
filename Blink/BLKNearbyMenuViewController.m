//
//  BLKNearbyMenuViewController.m
//  Blink
//
//  Created by Chad Newbry on 2/21/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKNearbyMenuViewController.h"
#import "UIViewController+ViewUtils.h"
#import "BLKChatViewController.h"
#import "SBNearbyUsers.h"
#import "BLKChatData.h"
#import "BLKOtherPersonProfileViewController.h"
#import "BLKYourProfileViewController.h"
#import "BLKOtherPersonProfileViewController.h"
#import <JSMessagesViewController/JSAvatarImageFactory.h>
#import "SBUser.h"
#import "BLKChatData.h"
#import "BLKSaveImage.h"
#import "SBUserConnection.h"
#import "SBUserBroadcast.h"
#import "CALayer+Pulse.h"

@interface BLKNearbyMenuViewController () <SBUserConnectionDelegate, BLKChatDataDelegate>

@property (nonatomic)NSMutableDictionary *profileDictionary;
@property (nonatomic)NSMutableArray *messageArray;
@property (nonatomic)NSMutableArray *nearbyUsersArray;
@property (nonatomic)BLKUser *selectedUser;
@property (nonatomic)NSMutableArray *usersInConversation;
@property (nonatomic)PFObject *messageData;

@property (strong, nonatomic) CALayer *pulse;

@end

@implementation BLKNearbyMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!TARGET_IPHONE_SIMULATOR) {
        // Share Profile
        [SBUser createUserWithObjectId:[BLKUser currentUser].objectId];
        [[SBUserBroadcast currentUserBroadcast] peripheralAddUserProfileService];

        // Search for profile
        [SBUserConnection createUserConnection];
        // start recieving user discovery messages
        [SBUserConnection currentUserConnection].delegate = self;
        self.nearbyUsersArray = [[SBUserConnection currentUserConnection] allUsersBy:SBNextUserByNewest];
    }

    [[BLKChatData instance] searchForMessagesIncluding:[BLKUser currentUser]]; // starts search for messages that include current user, return in format that displays well in table view and also includes message data
    [BLKChatData instance].delegate = self;
    [[BLKChatData instance] refresh];

    // handles saving user profile image on background thread
    // TODO move to block in sign up view rather than own class
    [[BLKSaveImage instanceSavedImage] saveImageInBackground:[NSURL URLWithString:[BLKUser currentUser][@"pictureURL"]]]; // save image on another thread
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // start recieving message discovery messages

    [BLKChatData instance].delegate = self;
    self.messageArray = [[BLKChatData instance] chats];
    [BLKChatData instance].delegate = self;

    //set the background and shadow image to get rid of the line
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc]init];
}

- (void)viewDidAppear:(BOOL)animated
{
//    [CATransaction begin]; {
//        [CATransaction setAnimationDuration:3.0];
//        self.pulse.bounds = CGRectMake(0, 0, 40, 40);
//        self.pulse.opacity = 1.0;
//        self.pulse.cornerRadius = 20;
//    }
//    [CATransaction commit];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Returns count of unread and nearby arrays or 1 for profile section
    
    if (section == 0) return [self.messageArray count];
    if (section == 1) return [self.nearbyUsersArray count];
    return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    [headerView setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:51.0/255.0 alpha:1.0]];
    [headerView setAlpha:1];
    
    NSString *headerText;
    
    if (section == 0) headerText = @"Messages";
    if (section == 1) headerText = @"Nearby";
    
    UILabel *customLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, 300.0, 20.0)];
    customLabel.textColor = [UIColor colorWithRed:234.0 green:222.0 blue:252.0 alpha:1];
    [customLabel setText:headerText];
    [headerView addSubview:customLabel];

    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"MessagingCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

        cell.textLabel.text = [self putUserNameTogether:self.messageArray[indexPath.row][@"participants"]];
        cell.detailTextLabel.text = self.messageArray[indexPath.row][@"mostRecentMessage"];
        PFFile *imageThumbnail = self.messageArray[indexPath.row][@"participants"][0][@"thumbnailImage"];
        [imageThumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            cell.imageView.image = [JSAvatarImageFactory avatarImage:[UIImage imageWithData:data] croppedToCircle:NO];
        }];

        return cell;
        
    } else if (indexPath.section == 1){
        static NSString *CellIndentifier = @"NearbyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier forIndexPath:indexPath];

        // get the user
        BLKUser *myUser = [self.nearbyUsersArray objectAtIndex:indexPath.row];
        cell.layer.cornerRadius = cell.layer.bounds.size.height/2;

        cell.clipsToBounds = true;
        cell.textLabel.text = myUser.profileName;
        [myUser.profilePictureThumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            cell.imageView.image = [JSAvatarImageFactory avatarImage:[UIImage imageWithData:data] croppedToCircle:YES];
            [CALayer pulseLayer:cell.imageView.layer];

        }];
        cell.imageView.image = [UIImage imageNamed:@"user_circle"];


        return cell;
        
    }
    
    return nil;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if (indexPath.section == 2) [self.nearbyUsersArray removeObjectAtIndex:indexPath.row];
        if (indexPath.section == 1) [self.messageArray removeObjectAtIndex:indexPath.row];

        // When this next line is executed, the data has to agree with the changes this line is performing on the table view
        // if the data doesn't agree, the app falls all over itself and dies
        // that's why we remove the object from the contacts first
        // if you don't believe me, try reversing these two lines... just go ahead and try
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }

}

#pragma mark - Table View Delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    //Disable editing for 1st row in section
    return (indexPath.section == 0) ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        PFObject *chat = self.messageArray[indexPath.row];
        self.usersInConversation = [NSMutableArray new];
        self.usersInConversation = chat[@"participants"];

        [self performSegueWithIdentifier:@"toChat" sender:self];
    }
    if (indexPath.section == 1){
        self.selectedUser = self.nearbyUsersArray[indexPath.row];
        [self performSegueWithIdentifier:@"toOtherProfile" sender:self];
    }
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if ([segue.destinationViewController isKindOfClass:[BLKChatViewController class]]) {
        [segue.destinationViewController setupMessageDataWithUsers:self.usersInConversation];
    }
    
    if ([segue.identifier isEqualToString:@"toOtherProfile"]) {
        if ([segue.destinationViewController isKindOfClass:[BLKOtherPersonProfileViewController class]]) {
                    BLKOtherPersonProfileViewController *ovc = (BLKOtherPersonProfileViewController *)segue.destinationViewController;
                    //see above for values to pass

            [ovc setBLKUser:self.selectedUser];

        }
    }
    if ([segue.identifier isEqualToString:@"toMyProfile"]) {
        if ([segue.destinationViewController isKindOfClass:[BLKYourProfileViewController class]]) {
            BLKYourProfileViewController *pvc = (BLKYourProfileViewController *)segue.destinationViewController;
            [pvc setBLKUser:[BLKUser currentUser]];
        }
    }
}



#pragma mark - SBUserConnectionDelegate (For discovering when people are nearby)
- (void)userDidConnect:(BLKUser *)user
{
    if (!self.nearbyUsersArray) self.nearbyUsersArray = [NSMutableArray new];
    [self.nearbyUsersArray addObject:user];
    [self.tableView reloadData];
}

- (void)userDisconnectedWithNewArray:(NSMutableArray *)newArray
{
    self.nearbyUsersArray = newArray;
    [self.tableView reloadData];
}

#pragma mark - BLKMessageDataDelegate
// TODO implement this in 
- (void)newChatRecieved:(PFObject *)chat
{
    [self.messageArray addObject:chat];
    [self.tableView reloadData];
}

#pragma mark - support classes
- (NSString *)putUserNameTogether:(NSMutableArray *)users
{
    NSMutableString *userString = [[NSMutableString alloc] init];
    for (BLKUser *user in users){
        if (![user.username isEqual:[BLKUser currentUser].username]){
            if (user[@"profileName"]) {
                if (userString.length > 0)[userString appendString:@" & "];
                [userString appendString:user[@"profileName"]];
            }
        }
    }
    return userString;
}


@end
