//
//  XXNetworkResponse.m
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import "XXNetworkResponse.h"
#import "XXNetworkConfig.h"
#import "XXNetworkServiceProtocol.h"

@interface XXNetworkResponse ()

@property (nonatomic, copy) id responseData;
@property (nonatomic, assign, readwrite) XXNetworkStatus networkStatus;
@property (nonatomic, assign, readwrite) NSInteger requestTag;
@property (nonatomic, assign, readwrite) BOOL isCache;

@property (nonatomic, copy, readwrite) NSString *responseMessage;

@property (nonatomic, copy, readwrite) id responseContentData;
@property (nonatomic, assign, readwrite) NSInteger responseCode;

@end

@implementation XXNetworkResponse

- (instancetype)initWithResponseData:(id)responseData serviceIdentifierKey:(NSString *)serviceIdentifierKey requestTag:(NSInteger)requestTag networkStatus:(XXNetworkStatus)networkStatus {
    self = [super init];
    if (self) {
        _responseData = responseData;
        _requestTag = requestTag;
        _networkStatus = networkStatus;
        
        _responseCode = NSNotFound;
        switch (networkStatus) {
            case XXNetworkResponseDataSuccessStatus:
            case XXNetworkResponseDataIncorrectStatus:
            case XXNetworkResponseDataAuthenticationFailStatus:{
                NSObject<XXNetworkServiceProtocol> *serviceObject = [[XXNetworkConfig sharedInstance] serviceObjectWithServiceIdentifier:serviceIdentifierKey];
                if ([responseData isKindOfClass:[NSDictionary class]]) {
                    if ([serviceObject respondsToSelector:@selector(responseCodeKey)]) {
                        _responseCode = [responseData[[serviceObject responseCodeKey]] integerValue];
                        if (_responseCode == 401 || _responseCode == 10002) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:kXXNetworkLoginNotification object:nil userInfo:responseData];
                            });
                            
                        }
                    }
                    if ([serviceObject respondsToSelector:@selector(responseMessageKey)]) {
                        _responseMessage = responseData[[serviceObject responseMessageKey]];
                        if (![_responseMessage isKindOfClass:[NSString class]]) {
                            _responseMessage = @"";
                        }
                    }
                    if ([serviceObject respondsToSelector:@selector(responseContentDataKey)]) {
                        _responseContentData = responseData[[serviceObject responseContentDataKey]];
                    }
                }
            }
                break;
            default:
                _responseMessage = [self responseMsgByNetworkStatus:networkStatus];
                break;
        }
        
        
    }
    return self;
}

//- (id)fetchDataWithReformer:(id<XXNetworkResponseReformerProtocol>)reformer {
//    if ([reformer respondsToSelector:@selector(networkResponse:reformerDataWithOriginData:)]) {
//        return [reformer networkResponse:self reformerDataWithOriginData:self.responseData];
//    }
//    return [self.responseData mutableCopy];
//}

- (NSString *)responseMsgByNetworkStatus:(XXNetworkStatus)networkStatus {
    /**
     若做国际化的话，因为AFNetworking的国际化文件使用的是AFNetworking.strings，这个类库又是依赖AFNetworking的。为了少创建一个 .strings 文件。这里就复用“AFNetworking”了。
     */
    switch (networkStatus) {
        case XXNetworkRequestCancelStatus:
            return NSLocalizedStringFromTable(@"请求被取消", @"AFNetworking", nil);
        case XXNetworkNotReachableStatus:
            return NSLocalizedStringFromTable(@"网络异常", @"AFNetworking", nil);
        case XXNetworkRequestParamIncorrectStatus:
            return NSLocalizedStringFromTable(@"请求参数有误", @"AFNetworking", nil);
        case XXNetworkResponseFailureStatus:
            return NSLocalizedStringFromTable(@"系统异常", @"AFNetworking", nil);
        default:
            return nil;
    }
}

@end
