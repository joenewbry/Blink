//
//  BLKPopAnimator.m
//  Blink
//
//  Created by Joe Newbry on 2/24/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKPopAnimator.h"

@implementation BLKPopAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.transform = CGAffineTransformMakeTranslation(-320, 0);

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.transform = CGAffineTransformMakeTranslation(320, 0);
        toViewController.view.transform = CGAffineTransformMakeTranslation(0, 0);
        //toViewController.view.transform = 1;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        BOOL isCanceled = [transitionContext transitionWasCancelled];
        if (isCanceled) {
            toViewController.view.transform = CGAffineTransformMakeTranslation(0, 0);
        }
        [transitionContext completeTransition:!isCanceled];

    }];
}

@end

