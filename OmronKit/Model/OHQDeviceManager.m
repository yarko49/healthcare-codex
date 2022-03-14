//
//  OHQDeviceManager.m
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

#import "OHQDeviceManager.h"
#import "OHQDevice.h"
#import "OHQLog.h"
#import "CBUUID+Description.h"
#import "OHQSessionInfo.h"
#import "OHQConstants.h"
#import "OHQDeviceDiscoveryInfo.h"

#define OHQ_INLINE NS_INLINE
#define OHQ_UNUSED __attribute__((unused))

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of GCD (ohq_dispatch_*)
///---------------------------------------------------------------------------------------

OHQ_UNUSED static const char *CallbackQueueLabel = "OHQDeviceManager-callback";
static const char *InternalQueueLabel = "OHQDeviceManager-internal";
static const char *observeCentralManagerStateQueueLabel = "OHQDeviceManager-observeCentralManagerState";

OHQ_INLINE
dispatch_queue_t ohq_dispatch_get_callback_queue() {
	static dispatch_queue_t callbackQueue = NULL;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
#ifdef OHQ_OPTION_CALLBACK_USING_MAIN_QUEUE
		callbackQueue = dispatch_get_main_queue();
#else // OHQ_OPTION_CALLBACK_USING_MAIN_QUEUE
		callbackQueue = dispatch_queue_create(CallbackQueueLabel, DISPATCH_QUEUE_SERIAL);
#endif // OHQ_OPTION_CALLBACK_USING_MAIN_QUEUE
	});
	return callbackQueue;
}

OHQ_INLINE
BOOL ohq_dispatch_current_queue_is_callback_queue() {
	BOOL ret = NO;
#ifdef OHQ_OPTION_CALLBACK_USING_MAIN_QUEUE
	ret = [NSThread isMainThread];
#else // OHQ_OPTION_CALLBACK_USING_MAIN_QUEUE
	const char *currentQueueLabel = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
	ret = (strcmp(CallbackQueueLabel, currentQueueLabel) == 0);
#endif // OHQ_OPTION_CALLBACK_USING_MAIN_QUEUE
	return ret;
}

OHQ_INLINE
void ohq_dispatch_to_callback_queue(dispatch_block_t block) {
	if (block) {
		if (ohq_dispatch_current_queue_is_callback_queue()) {
			block();
		}
		else {
			dispatch_async(ohq_dispatch_get_callback_queue(), block);
		}
	}
}

OHQ_INLINE
dispatch_queue_t ohq_dispatch_get_internal_queue() {
	static dispatch_queue_t internalQueue = NULL;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		internalQueue = dispatch_queue_create(InternalQueueLabel, DISPATCH_QUEUE_SERIAL);
	});
	return internalQueue;
}

OHQ_INLINE
BOOL ohq_dispatch_current_queue_is_internal_queue() {
	const char *currentQueueLabel = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
	return (strcmp(InternalQueueLabel, currentQueueLabel) == 0);
}

OHQ_INLINE
void ohq_dispatch_to_internal_queue(dispatch_block_t block) {
	if (block) {
		if (ohq_dispatch_current_queue_is_internal_queue()) {
			block();
		}
		else {
			dispatch_async(ohq_dispatch_get_internal_queue(), block);
		}
	}
}

///---------------------------------------------------------------------------------------
#pragma mark - OHQDeviceManager class extension
///---------------------------------------------------------------------------------------

@interface OHQDeviceManager () <CBCentralManagerDelegate, OHQDeviceDelegate>
@property (nonatomic, strong) CBCentralManager *central;
@property (nonatomic, assign, readwrite) OHQDeviceManagerState state;
@property (nonatomic, copy) dispatch_block_t scanStartBlock;
@property (nonatomic, copy) OHQScanObserverBlock scanObserverBlock;
@property (nonatomic, copy) OHQCompletionBlock scanCompletionBlock;
@property (nonatomic, strong) NSMutableDictionary<NSUUID *, OHQDeviceDiscoveryInfo *> *discoveredDevices;
@property (nonatomic, strong) NSMutableDictionary<NSUUID *, OHQSessionInfo *> *sessionInfoDictionary;
@property (nonatomic, strong) NSHashTable<OHQDeviceManagerDelegate> *delegates;
@end

