//
//  BLKSaveImage.m
//  Blink
//
//  Created by Joe Newbry on 2/25/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKSaveImage.h"
#import <Parse/Parse.h>
#import "SBUser.h"
#import "SBUserBroadcast.h"

@interface BLKSaveImage ()

@property (nonatomic, strong) NSMutableData *imgData;
@property (nonatomic, strong) NSURLConnection *URLConnection;

@end

@implementation BLKSaveImage

static BLKSaveImage *instance = nil;

+ (BLKSaveImage *)instanceSavedImage
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[BLKSaveImage alloc] init];
        }
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.imgData = [NSMutableData new];
    }
    return self;
}

- (void)saveImageInBackground:(NSURL *)url
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0f];
    self.URLConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}

// Called every time a chunk of the data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.imgData appendData:data]; // Build the image
}

// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set the image in the header imageView
    PFFile *imageFile = [PFFile fileWithData:self.imgData]; // saves to parse
    [SBUser currentUser].userModel.profileImage = [UIImage imageWithData:self.imgData]; // saves to SBUser

    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [BLKUser currentUser][@"profileImage"] = imageFile;
        [[BLKUser currentUser] saveEventually];
    }];

    UIImage *thumbnailImage =[UIImage imageWithData:self.imgData scale:.1];
    PFFile *thumbnailFile = [PFFile fileWithData:UIImagePNGRepresentation(thumbnailImage)];

    [thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [BLKUser currentUser][@"thumbnailImage"] = thumbnailFile;
        [[BLKUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error)  { NSLog(@"Error saving profile %@", [error localizedDescription]); }
            else {
                NSLog(@"a user has saved data, should already be signed in");
            }
        }];
    }];

}
@end
