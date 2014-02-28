//
//  BLKProfileViewController.m
//  Blink
//
//  Created by Joe Newbry on 2/9/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "BLKBasicProfileViewController.h"
#import <Parse/Parse.h>
#import "UIViewController+ViewUtils.h"

@interface BLKBasicProfileViewController ()

@property (strong, nonatomic) NSURLConnection *URLConnection;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *relationshipLabel;
@property (weak, nonatomic) IBOutlet UILabel *collegeLabel;

@property (nonatomic) NSMutableArray *labelArray;


@end

@implementation BLKBasicProfileViewController

# pragma mark-- Getters_Setters

@synthesize quoteString = _quoteString;
@synthesize nameString = _nameString;


- (void)setImgData:(NSMutableData *)imgData {
    _imgData = imgData;
    [self update];
}

-(NSMutableString *)nameString {
    if (!_nameString) _nameString = [[NSMutableString alloc] initWithString:@"Nobody Nearby"];
    
    return _nameString;
}

-(void)setNameString:(NSMutableString *)nameString {
    _nameString = nameString;
    
    [self update];
}

- (NSMutableArray *)labelArray {
    if (!_labelArray) _labelArray = [[NSMutableArray alloc] init];
    
    return _labelArray;
}

-(NSMutableString *)quoteString {
    if (!_quoteString) _quoteString = [[NSMutableString alloc] initWithString:@"Try inviting more friends to improve the Blink experience"];
    
    return _quoteString;
}

- (void)setQuoteString:(NSMutableString *)quoteString {
    _quoteString = quoteString;
    [self update];
}

- (void)setRelationshipString:(NSMutableString *)relationshipString {
    _relationshipString = relationshipString;
    
    [self update];
}

- (void)setCollegeString:(NSMutableString *)collegeString {
    _collegeString = collegeString;
    
    [self update];
}

# pragma mark-- initilization methods

- (id)init
{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.labelArray addObjectsFromArray:@[self.nameLabel, self.quoteLabel, self.collegeLabel, self.relationshipLabel]];
    [self update];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark-- UpdateMethod

- (void)update {
    [self.imageView setImage:[[UIImage alloc] initWithData:self.imgData]];
    [self.nameLabel  setText:self.nameString];
    [self.quoteLabel setText:self.quoteString];
    [self.collegeLabel setText:self.collegeString];
    [self.relationshipLabel setText:self.relationshipString];
    
}



#pragma mark-- Helper

- (UILabel *)getLabelFromTag:(NSInteger)tag {
    
    for (UILabel *label in self.labelArray) {
        if (label.tag == tag) {
            return label;
            break; // don't know if this is necessary
        }
    }
    
    NSLog(@"error didn't find frame for tag");
    return [[UILabel alloc] init];
    
}

- (void)setLablesToHidden:(BOOL)hidden {
    [self.labelArray setValue:[NSNumber numberWithBool:hidden] forKey:@"hidden"];
    NSLog(@"Hide values called");
}

@end
