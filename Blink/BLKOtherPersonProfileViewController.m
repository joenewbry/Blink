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

- (IBAction)chatButtonPressed:(UIBarButtonItem *)sender {
    BLKChatViewController *chatController = [[BLKChatViewController alloc] init];

    [chatController setupMessageDataWithUsers:[[NSMutableArray alloc] initWithObjects:self.user, nil]]; //TODO pass array of users in chat

    [self.navigationController pushViewController:chatController animated:NO];
}



@end
