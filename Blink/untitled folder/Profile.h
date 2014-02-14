//
//  Profile.h
//  Blink
//
//  Created by Chad Newbry on 2/13/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Profile : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) NSMutableString *name;
@property (nonatomic) NSMutableString *quote;
@property (nonatomic) NSMutableString *college;
@property (nonatomic) NSMutableString *birthday;

@end
