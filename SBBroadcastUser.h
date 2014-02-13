//
//  SBUserBroadcast.h
//  Blink
//
//  Created by Joe Newbry on 2/12/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const *SBBroadcastUserUserPeripheralUUID;
extern NSString const *SBBroadcastUserUserNameCharacteristicUUID;


@interface SBBroadcastUser : NSObject

+ (id)buildUserBroadcastScaffold;
+ (id)buildUserBroadcastScaffoldWithLaunchOptions:(NSDictionary *)launchOptions;
+ (id)currentBroadcastScaffold;

- (void)peripheralAddUserNameService;
- (void)peripheralManagerBroadcastServices;
- (void)peripheralManagerEndBroadcastServices;



@end

