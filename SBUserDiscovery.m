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
@property (strong, nonatomic) NSMutableSet *discoveredUsers;

// store array of discovered users
// send out messages when new user with data is found

@end

@implementation SBUserDiscovery
@synthesize centralManager;
@synthesize discoveredUsers;

#pragma mark - External API
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

- (id)init
{
    return [self initWithLaunchOptions:nil];
}

- (id)initWithLaunchOptions:(NSDictionary *)launchOptions
{
    if (self = [super init]) {
        if (launchOptions) self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionShowPowerAlertKey : @YES,
                                CBCentralManagerOptionRestoreIdentifierKey : launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey]                                                            }];
    }
    return self;
}
- (void)searchForUsers
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SBBroadcastUserServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
}

- (void)stopSearchForUsers
{
    [self.centralManager stopScan];
}

#pragma mark - Internal Implementation


// central manager delegate methods

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{

}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        CBCentralManagerStatePoweredOff:
            NSLog(@"State powered off");
            break;
        CBCentralManagerStatePoweredOn:
            NSLog(@"State powered on");
            break;
        CBCentralManagerStateResetting:
            NSLog(@"State resetting");
            break;
        CBCentralManagerStateUnauthorized:
            NSLog(@"State unauthorized");
            break;
        CBCentralManagerStateUnknown:
            NSLog(@"State unknown");
            break;
        CBCentralManagerStateUnsupported:
            NSLog(@"State unsupported");
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered peripheral with proper service UUID, attempting to connect");
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected to peripheral with correct service UUID");
    NSLog(@"Discovering services");
    [peripheral discoverServices:nil]; // search for all services
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
        NSLog(@"Discovered service %d %@ ", count, service);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SBBroadcastUserUserPeripheralUUID]]) {
            NSLog(@"Discovered correct service");
            [peripheral discoverCharacteristics:nil forService:service];
        }
        count ++;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData *myData = characteristic.value;
    NSString *myString = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    NSLog(@"Data from correct peripheral and service is %@", myString);
}

@end

