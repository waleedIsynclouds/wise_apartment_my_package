//
//  WAWiFiConfigManager.m
//  wise_apartment
//
//  WiFi configuration implementation
//

#import "WAWiFiConfigManager.h"
#import "WAEventEmitter.h"
#import "WAErrorHandler.h"

// TODO: Import SDK WiFi config helper
// #import <HXJBLESDK/HXWiFiConfigHelper.h>

@interface WAWiFiConfigManager () // TODO: Add SDK delegate
// Example: <HXWiFiConfigHelperDelegate>

@property (nonatomic, weak) WAEventEmitter *eventEmitter;
@property (nonatomic, copy, nullable) WAWiFiConfigCompletion currentCompletion;
@property (nonatomic, assign) BOOL isConfiguringWiFi;
@property (nonatomic, strong) NSTimer *configTimeoutTimer;

// TODO: SDK helper instance
// @property (nonatomic, strong) HXWiFiConfigHelper *wifiConfigHelper;

@end

@implementation WAWiFiConfigManager

- (instancetype)initWithEventEmitter:(WAEventEmitter *)eventEmitter {
    NSLog(@"[WAWiFiConfigManager] Initializing WiFi config manager");
    self = [super init];
    if (self) {
        _eventEmitter = eventEmitter;
        
        // TODO: Initialize SDK WiFi config helper
        // _wifiConfigHelper = [[HXWiFiConfigHelper alloc] init];
        // _wifiConfigHelper.delegate = self;
        NSLog(@"[WAWiFiConfigManager] WiFi config manager initialized successfully");
    }
    return self;
}

- (void)dealloc {
    [self cancelConfiguration];
}

#pragma mark - Public Methods

- (void)configureWifiForDevice:(NSString *)deviceId
                          ssid:(NSString *)ssid
                      password:(NSString *)password
                      wifiType:(NSInteger)wifiType
                       timeout:(NSTimeInterval)timeout
                    completion:(WAWiFiConfigCompletion)completion {
    NSLog(@"[WAWiFiConfigManager] configureWifi called - deviceId: %@, ssid: %@, wifiType: %ld, timeout: %.1fs", deviceId, ssid, (long)wifiType, timeout);
    
    if (self.isConfiguringWiFi) {
        NSLog(@"[WAWiFiConfigManager] WiFi configuration already in progress");
        if (completion) {
            NSError *error = [WAErrorHandler errorWithCode:WAErrorCodeWiFiConfigFailed
                                                   message:@"WiFi configuration already in progress"];
            completion(NO, error);
        }
        return;
    }
    
    // Validate SSID
    if (!ssid || [ssid length] == 0) {
        NSLog(@"[WAWiFiConfigManager] Invalid SSID provided");
        if (completion) {
            NSError *error = [WAErrorHandler errorWithCode:WAErrorCodeInvalidSSID
                                                   message:@"SSID cannot be empty"];
            completion(NO, error);
        }
        return;
    }
    
    NSLog(@"[WAWiFiConfigManager] Starting WiFi configuration");
    self.isConfiguringWiFi = YES;
    self.currentCompletion = completion;
    
    // Emit initial progress
    [self emitWiFiProgress:@"preparing" percent:0];
    
    // TODO: Replace with actual SDK WiFi config call
    /*
    [self.wifiConfigHelper configureDevice:deviceId
                                      ssid:ssid
                                  password:password
                                  wifiType:wifiType
                                   timeout:timeout
                                   success:^{
        [self handleConfigSuccess:deviceId];
    } failure:^(NSError *error) {
        [self handleConfigFailure:error];
    }];
    */
    
    // === SIMULATION for demonstration (remove when SDK is integrated) ===
    [self simulateWiFiConfig:deviceId timeout:timeout];
}

- (void)cancelConfiguration {
    NSLog(@"[WAWiFiConfigManager] cancelConfiguration called");
    if (!self.isConfiguringWiFi) {
        NSLog(@"[WAWiFiConfigManager] No configuration in progress to cancel");
        return;
    }
    
    NSLog(@"[WAWiFiConfigManager] Cancelling WiFi configuration");
    // TODO: Cancel SDK WiFi config operation
    // [self.wifiConfigHelper cancelConfiguration];
    
    [self.configTimeoutTimer invalidate];
    self.configTimeoutTimer = nil;
    
    [self.eventEmitter emitEvent:@{
        @"type": @"wifiError",
        @"code": @(WAErrorCodeWiFiConfigFailed),
        @"message": @"WiFi configuration was cancelled"
    }];
    
    if (self.currentCompletion) {
        NSError *error = [WAErrorHandler errorWithCode:WAErrorCodeWiFiConfigFailed
                                               message:@"Configuration cancelled"];
        self.currentCompletion(NO, error);
        self.currentCompletion = nil;
    }
    
    self.isConfiguringWiFi = NO;
}

