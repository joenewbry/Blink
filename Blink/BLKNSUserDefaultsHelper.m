//
//  BLKNSUserDefaultsHelper.m
//  Blink
//
//  Created by Chad Newbry on 3/7/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKNSUserDefaultsHelper.h"

@implementation BLKNSUserDefaultsHelper

+(void)setUserPropertyStringForKey:(id)property key:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:property forKey:key];
}

+(NSString *)getUserPropertyStringForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return [userDefaults objectForKey:key];

}

@end
