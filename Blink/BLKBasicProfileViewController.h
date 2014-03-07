//
//  BLKProfileViewController.h
//  Blink
//
//  Created by Joe Newbry on 2/9/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBUserModel.h"

@interface BLKBasicProfileViewController : UIViewController 

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (void)setBLKUser:(BLKUser *)user;

@property (nonatomic, strong) BLKUser* user;

@property (strong, nonatomic) UIImage *profileImage;
@property (nonatomic) NSMutableString *username;
@property (nonatomic) NSMutableString *quote;
@property (nonatomic) NSMutableString *relationshipStatus;
@property (nonatomic) NSMutableString *college;



//@property (nonatomic) SBUserModel *SBUserModel;

- (UILabel*)getLabelFromTag:(NSInteger)tag;
- (void)setLablesToHidden:(BOOL)hidden;
- (void)setNormalViewToHidden:(BOOL)hidden;

@end
