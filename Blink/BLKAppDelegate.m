//
//  BLKAppDelegate.m
//  Blink
//
//  Created by Joe Newbry on 2/9/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKAppDelegate.h"
#import "BLKConstants.h"
#import <Parse/Parse.h>
#import "SBBroadcastUser.h"
#import "SBUserDiscovery.h"
#import "SBUser.h"
#import "BLKSignUpViewController.h"
#import "HomeViewController.h"
#import "BLKDiscoveredProfileViewController.h"

@implementation BLKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BOOL local = true;
    
    
    if (local) {
        //setup parse authorization, facebook login
        [Parse setApplicationId:@"uArzEK3OI68YCGI6KHTCNbV0XsNI2eHwHLVC0a03" clientKey:@"dauk1AeWtQy1d6YF8iX6jk1DqhThrPkIA7cTjVhZ"];
        [PFFacebookUtils initializeFacebook];

        // sets the time wifi and stuff at the top to either white or black
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

        //init the window
//        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//        self.window.backgroundColor = [UIColor whiteColor];
//
//        //makes sign up view controller
//        BLKSignUpViewController *signUpVC = [[BLKSignUpViewController alloc] initWithNibName:@"SignUpView" bundle:[NSBundle mainBundle]];
//        self.navController = [[UINavigationController alloc] initWithRootViewController: signUpVC];
//        [self.window setRootViewController:self.navController];
//        [self.window makeKeyAndVisible];

    }
    
//    BLKDiscoveredProfileViewController *discoveredViewController = [[BLKDiscoveredProfileViewController alloc] initWithNibName:@"BLKDiscoveredProfileView" bundle:[NSBundle mainBundle]     ];
//    self.navController = [[UINavigationController alloc] initWithRootViewController:discoveredViewController];
//    
//    [self.window setRootViewController:self.navController];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - FBIntegration

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

@end
