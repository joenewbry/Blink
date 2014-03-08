//
//  BLKOtherPersonProfileViewController.m
//  Blink
//
//  Created by Chad Newbry on 2/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKOtherPersonProfileViewController.h"
#import "BLKChatViewController.h"

@interface BLKOtherPersonProfileViewController ()

@end

@implementation BLKOtherPersonProfileViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] //notice back button set on this vc for display in next vc
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStyleBordered
                                   target:Nil action:nil];
    
    [self.navigationItem setBackBarButtonItem:backButton];
}

- (IBAction)chatButtonPressed:(UIBarButtonItem *)sender {
    BLKChatViewController *chatController = [[BLKChatViewController alloc] init];

    [chatController setupMessageDataWithUsers:[[NSMutableArray alloc] initWithObjects:self.user,[BLKUser currentUser], nil]]; //TODO pass array of users in chat

    
    [self.navigationController pushViewController:chatController animated:NO];
}



@end
