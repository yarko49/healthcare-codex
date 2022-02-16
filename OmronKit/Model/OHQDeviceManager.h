//
//  OHQDeviceManager.h
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#pragma clang system_header
#import <Foundation/Foundation.h>
#import "OHQDefines.h"

@protocol OHQDeviceManagerDataSource;
@protocol OHQDeviceManagerDelegate;

NS_ASSUME_NONNULL_BEGIN

///---------------------------------------------------------------------------------------
#pragma mark - OHQDeviceManager interface
///---------------------------------------------------------------------------------------

@interface OHQDeviceManager : NSObject

+ (OHQDeviceManager *)sharedManager;

@property (nonatomic, assign, readonly) OHQDeviceManagerState state;
@property (nonatomic, weak, nullable) id<OHQDeviceManagerDelegate> delegate;
@property (nonatomic, weak, nullable) id<OHQDeviceManagerDataSource> dataSource;

/** Scan the device.
 @param category Device category to scan
 @param observer Scan monitoring block
 @param completion Complete process block
 */
- (void)scanForDevicesWithCategory:(OHQDeviceCategory)category
                     usingObserver:(OHQScanObserverBlock)observer
                        completion:(OHQCompletionBlock)completion;

/** Suspend the Scanning.
 */
- (void)stopScan;

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

@end

///---------------------------------------------------------------------------------------
#pragma mark - OHQDeviceManagerDataSource protocol
///---------------------------------------------------------------------------------------

@protocol OHQDeviceManagerDataSource <NSObject>

@optional
- (nullable NSString *)deviceManager:(OHQDeviceManager *)manager localNameForDevice:(NSUUID *)identifier;

@end

@protocol OHQDeviceManagerDelegate <NSObject>
@optional
- (void)deviceManager:(OHQDeviceManager *)manager didFindDeviceWithInfo:(NSDictionary<OHQDeviceInfoKey,id> *)deviceInfo;

@end
NS_ASSUME_NONNULL_END
