//
//  UIView+LinerGradient.h
//  Blink
//
//  Created by Chad Newbry on 2/28/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LinerGradient)
+ (void)addLinearGradientToView:(UIView *)theView withPercentageCoverage:(float)withPercentageCoverage withColor:(UIColor *)theColor transparentToOpaque:(BOOL)transparentToOpaque;
@end
