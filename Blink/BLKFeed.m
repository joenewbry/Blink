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
@property (nonatomic) BOOL isAnimating;

@end


@implementation BLKFeed

static const NSInteger offset = 20;

#pragma mark-- Initialization

- (id)initWithTimerInterval:(float)timerInterval {
    self = [super init];
    
    if (self) {

    } else {
        NSLog(@"error initializing self");
    }
    
    return self;
}

#pragma mark-- GettersAndSetters

- (NSMutableArray *)feed {
    if (!_feed) _feed = [[NSMutableArray alloc] init];
    
    return _feed;
}

#pragma mark-- ManageFeed

-(void)addToFeed:(UILabel *)label {
    
    if (label) {
        if (label.text.length > 0) {
            label.alpha = 0;
            [label setTextColor:[UIColor whiteColor]];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setHidden:NO];
            label.frame   = CGRectMake(0, -offset, label.frame.size.width, label.frame.size.height);
            [self.feed addObject:label];
            [self addSubview:label];
            
        }
    }
}

-(void)removeFromFeed:(int)index {
    [self.feed removeObjectAtIndex:index];
}

- (void)clear {
    
    while ([self.feed count] > 0) {
        [[self.feed objectAtIndex:0] removeFromSuperview];
        [self.feed removeObjectAtIndex:0];
    }
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

-(void)start:(float)timerInterval {
    self.isAnimating = YES;
    self.timerInterval = timerInterval;
    
    if (!_timer) _timer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                           target:self
                                                         selector:@selector(timerFireMethod:)
                                                         userInfo:nil
                                                          repeats:YES];
}



- (void)pause {
    self.isAnimating = NO;
}

- (void)resume {
    self.isAnimating = YES;
}

- (void)stop {
    [self.timer invalidate];
}


- (void)timerFireMethod:(NSTimer *)timer {
    
    if (self.isAnimating) {
        
        if ([self getPrevious].alpha != 0) {
            // need to animate the previous view out
            
            [UILabel animateWithDuration:.5 animations:^{
                UILabel * previousLabel = [self getPrevious];
                previousLabel.alpha = 0.0;
                previousLabel.frame = CGRectMake(previousLabel.frame.origin.x,
                                                 previousLabel.frame.origin.y +offset, previousLabel.frame.size.width,
                                                 previousLabel.frame.size.height);
            }];
        }
        
        //animate the currentView in
        UILabel *currentLabel = [self getCurrent];
        [currentLabel setFrame:CGRectMake(0.0, -offset, currentLabel.frame.size.width, currentLabel.frame.size.height)];
        
        [UILabel animateWithDuration:.5 animations:^{
            
            [currentLabel setFrame: CGRectMake(currentLabel.frame.origin.x,
                                               currentLabel.frame.origin.y + offset,
                                               currentLabel.frame.size.width,
                                               currentLabel.frame.size.height)];
            currentLabel.alpha = 1.0;
            
        }];
        
        self.currentIndex = (self.currentIndex == (self.feed.count -1)) ? 0 : (self.currentIndex +1);
        
    }
}




@end