///---------------------------------------------------------------------------------------
#pragma mark - OHQDeviceManager class implementation
///---------------------------------------------------------------------------------------

// Service UUID Strings
static NSString * const BloodGlucoseServiceUUIDString = @"1808";
static NSString * const BloodPressureServiceUUIDString = @"1810";
static NSString * const BodyCompositionServiceUUIDString = @"181B";
static NSString * const WeightScaleServiceUUIDString = @"181D";

// Service UUIDs
static CBUUID * _bloodGlucoseServiceUUID = nil;
static CBUUID * _bloodPressureServiceUUID = nil;
static CBUUID * _bodyCompositionServiceUUID = nil;
static CBUUID * _weightScaleServiceUUID = nil;

@implementation OHQDeviceManager

+ (void)initialize {
	if (self == [OHQDeviceManager class]) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			_bloodGlucoseServiceUUID = [CBUUID UUIDWithString:BloodGlucoseServiceUUIDString];
			_bloodPressureServiceUUID = [CBUUID UUIDWithString:BloodPressureServiceUUIDString];
			_bodyCompositionServiceUUID = [CBUUID UUIDWithString:BodyCompositionServiceUUIDString];
			_weightScaleServiceUUID = [CBUUID UUIDWithString:WeightScaleServiceUUIDString];
		});
	}
}

+ (CBUUID *)bloodGlucoseServiceUUID {
	return _bloodGlucoseServiceUUID;
}

+ (CBUUID *)bloodPressureServiceUUID {
	return _bloodPressureServiceUUID;
}

+ (CBUUID *)bodyCompositionServiceUUID {
	return _bodyCompositionServiceUUID;
}

+ (CBUUID *)weightScaleServiceUUID {
	return _weightScaleServiceUUID;
}

