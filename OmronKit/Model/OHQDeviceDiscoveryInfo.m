//
//  OHQDeviceDiscoveryInfo.m
//  OmronKit
//
//  Created by Waqar Malik on 2/14/22.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "OHQDeviceDiscoveryInfo.h"
#import "OHQDefines.h"
#import "OHQConstants.h"

@implementation OHQDeviceDiscoveryInfo

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral rawAdvertisementData:(NSDictionary<NSString *,id> *)rawAdvertisementData RSSI:(NSNumber *)RSSI {
    NSString *localName = rawAdvertisementData[CBAdvertisementDataLocalNameKey];
    if (!peripheral || !localName || !RSSI) {
        return nil;
    }
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        [self updateWithRawAdvertisementData:rawAdvertisementData RSSI:RSSI];
    }
    return self;
}

- (void)updateWithRawAdvertisementData:(NSDictionary<NSString *,id> *)rawAdvertisementData RSSI:(NSNumber *)RSSI {
    NSMutableDictionary<OHQAdvertisementDataKey,id> *newAdvertisementData = (_advertisementData ? [_advertisementData mutableCopy] : [@{} mutableCopy]);
    
    id localName = rawAdvertisementData[CBAdvertisementDataLocalNameKey];
    if (localName) {
        newAdvertisementData[OHQAdvertisementDataLocalNameKey] = localName;
    }
    id isConnectable = rawAdvertisementData[CBAdvertisementDataIsConnectable];
    newAdvertisementData[OHQAdvertisementDataIsConnectable] = isConnectable;
    id overflowServiceUUIDs = rawAdvertisementData[CBAdvertisementDataOverflowServiceUUIDsKey];
    newAdvertisementData[OHQAdvertisementDataOverflowServiceUUIDsKey] = overflowServiceUUIDs;
    id serviceData = rawAdvertisementData[CBAdvertisementDataServiceDataKey];
    newAdvertisementData[OHQAdvertisementDataServiceDataKey] = serviceData;
    id serviceUUIDs = rawAdvertisementData[CBAdvertisementDataServiceUUIDsKey];
    newAdvertisementData[OHQAdvertisementDataServiceUUIDsKey] = serviceUUIDs;
    id solicitedServiceUUIDs = rawAdvertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey];
    newAdvertisementData[OHQAdvertisementDataSolicitedServiceUUIDsKey] = solicitedServiceUUIDs;
    id txPowerLevel = rawAdvertisementData[CBAdvertisementDataTxPowerLevelKey];
    newAdvertisementData[OHQAdvertisementDataTxPowerLevelKey] = txPowerLevel;
    NSData *rawManufacturerData = rawAdvertisementData[CBAdvertisementDataManufacturerDataKey];
    if (rawManufacturerData && [serviceUUIDs containsObject:_weightScaleServiceUUID]) {
        const void *pt = rawManufacturerData.bytes;
        NSMutableDictionary<OHQManufacturerDataKey,id> *newManufacturerData = [@{} mutableCopy];
        
        UInt16 companyIdentifier;
        memcpy(&companyIdentifier, pt, sizeof(companyIdentifier));
        pt += sizeof(companyIdentifier);
        
        newManufacturerData[OHQManufacturerDataCompanyIdentifierKey] = @(companyIdentifier);
        newManufacturerData[OHQManufacturerDataCompanyIdentifierDescriptionKey] = CompanyIdentifierDescription(companyIdentifier);
        
        if (companyIdentifier == OmronCompanyIdentifier) {
            OmronManufacturerDataType manufacturerDataType;
            memcpy(&manufacturerDataType, pt, sizeof(manufacturerDataType));
            pt += sizeof(manufacturerDataType);
            
            switch (manufacturerDataType) {
                case OmronManufacturerDataTypeEachUserData: {
                    OmronEachUserDataFlags eachUserDataFlags;
                    memcpy(&eachUserDataFlags, pt, sizeof(eachUserDataFlags));
                    pt += sizeof(eachUserDataFlags);
                    
                    NSUInteger numberOfUser = (eachUserDataFlags & OmronEachUserDataFlagsNumberOfUser) + 1;
                    newManufacturerData[OHQManufacturerDataNumberOfUserKey] = @(numberOfUser);
                    if (eachUserDataFlags & OmronEachUserDataFlagsIsPairable) {
                        newManufacturerData[OHQManufacturerDataIsPairingMode] = @YES;
                    }
                    if (eachUserDataFlags & OmronEachUserDataFlagsTimeNotConfigured) {
                        newManufacturerData[OHQManufacturerDataTimeNotConfigured] = @YES;
                    }
                    NSMutableArray *recordInfoArray = [@[] mutableCopy];
                    for (int i = 0; i < numberOfUser; i++) {
                        UInt16 lastSequenceNumber;
                        memcpy(&lastSequenceNumber, pt, sizeof(lastSequenceNumber));
                        pt += sizeof(lastSequenceNumber);
                        
                        UInt8 numberOfRecords;
                        memcpy(&numberOfRecords, pt, sizeof(numberOfRecords));
                        pt += sizeof(numberOfRecords);
                        
                        [recordInfoArray addObject:@{OHQRecordInfoUserIndexKey: @(i + 1), OHQRecordInfoLastSequenceNumberKey: @(lastSequenceNumber), OHQRecordInfoNumberOfRecordsKey: @(numberOfRecords)}];
                    }
                    if (recordInfoArray.count) {
                        newManufacturerData[OHQManufacturerDataRecordInfoArrayKey] = [recordInfoArray copy];
                    }
                    break;
                }
                default: {
                    break;
                }
            }
        }
        newAdvertisementData[OHQAdvertisementDataManufacturerDataKey] = [newManufacturerData copy];
    }
    _advertisementData = [newAdvertisementData copy];
    if (RSSI) {
        _RSSI = RSSI;
    }
}

