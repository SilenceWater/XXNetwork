//
//  XXNetworkManager.m
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import "XXNetworkManager.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
#import <AFNetworking/AFNetworking.h>
#import "XXNetworkConfig.h"
#import "XXNetworkRequest.h"
#import "XXNetworkResponse.h"
#import "XXNetworkLogger.h"
#import "XXNetworkBatchRequest.h"

@interface XXNetworkManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@property (nonatomic, strong) NSMutableDictionary <NSString *, __kindof XXNetworkRequest *> *requestRecordDict;

@property (nonatomic, strong) NSMutableArray <NSString *> *historyCustomHeaderKeys;

@end

@implementation XXNetworkManager

#pragma mark -
#pragma mark - Initialize

+ (XXNetworkManager *)sharedInstance {
    static XXNetworkManager *networkAgentInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkAgentInstance = [[self alloc] init];
    });
    return networkAgentInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestRecordDict = [NSMutableDictionary dictionary];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.operationQueue.maxConcurrentOperationCount = 4;
        AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        _sessionManager.responseSerializer = jsonResponseSerializer;
//        [_sessionManager setSecurityPolicy:[self customSecurityPolicy]];
    }
    return _sessionManager;
}


#pragma mark -
#pragma mark - Methods
//- (AFSecurityPolicy *)customSecurityPolicy {
//
//    // 先导入证书 证书由服务端生成，具体由服务端人员操作
//   NSBundle * bundle = [NSBundle XX_bundleWithBundleName:@"XXNetwork" podName:@"XXNetwork"];
//    NSString *cerPath = [bundle pathForResource:@"www.chengshizhichuang.com" ofType:@"cer"];//证书的路径
//    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
//
//    // AFSSLPinningModeCertificate 使用证书验证模式
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
//    // 如果是需要验证自建证书，需要设置为YES
//    securityPolicy.allowInvalidCertificates = YES;
//
//    //validatesDomainName 是否需要验证域名，默认为YES;
//    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
//    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
//    //如置为NO，建议自己添加对应域名的校验逻辑。
//    securityPolicy.validatesDomainName = NO;
//
//    securityPolicy.pinnedCertificates = [[NSSet alloc]initWithObjects:cerData, nil];
//
//    return securityPolicy;
//}