- (BOOL)isConfiguring {
    return self.isConfiguringWiFi;
}

#pragma mark - Private Helpers

- (void)emitWiFiProgress:(NSString *)step percent:(NSInteger)percent {
    [self.eventEmitter emitEvent:@{
        @"type": @"wifiProgress",
        @"step": step,
        @"percent": @(percent)
    }];
}

- (void)handleConfigSuccess:(NSString *)deviceId {
    NSLog(@"[WAWiFiConfigManager] WiFi configuration successful for device: %@", deviceId);
    self.isConfiguringWiFi = NO;
    
    [self.configTimeoutTimer invalidate];
    self.configTimeoutTimer = nil;
    
    [self.eventEmitter emitEvent:@{
        @"type": @"wifiSuccess",
        @"deviceId": deviceId
    }];
    
    if (self.currentCompletion) {
        self.currentCompletion(YES, nil);
        self.currentCompletion = nil;
    }
}

- (void)handleConfigFailure:(NSError *)error {
    NSLog(@"[WAWiFiConfigManager] WiFi configuration failed: %@", error.localizedDescription);
    self.isConfiguringWiFi = NO;
    
    [self.configTimeoutTimer invalidate];
    self.configTimeoutTimer = nil;
    
    WAErrorCode errorCode = (error && [error.domain isEqualToString:@"com.wiseapartment.error"])
        ? (WAErrorCode)error.code
        : WAErrorCodeWiFiConfigFailed;
    
    [self.eventEmitter emitEvent:@{
        @"type": @"wifiError",
        @"code": [NSString stringWithFormat:@"%ld", (long)errorCode],
        @"message": error.localizedDescription ?: @"WiFi configuration failed"
    }];
    
    if (self.currentCompletion) {
        self.currentCompletion(NO, error);
        self.currentCompletion = nil;
    }
}

#pragma mark - Simulation (TODO: REMOVE when SDK is integrated)

- (void)simulateWiFiConfig:(NSString *)deviceId timeout:(NSTimeInterval)timeout {
    // This simulates a multi-step WiFi configuration
    // Replace this entire method with actual SDK calls
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // Setup timeout
    __weak typeof(self) weakSelf = self;
    self.configTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                              repeats:NO
                                                                block:^(NSTimer *timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && strongSelf.isConfiguringWiFi) {
            NSError *error = [WAErrorHandler errorWithCode:WAErrorCodeWiFiConfigTimeout
                                                   message:@"WiFi configuration timed out"];
            [strongSelf handleConfigFailure:error];
        }
    }];
    
    // Step 1: Sending credentials
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), queue, ^{
        [self emitWiFiProgress:@"sending" percent:30];
        
        // Step 2: Device connecting to WiFi
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), queue, ^{
            [self emitWiFiProgress:@"connecting" percent:60];
            
            // Step 3: Verifying connection
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), queue, ^{
                [self emitWiFiProgress:@"verifying" percent:90];
                
                // Step 4: Success
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), queue, ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self handleConfigSuccess:deviceId];
                    });
                });
            });
        });
    });
}

#pragma mark - SDK Delegate (TODO: Implement actual delegate methods)

// TODO: Implement SDK delegate methods
/*
- (void)wifiConfigHelper:(HXWiFiConfigHelper *)helper
                progress:(NSString *)step
                 percent:(NSInteger)percent {
    [self emitWiFiProgress:step percent:percent];
}

- (void)wifiConfigHelper:(HXWiFiConfigHelper *)helper
       didSucceedForDevice:(NSString *)deviceId {
    [self handleConfigSuccess:deviceId];
}

- (void)wifiConfigHelper:(HXWiFiConfigHelper *)helper
        didFailWithError:(NSError *)error {
    [self handleConfigFailure:error];
}
*/

@end
