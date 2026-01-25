//
//  WABluetoothStateManager.m
//  wise_apartment
//
//  Bluetooth state monitoring implementation
//

#import "WABluetoothStateManager.h"
#import "WAEventEmitter.h"

@interface WABluetoothStateManager () <CBCentralManagerDelegate>

@property (nonatomic, weak) WAEventEmitter *eventEmitter;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, assign) CBManagerState currentState;

@end

@implementation WABluetoothStateManager

- (instancetype)initWithEventEmitter:(WAEventEmitter *)eventEmitter {
    NSLog(@"[WABluetoothStateManager] Initializing Bluetooth state manager");
    self = [super init];
    if (self) {
        _eventEmitter = eventEmitter;
        
        // Initialize CBCentralManager to monitor state
        // Use dispatch_queue_create to avoid blocking main thread during init
        dispatch_queue_t queue = dispatch_queue_create("com.wiseapartment.bluetooth_state", DISPATCH_QUEUE_SERIAL);
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue];
        _currentState = CBManagerStateUnknown;
        NSLog(@"[WABluetoothStateManager] Bluetooth state manager initialized");
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL)isBluetoothAvailable {
    BOOL available = self.currentState != CBManagerStateUnsupported;
    NSLog(@"[WABluetoothStateManager] isBluetoothAvailable: %d (state: %@)", available, [self getCurrentStateString]);
    return available;
}

- (BOOL)isBluetoothPoweredOn {
    BOOL poweredOn = self.currentState == CBManagerStatePoweredOn;
    NSLog(@"[WABluetoothStateManager] isBluetoothPoweredOn: %d (state: %@)", poweredOn, [self getCurrentStateString]);
    return poweredOn;
}

- (NSString *)getCurrentStateString {
    switch (self.currentState) {
        case CBManagerStatePoweredOn:
            return @"on";
        case CBManagerStatePoweredOff:
            return @"off";
        case CBManagerStateUnauthorized:
            return @"unauthorized";
        case CBManagerStateUnsupported:
            return @"unsupported";
        case CBManagerStateResetting:
            return @"resetting";
        case CBManagerStateUnknown:
        default:
            return @"unknown";
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    self.currentState = central.state;
    
    NSLog(@"[WABluetoothStateManager] Bluetooth state changed: %@", [self getCurrentStateString]);
    
    // Optionally emit state change events to Flutter
    // (Uncomment if you want to stream BT state changes)
    /*
    [self.eventEmitter emitEvent:@{
        @"type": @"bluetoothStateChanged",
        @"state": [self getCurrentStateString]
    }];
    */
}

@end
