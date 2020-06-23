//
//  XXNetworkRequest.m
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import "XXNetworkRequest.h"
#import "XXNetworkManager.h"
#import "XXNetworkResponse.h"

@interface XXNetworkRequest ()

@property (nonatomic, weak) id <XXNetworkRequestConfigProtocol> requestConfigProtocol;

@property (nonatomic, strong) NSMutableArray *accessoryArray;

@property (nonatomic, assign) XXNetworkPriorityType priorityType;

@end

@implementation XXNetworkRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(XXNetworkRequestConfigProtocol)]) {
            _requestConfigProtocol = (id <XXNetworkRequestConfigProtocol>)self;
        } else {
            NSAssert(NO, @"子类必须实现XXNetworkRequestConfigProtocol协议");
        }
    }
    return self;
}

- (XXNetworkPriorityType)priorityType {
    if (!_priorityType) {
        if ([self.requestConfigProtocol respondsToSelector:@selector(networkPriorityType)]) {
            _priorityType = [self.requestConfigProtocol networkPriorityType];
        }else {
            _priorityType = XXNetworkPriorityTypeDefaultNormal;
        }
    }
    return _priorityType;
}

- (void)startRequest {
    [self accessoryWillStart];
    [[XXNetworkManager sharedInstance] addRequest:self];
    [self accessoryDidStart];
}


- (void)stopRequestByStatus:(XXNetworkStatus)status {
    [[XXNetworkManager sharedInstance] removeRequest:self];
    XXNetworkResponse *cancelResponse = [[XXNetworkResponse alloc] initWithResponseData:nil serviceIdentifierKey:nil requestTag:self.tag networkStatus:XXNetworkRequestCancelStatus];
    [self accessoryFinishByResponse:cancelResponse];
}

- (void)stopRequestByResponse:(XXNetworkResponse *)response {
    [[XXNetworkManager sharedInstance] removeRequest:self];
    [self accessoryFinishByResponse:response];
}

- (void)clearAllBlock {
    self.responseSuccessBlock = nil;
    self.requestProgressBlock = nil;
    self.responseFailBlock = nil;
}

- (void)dealloc {
    if (self.containerClass) {
        _containerClass = nil;
    }
    [[XXNetworkManager sharedInstance] removeRequest:self];
}

#pragma mark-
#pragma mark-Accessory

- (void)addNetworkAccessoryObject:(id <XXNetworkAccessoryProtocol>)accessoryDelegate {
    if (accessoryDelegate == nil)  return;
    
    if (_accessoryArray == nil) {
        _accessoryArray = [NSMutableArray array];
    }
    [self.accessoryArray addObject:accessoryDelegate];
}

- (void)accessoryWillStart {
    for (id<XXNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryWillStart)]) {
            [accessory networkRequestAccessoryWillStart];
        }
    }
}

- (void)accessoryDidStart {
    for (id<XXNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidStart)]) {
            [accessory networkRequestAccessoryDidStart];
        }
    }
}


- (void)accessoryFinishByResponse:(XXNetworkResponse *)response {
    for (id<XXNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidFinish)]) {
            [accessory networkRequestAccessoryDidFinish];
        }
        
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryByStatus:)]) {
            [accessory networkRequestAccessoryByStatus:response.networkStatus];
        }
        
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidEndByResponse:)]) {
            [accessory networkRequestAccessoryDidEndByResponse:response];
        }
    }
}

@end