- (instancetype)init {
	self = [super init];
	if (self) {
#ifdef OHQ_OPTION_CALLBACK_USING_MAIN_QUEUE
		OHQLogV(@"defined OHQ_OPTION_CALLBACK_USING_MAIN_QUEUE");
#endif // OHQ_OPTION_CALLBACK_USING_MAIN_QUEUE
#ifdef OHQ_OPTION_ENABLE_RETRY_FOR_NOTIFICATION_ACTIVATION
		OHQLogV(@"defined OHQ_OPTION_ENABLE_RETRY_FOR_NOTIFICATION_ACTIVATION");
		OHQLogV(@"defined OHQ_OPTION_RETRY_INTERVAL_FOR_NOTIFICATION_ACTIVATION %f", OHQ_OPTION_RETRY_INTERVAL_FOR_NOTIFICATION_ACTIVATION);
		OHQLogV(@"defined OHQ_OPTION_RETRY_COUNT_FOR_NOTIFICATION_ACTIVATION %d", OHQ_OPTION_RETRY_COUNT_FOR_NOTIFICATION_ACTIVATION);
#endif // OHQ_OPTION_ENABLE_RETRY_FOR_NOTIFICATION_ACTIVATION

		_delegates = (NSHashTable<OHQDeviceManagerDelegate> *)[NSHashTable weakObjectsHashTable];
		NSDictionary<NSString *,id> *options = @{CBCentralManagerOptionShowPowerAlertKey: @NO};
		OHQLogD(@"-[CBCentralManager initWithDelegate:queue:options:] options:%@", options);

		self.central = [[CBCentralManager alloc] initWithDelegate:self queue:ohq_dispatch_get_internal_queue() options:options];

		// メインスレッドでのCentralManagerStateの監視を回避(DEV-199)
		dispatch_queue_t deviceStateQueue = dispatch_queue_create(observeCentralManagerStateQueueLabel, DISPATCH_QUEUE_SERIAL);
		__weak typeof(self) weakSelf = self;
		__block OHQDeviceManagerState * deviceManagerState = &_state;
		dispatch_async(deviceStateQueue, ^{
			while (weakSelf.central.state == CBManagerStateUnknown || weakSelf.central.state == CBManagerStateResetting) {
				[NSThread sleepForTimeInterval:0.1];
			}
			[weakSelf ohq_convertManagerState:weakSelf.central.state toDeviceManagerState:deviceManagerState];

			weakSelf.scanStartBlock = nil;
			weakSelf.scanObserverBlock = nil;
			weakSelf.scanCompletionBlock = nil;
			weakSelf.discoveredDevices = [@{} mutableCopy];
			weakSelf.sessionInfoDictionary = [@{} mutableCopy];

			[[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(ohq_observeNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(ohq_observeNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
		});
	}
	return self;
}

- (void)addDelegate:(NSObject<OHQDeviceManagerDelegate> *)delegate {
	@synchronized (self) {
		if(![self.delegates containsObject:delegate]) {
			[self.delegates addObject:delegate];
		}
	}
}

- (void)removeDelegate:(NSObject<OHQDeviceManagerDelegate> *)delegate {
	@synchronized (self) {
		NSEnumerator *delegateEnumerator = [[self.delegates allObjects] reverseObjectEnumerator];

		for(NSObject<OHQDeviceManagerDelegate> *existing in delegateEnumerator) {
			if(existing == delegate) {
				[self.delegates removeObject:existing];
				break;
			}
		}
	}
}

- (void)dealloc {
	[_delegates removeAllObjects];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

///---------------------------------------------------------------------------------------
#pragma mark - Public methods
///---------------------------------------------------------------------------------------

+ (OHQDeviceManager *)sharedManager {
	static OHQDeviceManager *sharedManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedManager = [[OHQDeviceManager alloc] init];
	});
	return sharedManager;
}

- (void)scanForDevicesWithCategory:(OHQDeviceCategory)category usingObserver:(OHQScanObserverBlock)observer completion:(OHQCompletionBlock)completion {
	OHQFuncLogI(@"[IN] categories:%@ observer:%@ completion:%@", OHQDeviceCategoryDescription(category), observer, completion);

	// Check Parameter.
	if (!completion) {
		OHQFuncLogW(@"completion cannot be nil");
		@throw [NSException exceptionWithName:NSInvalidArgumentException
		        reason:[NSString stringWithFormat:@"%s: completion cannot be nil", __PRETTY_FUNCTION__]
		        userInfo:nil];
		return;
	}

	NSMutableSet<CBUUID *> *services = [NSMutableSet set];
	switch (category) {
	case OHQDeviceCategoryBloodPressureMonitor:
		[services addObject:_bloodPressureServiceUUID];
		break;
	case OHQDeviceCategoryWeightScale:
		[services addObject:_weightScaleServiceUUID];
		break;
	case OHQDeviceCategoryBodyCompositionMonitor:
		// !!!: In Omron device, body composition service is secondary service of weight scale service, it is not included in advertisement data, so we can not distinguish between weight scale and body composition monitor by scanning.
		[services addObject:_weightScaleServiceUUID];
		[services addObject:_bodyCompositionServiceUUID];
		break;
	case OHQDeviceCategoryBloodGlucoseMonitor:
		[services addObject:_bloodGlucoseServiceUUID];
		break;
	case OHQDeviceCategoryAny:
		[services addObject:_bloodPressureServiceUUID];
		[services addObject:_weightScaleServiceUUID];
		[services addObject:_bodyCompositionServiceUUID];
		[services addObject:_bloodGlucoseServiceUUID];
		break;
	default: break;
	}

	if (!services.count) {
		OHQFuncLogW(@"category cannot be none");
		@throw [NSException exceptionWithName:NSInvalidArgumentException
		        reason:[NSString stringWithFormat:@"%s: category cannot be none", __PRETTY_FUNCTION__]
		        userInfo:nil];
		return;
	}

	__weak typeof(self) weakSelf = self;
	ohq_dispatch_to_internal_queue(^{

		// Check the Bluetooth state.
		if (weakSelf.state != OHQDeviceManagerStatePoweredOn) {
			ohq_dispatch_to_callback_queue(^{
				OHQCompletionReason reason = OHQCompletionReasonPoweredOff;
				OHQLogI(@"[SCAN] completion(%@)", OHQCompletionReasonDescription(reason));
				completion(reason);
			});
			return;
		}

		// Check the scanning.
		if (weakSelf.scanCompletionBlock) {
			ohq_dispatch_to_callback_queue(^{
				OHQCompletionReason reason = OHQCompletionReasonBusy;
				OHQLogI(@"[SCAN] completion(%@)", OHQCompletionReasonDescription(reason));
				completion(reason);
			});
			return;
		}

		// Clear the scan cache.
		[weakSelf.discoveredDevices removeAllObjects];

		weakSelf.scanStartBlock = ^{
		        NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES};
		        OHQLogD(@"-[CBCentralManager scanForPeripheralsWithServices:options:] services:%@ options:%@", services, options);
		        [weakSelf.central scanForPeripheralsWithServices:services.allObjects options:options];
		};
		weakSelf.scanObserverBlock = ^(NSDictionary<OHQDeviceInfoKey,id> *deviceInfo) {
		        if (observer) {
				OHQDeviceCategory foundDeviceCategory = [deviceInfo[OHQDeviceInfoCategoryKey] unsignedIntegerValue];
				if (category != OHQDeviceCategoryAny && category != foundDeviceCategory) {
					OHQLogV(@"[SCAN] category(%@) mismatch -> ignore", OHQDeviceCategoryDescription(foundDeviceCategory));
					return;
				}
				ohq_dispatch_to_callback_queue(^{
					OHQLogV(@"[SCAN] observer(%@)", deviceInfo);
					observer(deviceInfo);
				});
			}
		};
		weakSelf.scanCompletionBlock = ^(OHQCompletionReason aReason) {
		        OHQLogD(@"-[CBCentralManager stopScan]");
		        [weakSelf.central stopScan];
		        weakSelf.scanStartBlock = nil;
		        weakSelf.scanObserverBlock = nil;
		        weakSelf.scanCompletionBlock = nil;
		        ohq_dispatch_to_callback_queue(^{
				OHQLogI(@"[SCAN] completion(%@)", OHQCompletionReasonDescription(aReason));
				completion(aReason);
			});
		};

		// Start to scan.
		weakSelf.scanStartBlock();
	});
}

- (void)connectPerpherial:(CBPeripheral *)peripheral withOptions:(nullable NSDictionary<NSString *, id> *)options {
	[self.central connectPeripheral:peripheral options:options];
}

- (nullable NSDictionary<OHQDeviceInfoKey,id> *)deviceInfoForPeripheral:(CBPeripheral *)peripheral {
	return [self.discoveredDevices[peripheral.identifier] deviceInfo];
}

- (nullable NSDictionary<OHQDeviceInfoKey,id> *)deviceInfoForIdentifier:(NSUUID *)identifier {
	return [self.discoveredDevices[identifier] deviceInfo];
}

- (void)startScan {
	OHQFuncLogI(@"[IN]");

	__weak typeof(self) weakSelf = self;
	ohq_dispatch_to_internal_queue(^{
		if (weakSelf.scanStartBlock) {
			weakSelf.scanStartBlock();
		}
	});
}

- (void)stopScan {
	OHQFuncLogI(@"[IN]");

	__weak typeof(self) weakSelf = self;
	ohq_dispatch_to_internal_queue(^{
		if (weakSelf.scanCompletionBlock) {
			weakSelf.scanCompletionBlock(OHQCompletionReasonCanceled);
		}
	});
}

- (BOOL)isDeviceConnected:(NSString *)identifier {
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:identifier];
	if(uuid == NULL) {
		return NO;
	}
	return (self.discoveredDevices[uuid] != NULL);
}

- (void)startSessionWithDevice:(NSUUID *)identifier usingDataObserver:(OHQDataObserverBlock)dataObserver connectionObserver:(OHQConnectionObserverBlock)connectionObserver completion:(OHQCompletionBlock)completion options:(NSDictionary<OHQSessionOptionKey,id> *)options {
	OHQFuncLogI(@"[IN] identifier:%@ dataObserver:%@ connectionObserver:%@ completion:%@ options:%@", identifier, dataObserver, connectionObserver, completion, options);

	// Check Parameter.
	if (!identifier) {
		OHQFuncLogW(@"identifier cannot be nil");
		@throw [NSException exceptionWithName:NSInvalidArgumentException
		        reason:[NSString stringWithFormat:@"%s: identifier cannot be nil", __PRETTY_FUNCTION__]
		        userInfo:nil];
		return;
	}
	if (!completion) {
		OHQFuncLogW(@"completion cannot be nil");
		@throw [NSException exceptionWithName:NSInvalidArgumentException
		        reason:[NSString stringWithFormat:@"%s: completion cannot be nil", __PRETTY_FUNCTION__]
		        userInfo:nil];
		return;
	}
	if (![self ohq_validateSessionOptions:options]) {
		OHQFuncLogW(@"specified options is invalid");
		@throw [NSException exceptionWithName:NSInvalidArgumentException
		        reason:[NSString stringWithFormat:@"%s: specified options is invalid", __PRETTY_FUNCTION__]
		        userInfo:nil];
		return;
	}

	__weak typeof(self) weakSelf = self;
	ohq_dispatch_to_internal_queue(^{

		// Check the Bluetooth state.
		if (weakSelf.state != OHQDeviceManagerStatePoweredOn) {
			ohq_dispatch_to_callback_queue(^{
				OHQCompletionReason reason = OHQCompletionReasonPoweredOff;
				OHQLogI(@"[SESSION] completion(%@)", OHQCompletionReasonDescription(reason));
				completion(reason);
			});
			return;
		}

		// Get Peripheral object
		CBPeripheral *peripheral = weakSelf.discoveredDevices[identifier].peripheral;
		if (!peripheral) {
			NSArray<NSUUID *> *identifiers = @[identifier];
			OHQLogD(@"-[CBCentralManager retrievePeripheralsWithIdentifiers:] identifiers:%@", identifiers);
			NSArray<CBPeripheral *> *peripherals = [weakSelf.central retrievePeripheralsWithIdentifiers:identifiers];
			peripheral = peripherals.firstObject;
			if (!peripheral) {
				ohq_dispatch_to_callback_queue(^{
					OHQCompletionReason reason = OHQCompletionReasonInvalidDeviceIdentifier;
					OHQLogI(@"[SESSION] completion(%@)", OHQCompletionReasonDescription(reason));
					completion(reason);
				});
				return;
			}
		}

		// Checks if the connected.
		if (peripheral.state != CBPeripheralStateDisconnected) {
			ohq_dispatch_to_callback_queue(^{
				OHQCompletionReason reason = OHQCompletionReasonBusy;
				OHQLogI(@"[SESSION] completion(%@)", OHQCompletionReasonDescription(reason));
				completion(reason);
			});
			return;
		}

		// Checks if the processing.
		if (weakSelf.sessionInfoDictionary[identifier]) {
			ohq_dispatch_to_callback_queue(^{
				OHQCompletionReason reason = OHQCompletionReasonBusy;
				OHQLogI(@"[SESSION] completion(%@)", OHQCompletionReasonDescription(reason));
				completion(reason);
			});
			return;
		}

		OHQSessionInfo *sessionInfo = [OHQSessionInfo sessionInfoWithDataObserver:^(OHQDataType aDataType, id _Nonnull data) {
		                                       if (dataObserver) {
							       ohq_dispatch_to_callback_queue(^{
												      OHQLogI(@"[SESSION] dataObserver(%@, %@)", OHQDataTypeDescription(aDataType), data);
												      dataObserver(aDataType, data);
											      });
						       }
					       } connectionObserver:^(OHQConnectionState aState) {
		                                       if (connectionObserver) {
							       ohq_dispatch_to_callback_queue(^{
												      OHQLogI(@"[SESSION] connectionObserver(%@)", OHQConnectionStateDescription(aState));
												      connectionObserver(aState);
											      });
						       }
					       } completion:^(OHQCompletionReason aReason) {
		                                       weakSelf.sessionInfoDictionary[identifier] = nil;
		                                       ohq_dispatch_to_callback_queue(^{
											      OHQLogI(@"[SESSION] completion(%@)", OHQCompletionReasonDescription(aReason));
											      completion(aReason);
										      });
					       } options:options];
		sessionInfo.device = [[OHQDevice alloc] initWithPeripheral:peripheral queue:ohq_dispatch_get_internal_queue()];

		NSNumber *connectionWaitTimeObject = options[OHQSessionOptionConnectionWaitTimeKey];
		if (connectionWaitTimeObject) {
			NSTimeInterval connectionWaitTime = connectionWaitTimeObject.doubleValue;
			NSUUID *timeoutIdentifier = [NSUUID UUID];
			sessionInfo.connectionTimeoutHandler = ^(NSUUID *aTimeoutIdentifier) {
			        if (![timeoutIdentifier isEqual:aTimeoutIdentifier]) {
					return;
				}
			        if (peripheral.state != CBPeripheralStateConnecting) {
					return;
				}
			        OHQSessionInfo *timedOutSessionInfo = weakSelf.sessionInfoDictionary[identifier];
			        OHQCompletionBlock compleationBlock = timedOutSessionInfo.completionBlock;
			        timedOutSessionInfo.completionBlock = ^(OHQCompletionReason aReason) {
			                compleationBlock(OHQCompletionReasonConnectionTimedOut);
				};
			        timedOutSessionInfo.connectionObserverBlock(OHQConnectionStateDisconnecting);
			        OHQLogD(@"-[CBCentralManager cancelPeripheralConnection:] peripheral:%@", timedOutSessionInfo.device.peripheral);
			        [self.central cancelPeripheralConnection:timedOutSessionInfo.device.peripheral];
			        timedOutSessionInfo.connectionTimeoutHandler = nil;
			};
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(connectionWaitTime * NSEC_PER_SEC)), ohq_dispatch_get_internal_queue(), ^{
				OHQSessionInfo *timedOutSessionInfo = weakSelf.sessionInfoDictionary[identifier];
				if (timedOutSessionInfo.connectionTimeoutHandler) {
					timedOutSessionInfo.connectionTimeoutHandler(timeoutIdentifier);
				}
			});
		}

		weakSelf.sessionInfoDictionary[identifier] = sessionInfo;

		OHQLogD(@"-[CBCentralManager connectPeripheral:options:] peripheral:%@ options:%@", peripheral, nil);
		[weakSelf.central connectPeripheral:peripheral options:nil];

		weakSelf.sessionInfoDictionary[identifier].connectionObserverBlock(OHQConnectionStateConnecting);
	});
}

