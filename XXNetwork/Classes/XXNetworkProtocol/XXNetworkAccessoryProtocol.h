//
//  XXNetworkAccessoryProtocol.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import <Foundation/Foundation.h>
#import "XXNetworkEnumerator.h"
#import "XXNetworkResponse.h"

NS_ASSUME_NONNULL_BEGIN

/// 网络插件协议（多用于hud加载，但不限于hud加载）
@protocol XXNetworkAccessoryProtocol <NSObject>

@optional

/**
 请求将要执行 will
 */
- (void)networkRequestAccessoryWillStart;

/**
 请求已经执行 did
 */
- (void)networkRequestAccessoryDidStart;

/**
 请求已经完成 finish
 */
- (void)networkRequestAccessoryDidFinish;

/**
 请求完成执行 end 与 networkRequestAccessoryDidEndByResponse: 会同时被调用（只适用于 单体请求）

 @param networkStatus 网络请求状态值
 */
- (void)networkRequestAccessoryByStatus:(XXNetworkStatus)networkStatus;

/**
 请求完成执行 与 networkRequestAccessoryByStatus: 会同时被调用（只适用于 单体请求）

 @param response 请求响应数据
 */
- (void)networkRequestAccessoryDidEndByResponse:(XXNetworkResponse *)response;



@end

NS_ASSUME_NONNULL_END
