//
//  OHQSessionInfo.h
//  OmronKit
//
//  Created by Waqar Malik on 2/14/22.
//

#import <Foundation/Foundation.h>
#import "OHQDefines.h"

@class OHQDevice;

NS_ASSUME_NONNULL_BEGIN

@interface OHQSessionInfo : NSObject
+ (OHQSessionInfo *)sessionInfoWithDataObserver:(OHQDataObserverBlock)dataObserver
                             connectionObserver:(OHQConnectionObserverBlock)connectionObserver
                                     completion:(OHQCompletionBlock)completion
                                        options:(NSDictionary<OHQSessionOptionKey,id> *)options;

@property (nonatomic, copy) OHQDataObserverBlock dataObserverBlock;
@property (nonatomic, copy) OHQConnectionObserverBlock connectionObserverBlock;
@property (nonatomic, copy) OHQCompletionBlock completionBlock;
@property (nonatomic, nullable, copy) void (^connectionTimeoutHandler)(NSUUID *timeoutIdentifier);
@property (nonatomic, copy) NSDictionary<OHQSessionOptionKey,id> *options;
@property (nonatomic, nullable, strong) OHQDevice *device;

- (instancetype)initWithDataObserver:(OHQDataObserverBlock)dataObserver
                  connectionObserver:(OHQConnectionObserverBlock)connectionObserver
                          completion:(OHQCompletionBlock)completion
                             options:(NSDictionary<OHQSessionOptionKey,id> *)options;
@end

NS_ASSUME_NONNULL_END
