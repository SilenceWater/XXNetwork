//
//  XXNetworkConfig.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import <Foundation/Foundation.h>
#import "XXNetworkServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XXNetworkConfig : NSObject

/**
 网络接口配置单例
 */
+ (XXNetworkConfig *)sharedInstance;

/*! 是否打开debug日志 */
@property (nonatomic, assign) BOOL enableDebug;


/// 获取网络接口不同服务配置对象
/// @param serviceIdentifier 服务配置对象的存储标示
- (NSObject<XXNetworkServiceProtocol> *)serviceObjectWithServiceIdentifier:(NSString *)serviceIdentifier;



/// 设置网络接口所需的服务配置对象
/// @param serviceObject 服务配置对象
/// @param serviceIdentifier 服务配置对象的存储标示
- (void)registerServiceObject:(NSObject<XXNetworkServiceProtocol> *)serviceObject serviceIdentifier:(NSString *)serviceIdentifier;


@end

NS_ASSUME_NONNULL_END
