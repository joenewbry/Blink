//
//  Profile.m
//  Blink
//
//  Created by Chad Newbry on 2/13/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "Profile.h"

@implementation Profile


- (UIImage *)image {
    if (!_image) _image = [[UIImage alloc] init]; //TODO could overide to provide default image
    
    return _image;
}

- (NSMutableString *)name {
    if (_name) _name   = [[NSMutableString alloc] initWithString:@"Nearby People"];
    
    return _name;
}

@end