- (void)addRequest:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    
    if ([_requestRecordDict.allValues containsObject:request]) {
        NSLog(@"\n\n\n------------- 重复启动请求！相同的请求正在执行中 -----------");
        return;
    }
    
    /// 记录请求时间
    NSTimeInterval time = [self timeAbsoluteTimeByRequest:request];
    /// 请求基础url
    NSString *requestURLString = [self urlStringByRequest:request];
    /// 请求参数
    NSDictionary *requestParam = [self requestParamByRequest:request];
    
    if (time > 0) {
        request.startAbsoluteTime = CFAbsoluteTimeGetCurrent();
    }
    
    //检查参数配置
    if (![self isCorrectByRequestParams:requestParam request:request]) {
        NSLog(@"参数配置有误！请查看isCorrectWithRequestParams: !");
        
        XXNetworkResponse *paramIncorrectResponse = [[XXNetworkResponse alloc] initWithResponseData:nil serviceIdentifierKey:nil requestTag:request.tag networkStatus:XXNetworkRequestParamIncorrectStatus];
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
        NSTimeInterval allTime = endTime-request.startAbsoluteTime;
        if (allTime < time) {
            [NSThread sleepForTimeInterval:time-allTime];
        }
        [request stopRequestByResponse:paramIncorrectResponse];
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
            [request.responseDelegate networkRequest:request failedByResponse:paramIncorrectResponse];
        }else if (request.responseFailBlock) {
            NSError *error;
            request.responseFailBlock(paramIncorrectResponse, error);
        }
        return;
    }
    
    XXRequestHandleSameRequestType handleSameRequestType = [self handleSameRequestTypeByRequest:request];
    if (handleSameRequestType != XXRequestHandleSameRequestTypeBothContinue) {
        //检查是否存在相同请求方法未完成，并根据协议接口决定是否结束之前的请求
        BOOL isContinuePerform = YES;
        for (XXNetworkRequest<XXNetworkRequestConfigProtocol> *requestingObj in self.requestRecordDict.allValues) {
            if ([[self urlStringByRequest:requestingObj] isEqualToString:requestURLString]) {
                switch (handleSameRequestType) {
                    case XXRequestHandleSameRequestTypeCancelCurrent:
                        isContinuePerform = NO;
                        break;
                    case XXRequestHandleSameRequestTypeCancelPrevious:{
                        XXNetworkResponse *cancelResponse = [[XXNetworkResponse alloc] initWithResponseData:nil serviceIdentifierKey:nil requestTag:requestingObj.tag networkStatus:XXNetworkRequestCancelStatus];
                        [requestingObj stopRequestByResponse:cancelResponse];
                    }
                        break;
                    default:
                        break;
                }
                break;
            }
        }
        
        if (isContinuePerform == NO) {
            NSLog(@"\n\n---------------------有个相同URL请求未完成，这个请求被取消了（可设置handleSameRequestType）---------------------\n\n");
            XXNetworkResponse *cancelResponse = [[XXNetworkResponse alloc] initWithResponseData:nil serviceIdentifierKey:nil requestTag:request.tag networkStatus:XXNetworkRequestCancelStatus];
            [request stopRequestByResponse:cancelResponse];
            return;
        }
    }
    
    if ([request respondsToSelector:@selector(enableDebugLog)]) {
        if ([request enableDebugLog]) {
            [XXNetworkLogger logDebugRequestInfoWithURL:requestURLString httpMethod:[self requestMethodByRequest:request] params:requestParam reachabilityStatus:[[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] networkPriority:request.priorityType];
        }
    }else if ([XXNetworkConfig sharedInstance].enableDebug) {
        [XXNetworkLogger logDebugRequestInfoWithURL:requestURLString httpMethod:[self requestMethodByRequest:request] params:requestParam reachabilityStatus:[[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] networkPriority:request.priorityType];
    }
    
    [self setupSessionManagerRequestSerializerByRequest:request];
    
    __weak typeof(self)weakSelf = self;
    __block XXNetworkRequest<XXNetworkRequestConfigProtocol> *blockRequest = request;
    switch ([self requestMethodByRequest:request]) {
        case XXRequestMethodGet:{
            request.sessionDataTask = [self.sessionManager GET:requestURLString
                                                    parameters:requestParam
                                                       headers:nil
                                                      progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                [weakSelf handleRequestProgress:downloadProgress request:blockRequest];
                                                            }
                                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                                [weakSelf handleRequestSuccess:task responseObject:responseObject];
                                                            }
                                                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                [weakSelf handleRequestFailure:task error:error];
                                                            }];
            
        }
            break;
        case XXRequestMethodPost:{
            AFConstructingBlock constructingBlock = [self constructingBlockByRequest:request];
            if (constructingBlock) {
                request.sessionDataTask = [self.sessionManager POST:requestURLString
                                                         parameters:requestParam
                                                            headers:nil
                                          constructingBodyWithBlock:constructingBlock
                                                           progress:^(NSProgress * _Nonnull uploadProgress) {
                                                                    [weakSelf handleRequestProgress:uploadProgress request:blockRequest];
                                                                }
                                                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                                    [weakSelf handleRequestSuccess:task responseObject:responseObject];
                                                                }
                                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                    [weakSelf handleRequestFailure:task error:error];
                                                                }];
                
            }else{
                
                request.sessionDataTask = [self.sessionManager POST:requestURLString
                                                         parameters:requestParam
                                                            headers:nil
                                                           progress:^(NSProgress * _Nonnull uploadProgress) {
                                                                    [weakSelf handleRequestProgress:uploadProgress request:blockRequest];
                                                                }
                                                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                                    [weakSelf handleRequestSuccess:task responseObject:responseObject];
                                                                }
                                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                    [weakSelf handleRequestFailure:task error:error];
                                                                }];
                
            }
        }
            break;
        default:
            break;
    }
    [self addRequestObject:request];
    
}

