//
//  XXNetworkServiceObject.h
//  XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//  Copyright © 2020 Monster . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XXNetwork/XXNetwork.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DYNetworkServiceType) {
    DYNetworkServiceTypeDEV,
    DYNetworkServiceTypeCIT,
    DYNetworkServiceTypeUAT,
};

/// 项目网络配置类
@interface XXNetworkServiceObject : NSObject <XXNetworkServiceProtocol>

@property (nonatomic, assign) DYNetworkServiceType serviceType;

@end

NS_ASSUME_NONNULL_END
