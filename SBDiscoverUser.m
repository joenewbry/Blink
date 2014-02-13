//
//  SBUserDiscovery.m
//  Blink
//
//  Created by Joe Newbry on 2/12/14.
//  Copyright (c) 2014 Joe Newbry. All rights reserved.
//

#import "SBDiscoverUser.h"
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
        if (mySBUserDiscovery ==nil) mySBUserDiscovery = [[self alloc] init];
        // creates central manager that will look for peripherals with the specified
        // CBUUID as one of the services
        mySBUserDiscovery.centralManager = [[CBCentralManager alloc] initWithDelegate:mySBUserDiscovery queue:nil options:@{ CBCentralManagerOptionShowPowerAlertKey : @YES,
                                                          CBCentralManagerOptionRestoreIdentifierKey : centralManagerRestorationUUID                                                            }];
    }
    return mySBUserDiscovery;
}

+ (id)buildUserDiscoveryScaffoldWithLaunchOptions:(NSDictionary *)launchOptions
{
    return [self buildUserDiscoveryScaffold];
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

- (void)searchForUsers
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SBBroadcastUserUserNameCharacteristicUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
}

- (void)stopSearchForUsers
{
    [self.centralManager stopScan];
}

#pragma mark - Internal Implementation

// central manager delegate methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch ([central state]) {
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

