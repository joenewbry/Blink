//
//  BLKProfileViewController.m
//  Blink
//
//  Created by Joe Newbry on 2/9/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKMyProfileViewController.h"
#import <Parse/Parse.h>
#import "UIViewController+ViewUtils.h"

@interface BLKMyProfileViewController ()

@property (nonatomic) NSMutableString *profileDetailHeaderString;
@property (nonatomic) NSMutableString *profileDetailLabelString;
@property (strong, nonatomic) NSMutableData *imgData;

@property (strong, nonatomic) NSURLConnection *URLConnection;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIView *detailView;

@property (weak, nonatomic) IBOutlet UILabel *profileDetailInformationLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileDetailHeaderLabel;



@end

@implementation BLKMyProfileViewController

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
    [self displayPushNotificationFrom:@"Chad" WithMessage:@"Wanna lyft and stuff"];
    [self displayLogoutModal];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark-- UpdateMethod

- (void)update {
    
    [self.profileDetailHeaderLabel  setText:self.profileDetailHeaderString];
    [self.profileDetailInformationLabel setText:self.profileDetailLabelString];
    [self.profileImage setImage:[[UIImage alloc] initWithData:self.imgData]];
    
}

@end
