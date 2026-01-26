#import "HxjBleClient.h"

#import <HXJBLESDK/HXBluetoothLockHelper.h>

@implementation HxjBleClient

- (void)disConnectBle:(void (^)(void))callback {
    NSString *mac = self.lastConnectedMac;
    if (mac.length > 0) {
        [HXBluetoothLockHelper tryDisconnectPeripheralWithMac:mac];
    }
    if (callback) {
        dispatch_async(dispatch_get_main_queue(), callback);
    }
}

@end
