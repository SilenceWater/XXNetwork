//
//  XXNetworkConfig.m
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import "XXNetworkConfig.h"

@interface XXNetworkConfig ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSObject<XXNetworkServiceProtocol> *> *serviceStorageDictionary;

@end

@implementation XXNetworkConfig

+ (XXNetworkConfig *)sharedInstance {
    static XXNetworkConfig *networkConfigInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkConfigInstance = [[XXNetworkConfig alloc] init];
    });
    return networkConfigInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enableDebug = NO;
    }
    return self;
}

- (NSMutableDictionary<NSString *, NSObject<XXNetworkServiceProtocol> *> *)serviceStorageDictionary {
    if (_serviceStorageDictionary == nil) {
        _serviceStorageDictionary = [[NSMutableDictionary alloc] init];
    }
    return _serviceStorageDictionary;
}

- (NSObject<XXNetworkServiceProtocol> *)serviceObjectWithServiceIdentifier:(NSString *)serviceIdentifier {
    if (self.serviceStorageDictionary[serviceIdentifier] == nil) {
        NSAssert(NO, @"无法找到 %@ 相匹配的服务对象", serviceIdentifier);
        return nil;
    }
    return self.serviceStorageDictionary[serviceIdentifier];
}

- (void)registerServiceObject:(NSObject<XXNetworkServiceProtocol> *)serviceObject serviceIdentifier:(NSString *)serviceIdentifier {
    if (serviceObject == nil)   return;
    
    NSAssert([serviceObject conformsToProtocol:@protocol(XXNetworkServiceProtocol)], @"你提供的Service没有遵循XXNetworkServiceProtocol");
    self.serviceStorageDictionary[serviceIdentifier] = serviceObject;
}


@end
