//
//  OHQDeviceDiscoveryInfo.h
//  OmronKit
//
//  Created by Waqar Malik on 2/14/22.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "OHQDefines.h"

NS_ASSUME_NONNULL_BEGIN

///---------------------------------------------------------------------------------------
#pragma mark - OHQDeviceDiscoveryInfo class
///---------------------------------------------------------------------------------------

@interface OHQDeviceDiscoveryInfo : NSObject {
    @protected
    CBPeripheral *_peripheral;
    NSNumber *_RSSI;
    NSDictionary<OHQAdvertisementDataKey,id> *_advertisementData;
}

@property (readonly) CBPeripheral *peripheral;
@property (readonly) NSNumber *RSSI;
@property (readonly) NSDictionary<OHQAdvertisementDataKey,id> *advertisementData;
@property (nullable, readonly) NSString *modelName;
@property (readonly) NSDictionary<OHQDeviceInfoKey,id> *deviceInfo;
@property (readonly) OHQDeviceCategory category;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral rawAdvertisementData:(NSDictionary<NSString *,id> *)rawAdvertisementData RSSI:(NSNumber *)RSSI;
- (void)updateWithRawAdvertisementData:(NSDictionary<NSString *,id> *)rawAdvertisementData RSSI:(NSNumber *)RSSI;

@end

NS_ASSUME_NONNULL_END
