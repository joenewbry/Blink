//
//  UIViewController+ViewUtils.h
//  Blink
//
//  Created by Joe Newbry on 2/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (BLKViewUtils) <UIAlertViewDelegate>

- (void)displayPushNotificationFrom:(NSString *)userName WithMessage:(NSString *)string;
- (void)displayLogoutModal;

@end
