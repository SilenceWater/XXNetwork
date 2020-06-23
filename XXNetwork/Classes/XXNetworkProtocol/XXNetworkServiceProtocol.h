//
//  XXNetworkServiceProtocol.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import <Foundation/Foundation.h>
#import "XXNetworkRequestConfigProtocol.h"
#import "XXNetworkEnumerator.h"

NS_ASSUME_NONNULL_BEGIN

@class XXNetworkRequest;

/// 网络接口服务配置协议
@protocol XXNetworkServiceProtocol <NSObject>

@required

/// 服务接口地址的基础URL
- (NSString *)serviceApiBaseUrlString;



/// 服务接口 Acceptable-Content 配置
- (NSSet<NSString *> *)serviceResponseAcceptableContentTypes;

@optional

/// 默认DYRequestSerializerTypeJSON
- (XXRequestSerializerType)serviceRequestSerializerType;



/// 默认DYResponseSerializerTypeJSON
- (XXResponseSerializerType)serviceResponseSerializerType;



/// 是否从响应JSON中删除具有 'NSNull' 值的键。默认为 'NO'(只在responseSerializerType 为 DYResponseSerializerTypeJSON 情况下有效)
- (BOOL)removesKeysWithNullValues;



/// 返回需要统一设定的请求头
- (NSDictionary<NSString *,NSString *> *)serviceBaseHTTPRequestHeaders;



/// 基本的请求参数，在较多接口都会使用到的参数，这些参数可以作为base参数设定，比如用户名、app标示、版本 等等
- (NSDictionary<NSString *,NSString *> *)serviceBaseParamSource;



/// 针对特定服务的请求响应数据的统一验证。将影响响应数据的状态
/// @param networkRequest 网络接口请求对象
/// @param response 验证结果状态
- (XXServiceAuthenticationStatus)serviceBaseAuthenticationWithNetworkRequest:(XXNetworkRequest *)networkRequest response:(id)response;



/// 请求失败之后的重试次数，最大设置为3次，默认为0   仅限DYNetworkResponseFailureStatus 或 DYNetworkNotReachableStatus 失败状态下，起作用
- (NSUInteger)serviceRequestRetryCountWhenFailure;



/// 请求执行的最小时间
- (NSTimeInterval)serviceRequestMinTimeInterval;



/// 请求超时时间，默认15秒
- (NSTimeInterval)serviceRequestTimeoutInterval;




/*******以下协议的设定用于服务端返回数据的第一层格式统一，设定后，便于更深一层的取到数据 *********/


/// 响应数据提示信息的key
- (NSString *)responseMessageKey;



/// 响应数据定制code的key
- (NSString *)responseCodeKey;



/// 响应数据具体内容的key
- (NSString *)responseContentDataKey;





@end

NS_ASSUME_NONNULL_END