- (void)removeRequest:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    if(request.sessionDataTask == nil)  return;
    
    [request.sessionDataTask cancel];
    NSString *taskKey = [self keyForSessionDataTask:request.sessionDataTask];
    @synchronized(self) {
        [_requestRecordDict removeObjectForKey:taskKey];
    }
}

#pragma mark -
#pragma mark - Getter

- (NSObject<XXNetworkServiceProtocol> *)serviceObjectByRequest:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    NSString *serviceKey = [request.requestConfigProtocol serviceIdentifierKey];
    NSAssert(serviceKey.length, @"你应该设置服务标示的key");
    NSObject<XXNetworkServiceProtocol> *serviceObject = [[XXNetworkConfig sharedInstance] serviceObjectWithServiceIdentifier:serviceKey];
    return serviceObject;
}

- (NSTimeInterval)timeAbsoluteTimeByRequest:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    NSTimeInterval absoluteTime = 0;
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestMinTimeInterval)]) {
        absoluteTime = [request.requestConfigProtocol requestMinTimeInterval];
    }else if ([[self serviceObjectByRequest:request] respondsToSelector:@selector(serviceRequestMinTimeInterval)]) {
        absoluteTime = [[self serviceObjectByRequest:request] serviceRequestMinTimeInterval];
    }
    return absoluteTime;
}

- (NSString *)urlStringByRequest:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    NSString *detailUrl = @"";
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestMethodName)]) {
        detailUrl = [request.requestConfigProtocol requestMethodName];
    }
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    
    NSString *serviceURLString = nil;
    
    serviceURLString = [[self serviceObjectByRequest:request] serviceApiBaseUrlString];
    if ([serviceURLString hasPrefix:@"http"]) {
        if ([detailUrl hasPrefix:@":"]) {
            //适用于带自定义端口号
            return [serviceURLString stringByAppendingFormat:@"%@", detailUrl];
        }
        return [serviceURLString stringByAppendingPathComponent:detailUrl];
    }else {
        NSLog(@"\n\n\n请设置正确的URL\n\n\n");
        return nil;
    }
}

- (NSDictionary *)requestParamByRequest:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestParamDictionary)]) {
        NSDictionary *paramDict = [request.requestConfigProtocol requestParamDictionary];
        if (paramDict != nil) {
            [tempDict addEntriesFromDictionary:paramDict];
        }
    }
    
    if ((![request.requestConfigProtocol respondsToSelector:@selector(useBaseRequestParamSource)] || [request.requestConfigProtocol useBaseRequestParamSource])) {
        NSObject<XXNetworkServiceProtocol> *serviceObject = [self serviceObjectByRequest:request];
        if ([serviceObject respondsToSelector:@selector(serviceBaseParamSource)]) {
            NSDictionary *baseRequestParamSource = [serviceObject serviceBaseParamSource];
            if (baseRequestParamSource != nil) {
                [tempDict addEntriesFromDictionary:baseRequestParamSource];
            }
        }
    }
    if (tempDict.count == 0) {
        return nil;
    }
    return [NSDictionary dictionaryWithDictionary:tempDict];
}

- (BOOL)isCorrectByRequestParams:(NSDictionary *)requestParams request:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(isCorrectWithRequestParams:)]) {
        return [request.requestConfigProtocol isCorrectWithRequestParams:requestParams];
    }
    return YES;
}

- (XXRequestHandleSameRequestType)handleSameRequestTypeByRequest:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(handleSameRequestType)]) {
        return [request.requestConfigProtocol handleSameRequestType];
    }
    return XXRequestHandleSameRequestTypeCancelCurrent;
}

