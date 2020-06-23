//
//  XXNetworkResponseProtocol.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XXNetworkRequest;
@class XXNetworkResponse;

/// 响应协议
@protocol XXNetworkResponseProtocol <NSObject>

@optional

/**
 请求成功的回调

 @param networkRequest 请求对象
 @param response 响应的数据（XXNetworkResponse）
 */
- (void)networkRequest:(XXNetworkRequest *)networkRequest succeedByResponse:(XXNetworkResponse *)response;


/**
 请求失败的回调

 @param networkRequest 请求对象
 @param response 响应的数据（XXNetworkResponse）
 */
- (void)networkRequest:(XXNetworkRequest *)networkRequest failedByResponse:(XXNetworkResponse *)response;


/**
 请求进度的回调，一般适用于上传文件

 @param networkRequest 请求对象
 @param progress 进度
 */
- (void)networkRequest:(XXNetworkRequest *)networkRequest requestingByProgress:(NSProgress *)progress;


@end

NS_ASSUME_NONNULL_END
