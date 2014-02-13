//
//  SwipeViewDataSource.m
//  Blink
//
//  Created by Joe Newbry on 2/13/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "SwipeViewDataSource.h"

@interface SwipeViewDataSource ()

@property (nonatomic, strong) NSMutableArray *discoveredUsers;

@end

@implementation SwipeViewDataSource

-(id)initWithParentView:(UIView *)
{
    if (self = [super init]) {
        self.discoveredUsers = [[NSMutableArray alloc] initWithArray:@[@1,@2,@3]];
    }
    return self;
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [self.discoveredUsers count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIView *currentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    UILabel *outOf = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    outOf.text = (@"%@ / %@", [super]
}

@end
