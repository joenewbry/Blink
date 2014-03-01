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
#import "SBBroadcastUser.h"
#import "SBUserDiscovery.h"
#import "BLKConstants.h"
#import "BLKSaveImage.h"
#import "SBNearbyUsers.h"
#import "BLKMessageData.h"
#import <NZAlertView/NZAlertView.h>


@interface BLKSignUpViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *logoView;

@end

@implementation BLKSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:true];
    if ([SBBroadcastUser isBuilt]) [[SBBroadcastUser currentBroadcastScaffold] peripheralManagerEndBroadcastServices];
    if ([SBUserDiscovery isBuilt]) [[SBUserDiscovery userDiscoveryScaffold] stopSearchForUsers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)facebookLoginPressed:(id)sender {
    [self startSpin:self.logoView];

    NSArray *permissionsArray = @[@"user_about_me", @"user_relationships", @"user_birthday"];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            [self stopSpin]; // stop spinner
            if (!error) {
                NSLog(@"User canceled facebook login");
                NZAlertView *canceledAlert = [[NZAlertView alloc] initWithStyle:NZAlertStyleInfo title:@"Facebook login canceled" message:@"To use Blink you need to sign in with Facebook."];
                [canceledAlert setTextAlignment:NSTextAlignmentLeft];
                [canceledAlert show];
            } else {
                NSLog(@"An error occuered: %@", error);
                if (error.code == 5){ // Internet connection appears to be offline
                    NZAlertView *connectivityAlert = [[NZAlertView alloc] initWithStyle:NZAlertStyleInfo title:@"The Gnomes are on Strike" message:@"No internet connection detected. Try turning on 3G, 4G, or connecting to wifi!"];
                    [connectivityAlert setTextAlignment:NSTextAlignmentLeft];
                    [connectivityAlert show];
                }

            }

        } else {
            FBRequest *request = [FBRequest requestForMe];

            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                [self stopSpin]; // stop spinning modal
                if (error) {
                    NSLog(@"An error occured getting FBData: erro %@", error);
                    NZAlertView *fbDataErrorAlert = [[NZAlertView alloc] initWithStyle:NZAlertStyleInfo title:@"Oops, No Facebook Data" message:@"We weren't able to fetch your Facebook data. Try connecting with Facebook again. If you still can't log in get send an email to joenewbry@gmail.com or text 1-541-760-1871."];
                    [fbDataErrorAlert setTextAlignment:NSTextAlignmentLeft];
                    [fbDataErrorAlert show];
                } else {
                    if (user) {
                        // TODO: sometimes breaks doesn't perform segue
                        NSLog(@"User has connected with facebook, initialize all processes");
                        // stop spining icon
                        [self stopSpin];
                        [self performSegueWithIdentifier:@"toHomeScreen" sender:self];

                        NSDictionary *userData = (NSDictionary *)result;
                        [self parseUserDataAndSaveToParse:userData]; // FBProfileData to PFUser
                        [self shareProfileViaBluetooth]; // share PFUser data over bluetooth
                        [self saveInstallationForPush]; // save unique push channel for logged in user
                        [[BLKSaveImage instanceSavedImage] saveImageInBackground:[NSURL URLWithString:[PFUser currentUser][@"pictureURL"]]]; // save image on another thread, maybe this will work

                        [[SBNearbyUsers instance] searchForUsers]; // instantiates User discover and starts search, listening for UUIDs

                        [[BLKMessageData instance] searchForMessagesIncluding:user]; // starts search for messages that include current user, return in format that displays well in table view and also includes message data
                    }
                }
            }];
        }
    }];
}

- (void)parseUserDataAndSaveToParse:(NSDictionary *)userData
{
    NSString *facebookID = userData[@"id"];
    NSString *name = userData[@"name"];
    NSString *gender = userData[@"gender"];
    NSString *birthday = userData[@"birthday"];
    NSString *relationship = userData[@"relationship_status"];
    NSString *college = [self getCollegeStringFromEducation:userData[@"education"]];
    NSString *quotes = userData[@"quotes"];
    NSString *pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];

    // save facebook information to parse
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"facebookID"] = facebookID;
    currentUser[@"profileName"] = name;
    currentUser[@"gender"] = gender;
    currentUser[@"birthday"] = birthday;
    currentUser[@"relationship"] = relationship;
    currentUser[@"college"] = college;
    currentUser[@"quote"] = quotes;
    currentUser[@"pictureURL"] = pictureURL;
    [currentUser saveInBackground];
}

- (void)shareProfileViaBluetooth
{
    [SBUser createUser];
    [SBUser currentUser].userName = [PFUser currentUser].username;
    [SBUser currentUser].objectId = [PFUser currentUser].objectId;
    [SBUser currentUser].quote = [PFUser currentUser][@"quote"];
    [SBUser currentUser].status = [PFUser currentUser][@"relationship"];
}

- (void)saveInstallationForPush
{
    NSString *privateChannelName =[NSString stringWithFormat:@"user_%@", [PFUser currentUser].objectId];
    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:kInstallationUserKey];
    [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kInstallationChannelsKey];
    [[PFInstallation currentInstallation] saveEventually];
    [[PFUser currentUser] setObject:privateChannelName forKey:kUserPrivateChannelKey];
}

BOOL animating;

- (void)spinView:(UIView *)view WithOptions:(UIViewAnimationOptions)options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         view.transform = CGAffineTransformRotate(view.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinView:view WithOptions:UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinView:view WithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin:(UIView *)view {
    if (!animating) {
        animating = YES;
        [self spinView:view WithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
}

- (NSString *)getCollegeStringFromEducation:(FBGraphObject *)fBGraphObject
{
    for (NSDictionary *school in fBGraphObject) {
        if ([school[@"type"] isEqualToString:@"College"]){
            return school[@"school"][@"name"];
        }
    }
    return @"No College Found";
}

@end
