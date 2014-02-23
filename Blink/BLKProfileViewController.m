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

@property (nonatomic) NSMutableString *profileDetailHeaderString;
@property (nonatomic) NSMutableString *profileDetailLabelString;
@property (strong, nonatomic) NSMutableData *imgData;

@property (strong, nonatomic) NSURLConnection *URLConnection;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIView *detailView;

@property (weak, nonatomic) IBOutlet UILabel *profileDetailInformationLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileDetailHeaderLabel;



@end

@implementation BLKProfileViewController

# pragma mark-- Getters_Setters

@synthesize profileDetailLabelString = _profileDetailLabelString;
@synthesize profileDetailHeaderString = _profileDetailHeaderString;

-(NSMutableString *)profileDetailLabelString {
    if (!_profileDetailLabelString) _profileDetailLabelString = [[NSMutableString alloc] initWithString:@"Try inviting more friends to improve the Blink experience"];
    
    return _profileDetailLabelString;
}

-(NSMutableString *)profileDetailHeaderString {
    if (!_profileDetailHeaderString) _profileDetailHeaderString = [[NSMutableString alloc] initWithString:@"Nobody Nearby"];
    
    return _profileDetailHeaderString;
}

-(void)setProfileDetailHeaderString:(NSMutableString *)profileDetailHeaderString {
    _profileDetailHeaderString = profileDetailHeaderString;
    
    [self update];
}

-(void)setProfileDetailLabelString:(NSMutableString *)profileDetailLabelString {
    _profileDetailLabelString = profileDetailLabelString;
    
    [self update];
}

# pragma mark-- initilization methods

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
    
    [self getFacebookProfileInformationAndSaveToParseUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-- FacebookInitilization

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
            
            //*** this is where the data properties are being used to set the label text ***/
            self.profileDetailHeaderString = [[NSMutableString alloc] initWithString:name];
            self.profileDetailLabelString = [[NSMutableString alloc] initWithString:gender];
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
    
   
    [self update];
}

# pragma mark-- UpdateMethod

- (void)update {
    
    [self.profileDetailHeaderLabel  setText:self.profileDetailHeaderString];
    [self.profileDetailInformationLabel setText:self.profileDetailLabelString];
    [self.profileImage setImage:[[UIImage alloc] initWithData:self.imgData]];
    
}

@end
