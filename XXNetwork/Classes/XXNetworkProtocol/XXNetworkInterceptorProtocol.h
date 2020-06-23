//
//  XXNetworkInterceptorProtocol.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XXNetworkRequest;
@class XXNetworkResponse;

/// 拦截协议
@protocol XXNetworkInterceptorProtocol <NSObject>

@optional

/**
 在请求成功回调之前执行

 @param networkRequest 网络接口请求对象
 @param networkResponse 网络接口响应对象
 */
- (void)networkRequest:(XXNetworkRequest *)networkRequest beforePerformSuccessWithResponse:(XXNetworkResponse *)networkResponse;


/**
 在请求成功回调之后执行

 @param networkRequest 网络接口请求对象
 @param networkResponse 网络接口响应对象
 */
- (void)networkRequest:(XXNetworkRequest *)networkRequest afterPerformSuccessWithResponse:(XXNetworkResponse *)networkResponse;


/**
 在请求失败回调之前执行
 
 @param networkRequest 网络接口请求对象
 @param networkResponse 网络接口响应对象
 */
- (void)networkRequest:(XXNetworkRequest *)networkRequest beforePerformFailWithResponse:(XXNetworkResponse *)networkResponse;

/**
 在请求失败回调之后执行
 
 @param networkRequest 网络接口请求对象
 @param networkResponse 网络接口响应对象
 */
- (void)networkRequest:(XXNetworkRequest *)networkRequest afterPerformFailWithResponse:(XXNetworkResponse *)networkResponse;


@end

NS_ASSUME_NONNULL_END
