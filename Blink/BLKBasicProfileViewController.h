//
//  BLKProfileViewController.h
//  Blink
//
//  Created by Joe Newbry on 2/9/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLKBasicProfileViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *relationshipLabel;
@property (weak, nonatomic) IBOutlet UILabel *collegeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;

@property (nonatomic) NSMutableString *profileDetailHeaderString;
@property (nonatomic) NSMutableString *profileDetailLabelString;


@end
