//
//  WAPairManager.m
//  wise_apartment
//
//  Device pairing implementation
//

#import "WAPairManager.h"
#import "WAEventEmitter.h"
#import "WAErrorHandler.h"

// TODO: Import SDK pairing helper
// #import <HXJBLESDK/HXAddBluetoothLockHelper.h>

@interface WAPairManager () // TODO: Add SDK delegate protocol
// Example: <HXAddBluetoothLockHelperDelegate>

@property (nonatomic, weak) WAEventEmitter *eventEmitter;
@property (nonatomic, copy, nullable) WAPairCompletion currentCompletion;
@property (nonatomic, assign) BOOL isPairingInProgress;
@property (nonatomic, strong) NSTimer *pairingTimeoutTimer;

// TODO: SDK helper instance
// @property (nonatomic, strong) HXAddBluetoothLockHelper *pairHelper;

@end

@implementation WAPairManager

- (instancetype)initWithEventEmitter:(WAEventEmitter *)eventEmitter {
    NSLog(@"[WAPairManager] Initializing pair manager");
    self = [super init];
    if (self) {
        _eventEmitter = eventEmitter;
        
        // TODO: Initialize SDK pairing helper
        // _pairHelper = [[HXAddBluetoothLockHelper alloc] init];
        // _pairHelper.delegate = self;
        NSLog(@"[WAPairManager] Pair manager initialized successfully");
    }
    return self;
}

- (void)dealloc {
    [self cancelPairing];
}

#pragma mark - Public Methods

- (void)pairDeviceWithId:(NSString *)deviceId
               authToken:(NSString *)authToken
              deviceName:(NSString *)deviceName
              completion:(WAPairCompletion)completion {
    NSLog(@"[WAPairManager] pairDevice called - deviceId: %@, deviceName: %@", deviceId, deviceName);
    
    if (self.isPairingInProgress) {
        NSLog(@"[WAPairManager] Pairing already in progress");
        if (completion) {
            NSError *error = [WAErrorHandler errorWithCode:WAErrorCodePairingFailed
                                                   message:@"A pairing operation is already in progress"];
            completion(NO, nil, error);
        }
        return;
    }
    
    self.isPairingInProgress = YES;
    self.currentCompletion = completion;
    
    NSLog(@"[WAPairManager] Starting pairing process");
    // Emit initial progress
    [self emitPairingProgress:@"initializing" message:@"Starting pairing process" percent:0];
    
    // TODO: Replace with actual SDK pairing call
    // Example SDK integration:
    /*
    [self.pairHelper addDeviceWithMac:deviceId
                            authToken:authToken
                           deviceName:deviceName
                              success:^(HXDeviceInfo *deviceInfo) {
        [self handlePairingSuccess:deviceInfo];
    } failure:^(NSError *error) {
        [self handlePairingFailure:error];
    }];
    */
    
    // === SIMULATION for demonstration (remove when SDK is integrated) ===
    [self simulatePairingFlow:deviceId authToken:authToken deviceName:deviceName];
}

- (void)cancelPairing {
    NSLog(@"[WAPairManager] cancelPairing called");
    if (!self.isPairingInProgress) {
        NSLog(@"[WAPairManager] No pairing in progress to cancel");
        return;
    }
    
    NSLog(@"[WAPairManager] Cancelling pairing operation");
    // TODO: Cancel SDK pairing operation
    // [self.pairHelper cancelPairing];
    
    [self.pairingTimeoutTimer invalidate];
    self.pairingTimeoutTimer = nil;
    
    [self.eventEmitter emitEvent:@{
        @"type": @"pairingError",
        @"code": @(WAErrorCodePairingCancelled),
        @"message": @"Pairing was cancelled",
        @"details": @{}
    }];
    
    if (self.currentCompletion) {
        NSError *error = [WAErrorHandler errorWithCode:WAErrorCodePairingCancelled message:nil];
        self.currentCompletion(NO, nil, error);
        self.currentCompletion = nil;
    }
    
    self.isPairingInProgress = NO;
}

- (BOOL)isPairing {
    return self.isPairingInProgress;
}

#pragma mark - Private Helpers

- (void)emitPairingProgress:(NSString *)step message:(NSString *)message percent:(NSInteger)percent {
    [self.eventEmitter emitEvent:@{
        @"type": @"pairingProgress",
        @"step": step,
        @"message": message,
        @"percent": @(percent)
    }];
}

