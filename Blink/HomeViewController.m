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

@interface HomeViewController () <SwipeViewDelegate, SwipeViewDataSource, SBDiscoverUser>

@property (nonatomic, strong) NSMutableArray *discoveredUsers;
@property (nonatomic, strong) NSNotificationCenter *mainCenter;
@property (strong, nonatomic) IBOutlet SwipeView *swipeView;
@property (strong, nonatomic) IBOutlet UIImageView *loadingSpinner;
@property (strong, nonatomic) IBOutlet UILabel *objectIdLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;

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
        [SBBroadcastUser buildUserBroadcastScaffold];
        SBBroadcastUser *broadcastUser = [SBBroadcastUser currentBroadcastScaffold];
        [broadcastUser peripheralAddUserProfileService];
        [broadcastUser peripheralManagerBroadcastServices];
        SBUserDiscovery *myScaffold = [SBUserDiscovery buildUserDiscoveryScaffold];
        myScaffold.delegate = self;

        // listen for new user discovery to get UUID,
        // TODO: update so that bluetooth framework provides this, just implement delegate
        self.mainCenter = [NSNotificationCenter defaultCenter];
        [self.mainCenter addObserver:self selector:@selector(foundNewUser:) name:@"kUserFoundWithObjectId" object:nil];

        [self startSpin:self.loadingSpinner];
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

    [self stopSpin]; // stops loading spinner animation
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

- (void)didReceiveObjectID:(NSString *)objectID
{
    self.objectIdLabel.text = objectID;
}

- (void)didReceiveUserName:(NSString *)userName
{
    self.usernameLabel.text = userName;
}

- (void)didReceiveStatus:(NSString *)status
{
    self.statusLabel.text = status;
}

- (void)didReceiveQuote:(NSString *)quote
{
    self.quoteLabel.text = quote;
}

- (void)didReceiveProfileImage:(UIImage *)profileImage
{

}


@end
