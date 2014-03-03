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
#import "BLKMessageData.h"
#import "BLKOtherPersonProfileViewController.h"
#import "BLKYourProfileViewController.h"
#import "BLKOtherPersonProfileViewController.h"
#import <JSMessagesViewController/JSAvatarImageFactory.h>
#import "SBUser.h"
#import "BLKMessageData.h"
#import "BLKSaveImage.h"

@interface BLKNearbyMenuViewController () <SBNearbyUsersDelegate, BLKMessageDataDelegate>

@property (nonatomic)NSMutableDictionary *profileDictionary;
@property (nonatomic)NSMutableArray *messageArray;
@property (nonatomic)NSMutableArray *nearbyArray;
@property (nonatomic)SBUserModel *selectedUser;
@property (nonatomic)PFObject *messageData;

@end

@implementation BLKNearbyMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self shareProfileViaBluetooth]; // share PFUser data over bluetooth
    [[SBNearbyUsers instance] searchForUsers]; // instantiates User discover and starts search, listening for UUIDs

    [[BLKMessageData instance] searchForMessagesIncluding:[PFUser currentUser]]; // starts search for messages that include current user, return in format that displays well in table view and also includes message data

    [[BLKSaveImage instanceSavedImage] saveImageInBackground:[NSURL URLWithString:[PFUser currentUser][@"pictureURL"]]]; // save image on another thread
}

- (void)shareProfileViaBluetooth
{
    [SBUser createUser];
    [SBUser currentUser].userModel.username = [PFUser currentUser][@"profileName"];
    [SBUser currentUser].userModel.objectId = [PFUser currentUser].objectId;
    [SBUser currentUser].userModel.quote = [PFUser currentUser][@"quote"];
    [SBUser currentUser].userModel.relationshipStatus = [PFUser currentUser][@"relationship"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    // start recieving user discovery messages
    [SBNearbyUsers instance].delegate = self;
    self.nearbyArray = [[SBNearbyUsers instance] allUsers];

    // start recieving message discovery messages
    [BLKMessageData instance].delegate = self;
    self.messageArray = [[BLKMessageData instance] chats];
    [BLKMessageData instance].delegate = self;

    //set the background and shadow image to get rid of the line
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc]init];
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
    if (section == 1) return [self.nearbyArray count];
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

        cell.textLabel.text = [self putUserNameTogether:self.messageArray[indexPath.row][@"recipientsArrayPFUser"]];
        cell.detailTextLabel.text = self.messageArray[indexPath.row][@"mostRecentMessage"];
        PFFile *imageThumbnail = self.messageArray[indexPath.row][@"recipientsArrayPFUser"][0][@"thumbnailImage"];
        [imageThumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            cell.imageView.image = [JSAvatarImageFactory avatarImage:[UIImage imageWithData:data] croppedToCircle:YES];
        }];

        return cell;
        
    } else if (indexPath.section == 1){
        static NSString *CellIndentifier = @"NearbyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier forIndexPath:indexPath];
        cell.layer.cornerRadius = cell.layer.bounds.size.height/2;
        cell.clipsToBounds = true;
        cell.textLabel.text = [self.nearbyArray[indexPath.row] username];
        cell.imageView.image = [JSAvatarImageFactory avatarImage:[self.nearbyArray[indexPath.row] thumbnailImg] croppedToCircle:YES];
               
        return cell;
        
    }
    
    return nil;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if (indexPath.section == 2) [self.nearbyArray removeObjectAtIndex:indexPath.row];
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
        self.messageData = self.messageArray[indexPath.row];
        [self performSegueWithIdentifier:@"toChat" sender:self];
    }
    if (indexPath.section == 1){
        self.selectedUser = self.nearbyArray[indexPath.row];
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
        [segue.destinationViewController setupMessageData:self.messageData];
    }
    
    if ([segue.identifier isEqualToString:@"toOtherProfile"]) {
        if ([segue.destinationViewController isKindOfClass:[BLKOtherPersonProfileViewController class]]) {
                    BLKOtherPersonProfileViewController *ovc = (BLKOtherPersonProfileViewController *)segue.destinationViewController;
                    //see above for values to pass
            ovc.SBUserModel = self.selectedUser;
           
        }
    }
    if ([segue.identifier isEqualToString:@"toMyProfile"]) {
        if ([segue.destinationViewController isKindOfClass:[BLKYourProfileViewController class]]) {
            BLKYourProfileViewController *pvc = (BLKYourProfileViewController *)segue.destinationViewController;
            pvc.SBUserModel = [SBUser currentUser].userModel;
        }
    }
}



#pragma mark - NearbyUserDelegate
- (void)userConnectedWithNewArray:(NSMutableArray *)newArray
{
    self.nearbyArray = newArray;
    [self.tableView reloadData];
}

- (void)userDisconnectedWithNewArray:(NSMutableArray *)newArray
{
    self.nearbyArray = newArray;
    [self.tableView reloadData];
}

#pragma mark - BLKMessageDataDelegate
- (void)newMessageRecievedAllMessages:(NSMutableArray *)messages
{
    self.messageArray = messages;
    [self.tableView reloadData];
}

#pragma mark - support classes
- (NSString *)putUserNameTogether:(NSMutableArray *)users
{
    NSMutableString *userString = [[NSMutableString alloc] init];
    for (PFUser *user in users){
        if (![user.username isEqual:[PFUser currentUser].username]){
            if (user[@"profileName"]) {
                if (userString.length > 0)[userString appendString:@" & "];
                [userString appendString:user[@"profileName"]];
            }
        }
    }
    return userString;
}


@end
