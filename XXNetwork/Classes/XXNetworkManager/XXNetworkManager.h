//
//  XXNetworkManager.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XXNetworkRequest,XXNetworkBatchRequest;

/// 单个请求管理类
@interface XXNetworkManager : NSObject

+ (instancetype)sharedInstance;



/// 添加request到请求栈中，并启动
/// @param request 一个基于XXNetworkRequest的实例
- (void)addRequest:(__kindof XXNetworkRequest *)request;



/// 结束一个请求，并从请求栈中移除
/// @param request 一个基于XXNetworkRequest的实例
- (void)removeRequest:(__kindof XXNetworkRequest *)request;

@end

NS_ASSUME_NONNULL_END
