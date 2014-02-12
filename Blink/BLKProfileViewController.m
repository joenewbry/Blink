//
//  BLKProfileViewController.m
//  Blink
//
//  Created by Joe Newbry on 2/9/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKProfileViewController.h"
#import <Parse/Parse.h>

@interface BLKProfileViewController ()

@property (strong, nonatomic) NSMutableData *imgData;

@end

@implementation BLKProfileViewController

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor greenColor]];

    UILabel *profileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, 100, 100)];
    profileNameLabel.text = [PFUser currentUser][@"profileName"];
    profileNameLabel.textColor = [UIColor purpleColor];
    [self.view addSubview:profileNameLabel];

    UILabel *profileStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 80, 200,100)];
    profileStatusLabel.text = [PFUser currentUser][@"relationship"];
    [self.view addSubview:profileStatusLabel];

    UILabel *profileGenderLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 120, 200, 100)];
    profileGenderLabel.text = [PFUser currentUser][@"gender"];
    [self.view addSubview:profileGenderLabel];

    UILabel *profileBirthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 160, 200, 100)];
    profileBirthdayLabel.text = [PFUser currentUser][@"birthday"];
    [self.view addSubview:profileBirthdayLabel];
	// Do any additional setup after loading the view.

    [self getFacebookProfileInformationAndSaveToParseUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFacebookProfileInformationAndSaveToParseUser
{
    FBRequest *request = [FBRequest requestForMe];

    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"An error occured getting FBData: erro %@", error);
        } else {
            NSDictionary *userData = (NSDictionary *)result;

            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *gender = userData[@"gender"];
            NSString *birthday = userData[@"birthday"];
            NSString *relationship = userData[@"relationship_status"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];

            PFUser *currentUser = [PFUser currentUser];

            [PFUser currentUser][@"facebookID"] = facebookID;
            [PFUser currentUser][@"profileName"] = name;
            [PFUser currentUser][@"gender"] = gender;
            [PFUser currentUser][@"birthday"] = birthday;
            [PFUser currentUser][@"relationship"] = relationship;

            [currentUser saveInBackground];

            _imgData = [[NSMutableData alloc] init];

            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];

            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        }
    }];
}

// Called every time a chunk of the data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_imgData appendData:data]; // Build the image
}

// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set the image in the header imageView
    PFFile *imageFile = [PFFile fileWithData:_imgData];
    [PFUser currentUser][@"profileImage"] = imageFile;
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) NSLog(@"Error is %@", [error localizedDescription]);
    }];

    UIImageView *profileImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:_imgData]];
    [self.view addSubview:profileImageView];
    [self.view sendSubviewToBack:profileImageView];
}

@end
