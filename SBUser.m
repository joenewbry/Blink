//
//  SBUser.m
//  Blink
//
//  Created by Joe Newbry on 2/11/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "SBUser.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface SBUser () {
}

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBPeripheral *userPeripheral;

@end

@implementation SBUser

+ (id)currentUser
{
    static SBUser *mySBUser = nil;
    @synchronized(self) {
    if (mySBUser == nil) mySBUser = [[self alloc] init];
    }
    return mySBUser;
}

+ (id)createUserWithName:(NSString *)user
{
    static SBUser *mySBUser = nil;
    @synchronized(self) {
        if (mySBUser == nil) mySBUser = [[self alloc] init];
        mySBUser.userName = user;
    }
    return mySBUser;
}

@end
