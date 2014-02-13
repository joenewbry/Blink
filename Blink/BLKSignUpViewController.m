//
//  BLKViewController.m
//  Blink
//
//  Created by Joe Newbry on 2/9/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKSignUpViewController.h"
#import <Parse/Parse.h>
#import "BLKProfileViewController.h"
#import "SBUser.h"

@implementation BLKSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [SBUser createUserWithName:@"Joe Newbry"];
    NSMutableArray *users = [NSMutableArray arrayWithArray:@[[SBUser currentUser]]];
    [users addObject:[SBUser createUserWithName:@"Chad Newbry"]];
    for (SBUser *user  in users){
        NSLog(@"user name is %@", user.userName);
    }

    //NSLog(@"username is %@", [PFUser currentUser].username);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)facebookLoginPressed:(id)sender {
    NSArray *permissionsArray = @[@"user_about_me", @"user_relationships", @"user_birthday"];

    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {

        if (!user) {
            if (!error) {
                NSLog(@"User canceled facebook login");
            } else {
                NSLog(@"An error occuered: %@", error);
            }

        } else if (user.isNew) {
            NSLog(@"there is a new user");
            BLKProfileViewController *profileVC = [[BLKProfileViewController alloc] init];
            [self presentViewController:profileVC animated:NO completion:nil];
        } else {
            NSLog(@"Existing FBUser logged in");
            BLKProfileViewController *profileVC = [[BLKProfileViewController alloc] init];
            [self presentViewController:profileVC animated:NO completion:nil];
        }

    }];
}
@end
