//
//  BLKOtherPersonProfileViewController.m
//  Blink
//
//  Created by Chad Newbry on 2/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKOtherPersonProfileViewController.h"

@interface BLKOtherPersonProfileViewController ()

@property (nonatomic, strong) SBUserModel* userData;

@end

@implementation BLKOtherPersonProfileViewController

- (void)setupUserData:(SBUserModel *)userData
{
    self.userData = userData;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

   
}

@end
