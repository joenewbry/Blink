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
    NSNumber *width = [NSNumber numberWithFloat:layer.bounds.size.width];
    NSNumber *height = [NSNumber numberWithFloat:layer.bounds.size.height];
    NSNumber *radius = [NSNumber numberWithFloat:layer.bounds.size.width/2]; // assuming circle
    NSNumber *growFactor = @15;
    NSNumber *growthRadius = [NSNumber numberWithFloat:growFactor.floatValue/2];
    CABasicAnimation* grow = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
    grow.fromValue = width;
    grow.byValue = growFactor;
    grow.duration = .75;

    CABasicAnimation *grow2 = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
    grow2.fromValue = height;
    grow2.byValue = growFactor;
    grow2.duration = .75;

    CABasicAnimation *grow3 = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    grow3.fromValue = radius;
    grow3.byValue = growthRadius;
    grow3.duration = .75;

    CABasicAnimation *grow4 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    grow4.fromValue = @.8;
    grow4.toValue = @0.0;
    grow4.duration = .75;



    CAAnimationGroup *pulseGroup = [CAAnimationGroup animation];
    pulseGroup.duration = .75;
    pulseGroup.repeatCount = 1000;
    pulseGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    pulseGroup.animations = @[grow, grow2, grow3, grow4];

    CALayer *pulseCircle = [CALayer layer];
    pulseCircle.bounds = layer.bounds;
    pulseCircle.position = CGPointMake(layer.bounds.size.width/2, layer.bounds.size.height/2);
    pulseCircle.cornerRadius = layer.cornerRadius;
    pulseCircle.masksToBounds = true;
    pulseCircle.borderColor = [UIColor purpleColor].CGColor;
    pulseCircle.borderWidth = .25;
    [layer addSublayer:pulseCircle];
    [pulseCircle addAnimation:pulseGroup forKey:@"pulseGroup"];
}

@end
