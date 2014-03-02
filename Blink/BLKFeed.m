//
//  BLKFeed.m
//  Blink
//
//  Created by Chad Newbry on 3/1/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKFeed.h"

@interface BLKFeed ()

@property (nonatomic) int currentIndex;
@property (nonatomic) NSMutableArray *feed;
@property (nonatomic) NSTimer *timer;
@end


@implementation BLKFeed

#pragma mark-- Initialization

- (id)initWithTimerInterval:(float)timerInterval {
    self = [super init];
    
    if (self) {
        self.timerInterval = timerInterval;
    } else {
        NSLog(@"error initializing self");
    }
    
    return self;
}

#pragma mark-- GettersAndSetters

-(NSTimer *)timer {
    if (!_timer) _timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(animateLabelChange:) userInfo:nil repeats:YES];
    
    return _timer;
}

- (NSMutableArray *)feed {
    if (!_feed) _feed = [[NSMutableArray alloc] init];
    
    return _feed;
}

-(void)setCurrentIndex:(int)currentIndex {
    
    if (!_currentIndex) _currentIndex = 0;
    
    [self animateLabelChange];
}

#pragma mark-- ManageFeed

-(void)addToFeed:(UILabel *)label {
    
    [self addSubview:label];
    label.alpha = 0;
    [self.feed addObject:label];

    
}

-(void)removeFromFeed:(int)index {
    [self.feed removeObjectAtIndex:index];
}

- (void)clear {
    [self.feed removeAllObjects];
}

- (UILabel *)getPrevious {
    
    int tempIndex = (self.currentIndex > 0) ? (self.currentIndex - 1) : (self.feed.count - 1) ;
    
    return [self.feed objectAtIndex:tempIndex];
}

- (UILabel *)getCurrent {
    UILabel *tempLabel = (UILabel *)[self.feed objectAtIndex:self.currentIndex];
    
    return tempLabel;
}

- (BOOL)isEmpty {
    return !(self.feed.count > 0);
}


#pragma mark-- Animation

- (void)animateLabelChange {
    if (self.isAnimating) {
        if ([self getPrevious].alpha != 0) {
            // need to animate the previous view out
            
            [UIView animateWithDuration:1.0 animations:^{
                [self getPrevious].alpha = 0.0;
            }];
            
        }
        
        //animate the currentView in
        
        [UIView animateWithDuration:1.0 animations:^{
            [self getCurrent].alpha = 1.0;
        }];
    }
}




@end
