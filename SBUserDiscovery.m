//
//  SBUserDiscovery.m
//  Blink
//
//  Created by Joe Newbry on 2/12/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "SBUserDiscovery.h"
#import "SBBroadcastUser.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString const *centralManagerRestorationUUID = @"F2552FC0-92C9-4A60-AA97-215E5FC3EE95";

@interface SBUserDiscovery () <CBCentralManagerDelegate, CBPeripheralDelegate> {
}

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableSet *discoveringUsers; // peripherals that I'm attempting to connect to
@property (strong, nonatomic) NSMutableArray *discoveredUsers; // peripherals that I've connected to
@property (strong, nonatomic) NSMutableDictionary *userData;

// store array of discovered users
// send out messages when new user with data is found

@end

@implementation SBUserDiscovery
@synthesize centralManager;
@synthesize discoveredUsers;

#pragma mark - External API
+ (BOOL)isBuilt
{
    static SBUserDiscovery *userDiscovery = nil;
    @synchronized(self) {
        return (userDiscovery != nil) ? true : false;
    }
    return false;
}

+ (BOOL)isBroadcasting
{
    return false;
}

+ (id)buildUserDiscoveryScaffold
{
    static SBUserDiscovery *mySBUserDiscovery = nil;
    @synchronized(self) {
        if (mySBUserDiscovery == nil) mySBUserDiscovery = [[SBUserDiscovery alloc] init];
    }
    return mySBUserDiscovery;
}

+ (id)buildUserDiscoveryScaffoldWithLaunchOptions:(NSDictionary *)launchOptions
{
    static SBUserDiscovery *mySBUserDiscovery = nil;
    @synchronized(self) {
        if (mySBUserDiscovery == nil) mySBUserDiscovery = [[SBUserDiscovery alloc] initWithLaunchOptions:launchOptions];
    }
    return mySBUserDiscovery;
}

+ (id)userDiscoveryScaffold
{
    static SBUserDiscovery *mySBUserDiscovery = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySBUserDiscovery = [[self alloc] init];
    });
    return mySBUserDiscovery;
}

- (NSMutableDictionary *)userData
{
    if (!_userData) _userData = [[NSMutableDictionary alloc]initWithDictionary:@{@"time-stamp" : @"Some date string"}];
    return _userData;
}

- (id)init
{
    return [self initWithLaunchOptions:nil];
}

- (id)initWithLaunchOptions:(NSDictionary *)launchOptions
{
    if (self = [super init]) {
        if (launchOptions)
        { self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:
                                                  @{CBCentralManagerOptionShowPowerAlertKey : @YES,
                                                    CBCentralManagerOptionRestoreIdentifierKey : launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey]                                                            }];
        } else {
            self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey : @YES }];
        }
        self.discoveringUsers = [[NSMutableSet alloc] init];
        self.discoveredUsers  = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)searchForUsers
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SBBroadcastServiceUserProfileUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
}

- (void)stopSearchForUsers
{
    [self.centralManager stopScan];
    self.centralManager = nil;
}

#pragma mark - Internal Implementation


// central manager delegate methods

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{

}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
     switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"State powered off");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"State powered on");
            [self searchForUsers];
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"State resetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"State unauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"State unknown");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"State unsupported");
            break;
    }

}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self.discoveringUsers addObject:peripheral];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected to peripheral with correct service UUID");
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SBBroadcastServiceUserProfileUUID]]]; // search for user profile service
    peripheral.delegate = self;
    [self.discoveredUsers addObject:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{

}

// peripheral delegate methods
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    int count = 0;

    
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %d UUID is %@ ", count, service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SBBroadcastServiceUserProfileUUID]]) {
            NSLog(@"Discovered user profile service");
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileObjectId],
                                                  [CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileUserName],
                                                  [CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileProfileImage],
                                                  [CBUUID UUIDWithString: SBBroadcastCharacteristicUserProfileQuote],
                                                  [CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileStatus]] forService:service];
        }
        count ++;
    }
}

// for found peripheral and service and characteristic attempt to read value
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Reading value for characteristic %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    }
}

// read and store value depending on what characteristic is being read
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData *myData = characteristic.value;

    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileObjectId]]){
        self.userData[@"objectId"] = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
        if ([self.delegate respondsToSelector:@selector(didReceiveObjectID:)]) {
            [self.delegate didReceiveObjectID:self.userData[@"objectId"]];
        }

    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileUserName]]) {
        self.userData[@"userName"]  = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
        if ([self.delegate respondsToSelector:@selector(didReceiveUserName:)]) {
            [self.delegate didReceiveUserName:self.userData[@"userName"]];
        }

    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileQuote]]) {
        self.userData[@"quote"] = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
        if ([self.delegate respondsToSelector:@selector(didReceiveQuote:)]) {
            [self.delegate didReceiveQuote:self.userData[@"quote"]];
        }

    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileStatus]]) {
        self.userData[@"status"] = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
        if ([self.delegate respondsToSelector:@selector(didReceiveStatus:)]) {
            [self.delegate didReceiveStatus:self.userData[@"status"]];
        }

    } /*else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SBBroadcastCharacteristicUserProfileProfileImage]]) {
        self.userData[@"profileImage"]  = [UIImage imageWithData:myData];
        if ([self.delegate respondsToSelector:@selector(didRecieveProfileImage:)]) {
            [self.delegate didReceiveProfileImage:self.userData[@"profileImage"]];
        }

    } **/else {
        NSLog(@"attempting to read characteristic %@", characteristic.description);
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    
    //self.discoveredUsers
    //self.discoveringUsers
}

@end

