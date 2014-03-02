//
//  BLKAppDelegate.m
//  Blink
//
//  Created by Joe Newbry on 2/9/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKAppDelegate.h"
#import <Parse/Parse.h>
#import "BLKConstants.h"
#import "BLKNearbyMenuViewController.h"

@implementation BLKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    //setup parse authorization, facebook login
    [Parse setApplicationId:kParseAppID clientKey:kParseClient];
    [PFFacebookUtils initializeFacebook];

    // sets app icon badge to 0
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveEventually];
    }

    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFOBjects belonging to the current users
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    [self configureRemoteNotifications:application];

    // sets the time wifi and stuff at the top to either white or black
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];


    //set navigation bar font type and size
    [[UINavigationBar appearance]  setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"GillSans-Light" size:30.0], NSFontAttributeName, nil]];

    // If a user is already logged in, override storyboard launch
    if ([PFUser currentUser]){
        UIWindow *window = self.window;
        UIStoryboard *storyboard = [[self.window rootViewController] storyboard];
        UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"navController"];
        window.rootViewController = navController;
    }


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

#pragma mark - remote notifications handling
- (void)configureRemoteNotifications:(UIApplication *)application
{
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound ];
}

// registered for specific remote notifications
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [PFPush storeDeviceToken:deviceToken];

    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }

    [[PFInstallation currentInstallation] addUniqueObject:@"" forKey:kInstallationChannelsKey];

    if ([PFUser currentUser]) {
        // Make sure they are subscribed to private channel
        NSString *privateChannelName = [[PFUser currentUser] objectForKey:kUserPrivateChannelKey];
        if (privateChannelName && privateChannelName.length > 0) {
            NSLog(@"Subscribing user to %@", privateChannelName);
            [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kInstallationChannelsKey];
        }
    }
    [[PFInstallation currentInstallation] saveEventually];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if ([error code] != 3010) { // 3010 is for iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
    }
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Recieved remote notification");
    [PFPush handlePush:userInfo];
}

#pragma mark - FBIntegration

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

@end
