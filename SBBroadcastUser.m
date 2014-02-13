//
//  SBUserBroadcast.m
//  Blink
//
//  Created by Joe Newbry on 2/12/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "SBBroadcastUser.h"
#import "SBUser.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString const *SBBroadcastUserUserPeripheralUUID = @"FC038B47-0022-4F8B-A8A3-74EC7D930B56";
NSString const *peripheralRestorationUUID = @"A6499ECB-0B6C-4609-B161-E3D15687AF3D";
NSString const *SBBroadcastUserUserNameCharacteristicUUID = @"2863DBD0-C65D-4F75-86B2-4A29D59776A5";
NSString const *SBBroadcastUserServiceUUID = @"1EF38271-ADE8-44A5-B9B6-BAB493D9A1F6";


@interface SBBroadcastUser () <CBPeripheralManagerDelegate>

- (id)init;
- (id)initWithLaunchOptions:(NSDictionary *)launchOptions;

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

// characteristics
@property (nonatomic, strong) CBCharacteristic *userNameCharacteristic;

@end

@implementation SBBroadcastUser

+ (id)buildUserBroadcastScaffold
{
    static SBBroadcastUser *mySBUserBroadcast = nil;
    @synchronized(self) {
        if (mySBUserBroadcast ==nil) mySBUserBroadcast = [[self alloc] init];
        // creates peripheral manager
    }
    return mySBUserBroadcast;
}

+ (id)buildUserBroadcastScaffoldWithLaunchOptions:(NSDictionary *)launchOptions
{
    static SBBroadcastUser *mySBUserBroadcast = nil;
    @synchronized(self) {
        if (mySBUserBroadcast == nil) mySBUserBroadcast = [[self alloc] initWithLaunchOptions:launchOptions];
    }
    return mySBUserBroadcast;
}

+ (id)currentBroadcastScaffold
{
    static SBBroadcastUser *mySBUserBroadcast = nil;
    @synchronized(self) {
        if (mySBUserBroadcast == nil) mySBUserBroadcast = [[self alloc] init];
    }
    return mySBUserBroadcast;
}

- (id)init
{
    return [self initWithLaunchOptions:nil];
}

- (id)initWithLaunchOptions:(NSDictionary *)launchOptions
{
    if (self = [super init]) {
        if (launchOptions) {
            self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionShowPowerAlertKey : @YES,
                CBCentralManagerOptionRestoreIdentifierKey : launchOptions[UIApplicationLaunchOptionsBluetoothPeripheralsKey]
                                                                                                             }];
        } else {
            self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionShowPowerAlertKey : @YES
                                                                                                             }];
        }
    }
    return self;
}

- (void)peripheralManagerBroadcastServices
{
    NSString *username = [SBUser currentUser].userName;

    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataLocalNameKey : username,
                                                CBAdvertisementDataServiceUUIDsKey : [CBUUID UUIDWithString:SBBroadcastUserUserPeripheralUUID]
                                                }];
}

- (void)peripheralManagerEndBroadcastServices
{
    [self.peripheralManager stopAdvertising];
}

- (void)peripheralAddUserNameService
{
    NSString *username = [SBUser currentUser].userName;
    NSData *usernameData = [username dataUsingEncoding:NSUTF8StringEncoding];
    self.userNameCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:SBBroadcastUserUserNameCharacteristicUUID] properties:CBCharacteristicPropertyRead value:usernameData permissions:CBAttributePermissionsReadable];
    CBMutableService *userNameService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SBBroadcastUserServiceUUID] primary:YES];
    userNameService.characteristics = @[self.userNameCharacteristic];
    [self.peripheralManager addService:userNameService];
}

#pragma mark - peripheral manager delegate
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict
{
    NSLog(@"Peripherary state is being restored");
}
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        CBPeripheralManagerStatePoweredOn:
            NSLog(@"peripheral state is powered on");
            break;
        CBPeripheralManagerStatePoweredOff:
            NSLog(@"peripheral state is powered off");
            break;
        CBPeripheralManagerStateResetting:
            NSLog(@"peripheral state resetting");
            break;
        CBPeripheralManagerStateUnauthorized:
            NSLog(@"peripheral state unauthorized");
            break;
        CBPeripheralManagerStateUnknown:
            NSLog(@"peripheral state unknown");
            break;
        CBPeripheralManagerStateUnsupported:
            NSLog(@"peripheral state unsupported");
            break;
    }


}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)myService
                    error:(NSError *)error {
    if (error) {
        NSLog(@"Error publishing myService: %@", [error localizedDescription]);
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    } else {
        NSLog(@"peripheral did start advertising peripheral named: %@", peripheral);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"Read request recieved");
    if ([request.characteristic.UUID isEqual:self.userNameCharacteristic.UUID]) {
        NSLog(@"Correct UUID");
        if (request.offset > self.userNameCharacteristic.value.length) {
            NSLog(@"Incorrect request bounds");
            return;
        }
        request.value = [self.userNameCharacteristic.value subdataWithRange:NSMakeRange(request.offset, self.userNameCharacteristic.value.length - request.offset)];
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }   else {
        NSLog(@"An error with the read request occured");
    }
}

@end