- (void)cancelSessionWithDevice:(NSUUID *)identifier {
	OHQFuncLogI(@"[IN] identifier:%@", identifier);

	OHQSessionInfo *sessionInfo = self.sessionInfoDictionary[identifier];
	if (!sessionInfo) {
		OHQFuncLogW(@"invalid identifier");
		return;
	}

	OHQCompletionBlock compleationBlock = sessionInfo.completionBlock;
	sessionInfo.completionBlock = ^(OHQCompletionReason aReason) {
		compleationBlock(OHQCompletionReasonCanceled);
	};

	sessionInfo.connectionObserverBlock(OHQConnectionStateDisconnecting);
	OHQLogD(@"-[CBCentralManager cancelPeripheralConnection:] peripheral:%@", sessionInfo.device.peripheral);
	[self.central cancelPeripheralConnection:sessionInfo.device.peripheral];
}

///---------------------------------------------------------------------------------------
#pragma mark - Private methods
///---------------------------------------------------------------------------------------

- (BOOL)ohq_convertManagerState:(CBManagerState)inState toDeviceManagerState:(OHQDeviceManagerState *)outState {
	BOOL ret = NO;
	if (outState) {
		switch (inState) {
		case CBManagerStateUnknown:
		case CBManagerStateResetting:
			*outState = OHQDeviceManagerStateUnknown;
			ret = YES;
			break;
		case CBManagerStateUnsupported:
			*outState = OHQDeviceManagerStateUnsupported;
			ret = YES;
			break;
		case CBManagerStateUnauthorized:
			*outState = OHQDeviceManagerStateUnauthorized;
			ret = YES;
			break;
		case CBManagerStatePoweredOff:
			*outState = OHQDeviceManagerStatePoweredOff;
			ret = YES;
			break;
		case CBManagerStatePoweredOn:
			*outState = OHQDeviceManagerStatePoweredOn;
			ret = YES;
			break;
		default:
			break;
		}
	}
	return ret;
}

