//
//  BLKDiscoveredProfileViewController.m
//  Blink
//
//  Created by Chad Newbry on 2/13/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKDiscoveredProfileViewController.h"


@interface BLKDiscoveredProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *collegeLabel;
@property (weak, nonatomic) IBOutlet UILabel *quotelabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation BLKDiscoveredProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self update];
        
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

- (Profile* )profile {
    
    if (!_profile) _profile = [[Profile alloc] init];
    
    return _profile;
}

- (void)update {
    
    
    self.collegeLabel.text = self.profile.college;
    [self.collegeLabel setText:@"Some text"];
    
}

@end