- (XXRequestMethod)requestMethodByRequest:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestMethod)]) {
        return [request.requestConfigProtocol requestMethod];
    }
    return XXRequestMethodPost;
}

- (NSURLRequestCachePolicy)cachePolicyByRequest:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(cachePolicy)]) {
        NSURLRequestCachePolicy cachePolicy = [request.requestConfigProtocol cachePolicy];
        if (cachePolicy == NSURLRequestUseProtocolCachePolicy) {
            if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
                return NSURLRequestReturnCacheDataDontLoad;
            }
            return NSURLRequestUseProtocolCachePolicy;
        }
        return cachePolicy;
    }
    return NSURLRequestReloadIgnoringCacheData;
}

#pragma mark -
#pragma mark - Setter

- (void)setSessionManagerRequestSerializerByRequestSerializerType:(XXRequestSerializerType)requestSerializerType {
    switch (requestSerializerType) {
        case XXRequestSerializerTypeHTTP:
            self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        case XXRequestSerializerTypeJSON:
            if (![self.sessionManager.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]]) {
                self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
            }
            break;
        case XXRequestSerializerTypePropertyList:
            if (![self.sessionManager.requestSerializer isKindOfClass:[AFPropertyListRequestSerializer class]]) {
                self.sessionManager.requestSerializer = [AFPropertyListRequestSerializer serializer];
            }
            break;
        default:
            break;
    }
}

- (void)setSessionManagerResponseSerializerByResponseSerializerType:(XXResponseSerializerType)responseSerializerType removesKeysWithNullValues:(BOOL)removesKeysWithNullValues {
    switch (responseSerializerType) {
        case XXResponseSerializerTypeHTTP:
            self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case XXResponseSerializerTypeJSON: {
            AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
            jsonResponseSerializer.removesKeysWithNullValues = removesKeysWithNullValues;
            self.sessionManager.responseSerializer = jsonResponseSerializer;
        }
            break;
        case XXResponseSerializerTypeImage:
            if (![self.sessionManager.responseSerializer isKindOfClass:[AFImageResponseSerializer class]]) {
                self.sessionManager.responseSerializer = [AFImageResponseSerializer serializer];
            }
            break;
        case XXResponseSerializerTypeXMLParser:
            if (![self.sessionManager.responseSerializer isKindOfClass:[AFXMLParserResponseSerializer class]]) {
                self.sessionManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            }
            break;
        case XXResponseSerializerTypePropertyList:
            if (![self.sessionManager.responseSerializer isKindOfClass:[AFPropertyListResponseSerializer class]]) {
                self.sessionManager.responseSerializer = [AFPropertyListResponseSerializer serializer];
            }
            break;
        default:
            break;
    }
    
}

