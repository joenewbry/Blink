//
//  SwipeViewDataSource.h
//  Blink
//
//  Created by Joe Newbry on 2/13/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SwipeView/SwipeView.h>

@interface SwipeViewDataSource : NSObject <SwipeViewDataSource>

-(id)initWithParentView:(SwipeView *)swipeView;

@end
