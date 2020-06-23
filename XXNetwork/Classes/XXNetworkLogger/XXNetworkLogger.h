//
//  XXNetworkLogger.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 网络请求打印类（需要debug开启log日志）
@interface XXNetworkLogger : NSObject

/**
 接口请求信息日志输出方法
 
 @param url 请求的url
 @param httpMethod 请求方式
 @param params 请求参数
 @param reachabilityStatus 网络状态
 */
+ (void)logDebugRequestInfoWithURL:(NSString *)url
                        httpMethod:(NSInteger)httpMethod
                            params:(NSDictionary *)params
                reachabilityStatus:(NSInteger)reachabilityStatus
                   networkPriority:(int)priority;


/**
 接口响应信息日志输出方法
 
 @param sessionDataTask 执行请求的sessionDataTask
 @param response 响应数据
 @param authentication 是否通过验证
 @param error error对象
 */
+ (void)logDebugResponseInfoWithSessionDataTask:(NSURLSessionDataTask *)sessionDataTask
                                 responseObject:(id)response
                                 authentication:(BOOL)authentication
                                          error:(NSError *)error;


@end

NS_ASSUME_NONNULL_END
