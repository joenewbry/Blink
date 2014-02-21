//
//  SBUserBroadcast.h
//  Blink
//
//  Created by Joe Newbry on 2/12/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const *SBBroadcastPeripheralUserProfileUUID;
extern NSString const *SBBroadcastServiceUserProfileUUID;
extern NSString const *SBBroadcastCharacteristicUserProfileObjectId;

extern NSString const *SBBroadcastPeripheralUserProfileUUID;
extern NSString const *SBBroadcastServiceUserProfileUUID;
extern NSString const *SBBroadcastCharacteristicUserProfileObjectId;
extern NSString const *SBBroadcastCharacteristicUserProfileUserName;
extern NSString const *SBBroadcastCharacteristicUserProfileProfileImage;
extern NSString const *SBBroadcastCharacteristicUserProfileStatus;
extern NSString const *SBBroadcastCharacteristicUserProfileQuote;

@interface SBBroadcastUser : NSObject

+ (id)buildUserBroadcastScaffold;
+ (id)buildUserBroadcastScaffoldWithLaunchOptions:(NSDictionary *)launchOptions;
+ (id)currentBroadcastScaffold;

- (void)peripheralAddUserProfileService;
- (void)peripheralManagerBroadcastServices;
- (void)peripheralManagerEndBroadcastServices;



@end