- (void)setupSessionManagerRequestSerializerByRequest:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    //配置requestSerializerType
    NSObject<XXNetworkServiceProtocol> *serviceObject = [self serviceObjectByRequest:request];
    XXRequestSerializerType requestSerializerType;
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestSerializerType)]) {
        requestSerializerType = [request.requestConfigProtocol requestSerializerType];
    }else if([serviceObject respondsToSelector:@selector(serviceRequestSerializerType)]){
        requestSerializerType = [serviceObject serviceRequestSerializerType];
    }else {
        requestSerializerType = XXRequestSerializerTypeJSON;
    }
    [self setSessionManagerRequestSerializerByRequestSerializerType:requestSerializerType];
    
    //配置请求头
    if (self.historyCustomHeaderKeys.count) {
        [self.historyCustomHeaderKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.sessionManager.requestSerializer setValue:nil forHTTPHeaderField:obj];
        }];
        [self.historyCustomHeaderKeys removeAllObjects];
    }
    
    if ((![request.requestConfigProtocol respondsToSelector:@selector(useBaseHTTPRequestHeaders)] || [request.requestConfigProtocol useBaseHTTPRequestHeaders])) {
        if ([serviceObject respondsToSelector:@selector(serviceBaseHTTPRequestHeaders)]) {
            NSDictionary *requestHeaders = [serviceObject serviceBaseHTTPRequestHeaders];
            [requestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
            }];
        }
    }
    
    if ([request.requestConfigProtocol respondsToSelector:@selector(customHTTPRequestHeaders)]) {
        NSDictionary *customRequestHeaders = [request.requestConfigProtocol customHTTPRequestHeaders];
        if (_historyCustomHeaderKeys == nil) {
            _historyCustomHeaderKeys = [[NSMutableArray alloc] init];
        }
        [self.historyCustomHeaderKeys addObjectsFromArray:customRequestHeaders.allKeys];
        [customRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[NSString class]]) {
                [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
            }else if ([obj isKindOfClass:[NSNumber class]]) {
                [self.sessionManager.requestSerializer setValue:[(NSNumber *)obj stringValue] forHTTPHeaderField:key];
            }else {
                [self.sessionManager.requestSerializer setValue:nil forHTTPHeaderField:key];
            }
        }];
    }
    
    //配置请求超时时间
    NSTimeInterval timeoutInterval = 15.0f;
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestTimeoutInterval)]) {
        timeoutInterval = [request.requestConfigProtocol requestTimeoutInterval];
    }else if ([serviceObject respondsToSelector:@selector(serviceRequestTimeoutInterval)]) {
        timeoutInterval = [serviceObject serviceRequestTimeoutInterval];
    }
    self.sessionManager.requestSerializer.timeoutInterval = timeoutInterval;
    
    //配置responseSerializerType
    XXResponseSerializerType responseSerializerType = XXResponseSerializerTypeJSON;
    BOOL removesKeysWithNullValues = NO;
    if ([request.requestConfigProtocol respondsToSelector:@selector(responseSerializerType)]) {
        responseSerializerType = [request.requestConfigProtocol responseSerializerType];
        if ([request.requestConfigProtocol respondsToSelector:@selector(removesKeysWithNullValues)]) {
            removesKeysWithNullValues = [request removesKeysWithNullValues];
        }
    }else if ([serviceObject respondsToSelector:@selector(serviceResponseSerializerType)]) {
        responseSerializerType = [serviceObject serviceResponseSerializerType];
        if ([serviceObject respondsToSelector:@selector(removesKeysWithNullValues)]) {
            removesKeysWithNullValues = [serviceObject removesKeysWithNullValues];
        }
    }
    [self setSessionManagerResponseSerializerByResponseSerializerType:responseSerializerType removesKeysWithNullValues:removesKeysWithNullValues];
    
    if ([request.requestConfigProtocol respondsToSelector:@selector(responseAcceptableContentTypes)] && [request.requestConfigProtocol responseAcceptableContentTypes]) {
        self.sessionManager.responseSerializer.acceptableContentTypes = [request.requestConfigProtocol responseAcceptableContentTypes];
    }else {
        self.sessionManager.responseSerializer.acceptableContentTypes = [serviceObject serviceResponseAcceptableContentTypes];
    }
    
    //配置请求缓存策略
    self.sessionManager.requestSerializer.cachePolicy = [self cachePolicyByRequest:request];
}

- (AFConstructingBlock)constructingBlockByRequest:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(constructingBoXXBlock)]) {
        return [request.requestConfigProtocol constructingBoXXBlock];
    }
    return nil;
}

- (NSUInteger)retryCountWhenFailureByRequest:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    NSObject<XXNetworkServiceProtocol> *serviceObject = [self serviceObjectByRequest:request];
    NSUInteger retryCount = 0;
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestRetryCountWhenFailure)]) {
        retryCount = [request.requestConfigProtocol requestRetryCountWhenFailure];
    }else if ([serviceObject respondsToSelector:@selector(serviceRequestRetryCountWhenFailure)]) {
        retryCount = [serviceObject serviceRequestRetryCountWhenFailure];
    }
    if (retryCount > 3) {
        retryCount = 3;
    }
    return retryCount;
}

