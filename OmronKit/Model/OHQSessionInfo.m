//
//  OHQSessionInfo.m
//  OmronKit
//
//  Created by Waqar Malik on 2/14/22.
//

#import "OHQSessionInfo.h"
#import "OHQDevice.h"

@implementation OHQSessionInfo

+ (OHQSessionInfo *)sessionInfoWithDataObserver:(OHQDataObserverBlock)dataObserver connectionObserver:(OHQConnectionObserverBlock)connectionObserver completion:(OHQCompletionBlock)completion options:(NSDictionary<OHQSessionOptionKey,id> *)options {
    return [[super alloc] initWithDataObserver:dataObserver connectionObserver:connectionObserver completion:completion options:options];
}

- (instancetype)initWithDataObserver:(OHQDataObserverBlock)dataObserver connectionObserver:(OHQConnectionObserverBlock)connectionObserver completion:(OHQCompletionBlock)completion options:(NSDictionary<OHQSessionOptionKey,id> *)options {
    self = [super init];
    if (self) {
        self.dataObserverBlock = dataObserver;
        self.connectionObserverBlock = connectionObserver;
        self.completionBlock = completion;
        self.options = options;
        self.device = nil;
    }
    return self;
}

@end
