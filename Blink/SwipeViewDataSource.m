//
//  SwipeViewDataSource.m
//  Blink
//
//  Created by Joe Newbry on 2/13/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "SwipeViewDataSource.h"

@interface SwipeViewDataSource ()

@property (weak) SwipeView *swipeView;

@end

@implementation SwipeViewDataSource

-(id)initWithParentView:(SwipeView *)swipeView
{
    if (self = [super init]) {
        self.swipeView = swipeView;
    }
    return self;
}



@end
