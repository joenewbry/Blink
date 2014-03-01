//
//  BLKFeed.h
//  Blink
//
//  Created by Chad Newbry on 3/1/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLKFeed : UIView

- (id)initWithTimerInterval:(float)timerInterval;

- (void)addToFeed:(NSMutableAttributedString *)string;
- (void)removeFromFeed:(int)index;
- (void)clear;

@property float timerInterval;
@property (nonatomic) BOOL isAnimating;



@end
