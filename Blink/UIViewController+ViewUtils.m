//
//  UIViewController+ViewUtils.m
//  Blink
//
//  Created by Joe Newbry on 2/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "UIViewController+ViewUtils.h"
#import <Parse/Parse.h>
#import "BLKSignUpViewController.h"
#import <NZAlertView/NZAlertView.h>
#import "BLKAppDelegate.h"
#import "SBUserDiscovery.h"
#import "SBUserBroadcast.h"

@implementation UIViewController (BLKViewUtils)

- (void)displayPushNotificationFrom:(NSString *)userName WithMessage:(NSString *)message
{
    NSString *title = [userName stringByAppendingString:@" wants to Chat!"];
    //UIAlertView *pushNotifView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:@"Chat", nil];
    //pushNotifView.tag = 1;

    UIAlertView *pushNotifAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:@"Chat", nil];
    pushNotifAlertView.tag = 1;
    [pushNotifAlertView show];
}

- (void)displayLogoutModal
{
    UIAlertView *logoutView = [[UIAlertView alloc] initWithTitle:@"Want to Logout" message:@"Loging out will make it so you cannot be discovered by people around you but if you're ready to go rouge, we hope to see you back soon!" delegate:self cancelButtonTitle:@"Not Now" otherButtonTitles:@"Log Out", nil];
    logoutView.tag = 2;
    [logoutView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1) { // wants to chat
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    if (alertView.tag == 2 && buttonIndex == 1) { // wants to log out
        UIStoryboard *storyboard = self.storyboard;
        BLKSignUpViewController *newSignUpView = [storyboard instantiateViewControllerWithIdentifier:@"signUp"];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [[self.navigationController presentingViewController] dismissViewControllerAnimated:NO completion:nil];
        BLKAppDelegate *app = [[UIApplication sharedApplication] delegate];
        app.window.rootViewController = newSignUpView;
        [app.window makeKeyAndVisible];
        
        [BLKUser logOut];
        [[SBUserDiscovery currentUserDiscovery] stopSearchForUsers];
        [[SBUserBroadcast currentUserBroadcast] peripheralManagerEndBroadcastServices];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    if (alertView.tag == 1) { // it's a push notif view

    }
    if (alertView.tag == 2) { // it's a log out view

    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [self displayLogoutModal];
    }
}



@end
