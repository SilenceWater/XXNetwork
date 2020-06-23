//
//  XXNetworkBatchManager.m
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import "XXNetworkBatchManager.h"
#import "XXNetworkBatchRequest.h"

@interface XXNetworkBatchManager()

@property (nonatomic, strong) NSMutableArray <XXNetworkBatchRequest *>*requestArray;

@end

@implementation XXNetworkBatchManager

+ (XXNetworkBatchManager *)sharedInstance {
    static XXNetworkBatchManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)addBatchRequest:(XXNetworkBatchRequest *)request {
    @synchronized(self) {
        [_requestArray addObject:request];
    }
}

- (void)removeBatchRequest:(XXNetworkBatchRequest *)request {
    @synchronized(self) {
        [_requestArray removeObject:request];
    }
}


@end
