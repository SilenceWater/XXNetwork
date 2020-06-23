//
//  XXNetworkRequestConfigProtocol.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import <Foundation/Foundation.h>
#import "XXNetworkEnumerator.h"
#import <AFNetworking/AFURLRequestSerialization.h>

NS_ASSUME_NONNULL_BEGIN

@class XXNetworkResponse,XXNetworkRequest;

/// 上传数据构造Block
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

/// 上传数据进度回调
typedef void (^XXNetworkRequestProgressBlock)(XXNetworkRequest *request, NSProgress *progress);

/// 单体请求响应失败block（优先级低于 delegate）
typedef void (^XXNetworkResponseFailBlock)(XXNetworkResponse *response, NSError *error);

/// 单体请求响应成功block（优先级低于 delegate）
typedef void (^XXNetworkResponseSuccessBlock)(XXNetworkResponse *response);


/// 请求配置协议
@protocol XXNetworkRequestConfigProtocol <NSObject>

@required


/// 属于哪个服务
/// 服务的key （string）
/// 需要注意的是若想取到这个key对应的服务，要先使用这个key配置XXNetworkConfig的setServiceObject:serviceIdentifier:。
- (NSString *)serviceIdentifierKey;



/// 接口地址 or 配置路径
/// 接口地址。若设置带有http的请求地址，将会忽略XXNetworkConfig设置的url
- (NSString *)requestMethodName;



/// 检查返回数据是否正确，这样将在response里的succeed和failed 直接使用数据。
/// @param responseData 返回的完整数据
- (BOOL)isCorrectWithResponseData:(id)responseData;

@optional


/// 请求方式，默认为 XXRequestMethodPost
- (XXRequestMethod)requestMethod;



/// 请求所需要的参数
- (NSDictionary *)requestParamDictionary;



/// 定制缓存策略，默认NSURLRequestUseProtocolCachePolicy
- (NSURLRequestCachePolicy)cachePolicy;



/// 请求失败之后的重试次数，默认为0     仅限XXNetworkResponseFailureStatus 或 XXNetworkNotReachableStatus 失败状态下，起作用
- (NSUInteger)requestRetryCountWhenFailure;



/// 请求连接的最短时间。
- (NSTimeInterval)requestMinTimeInterval;



/// 请求连接的超时时间。默认15秒
- (NSTimeInterval)requestTimeoutInterval;



/// 请求队列执行优先级
- (XXNetworkPriorityType)networkPriorityType;



/// 检查请求参数
/// @param params 请求参数
- (BOOL)isCorrectWithRequestParams:(NSDictionary *)params;



/// 请求的SerializerType 默认XXRequestSerializerTypeJSON, 可通过XXNetworkConfig设置默认值
- (XXRequestSerializerType)requestSerializerType;



/// 响应数据的responseSerializerType，默认XXResponseSerializerTypeJSON，可通过XXNetworkConfig设置默认值
- (XXResponseSerializerType)responseSerializerType;



/// 是否从响应JSON中删除具有 'NSNull' 值的键。默认为 'NO'(只在responseSerializerType 为 XXResponseSerializerTypeJSON 情况下有效)
- (BOOL)removesKeysWithNullValues;



/// 响应的可接受MIME类型。当非' nil '时，带有' Content-Type '的响应(带有与集合不相交的MIME类型)将在验证期间导致错误。
- (NSSet <NSString *> *)responseAcceptableContentTypes;



/// 当POST的内容带有文件等富文本时使用
- (AFConstructingBlock)constructingBoXXBlock;



/// 处理正在执行相同方法的请求（参数可能不同），默认取消正要启动的请求XXRequestHandleSameRequestTypeCancelCurrentType
- (XXRequestHandleSameRequestType)handleSameRequestType;



/// 很多请求都会需要相同的请求参数，可设置XXNetworkConfig的baseParamSourceBlock，这个block会返回你所设置的基础参数。默认YES
- (BOOL)useBaseRequestParamSource;



/// XXNetworkConfig设置过baseHTTPRequestHeadersBlock后，可通过此协议方法决定是否使用baseHTTPRequestHeaders，默认使用（YES）
- (BOOL)useBaseHTTPRequestHeaders;



/// 定制请求头 ###只作用于此接口
- (NSDictionary *)customHTTPRequestHeaders;



/// 是否启用XXNetworkConfig设定的请求验证，若设定了验证的Block，默认使用YES
- (BOOL)useBaseAuthentication;



/// 定制是否输出log日志 if YES ，将忽略XXNetworkConfig的enableDebug
- (BOOL)enableDebugLog;


@end

NS_ASSUME_NONNULL_END
