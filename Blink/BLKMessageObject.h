//
//  BLKMessageObject.h
//
/* subclassing PFObject to create more natural feel
 
    each message has a few properties to set/read
 
    everytime anything is set, save in background is called
    explicitly it is possible to call save
 
    messages last for 5 minutes by default
 
**/

//
//  Created by Joe Newbry on 3/5/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "SBUser.h"

@interface BLKMessageObject : PFObject <PFSubclassing>
// accessing this is the same as object for key "title"
+(NSString *)parseClassName;

@property (retain) NSString *message;
@property (retain) SBUser *sender;
@property (retain) NSString *senderName;

@end
