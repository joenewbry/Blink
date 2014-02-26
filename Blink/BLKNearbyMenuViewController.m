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

@interface BLKNearbyMenuViewController () <SBNearbyUsersDelegate, BLKMessageDataDelegate>

@property (nonatomic)NSMutableDictionary *profileDictionary;
@property (nonatomic)NSMutableArray *messageArray;
@property (nonatomic)NSMutableArray *nearbyArray;
@property (nonatomic)SBUserModel *selectedUser;

@end

@implementation BLKNearbyMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // start recieving user discovery messages
    [SBNearbyUsers instance].delegate = self;
    self.nearbyArray = [[SBNearbyUsers instance] allUsers];

    // start recieving message discovery messages
    [BLKMessageData instance].delegate = self;
    self.messageArray = [[BLKMessageData instance] messages];
    
    //set the background and shadow image to get rid of the line
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc]init];
    

    self.profileDictionary = [[NSMutableDictionary alloc] initWithDictionary:@{@"username" : @"Chad"}];
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
        cell.textLabel.text = self.messageArray[indexPath.row][@"username"];
        cell.detailTextLabel.text = self.messageArray[indexPath.row][@"message"];

        
        return cell;
        
    } else if (indexPath.section == 1){
        static NSString *CellIndentifier = @"NearbyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier forIndexPath:indexPath];
        cell.textLabel.text = [self.nearbyArray[indexPath.row] username];
               
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
    if (indexPath.section == 1){
        self.selectedUser = self.nearbyArray[indexPath.row];
    }
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"Go To Chat"]) {
        if ([segue.destinationViewController isKindOfClass:[BLKChatViewController class]]) {
            //could set vc properties here
            
        }
    }
    
}

#pragma mark - NearbyUserDelegate
- (void)userConnectedWithNewArray:(NSMutableArray *)newArray
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


@end
