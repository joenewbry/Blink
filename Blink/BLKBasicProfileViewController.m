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
#import "BLKNSUserDefaultsHelper.h"

@interface BLKBasicProfileViewController ()

@property (strong, nonatomic) NSURLConnection *URLConnection;


@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *relationshipLabel;
@property (weak, nonatomic) IBOutlet UILabel *collegeLabel;
@property (strong, nonatomic) IBOutlet BLKFeed *feedView;



@property (nonatomic) NSMutableArray *labelArray;


@end

@implementation BLKBasicProfileViewController

# pragma mark-- Getters_Setters

@synthesize quote = _quote;
@synthesize username = _username;

- (BLKFeed *)feedView {
    
    if (!_feedView) _feedView = [[BLKFeed alloc] initWithTimerInterval:3.0];
    return _feedView;
    
}

- (void)setBLKUser:(BLKUser *)user
{
    _user = user;
    
    //if values are already set then no need to fetch them from parse
    //in this case the values have been set by NSUserDefaults
    
   
         // if the current user is you
            dispatch_queue_t fetchImage = dispatch_queue_create("fetch image", NULL);
            dispatch_async(fetchImage,
            ^{
                
                UIImage * tempImage;
                //if current user is you try to read image from NSUserDefaults
                
                if ([[BLKUser currentUser].objectId isEqualToString:_user.objectId])
                {
                
                    tempImage =[[UIImage alloc] initWithContentsOfFile:
                                [BLKNSUserDefaultsHelper getUserPropertyStringForKey:BLK_PROFILE_IMAGE]];
                }
                
                //if image couldn't be read from cache read it Parse
                if (!tempImage)
                {
                    
                    NSError *error;
                    
                    NSData *data = [_user.profilePicture getData:&error];
                    
                    if (error) {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    } else {
                        tempImage = [UIImage imageWithData:data];
                        
                        
                    }
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.profileImage = tempImage;
                    
                });

            });

        
        
    
    
    //TODO bug not urgent
    if (!_username) {
        _username = [_user.profileName mutableCopy];
    }
    
    if (!_quote) {
        _quote = [_user.quote mutableCopy];
    }
    
    if (!_college) {
        _college = [_user.college mutableCopy];
    }
    
    if (!_relationshipStatus) {
        _relationshipStatus = [_user.relationshipStatus mutableCopy];
    }
}

- (NSMutableArray *)labelArray {
    if (!_labelArray) _labelArray  = [[NSMutableArray alloc] init];
    
    return _labelArray;
}

- (void)setProfileImage:(UIImage *)profileImage {
    _profileImage = profileImage;
    [self update];
}


-(void)setUsername:(NSMutableString *)username {
    _username = username;
    
    [self update];
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
    [self setLablesToHidden:YES];
    [self setUpFeedView];
    [self.feedView start:2.0];
    
    [UIView addLinearGradientToView:self.imageView
             withPercentageCoverage:0.2
                          withColor:[UIColor blackColor]
                transparentToOpaque:YES]; // so its only applied once

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:self.username];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.feedView stop];
}

# pragma mark-- UpdateMethod

- (void)update {

    [self.imageView setImage:self.profileImage];
    
    [self.nameLabel  setText:self.username];
    [self.quoteLabel setText:self.quote];
    [self.collegeLabel setText:self.college];
    [self.relationshipLabel setText:self.relationshipStatus];
    
}

#pragma mark-- Helper

- (void)setUpFeedView {
    if ([self.feedView isEmpty]) {
        [self.feedView addToFeed:[self deepLabelCopy:self.quoteLabel]];
        [self.feedView addToFeed:[self deepLabelCopy:self.collegeLabel]];
        [self.feedView addToFeed:[self deepLabelCopy: self.relationshipLabel]];
    }
}
- (UILabel *)deepLabelCopy:(UILabel *)label {
    UILabel *duplicateLabel = [[UILabel alloc] initWithFrame:label.frame];
    duplicateLabel.attributedText = label.attributedText;
    duplicateLabel.textColor = label.textColor;
    duplicateLabel.backgroundColor = label.backgroundColor;
    
    return duplicateLabel;
}

- (UILabel *)getLabelFromTag:(NSInteger)tag {
    
    for (UILabel *label in self.labelArray) {
        if (label.tag == tag) {
            return label;
            break; // don't know if this is necessary
        }
    }
    
    return [[UILabel alloc] init];
    
}

- (void)setLablesToHidden:(BOOL)hidden {
    [self.labelArray setValue:[NSNumber numberWithBool:hidden] forKey:@"hidden"];
}

- (void)setNormalViewToHidden:(BOOL)hidden {
    //[self setLablesToHidden:hidden];
    [self.feedView setHidden:hidden];
    if (hidden) {
        [self.feedView pause];
    } else {
        [self.feedView clear];
        [self setUpFeedView];
        [self.feedView resume];
    }
}

@end
