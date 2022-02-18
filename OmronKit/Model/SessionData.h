//
//  SessionData.h
//  OmronKit
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OHQDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SessionData : NSObject

@property (readonly, strong, nonatomic) NSUUID *identifier;
@property (readonly, nullable, copy, nonatomic) NSDictionary<OHQSessionOptionKey,id> *options;
@property (readonly, nullable, copy, nonatomic) NSString *modelName;
@property (readonly, assign, nonatomic) OHQDeviceCategory deviceCategory;
@property (readonly, nullable, strong, nonatomic) NSDate *currentTime;
@property (readonly, nullable, strong, nonatomic) NSNumber *batteryLevel;
@property (readonly, nullable, strong, nonatomic) NSNumber *registeredUserIndex;
@property (readonly, nullable, strong, nonatomic) NSNumber *authenticatedUserIndex;
@property (readonly, nullable, strong, nonatomic) NSNumber *deletedUserIndex;
@property (readonly, nullable, strong, nonatomic) NSNumber *databaseChangeIncrement;
@property (readonly, nullable, copy, nonatomic) NSDictionary<OHQUserDataKey,id> *userData;
@property (readonly, nullable, strong, nonatomic) NSNumber *sequenceNumberOfLatestRecord;
@property (readonly, nullable, copy, nonatomic) NSArray<NSDictionary<OHQMeasurementRecordKey,id> *> *measurementRecords;
@property (readonly, strong, nonatomic) NSDate *completionDate;
@property (assign, nonatomic) OHQCompletionReason completionReason;
@property (readonly, nullable, copy, nonatomic) NSString *log;

- (instancetype)initWithIdentifier:(NSUUID *)identifier options:(NSDictionary<OHQSessionOptionKey,id> *)options;
- (void)addSessionData:(id)data withType:(OHQDataType)type;

@end

NS_ASSUME_NONNULL_END
