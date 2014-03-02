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
#import <NZAlertView/NZAlertView.h>

NSString *peripheralRestorationUUID = @"A6499ECB-0B6C-4609-B161-E3D15687AF3D";

NSString *SBBroadcastPeripheralUserProfileUUID = @"FC038B47-0022-4F8B-A8A3-74EC7D930B56";
NSString *SBBroadcastServiceUserProfileUUID = @"1EF38271-ADE8-44A5-B9B6-BAB493D9A1F6";
NSString *SBBroadcastCharacteristicUserProfileObjectId = @"2863DBD0-C65D-4F75-86B2-4A29D59776A5";
NSString *SBBroadcastCharacteristicUserProfileUserName = @"5B7CF31D-31E9-4402-977D-6E0085B33293";
NSString *SBBroadcastCharacteristicUserProfileProfileImage = @"9F4EBB16-B1E1-4F67-9746-A5CEB54B98B8";
NSString *SBBroadcastCharacteristicUserProfileStatus = @"DA595224-C6F0-46DE-9C4C-EC75F43DC823";
NSString *SBBroadcastCharacteristicUserProfileQuote = @"E34C3A53-4D39-409D-AF50-96F123BA37E7";

@interface SBBroadcastUser () <CBPeripheralManagerDelegate>

- (id)init;
- (id)initWithLaunchOptions:(NSDictionary *)launchOptions;

// peripheral managers
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

// characteristics
@property (nonatomic, strong) CBMutableCharacteristic *objectIdCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *userNameCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *profileImageCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *statusCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *quoteCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *blobCharacteristic;

// services
@property (nonatomic, strong) CBMutableService *userProfileService;

@end

@implementation SBBroadcastUser

+ (BOOL)isBuilt
{
    static SBBroadcastUser *mySBUserBroadcast = nil;
    @synchronized(self) {
        return (mySBUserBroadcast != nil) ? true : false;
    }
    return false;
}
+ (BOOL)isBroadcasting
{
    return true;
}

+ (SBBroadcastUser *)buildUserBroadcastScaffold
{
    static SBBroadcastUser *mySBUserBroadcast = nil;
    @synchronized(self) {
        if (mySBUserBroadcast == nil) mySBUserBroadcast = [[self alloc] init];
        // creates peripheral manager
    }
    return mySBUserBroadcast;
}

+ (SBBroadcastUser *)buildUserBroadcastScaffoldWithLaunchOptions:(NSDictionary *)launchOptions
{
    static SBBroadcastUser *mySBUserBroadcast = nil;
    @synchronized(self) {
        if (mySBUserBroadcast == nil) mySBUserBroadcast = [[self alloc] initWithLaunchOptions:launchOptions];
    }
    return mySBUserBroadcast;
}

+ (SBBroadcastUser *)currentBroadcastScaffold
{
    static SBBroadcastUser *mySBUserBroadcast = nil;
    @synchronized(self) {
        if (mySBUserBroadcast == nil) mySBUserBroadcast = [[self alloc] init];
    }
    return mySBUserBroadcast;
}

- (CBPeripheralManager *)peripheralManager
{
    if (!_peripheralManager)_peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{ CBPeripheralManagerOptionShowPowerAlertKey : @YES } ];
    return _peripheralManager;
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
    [self.peripheralManager startAdvertising:@{ 
                                                CBAdvertisementDataServiceUUIDsKey : @[self.userProfileService.UUID]
                                                }];
}

- (void)peripheralManagerEndBroadcastServices
{
    // TODO : add way to check to see if peripheral and central are created or not
    [self.peripheralManager stopAdvertising];
    self.peripheralManager = nil;
}

