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

@interface HomeViewController () <SwipeViewDelegate, SwipeViewDataSource>

@property (nonatomic, strong) NSMutableArray *discoveredUsers;
@property (nonatomic, strong) NSNotificationCenter *mainCenter;
@property (strong, nonatomic) IBOutlet SwipeView *swipeView;

@end

@implementation HomeViewController

@synthesize swipeView = _swipeView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.discoveredUsers = [[NSMutableArray alloc] init];
        //self.profileViews = [[SwipeView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        self.navigationController.navigationBar.delegate = self;

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
        [self.swipeView reloadData];
    }];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _swipeView.dataSource = self;
    _swipeView.delegate = self;
    _swipeView.alignment = SwipeViewAlignmentEdge;
    _swipeView.pagingEnabled = YES;
    _swipeView.wrapEnabled = YES;
    _swipeView.truncateFinalPage = YES;
    _swipeView.delaysContentTouches = YES;

    [self.view addSubview:_swipeView];
    [self.swipeView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:false];
    [self setTitle:@"Blink"];
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [self.discoveredUsers count] * 4;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (!view) {
        view = [[NSBundle mainBundle] loadNibNamed:@"SwipeView" owner:self options:nil][0];
    }

    UIImageView *profileImageView = (UIImageView *)[self.view viewWithTag:1];
    PFFile *profileImageFile = self.discoveredUsers[index/4][@"profileImage"];
    [profileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        profileImageView.image = [UIImage imageWithData:data];
    }];

    UILabel *collegeLabel = (UILabel *)[self.view viewWithTag:2];
    collegeLabel.text = self.discoveredUsers[index/4][@"college"];  //@"Not saving this data yet";
    UILabel *birthdayLabel = (UILabel *)[self.view viewWithTag:3];
    birthdayLabel.text = self.discoveredUsers[index/4][@"quote"];
    UILabel *relationshipLabel = (UILabel *)[self.view viewWithTag:4];
    relationshipLabel.text =  self.discoveredUsers[index/4][@"relationship"];
    UILabel *progressLabel = (UILabel *)[self.view viewWithTag:5];
    progressLabel.text = [NSString stringWithFormat:@"%ld / %lu", (long)index + 1, (unsigned long)[self.discoveredUsers count]];

    if ([self.swipeView currentItemIndex] == index){
        [self.navigationItem setTitle:self.discoveredUsers[index/4][@"profileName"]];
    }

    return view;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self.navigationItem setTitle:self.discoveredUsers[swipeView.currentItemIndex / 4][@"profileName"]];
}

@end
