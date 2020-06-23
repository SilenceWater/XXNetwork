//
//  XXNetworkBatchRequest.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import <Foundation/Foundation.h>
#import "XXNetworkBatchResponseProtocol.h"
#import "XXNetworkAccessoryProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class XXNetworkRequest,XXNetworkResponse;

/// 批次请求
@interface XXNetworkBatchRequest : NSObject

/*! 批量请求响应代理 */
@property (nonatomic, weak) id <XXNetworkBatchResponseProtocol> delegate;

/*! 最大并发量 最大并发量不要乱写（5以内），不要开太多，一般以2~3为宜 默认3 */
@property (nonatomic, assign) NSInteger maxConcurrentCount;

/** 批量请求结束回调方法 */
@property (nonatomic, copy) XXNetworkBatchResponseFinishBlock batchResponseFinishBlock;

/**
 初始化批量请求。创建批量请求对象，只可使用此初始化方法
 
 @param requestArray 需要放在一起批量请求的请求对象集合
 @return 批量请求的对象
 */
- (instancetype)initWithRequestArray:(NSArray <XXNetworkRequest *>*)requestArray NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new  NS_UNAVAILABLE;


/**
 开始批量请求
 */
- (void)startBatchRequest;


/**
 取消批量请求
 */
- (void)stopBatchRequest;

/**
 添加实现了XXNetworkAccessoryProtocol的插件对象
 @waring 在启动请求之前添加插件 可添加多个
 @param accessoryDelegate accessoryDelegate 插件对象
 */
- (void)addNetworkAccessoryObject:(id<XXNetworkAccessoryProtocol>)accessoryDelegate;

@end

NS_ASSUME_NONNULL_END