// !!!: The stop and restart scannning processes for devices are implemented at the time of moving to backgournd only for iOS10 because these processes are implemented by Framework automatically in version prior to iOS10.
- (void)ohq_observeNotification:(NSNotification *)notification {
	OHQFuncLogD(@"[IN] notification:%@", notification);

	if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
		if (self.scanStartBlock) {
			OHQLogD(@"-[CBCentralManager stopScan]");
			[self.central stopScan];
		}
	}
	else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
		__weak typeof(self) weakSelf = self;
		ohq_dispatch_to_internal_queue(^{
			if (weakSelf.scanStartBlock) {
				weakSelf.scanStartBlock();
			}
		});
	}
}

- (BOOL)ohq_validateSessionOptions:(NSDictionary<OHQSessionOptionKey,id> *)options {
	OHQFuncLogD(@"[IN] options:%@", options);
	if ([options[OHQSessionOptionDeleteUserDataKey] boolValue]) {
		if (!options[OHQSessionOptionUserIndexKey]) {
			return NO;
		}
	}
	if (options[OHQSessionOptionUserDataKey] && ![options[OHQSessionOptionUserDataKey] count]) {
		return NO;
	}
	NSNumber *connectionWaitTimeObject = options[OHQSessionOptionConnectionWaitTimeKey];
	if (connectionWaitTimeObject) {
		NSTimeInterval connectionWaitTime = connectionWaitTimeObject.doubleValue;
		if (connectionWaitTime < 1.0) {
			return NO;
		}
	}
	return YES;
}

