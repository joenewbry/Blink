//
//  BLKProfileView.h
//  Blink
//
//  Created by Chad Newbry on 2/22/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <UIKit/UIKit.h>

enum BLKProfileViewState {
    BLKProfileViewStateCollapsed,
    BLKProfileViewStateExpanded,
    BLKProfileViewStateEditing,
};

typedef enum BLKProfileViewState BLKProfileViewState;

@interface BLKDetailProfileView : UIView

-(void)setState:(NSInteger)state;

@property (nonatomic)NSMutableString *quoteText;
@property (nonatomic)NSMutableString *name;

@end
