//
//  OHQConstants.h
//  OmronKit
//
//  Created by Waqar Malik on 2/14/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of advertisement data
///---------------------------------------------------------------------------------------
///
// Omron Local Name Prefix
static NSString * const OmronLocalNameLowercasePrefix = @"blesmart_";

// Omron Company Identifier
static const UInt16 OmronCompanyIdentifier = 0x020E;


// Omron Manufacturer Data Type
typedef NS_ENUM(UInt8, OmronManufacturerDataType) {
    OmronManufacturerDataTypeUnknown = 0x00,
    OmronManufacturerDataTypeEachUserData = 0x01,
};

// Omron Each User Data Flags
typedef NS_OPTIONS(UInt8, OmronEachUserDataFlags) {
    OmronEachUserDataFlagsNumberOfUser = 3,
    OmronEachUserDataFlagsTimeNotConfigured = 1 << 2,
    OmronEachUserDataFlagsIsPairable = 1 << 3,
};

extern NSString * CompanyIdentifierDescription(UInt16 arg);

NS_ASSUME_NONNULL_END
