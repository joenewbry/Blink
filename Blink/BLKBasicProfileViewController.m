//
//  BLKProfileViewController.m
//  Blink
//
//  Created by Joe Newbry on 2/9/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKBasicProfileViewController.h"
#import <Parse/Parse.h>
#import "UIViewController+ViewUtils.h"
#import "UIView+LinerGradient.h"
#import "BLKFeed.h"

@interface BLKBasicProfileViewController ()

@property (strong, nonatomic) NSURLConnection *URLConnection;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *relationshipLabel;
@property (weak, nonatomic) IBOutlet UILabel *collegeLabel;
@property (weak, nonatomic) IBOutlet BLKFeed *feedView;

@property (nonatomic) NSMutableArray *labelArray;


@end

@implementation BLKBasicProfileViewController

# pragma mark-- Getters_Setters

@synthesize quote = _quote;
@synthesize username = _username;

/*
- (BLKFeed *)feedView {
    
    if (!_feedView) _feedView = [[BLKFeed alloc] initWithTimerInterval:3.0];
    
}
*/

-(void)setSBUserModel:(SBUserModel *)SBUserModel {
    _SBUserModel = SBUserModel;
    
    //anytime the SBUserModel gets set all the properties
    _profileImage = _SBUserModel.profileImage;
    
    _username = (NSMutableString *)_SBUserModel.username;
    
    _quote = (NSMutableString *)_SBUserModel.quote;
    _college = (NSMutableString *)_SBUserModel.college;
    _relationshipStatus = (NSMutableString *)_SBUserModel.relationshipStatus;
}

- (void)setProfileImage:(UIImage *)profileImage {
    _profileImage = profileImage;
    [self update];
}

-(NSMutableString *)username {
    if (!_username) _username = [[NSMutableString alloc] initWithString:@"Nobody Nearby"];
    
    return _username;
}

-(void)setUsername:(NSMutableString *)username {
    _username = username;
    
    [self update];
}

- (NSMutableArray *)labelArray {
    if (!_labelArray) _labelArray = [[NSMutableArray alloc] init];
    
    return _labelArray;
}

-(NSMutableString *)quote {
    if (!_quote) _quote = [[NSMutableString alloc] initWithString:@"Try inviting more friends to improve the Blink experience"];
    
    return _quote;
}

- (void)setQuote:(NSMutableString *)quote {
    _quote = quote;
    [self update];
}

- (void)setRelationshipStatus:(NSMutableString *)relationshipStatus {
    _relationshipStatus = relationshipStatus;
    
    [self update];
}

- (void)setCollege:(NSMutableString *)college {
    _college = college;
    
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
    [self.labelArray addObjectsFromArray:@[self.nameLabel, self.quoteLabel, self.collegeLabel, self.relationshipLabel]];
    [self update];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark-- UpdateMethod

- (void)update {
<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream
    [self.imageView setImage:[[UIImage alloc] initWithData:self.imgData]];
    [self.nameLabel  setText:self.nameString];
    [self.quoteLabel setText:self.quoteString];
    [self.collegeLabel setText:self.collegeString];
    [self.relationshipLabel setText:self.relationshipString];
=======
>>>>>>> Stashed changes
    [self.imageView setImage:self.profileImage];
    [UIView addLinearGradientToView:self.imageView withPercentageCoverage:0.2 withColor:[UIColor blackColor] transparentToOpaque:YES];
    
    [self.nameLabel  setText:self.username];
    [self.quoteLabel setText:self.quote];
    [self.collegeLabel setText:self.college];
    [self.relationshipLabel setText:self.relationshipStatus];
    
<<<<<<< Updated upstream
    
=======
    if ([self.feedView isEmpty]) {
        [self.feedView addToFeed:[self.quoteLabel mutableCopy]];
        [self.feedView addToFeed:[self.collegeLabel mutableCopy]];
        [self.feedView addToFeed:[self.relationshipLabel mutableCopy]];
    }
    
    self.feedView.isAnimating = YES;
>>>>>>> Stashed changes
>>>>>>> Stashed changes
    
}



#pragma mark-- Helper

- (UILabel *)getLabelFromTag:(NSInteger)tag {
    
    for (UILabel *label in self.labelArray) {
        if (label.tag == tag) {
            return label;
            break; // don't know if this is necessary
        }
    }
    
    NSLog(@"error didn't find frame for tag");
    return [[UILabel alloc] init];
    
}

- (void)setLablesToHidden:(BOOL)hidden {
    [self.labelArray setValue:[NSNumber numberWithBool:hidden] forKey:@"hidden"];
    NSLog(@"Hide values called");
}

@end
