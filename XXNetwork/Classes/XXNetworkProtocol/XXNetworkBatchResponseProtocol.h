//
//  XXNetworkBatchResponseProtocol.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XXNetworkBatchRequest;
@class XXNetworkResponse;

/// 批次请求完成block（优先级低于 delegate）
typedef void (^XXNetworkBatchResponseFinishBlock)(NSArray <XXNetworkResponse *>*responses);

@protocol XXNetworkBatchResponseProtocol <NSObject>


/// 批量请求结束回调方法
/// @param batchRequest 批量请求的对象
/// @param responseArray 批量请求里的所有请求响应数据集合
- (void)networkBatchRequest:(XXNetworkBatchRequest *)batchRequest completedByResponseArray:(NSArray<XXNetworkResponse *> *)responseArray;

@end

NS_ASSUME_NONNULL_END