#pragma mark -
#pragma mark - 处理请求响应结果

- (void)beforePerformFailWithResponse:(XXNetworkResponse *)response request:(XXNetworkRequest *)request{
//    if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:beforePerformFailWithResponse:)]) {
//        [request.interceptorDelegate networkRequest:request beforePerformFailWithResponse:response];
//    }
}
- (void)afterPerformFailWithResponse:(XXNetworkResponse *)response request:(XXNetworkRequest *)request{
//    if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:afterPerformFailWithResponse:)]) {
//        [request.interceptorDelegate networkRequest:request afterPerformFailWithResponse:response];
//    }
}

- (void)handleRequestProgress:(NSProgress *)progress request:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    if ([request.responseDelegate respondsToSelector:@selector(networkRequest:requestingByProgress:)]) {
        [request.responseDelegate networkRequest:request requestingByProgress:progress];
    }else if (request.requestProgressBlock) {
        request.requestProgressBlock(request, progress);
    }
}

- (void)handleRequestSuccess:(NSURLSessionDataTask *)sessionDataTask responseObject:(id)response {
    NSString *taskKey = [self keyForSessionDataTask:sessionDataTask];
    if (!taskKey.length) {
        NSLog(@"\n\n--------------------NSURLSessionDataTask %@ 异常!--------------------\n\n",sessionDataTask);
        return;
    }
    XXNetworkRequest<XXNetworkRequestConfigProtocol> *request = _requestRecordDict[taskKey];
    if (request == nil) {
        NSLog(@"\n\n--------------------请求实例被意外释放!--------------------\n\n");
        return;
    }
    
    request.retryCount = 0;
    NSTimeInterval time = [self timeAbsoluteTimeByRequest:request];
    if (time > 0) {
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
        NSTimeInterval allTime = endTime-request.startAbsoluteTime;
        if (allTime < time) {
            [NSThread sleepForTimeInterval:time-allTime];
        }
    }
    
    XXServiceAuthenticationStatus authenticationStatus = XXServiceAuthenticationStatusPass;
    if ((![request.requestConfigProtocol respondsToSelector:@selector(useBaseAuthentication)] || [request.requestConfigProtocol useBaseAuthentication])) {
        NSObject<XXNetworkServiceProtocol> *serviceObject = [self serviceObjectByRequest:request];
        if ([serviceObject respondsToSelector:@selector(serviceBaseAuthenticationWithNetworkRequest:response:)]) {
            authenticationStatus = [serviceObject serviceBaseAuthenticationWithNetworkRequest:request response:response];
        }
    }
    if(authenticationStatus ==  XXServiceAuthenticationStatusPass && [request.requestConfigProtocol isCorrectWithResponseData:response]) {
        XXNetworkResponse *successResponse = [[XXNetworkResponse alloc] initWithResponseData:response serviceIdentifierKey:[request serviceIdentifierKey] requestTag:request.tag networkStatus:XXNetworkResponseDataSuccessStatus];
        [request stopRequestByResponse:successResponse];

        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:succeedByResponse:)]) {
            [request.responseDelegate networkRequest:request succeedByResponse:successResponse];
        }else if (request.responseSuccessBlock) {
            request.responseSuccessBlock(successResponse);
        }

    } else {
        XXNetworkStatus failStatus;
        switch (authenticationStatus) {
            case XXServiceAuthenticationStatusPass:
                failStatus = XXNetworkResponseDataIncorrectStatus;
                break;
            case XXServiceAuthenticationStatusWarning:
                failStatus = XXNetworkResponseDataAuthenticationFailStatus;
                break;
            default:
                failStatus = XXNetworkRequestCancelStatus;
                break;
        }
        XXNetworkResponse *dataErrorResponse = [[XXNetworkResponse alloc] initWithResponseData:response serviceIdentifierKey:[request serviceIdentifierKey] requestTag:request.tag networkStatus:failStatus];
        [request stopRequestByResponse:dataErrorResponse];
        if (authenticationStatus != XXServiceAuthenticationStatusWrong) {
            
            [self beforePerformFailWithResponse:dataErrorResponse request:request];
            if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
                [request.responseDelegate networkRequest:request failedByResponse:dataErrorResponse];
            }else if (request.responseFailBlock) {
                request.responseFailBlock(dataErrorResponse, nil);
            }
            [self afterPerformFailWithResponse:dataErrorResponse request:request];
        }
    }
    
    if ([request respondsToSelector:@selector(enableDebugLog)]) {
        if ([request enableDebugLog]) {
            [XXNetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask responseObject:response authentication:authenticationStatus ==  XXServiceAuthenticationStatusPass error:nil];
        }
    }else if ([XXNetworkConfig sharedInstance].enableDebug) {
        [XXNetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask responseObject:response authentication:authenticationStatus ==  XXServiceAuthenticationStatusPass error:nil];
    }
}