- (void)handlePairingSuccess:(NSDictionary *)deviceInfo {
    NSLog(@"[WAPairManager] Pairing successful: %@", deviceInfo);
    self.isPairingInProgress = NO;
    
    [self.eventEmitter emitEvent:@{
        @"type": @"pairingSuccess",
        @"device": deviceInfo[@"device"] ?: @{},
        @"dnaInfo": deviceInfo[@"dnaInfo"] ?: @{}
    }];
    
    if (self.currentCompletion) {
        self.currentCompletion(YES, deviceInfo, nil);
        self.currentCompletion = nil;
    }
}

- (void)handlePairingFailure:(NSError *)error {
    NSLog(@"[WAPairManager] Pairing failed: %@", error.localizedDescription);
    self.isPairingInProgress = NO;
    
    WAErrorCode errorCode = (error && [error.domain isEqualToString:@"com.wiseapartment.error"])
        ? (WAErrorCode)error.code
        : WAErrorCodePairingFailed;
    
    [self.eventEmitter emitEvent:@{
        @"type": @"pairingError",
        @"code": [NSString stringWithFormat:@"%ld", (long)errorCode],
        @"message": error.localizedDescription ?: @"Pairing failed",
        @"details": error.userInfo ?: @{}
    }];
    
    if (self.currentCompletion) {
        self.currentCompletion(NO, nil, error);
        self.currentCompletion = nil;
    }
}

#pragma mark - Simulation (TODO: REMOVE when SDK is integrated)

- (void)simulatePairingFlow:(NSString *)deviceId authToken:(NSString *)authToken deviceName:(NSString *)deviceName {
    // This simulates a multi-step pairing process
    // Replace this entire method with actual SDK calls
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // Step 1: Connecting
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), queue, ^{
        [self emitPairingProgress:@"connecting" message:@"Connecting to device..." percent:20];
        
        // Step 2: Authenticating
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), queue, ^{
            [self emitPairingProgress:@"authenticating" message:@"Authenticating..." percent:50];
            
            // Step 3: Pairing
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), queue, ^{
                [self emitPairingProgress:@"pairing" message:@"Pairing with device..." percent:75];
                
                // Step 4: Success
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), queue, ^{
                    NSDictionary *deviceInfo = @{
                        @"device": @{
                            @"deviceId": deviceId,
                            @"name": deviceName ?: @"Smart Lock",
                            @"type": @"BLE_LOCK"
                        },
                        @"dnaInfo": @{
                            @"dnaId": [NSString stringWithFormat:@"DNA_%@", [[NSUUID UUID] UUIDString]],
                            @"lockType": @"BLE_WIFI",
                            @"firmwareVersion": @"2.5.0"
                        }
                    };
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self handlePairingSuccess:deviceInfo];
                    });
                });
            });
        });
    });
}

#pragma mark - SDK Delegate (TODO: Implement actual delegate methods)

// TODO: Implement SDK delegate methods
/*
- (void)addBluetoothLockHelper:(HXAddBluetoothLockHelper *)helper
                      progress:(NSInteger)step
                       message:(NSString *)message
                       percent:(NSInteger)percent {
    
    NSString *stepName = [self stepNameForSDKStep:step];
    [self emitPairingProgress:stepName message:message percent:percent];
}

- (void)addBluetoothLockHelper:(HXAddBluetoothLockHelper *)helper
                didSucceedWithDevice:(HXDeviceInfo *)deviceInfo {
    
    NSDictionary *info = @{
        @"device": @{
            @"deviceId": deviceInfo.macAddress,
            @"name": deviceInfo.deviceName,
            @"type": deviceInfo.deviceType
        },
        @"dnaInfo": @{
            @"dnaId": deviceInfo.dnaId,
            @"lockType": deviceInfo.lockType,
            @"firmwareVersion": deviceInfo.firmwareVersion
        }
    };
    
    [self handlePairingSuccess:info];
}

- (void)addBluetoothLockHelper:(HXAddBluetoothLockHelper *)helper
                didFailWithError:(NSError *)error {
    [self handlePairingFailure:error];
}

- (NSString *)stepNameForSDKStep:(NSInteger)step {
    // Map SDK step constants to Flutter-friendly names
    switch (step) {
        case HXPairStepConnecting: return @"connecting";
        case HXPairStepAuthenticating: return @"authenticating";
        case HXPairStepPairing: return @"pairing";
        default: return @"processing";
    }
}
*/

@end
