//
//  HomeViewController.m
//  Blink
//
//  Created by Joe Newbry on 2/13/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "HomeViewController.h"
#import <SwipeView/SwipeView.h>
#import "SwipeViewDataSource.h"

@interface HomeViewController ()

@property (nonatomic, strong) SwipeView *profileViews;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        SwipeViewDataSource *swipeViewDS = [[SwipeViewDataSource alloc] init];
        self.profileViews.dataSource = swipeViewDS;
        self.profileViews.delegate = self;
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