- (void)handleRequestFailure:(NSURLSessionDataTask *)sessionDataTask error:(NSError *)error {
    NSString *taskKey = [self keyForSessionDataTask:sessionDataTask];
    if (!taskKey.length) {
        NSLog(@"\n\n--------------------NSURLSessionDataTask %@ 异常!--------------------\n\n",sessionDataTask);
        return;
    }
    XXNetworkRequest<XXNetworkRequestConfigProtocol> *request = _requestRecordDict[taskKey];
    if (request == nil) {
        NSLog(@"\n\n--------------------请求实例被意外释放!--------------------\n\n");
        return;
    }
    
    //请求失败时，重试
    NSUInteger retryCount = [self retryCountWhenFailureByRequest:request];
    if (request.retryCount < retryCount) {
        [self removeRequest:request];
        request.retryCount++;
        [self performSelector:@selector(addRequest:) withObject:request afterDelay:2.0f];
        return;
    }
    
    NSTimeInterval time = [self timeAbsoluteTimeByRequest:request];
    if (time > 0) {
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
        NSTimeInterval allTime = endTime-request.startAbsoluteTime;
        if (allTime < time) {
            [NSThread sleepForTimeInterval:time-allTime];
        }
    }
    
    XXNetworkStatus failStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable ? XXNetworkNotReachableStatus : XXNetworkResponseFailureStatus;
    XXNetworkResponse *failureResponse = [[XXNetworkResponse alloc] initWithResponseData:nil serviceIdentifierKey:[request serviceIdentifierKey] requestTag:request.tag networkStatus:failStatus];
    failureResponse.error = error;
    failureResponse.dataTask = sessionDataTask;
    [request stopRequestByResponse:failureResponse];
    [self beforePerformFailWithResponse:failureResponse request:request];
    if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
        [request.responseDelegate networkRequest:request failedByResponse:failureResponse];
    }else if (request.responseFailBlock) {
        request.responseFailBlock(failureResponse, error);
    }
    [self afterPerformFailWithResponse:failureResponse request:request];
    
    if ([request respondsToSelector:@selector(enableDebugLog)]) {
        if ([request enableDebugLog]) {
            [XXNetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask responseObject:nil authentication:NO error:error];
        }
    }else if ([XXNetworkConfig sharedInstance].enableDebug) {
        [XXNetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask responseObject:nil authentication:NO error:error];
    }
}

#pragma mark -
#pragma mark - 处理 请求集合
- (NSString *)keyForSessionDataTask:(NSURLSessionDataTask *)sessionDataTask {
    return [@(sessionDataTask.taskIdentifier) stringValue];
}

- (void)addRequestObject:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request {
    if (request.sessionDataTask == nil)    return;
    
    NSString *taskKey = [self keyForSessionDataTask:request.sessionDataTask];
    @synchronized(self) {
        _requestRecordDict[taskKey] = request;
    }
}




@end
