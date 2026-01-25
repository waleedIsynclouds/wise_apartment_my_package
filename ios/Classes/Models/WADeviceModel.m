//
//  WADeviceModel.m
//  wise_apartment
//
//  Device model implementation
//

#import "WADeviceModel.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation WADeviceModel

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[@"deviceId"] = self.deviceId ?: @"";
    dict[@"name"] = self.name ?: @"Unknown Device";
    
    if (self.rssi) {
        dict[@"rssi"] = self.rssi;
    }
    
    if (self.manufacturerData) {
        dict[@"manufacturerData"] = self.manufacturerData;
    }
    
    if (self.advertisementData) {
        dict[@"advertisementData"] = self.advertisementData;
    }
    
    if (self.deviceType) {
        dict[@"deviceType"] = self.deviceType;
    }
    
    return [dict copy];
}

+ (instancetype)deviceFromPeripheral:(CBPeripheral *)peripheral
                   advertisementData:(NSDictionary *)advertisementData
                                RSSI:(NSNumber *)rssi {
    NSLog(@"[WADeviceModel] Creating device model from peripheral: %@", peripheral.identifier.UUIDString);
    
    WADeviceModel *device = [[WADeviceModel alloc] init];
    
    device.deviceId = peripheral.identifier.UUIDString;
    device.name = peripheral.name ?: advertisementData[CBAdvertisementDataLocalNameKey] ?: @"Unknown Device";
    device.rssi = rssi;
    
    NSLog(@"[WADeviceModel] Device info - ID: %@, Name: %@, RSSI: %@", device.deviceId, device.name, rssi);
    
    // Extract manufacturer data
    NSData *manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey];
    if (manufacturerData) {
        device.manufacturerData = [manufacturerData base64EncodedStringWithOptions:0];
        NSLog(@"[WADeviceModel] Manufacturer data found: %lu bytes", (unsigned long)manufacturerData.length);
    }
    
    // Build advertisement data dictionary
    NSMutableDictionary *adData = [NSMutableDictionary dictionary];
    if (advertisementData[CBAdvertisementDataLocalNameKey]) {
        adData[@"localName"] = advertisementData[CBAdvertisementDataLocalNameKey];
    }
    if (advertisementData[CBAdvertisementDataTxPowerLevelKey]) {
        adData[@"txPowerLevel"] = advertisementData[CBAdvertisementDataTxPowerLevelKey];
    }
    if (advertisementData[CBAdvertisementDataServiceUUIDsKey]) {
        NSArray *serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey];
        NSMutableArray *uuidStrings = [NSMutableArray array];
        for (CBUUID *uuid in serviceUUIDs) {
            [uuidStrings addObject:uuid.UUIDString];
        }
        adData[@"serviceUUIDs"] = uuidStrings;
        NSLog(@"[WADeviceModel] Found %lu service UUIDs", (unsigned long)serviceUUIDs.count);
    }
    device.advertisementData = [adData copy];
    
    NSLog(@"[WADeviceModel] Device model created successfully");
    return device;
}

@end