- (void)ohq_abortCommunicationForPeripheral:(CBPeripheral *)peripheral byReason:(OHQCompletionReason)reason {
	OHQFuncLogD(@"[IN] peripheral:%@ reason:%@", peripheral, OHQCompletionReasonDescription(reason));

	OHQSessionInfo *sessionInfo = self.sessionInfoDictionary[peripheral.identifier];
	if (!sessionInfo) {
		return;
	}

	if (peripheral.state != CBPeripheralStateConnected) {
		return;
	}

	OHQCompletionBlock compleationBlock = sessionInfo.completionBlock;
	sessionInfo.completionBlock = ^(OHQCompletionReason aReason) {
		compleationBlock(reason);
	};

	sessionInfo.connectionObserverBlock(OHQConnectionStateDisconnecting);
	OHQLogD(@"-[CBCentralManager cancelPeripheralConnection:] peripheral:%@", peripheral);
	[self.central cancelPeripheralConnection:peripheral];
}

///---------------------------------------------------------------------------------------
#pragma mark - Central manager delegate
///---------------------------------------------------------------------------------------

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
	OHQFuncLogD(@"[IN] central:%@", central);

	OHQDeviceManagerState state;
	[self ohq_convertManagerState:self.central.state toDeviceManagerState:&state];
	self.state = state;
	if (self.state != OHQDeviceManagerStatePoweredOn) {
		if (self.scanCompletionBlock) {
			self.scanCompletionBlock(OHQCompletionReasonPoweredOff);
		}
		[self.sessionInfoDictionary enumerateKeysAndObjectsUsingBlock:^(NSUUID * _Nonnull key, OHQSessionInfo * _Nonnull sessionInfo, BOOL * _Nonnull stop) {
		         sessionInfo.connectionObserverBlock(OHQConnectionStateDisconnected);
		         sessionInfo.completionBlock(OHQCompletionReasonPoweredOff);
		 }];
	}
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
	OHQFuncLogV(@"[IN] central:%@ peripheral:%@ advertisementData:%@ RSSI:%@", central, peripheral, advertisementData, RSSI);

	NSUUID *identifier = peripheral.identifier;

	OHQDeviceDiscoveryInfo *discoveredDevice = self.discoveredDevices[identifier];
	NSDictionary<OHQDeviceInfoKey,id> *deviceInfo = nil;
	NSMutableDictionary<NSString *, id> *mutableAdvertisementData = [advertisementData mutableCopy];
	if(mutableAdvertisementData[CBAdvertisementDataLocalNameKey] == NULL && [[peripheral.name lowercaseString] containsString:@"contour"]) {
		NSArray<CBUUID *> *serviceUUIDs = (NSArray<CBUUID *> *)advertisementData[CBAdvertisementDataServiceUUIDsKey];
		if([serviceUUIDs containsObject:_bloodGlucoseServiceUUID]) {
			mutableAdvertisementData[CBAdvertisementDataLocalNameKey] = peripheral.name;
		}
	}

	if (discoveredDevice) {
		// update discovery info
		[discoveredDevice updateWithRawAdvertisementData:mutableAdvertisementData RSSI:RSSI];
		deviceInfo = discoveredDevice.deviceInfo;
	} else {
		// new discovery info
		OHQDeviceDiscoveryInfo *newDevice = [[OHQDeviceDiscoveryInfo alloc] initWithPeripheral:peripheral rawAdvertisementData:mutableAdvertisementData RSSI:RSSI];
		self.discoveredDevices[peripheral.identifier] = newDevice;
		deviceInfo = newDevice.deviceInfo;
	}

	if (deviceInfo.count && self.scanObserverBlock) {
		self.scanObserverBlock(deviceInfo);
	}

	if(deviceInfo.count) {
		@synchronized (self) {
			for(NSObject<OHQDeviceManagerDelegate> *delegate in self.delegates) {
				[delegate deviceManager:self didDiscoverPeripheral:peripheral advertisementData:mutableAdvertisementData RSSI:RSSI];
			}
		}
	}
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	OHQFuncLogD(@"[IN] central:%@ peripheral:%@ error:%@", central, peripheral, error);

	@synchronized (self) {
		for(NSObject<OHQDeviceManagerDelegate> *delegate in self.delegates) {
			[delegate deviceManager:self didFailToConnectPeripheral:peripheral error:error];
		}
	}

	OHQSessionInfo *sessionInfo = self.sessionInfoDictionary[peripheral.identifier];
	if (!sessionInfo) {
		return;
	}

	if (error) {
		OHQFuncLogE(@"error:%@", error);
	}

	sessionInfo.connectionObserverBlock(OHQConnectionStateDisconnected);
	sessionInfo.completionBlock(OHQCompletionReasonFailedToConnect);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	OHQFuncLogD(@"[IN] central:%@ peripheral:%@ error:%@", central, peripheral, error);

	@synchronized (self) {
		for(NSObject<OHQDeviceManagerDelegate> *delegate in self.delegates) {
			[delegate deviceManager:self didDisconnectPeripheral:peripheral error:error];
		}
	}

	OHQSessionInfo *sessionInfo = self.sessionInfoDictionary[peripheral.identifier];
	if (!sessionInfo) {
		return;
	}

	if (error) {
		OHQFuncLogW(@"error:%@", error);
	}

	if (sessionInfo.device.measurementRecords) {
		sessionInfo.dataObserverBlock(OHQDataTypeMeasurementRecords, sessionInfo.device.measurementRecords);
	}

	sessionInfo.connectionObserverBlock(OHQConnectionStateDisconnected);
	sessionInfo.completionBlock(OHQCompletionReasonDisconnected);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	OHQFuncLogD(@"[IN] central:%@ peripheral:%@", central, peripheral);
	@synchronized (self) {
		for(NSObject<OHQDeviceManagerDelegate> *delegate in self.delegates) {
			[delegate deviceManager:self didConnectPeripheral:peripheral];
		}
	}
	OHQSessionInfo *sessionInfo = self.sessionInfoDictionary[peripheral.identifier];
	if (!sessionInfo) {
		return;
	}

	OHQDeviceDiscoveryInfo *discoveryInfo = self.discoveredDevices[peripheral.identifier];
	NSString *localName = nil;
	if (discoveryInfo) {
		localName = discoveryInfo.advertisementData[OHQAdvertisementDataLocalNameKey];
	} else if ([self.dataSource respondsToSelector:@selector(deviceManager:localNameForDevice:)]) {
		localName = [self.dataSource deviceManager:self localNameForDevice:peripheral.identifier];
	}
	OHQLogI(@"Connected with %@ (%@)", peripheral.identifier, (localName ? localName : peripheral.name));
	@synchronized (self) {
		for(NSObject<OHQDeviceManagerDelegate> *delegate in self.delegates) {
			if ([delegate respondsToSelector:@selector(deviceManager:shouldStartTransferForPeripherial:)]) {
				BOOL result = [delegate deviceManager:self shouldStartTransferForPeripherial:peripheral];
				if(result) {
					sessionInfo.connectionObserverBlock(OHQConnectionStateConnected);
					sessionInfo.device.delegate = self;
					[sessionInfo.device startTransferWithDataObserverBlock:sessionInfo.dataObserverBlock options:sessionInfo.options];
				}
			}
		}
	}
}

///---------------------------------------------------------------------------------------
#pragma mark - Device delegate
///---------------------------------------------------------------------------------------

- (void)device:(OHQDevice *)device didAbortTransferWithReason:(OHQCompletionReason)reason {
	OHQFuncLogD(@"[IN] device:%@ reason:%@", device, OHQCompletionReasonDescription(reason));

	[self ohq_abortCommunicationForPeripheral:device.peripheral byReason:reason];
}

@end
