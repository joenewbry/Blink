//
//  BLKSaveImage.h
//  Blink
//
//  Created by Joe Newbry on 2/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLKSaveImage : NSObject <NSURLConnectionDelegate>

+ (BLKSaveImage *)instanceSavedImage;
- (void)saveImageInBackground:(NSURL *)url;

@end

BOOL isSaved;
