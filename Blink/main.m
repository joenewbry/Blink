 //
//  main.m
//  Blink
//
//  Created by Joe Newbry on 2/9/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BLKAppDelegate.h"

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([BLKAppDelegate class]));
    }
}
