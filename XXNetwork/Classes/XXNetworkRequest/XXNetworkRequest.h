//
//  XXNetworkRequest.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import <Foundation/Foundation.h>
#import "XXNetworkAccessoryProtocol.h"
#import "XXNetworkRequestConfigProtocol.h"
#import "XXNetworkResponseProtocol.h"
#import "XXNetworkServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 单体请求
@interface XXNetworkRequest : NSObject

/*! 请求tag 区分同一个代理存在多个请求 */
@property (nonatomic, assign) NSInteger tag;

/*! 请求体开始请求的绝对时间  */
@property (nonatomic) CFAbsoluteTime startAbsoluteTime;

/*! 请求载体 */
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

/*! 请求配置协议 */
@property (nonatomic, weak, readonly) NSObject <XXNetworkRequestConfigProtocol>*requestConfigProtocol;

/*! 响应协议 */
@property (nonatomic, weak) id <XXNetworkResponseProtocol>responseDelegate;

/*! 插件协议 */
@property (nonatomic, weak) id <XXNetworkAccessoryProtocol>accessoryDelegate;

/*! 重复次数 */
@property (nonatomic, assign) NSUInteger retryCount;

/*! 优先级（默认 XXNetworkPriorityTypeDefaultNormal ） */
@property (nonatomic, assign, readonly) XXNetworkPriorityType priorityType;

/*! 容器类（单体请求可以为空） */
@property (nonatomic, weak) id containerClass;

/*! 上传进度block  */
@property (nonatomic, copy) XXNetworkRequestProgressBlock requestProgressBlock;

/*! 请求失败block  */
@property (nonatomic, copy) XXNetworkResponseFailBlock responseFailBlock;

/*! 请求成功block  */
@property (nonatomic, copy) XXNetworkResponseSuccessBlock responseSuccessBlock;


/**
 开始网络请求，使用delegate 方式使用这个方法
 */
- (void)startRequest;


/**
 停止网络请求

 @param status 网络接口状态
 */
- (void)stopRequestByStatus:(XXNetworkStatus)status;

/**
 停止网络请求

 @param response 返回实体
 */
- (void)stopRequestByResponse:(XXNetworkResponse *)response;


/**
 添加实现了XXNetworkAccessoryProtocol的插件对象
 @waring 在启动请求之前添加插件 可添加多个
 @param accessoryDelegate accessoryDelegate 插件对象
 */
- (void)addNetworkAccessoryObject:(id<XXNetworkAccessoryProtocol>)accessoryDelegate;

@end

NS_ASSUME_NONNULL_END