- (NSString *)modelName {
    NSString *ret = nil;
    if (![_peripheral.name.lowercaseString hasPrefix:OmronLocalNameLowercasePrefix]) {
        ret = _peripheral.name;
    }
    return ret;
}

- (OHQDeviceCategory)category {
    OHQDeviceCategory ret = 0;
    
    NSArray<CBUUID *> *serviceUUIDs = self.advertisementData[OHQAdvertisementDataServiceUUIDsKey];
    if ([serviceUUIDs containsObject:_bloodPressureServiceUUID]) {
        ret = OHQDeviceCategoryBloodPressureMonitor;
    }
    else if ([serviceUUIDs containsObject:_bodyCompositionServiceUUID]) {
        ret = OHQDeviceCategoryBodyCompositionMonitor;
    }
    else if ([serviceUUIDs containsObject:_weightScaleServiceUUID]) {
        NSDictionary *manufacturerData = self.advertisementData[OHQAdvertisementDataManufacturerDataKey];
        UInt16 companyIdentifier = [manufacturerData[OHQManufacturerDataCompanyIdentifierKey] unsignedShortValue];
        ret = (companyIdentifier == OHQOmronHealthcareCompanyIdentifier ? OHQDeviceCategoryBodyCompositionMonitor : OHQDeviceCategoryWeightScale);
    } else if ([serviceUUIDs containsObject:_bloodGlucoseServiceUUID]) {
        ret = OHQDeviceCategoryBloodGlucoseMonitor;
    }
    return ret;
}

- (NSDictionary<OHQDeviceInfoKey,id> *)deviceInfo {
    NSMutableDictionary *ret = [@{ OHQDeviceInfoIdentifierKey: _peripheral.identifier,
                                   OHQDeviceInfoAdvertisementDataKey: _advertisementData,
                                   OHQDeviceInfoRSSIKey: _RSSI} mutableCopy];
    NSString *modelName = self.modelName;
    if (modelName) {
        ret[OHQDeviceInfoModelNameKey] = modelName;
    }
    OHQDeviceCategory category = self.category;
    if (category != 0) {
        ret[OHQDeviceInfoCategoryKey] = @(category);
    }
    return [ret copy];
}

- (BOOL)isEqual:(id)other {
    BOOL ret = NO;
    if (other == self) {
        ret = YES;
    }
    else if ([super isEqual:other]) {
        ret = YES;
    }
    else if ([other isKindOfClass:[self class]]) {
        typeof(self) otherItem = other;
        if ([otherItem.peripheral isEqual:self.peripheral]) {
            ret = YES;
        }
    }
    return ret;
}

- (NSUInteger)hash {
    return self.peripheral.hash;
}

@end
