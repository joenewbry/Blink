//
//  CALayer+Pulse.m
//  Blink
//
//  Created by Joe Newbry on 3/7/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "CALayer+Pulse.h"

@implementation CALayer (Pulse)


//TODO read current size of layer
// TODO make it so the radius distance, time, fadeout, pause duration are configurable
+(void)pulseLayer:(CALayer *)layer
{
    CABasicAnimation* grow = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
    grow.fromValue = @10;
    grow.toValue = @30;
    grow.duration = .75;

    CABasicAnimation *grow2 = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
    grow2.fromValue = @10;
    grow2.toValue = @30;
    grow2.duration = .75;

    CABasicAnimation *grow3 = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    grow3.fromValue = @5;
    grow3.toValue = @15;
    grow3.duration = .75;

    CABasicAnimation *grow4 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    grow4.fromValue = @.8;
    grow4.toValue = @0.0;
    grow4.duration = .75;

    CABasicAnimation *grow5 = [CABasicAnimation animationWithKeyPath:@"hidden"];
    grow5.fromValue = [NSNumber numberWithBool:false];
    grow5.toValue = [NSNumber numberWithBool:true];
    grow5.duration = .75;

    CAAnimationGroup *pulseGroup = [CAAnimationGroup animation];
    pulseGroup.duration = 3;
    pulseGroup.repeatCount = 1000;
    pulseGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    pulseGroup.animations = @[grow, grow2, grow3, grow4, grow5];
    [layer addAnimation:pulseGroup forKey:@"pulseGroup"];
}

@end