- (void)peripheralAddUserProfileService
{
    // read values from SBUser ToSetCharacteristicValues
    NSString *objectId = [SBUser currentUser].userModel.objectId;
    NSData *objectIdData = [objectId dataUsingEncoding:NSUTF8StringEncoding];
    self.objectIdCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileObjectId] properties:CBCharacteristicPropertyRead value:objectIdData permissions:CBAttributePermissionsReadable];

    NSString *username = [SBUser currentUser].userModel.username;
    NSData *usernameData = [username dataUsingEncoding:NSUTF8StringEncoding];
    self.userNameCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileUserName] properties:CBCharacteristicPropertyRead value:usernameData permissions:CBAttributePermissionsReadable];

    UIImage *profileImage = [SBUser currentUser].userModel.profileImage;
    NSData *profileImageData = UIImageJPEGRepresentation(profileImage, 1);
    self.profileImageCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileProfileImage] properties:CBCharacteristicPropertyRead value:profileImageData permissions:CBAttributePermissionsReadable];

    NSString *status = [SBUser currentUser].userModel.relationshipStatus;
    NSData *statusData = [status dataUsingEncoding:NSUTF8StringEncoding];
    self.statusCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileStatus] properties:CBCharacteristicPropertyRead value:statusData permissions:CBAttributePermissionsReadable];

    NSString *quote = [SBUser currentUser].userModel.quote;
    NSData *quoteData = [quote dataUsingEncoding:NSUTF8StringEncoding];
    self.quoteCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileQuote] properties:CBCharacteristicPropertyRead value:quoteData permissions:CBAttributePermissionsReadable];

    self.userProfileService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SBBroadcastServiceUserProfileUUID] primary:YES];
    [self.userProfileService setCharacteristics:@[self.objectIdCharacteristic, self.userNameCharacteristic, self.profileImageCharacteristic, self.statusCharacteristic, self.quoteCharacteristic]];

    // share newly created user services
    [self.peripheralManager addService:self.userProfileService];
}

#pragma mark - peripheral manager delegate
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict
{
    NSLog(@"Peripherary state is being restored");
}
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSString *errorMessage = [[NSString alloc] init];
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"peripheral state is powered on");
            break;
        case CBPeripheralManagerStatePoweredOff:
            errorMessage = @"It looks like Bluetooth is turned off. Turn on Bluetooth to discover people!";
            break;
        case CBPeripheralManagerStateResetting:
            NSLog(@"peripheral state resetting");
            break;
        case CBPeripheralManagerStateUnauthorized:
            errorMessage = @"peripheral state unauthorized";
            break;
        case CBPeripheralManagerStateUnknown:
            NSLog(@"peripheral state unknown");
            break;
        case CBPeripheralManagerStateUnsupported:
            NSLog(@"peripheral state unsupported");
            break;
    }

    if (peripheral.state == CBPeripheralManagerStateUnknown ||
        peripheral.state == CBPeripheralManagerStateUnsupported ||
        peripheral.state == CBPeripheralManagerStatePoweredOff ){
        NZAlertView *alert = [[NZAlertView alloc] initWithStyle:NZAlertStyleError title:@"Turn on Bluetooth" message:errorMessage];
        [alert setTextAlignment:NSTextAlignmentLeft];
        [alert show];
    }


}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)myService
                    error:(NSError *)error {
    if (error) {
        NSLog(@"Error publishing myService: %@", [error localizedDescription]);
    }

    if ([myService isEqual:self.userProfileService]){
        [self peripheralManagerBroadcastServices];
    }

}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    } else {
        NSLog(@"peripheral did start advertising peripheral named: %@", peripheral.description);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"Read request recieved");
    if ([request.characteristic.UUID isEqual:self.objectIdCharacteristic.UUID]) {
        [self respondToReadRequest:request forCharacteristic:self.objectIdCharacteristic];
    } else if ([request.characteristic.UUID isEqual:self.userNameCharacteristic.UUID]) {
         [self respondToReadRequest:request forCharacteristic:self.userNameCharacteristic];
    } else if ([request.characteristic.UUID isEqual:self.profileImageCharacteristic.UUID]) {
        [self respondToReadRequest:request forCharacteristic:self.profileImageCharacteristic];
    } else if ([request.characteristic.UUID isEqual:self.statusCharacteristic.UUID]) {
        [self respondToReadRequest:request forCharacteristic:self.statusCharacteristic];
    } else if ([request.characteristic.UUID isEqual:self.quoteCharacteristic.UUID]) {
        [self respondToReadRequest:request forCharacteristic:self.quoteCharacteristic];
    } else {
        NSLog(@"An error with the read request occured");
     }
}

#pragma mark - Supporting Methods
- (void)respondToReadRequest:(CBATTRequest *)request forCharacteristic:(CBCharacteristic *)characteristic
{
    if (request.offset > characteristic.value.length) {
        NSLog(@"Incorect request bounds");
        return;
    }
    request.value = [characteristic.value subdataWithRange:NSMakeRange(request.offset, characteristic.value.length - request.offset)];
    [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
}

@end


