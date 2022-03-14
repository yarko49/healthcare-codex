//
//  OHQDeviceManager.h
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#pragma clang system_header
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "OHQDefines.h"

@protocol OHQDeviceManagerDataSource;
@protocol OHQDeviceManagerDelegate;

NS_ASSUME_NONNULL_BEGIN

///---------------------------------------------------------------------------------------
#pragma mark - OHQDeviceManager interface
///---------------------------------------------------------------------------------------

@interface OHQDeviceManager : NSObject

+ (OHQDeviceManager *)sharedManager;

+ (CBUUID *)bloodGlucoseServiceUUID;
+ (CBUUID *)bloodPressureServiceUUID;
+ (CBUUID *)bodyCompositionServiceUUID;
+ (CBUUID *)weightScaleServiceUUID;

@property (nonatomic, assign, readonly) OHQDeviceManagerState state;
@property (nonatomic, weak, nullable) id<OHQDeviceManagerDataSource> dataSource;

/** Scan the device.
   @param category Device category to scan
   @param observer Scan monitoring block
   @param completion Complete process block
 */
- (void)scanForDevicesWithCategory:(OHQDeviceCategory)category
        usingObserver:(OHQScanObserverBlock)observer
        completion:(OHQCompletionBlock)completion;

- (void)startScan;
/** Suspend the Scanning.
 */
- (void)stopScan;

- (BOOL)isDeviceConnected:(NSString *)identifier;

/** Start session with the device with the specified identifier.
   @param identifier Identifier of device
   @param dataObserver Data monitoring block
   @param connectionObserver Connection monitoring block
   @param completion Complete process block
   @param options Session options
 */
- (void)startSessionWithDevice:(NSUUID *)identifier
        usingDataObserver:(nullable OHQDataObserverBlock)dataObserver
        connectionObserver:(nullable OHQConnectionObserverBlock)connectionObserver
        completion:(OHQCompletionBlock)completion
        options:(nullable NSDictionary<OHQSessionOptionKey,id> *)options;

/** Cancel session with the device with the specified identifier.
   @param identifier Identifier of device
 */
- (void)cancelSessionWithDevice:(NSUUID *)identifier;

- (void)connectPerpherial:(CBPeripheral *)peripheral withOptions:(nullable NSDictionary<NSString *, id> *)options;
- (nullable NSDictionary<OHQDeviceInfoKey,id> *)deviceInfoForPeripheral:(CBPeripheral *)peripheral;
- (nullable NSDictionary<OHQDeviceInfoKey,id> *)deviceInfoForIdentifier:(NSUUID *)identifier;

- (void)addDelegate:(NSObject<OHQDeviceManagerDelegate> *) delegate NS_SWIFT_NAME(add(delegate:));
- (void)removeDelegate:(NSObject<OHQDeviceManagerDelegate> *) delegate NS_SWIFT_NAME(remove(delegate:));
@end

///---------------------------------------------------------------------------------------
#pragma mark - OHQDeviceManagerDataSource protocol
///---------------------------------------------------------------------------------------

@protocol OHQDeviceManagerDataSource <NSObject>
@optional
- (nullable NSString *)deviceManager:(OHQDeviceManager *)manager localNameForDevice:(NSUUID *)identifier;
@end

@protocol OHQDeviceManagerDelegate <NSObject>
- (void)deviceManager:(OHQDeviceManager *)manager didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI;
- (void)deviceManager:(OHQDeviceManager *)manager didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
- (void)deviceManager:(OHQDeviceManager *)manager didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
- (void)deviceManager:(OHQDeviceManager *)manager didConnectPeripheral:(CBPeripheral *)peripheral;
- (BOOL)deviceManager:(OHQDeviceManager *)manager shouldStartTransferForPeripherial:(CBPeripheral *)peripheral;

@end
NS_ASSUME_NONNULL_END
