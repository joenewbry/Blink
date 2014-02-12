//
//  BLKOneProfileViewController.m
//  Blink
//
//  Created by Joe Newbry on 2/10/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKOneProfileViewController.h"
#import <Parse/Parse.h>

@interface BLKOneProfileViewController ()

@end

@implementation BLKOneProfileViewController

- (id)initWithPFUserObjectID:(NSString *)userObjectID
{
    self = [super init];
    if (self)   {
        PFQuery *userProfileQuery = [PFQuery queryWithClassName:@"_User"];
        [userProfileQuery whereKey:@"objectId" equalTo:userObjectID];
        [userProfileQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {

            UILabel *profileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, 100, 100)];
            profileNameLabel.text = object[@"profileName"];
            profileNameLabel.textColor = [UIColor purpleColor];
            [self.view addSubview:profileNameLabel];

            UILabel *profileStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 80, 200,100)];
            profileStatusLabel.text = object[@"relationship"];
            [self.view addSubview:profileStatusLabel];

            UILabel *profileGenderLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 120, 200, 100)];
            profileGenderLabel.text = object[@"gender"];
            [self.view addSubview:profileGenderLabel];

            UILabel *profileBirthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 160, 200, 100)];
            profileBirthdayLabel.text = object[@"birthday"];
            [self.view addSubview:profileBirthdayLabel];

            [object[@"profileImage"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                UIImageView *profileImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
                [self.view addSubview:profileImageView];
                [self.view sendSubviewToBack:profileImageView];
            }];

        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
