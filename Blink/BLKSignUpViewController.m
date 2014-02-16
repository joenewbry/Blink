//
//  BLKViewController.m
//  Blink
//
//  Created by Joe Newbry on 2/9/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKSignUpViewController.h"
#import <Parse/Parse.h>
#import "SBUser.h"
#import "HomeViewController.h"

@interface BLKSignUpViewController () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableData *imgData;
@property (strong, nonatomic) NSURLConnection *URLConnection;
@property (strong, nonatomic) IBOutlet UILabel *taglineLabel;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;
@property (strong, nonatomic) IBOutlet UIButton *appIconButton;

@end

@implementation BLKSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.taglineLabel.alpha = 0;
    self.signUpButton.alpha = 0;
    [self.navigationController setNavigationBarHidden:true];
    [UIView animateWithDuration:1 animations:^{
        self.taglineLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            self.signUpButton.alpha = 1;
        }];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)facebookLoginPressed:(id)sender {
    NSArray *permissionsArray = @[@"user_about_me", @"user_relationships", @"user_birthday"];
    [UIView animateWithDuration:1 animations:^{
        self.appIconButton.transform = CGAffineTransformMakeRotation(2 * M_PI);
    } completion:^(BOOL finished) {

    }];
        [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {

        if (!user) {
            if (!error) {
                NSLog(@"User canceled facebook login");
            } else {
                NSLog(@"An error occuered: %@", error);
            }

        } else if (user.isNew) {
            
            NSLog(@"there is a new user");
            HomeViewController *homeVC = [[HomeViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:homeVC animated:YES];
        } else {
            NSLog(@"Existing FBUser logged in");
            HomeViewController *homeVC = [[HomeViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:homeVC animated:YES];
        }

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

                // save facebook information to parse
                PFUser *currentUser = [PFUser currentUser];
                [PFUser currentUser][@"facebookID"] = facebookID;
                [PFUser currentUser][@"profileName"] = name;
                [PFUser currentUser][@"gender"] = gender;
                [PFUser currentUser][@"birthday"] = birthday;
                [PFUser currentUser][@"relationship"] = relationship;
                [currentUser saveInBackground];

                _imgData = [[NSMutableData alloc] init];

                NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
                
                self.URLConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            }
        }];

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
}

@end
