//
//  HomeViewController.m
//  Blink
//
//  Created by Joe Newbry on 2/13/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "SBUser.h"
#import "SBUserDiscovery.h"
#import "SBBroadcastUser.h"

@interface HomeViewController () <SwipeViewDelegate, SwipeViewDataSource, UINavigationBarDelegate>

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

        //social bluetooth framework setup
        [SBUser createUserWithName:[PFUser currentUser].username];
        [SBUser currentUser].objectId = [PFUser currentUser].objectId;
        [SBBroadcastUser buildUserBroadcastScaffold];
        SBBroadcastUser *broadcastUser = [SBBroadcastUser currentBroadcastScaffold];
        [broadcastUser peripheralAddUserNameService];
        [broadcastUser peripheralManagerBroadcastServices];
        [SBUserDiscovery buildUserDiscoveryScaffold];

        // listen for new user discovery to get UUID,
        // TODO: update so that bluetooth framework provides this, just implement delegate
        self.mainCenter = [NSNotificationCenter defaultCenter];
        [self.mainCenter addObserver:self selector:@selector(foundNewUser:) name:@"kUserFoundWithObjectId" object:nil];

        //
        self.navigationItem.title = @"Blink";
        self.navigationController.navigationBar.tintColor = [UIColor blueColor];
    }
    return self;
}

- (void)foundNewUser:(NSNotification *)aNotification
{
    NSString *objectId = aNotification.userInfo[@"objectId"];

    PFQuery *userProfileQuery = [PFQuery queryWithClassName:@"_User"];
    [userProfileQuery whereKey:@"objectId" equalTo:objectId];
    [userProfileQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) NSLog(@"Localized error desc is %@", [error localizedDescription]);
        for (PFUser *user in objects) {
            [self.discoveredUsers addObject:user];
        }
        [self.profileViews reloadData];
    }];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    _profileViews.dataSource = self;
    _profileViews.delegate = nil;
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
    return [self.discoveredUsers count] * 4;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (!view) {
        view = [[NSBundle mainBundle] loadNibNamed:@"BLKDiscoveredProfileView" owner:self options:nil][0];
    }

    UIImageView *profileImageView = (UIImageView *)[view viewWithTag:1];
    PFFile *profileImageFile = self.discoveredUsers[index/4][@"profileImage"];
    [profileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        profileImageView.image = [UIImage imageWithData:data];
    }];
    for (UIView *sub in [view subviews]){
        NSLog(@"Subview description is %@", sub.description);
    }
    UILabel *collegeLabel = (UILabel *)[view viewWithTag:4];
    collegeLabel.text = self.discoveredUsers[index/4][@"profileName"];  //@"Not saving this data yet";
    UILabel *birthdayLabel = (UILabel *)[view viewWithTag:3];
    birthdayLabel.text = self.discoveredUsers[index/4][@"birthday"];
    UILabel *relationshipLabel = (UILabel *)[view viewWithTag:4];
    relationshipLabel.text =  self.discoveredUsers[index/4][@"relationship"];
    UILabel *progressLabel = (UILabel *)[view viewWithTag:5];
    progressLabel.text = [NSString stringWithFormat:@"%ld / %lu", (long)index + 1, (unsigned long)[self.discoveredUsers count]];

    return view;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self.navigationItem setTitle:self.discoveredUsers[swipeView.currentItemIndex][@"profileName"]];
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
{
    [PFUser logOut];
    [[SBBroadcastUser currentBroadcastScaffold] peripheralManagerEndBroadcastServices];
    [[SBUserDiscovery userDiscoveryScaffold] stopSearchForUsers];
}

@end
