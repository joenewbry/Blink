//
//  HomeViewController.m
//  Blink
//
//  Created by Joe Newbry on 2/13/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "HomeViewController.h"
#import "SwipeViewDataSource.h"
#import <Parse/Parse.h>

@interface HomeViewController () <SwipeViewDelegate, SwipeViewDataSource>

@property (nonatomic, strong) NSMutableArray *discoveredUsers;
@property (nonatomic, strong) NSNotificationCenter *mainCenter;

@end

@implementation HomeViewController

@synthesize profileViews = _profileViews;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.discoveredUsers = [[NSMutableArray alloc] init];
        self.profileViews = [[SwipeView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];

        self.mainCenter = [NSNotificationCenter defaultCenter];
        [self.mainCenter addObserver:self selector:@selector(foundNewUser:) name:@"kUserFound" object:nil];
    }
    return self;
}

- (void)foundNewUser:(NSNotification *)aNotification
{
    NSString *foundUser = aNotification.userInfo[@"username"];

    //PFQuery *

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    _profileViews.dataSource = self;
    _profileViews.delegate = self;
    _profileViews.alignment = SwipeViewAlignmentEdge;
    _profileViews.pagingEnabled = YES;
    _profileViews.wrapEnabled = YES;
    _profileViews.truncateFinalPage = YES;
    _profileViews.delaysContentTouches = YES;

    [self.view addSubview:self.profileViews];
    [self.profileViews reloadData];
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [self.discoveredUsers count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *outOf = nil;
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];

        UILabel *outOf = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
        outOf.backgroundColor = [UIColor greenColor];
        outOf.backgroundColor = [UIColor blueColor];
        outOf.tag = 1;
        [view addSubview:outOf];
    } else {
        outOf = (UILabel *)[view viewWithTag:1];
    }

    // set values outside of carousel to avoid weird behaivor
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat green = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;
    view.backgroundColor = [UIColor colorWithRed:red
                                           green:green
                                            blue:blue
                                           alpha:1.0f];
    outOf.text = [NSString stringWithFormat:@"%lid / %lid", (long)index + 1, (long)swipeView.numberOfItems];

    return view;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self setTitle:[NSString stringWithFormat:@"%d", (int)swipeView.currentItemIndex]];

}

@end
