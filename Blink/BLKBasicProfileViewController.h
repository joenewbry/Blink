//
//  BLKProfileViewController.h
//  Blink
//
//  Created by Joe Newbry on 2/9/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLKBasicProfileViewController : UIViewController 

@property (strong, nonatomic) NSMutableData *imgData;
@property (nonatomic) NSMutableString *nameString;
@property (nonatomic) NSMutableString *quoteString;
@property (nonatomic) NSMutableString *relationshipString;
@property (nonatomic) NSMutableString *collegeString;

- (UILabel*)getLabelFromTag:(NSInteger)tag;
- (void)setLablesToHidden:(BOOL)hidden;

@end
