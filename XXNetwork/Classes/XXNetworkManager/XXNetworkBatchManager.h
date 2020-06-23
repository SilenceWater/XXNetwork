//
//  XXNetworkBatchManager.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XXNetworkBatchRequest;

/// 批量请求管理类
@interface XXNetworkBatchManager : NSObject

/*! 管理批量请求实例  */
+ (instancetype)sharedInstance;


/**
 添加批处理请求

 @param request 批量请求体
 */
- (void)addBatchRequest:(XXNetworkBatchRequest *)request;


/**
 删除先前添加的批处理请求

 @param request 批量请求体
 */
- (void)removeBatchRequest:(XXNetworkBatchRequest *)request;

@end

NS_ASSUME_NONNULL_END
