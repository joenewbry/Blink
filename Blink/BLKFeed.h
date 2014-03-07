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


- (void)addToFeed:(UILabel *)string;
- (void)removeFromFeed:(int)index;
-(BOOL)isEmpty;
- (void)clear;
- (void)start:(float)timerInterval;
- (void)pause;
- (void)resume;
- (void)stop;

@property float timerInterval;



@end
