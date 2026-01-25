//
//  WAErrorHandler.m
//  wise_apartment
//
//  Error handling implementation
//

#import "WAErrorHandler.h"

static NSString *const kWAErrorDomain = @"com.wiseapartment.error";

@implementation WAErrorHandler

+ (FlutterError *)flutterErrorWithCode:(WAErrorCode)code
                               message:(NSString *)message
                               details:(id)details {
    NSLog(@"[WAErrorHandler] Creating Flutter error - code: %ld, message: %@", (long)code, message);
    NSString *codeString = [NSString stringWithFormat:@"%ld", (long)code];
    return [FlutterError errorWithCode:codeString
                               message:message ?: [self messageForErrorCode:code]
                               details:details];
}

+ (FlutterError *)flutterErrorFromNSError:(NSError *)error {
    NSLog(@"[WAErrorHandler] Converting NSError to Flutter error: %@", error);
    if (!error) {
        return [self flutterErrorWithCode:WAErrorCodeUnknown message:@"Unknown error" details:nil];
    }
    
    // Extract error code (if it's a WAError, use it directly)
    WAErrorCode code = WAErrorCodeUnknown;
    if ([error.domain isEqualToString:kWAErrorDomain]) {
        code = (WAErrorCode)error.code;
    } else {
        // Map common NSError codes
        if ([error.domain isEqualToString:NSURLErrorDomain]) {
            code = WAErrorCodeNetworkError;
        } else {
            code = WAErrorCodeSDKError;
        }
    }
    
    NSString *message = error.localizedDescription ?: [self messageForErrorCode:code];
    NSDictionary *details = @{
        @"domain": error.domain,
        @"code": @(error.code),
        @"userInfo": error.userInfo ?: @{}
    };
    
    return [self flutterErrorWithCode:code message:message details:details];
}

+ (NSError *)errorWithCode:(WAErrorCode)code message:(NSString *)message {
    NSLog(@"[WAErrorHandler] Creating NSError - code: %ld, message: %@", (long)code, message);
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: message ?: [self messageForErrorCode:code]
    };
    return [NSError errorWithDomain:kWAErrorDomain code:code userInfo:userInfo];
}

+ (NSString *)messageForErrorCode:(WAErrorCode)code {
    switch (code) {
        case WAErrorCodeBluetoothUnavailable:
            return @"Bluetooth is not available on this device";
        case WAErrorCodeScanAlreadyRunning:
            return @"A scan is already in progress";
        case WAErrorCodeBluetoothOff:
            return @"Bluetooth is turned off. Please enable it in Settings.";
        case WAErrorCodePermissionDenied:
            return @"Bluetooth permission denied. Please grant access in Settings.";
            
        case WAErrorCodeDeviceNotFound:
            return @"Device not found or out of range";
        case WAErrorCodePairingFailed:
            return @"Failed to pair with device";
        case WAErrorCodePairingCancelled:
            return @"Pairing was cancelled";
        case WAErrorCodePairingTimeout:
            return @"Pairing timed out";
            
        case WAErrorCodeServerRegistrationFailed:
            return @"Failed to register device with server";
        case WAErrorCodeNetworkError:
            return @"Network error occurred";
            
        case WAErrorCodeWiFiConfigFailed:
            return @"WiFi configuration failed";
        case WAErrorCodeWiFiConfigTimeout:
            return @"WiFi configuration timed out";
        case WAErrorCodeInvalidSSID:
            return @"Invalid WiFi SSID or password";
            
        case WAErrorCodeInvalidParameters:
            return @"Invalid parameters provided";
        case WAErrorCodeSDKError:
            return @"SDK error occurred";
        case WAErrorCodeUnknown:
        default:
            return @"An unknown error occurred";
    }
}

@end
