//
//  XXTestNetwork.m
//  XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//  Copyright © 2020 Monster . All rights reserved.
//

#import "XXTestNetwork.h"

@implementation XXTestNetwork


- (NSString *)serviceIdentifierKey {
    return @"com.dy.dev.service.identifier";
}

- (NSString *)requestMethodName {
    return @"config/start/ad";
    return @"http://r.qzone.qq.com/";
}

- (BOOL)isCorrectWithResponseData:(nonnull id)responseData {
    if (responseData) {
        return YES;
    }
    return NO;
}

//- (BOOL)isCorrectWithRequestParams:(NSDictionary *)params {
//    return NO;
//}

- (NSTimeInterval)requestMinTimeInterval {
    return 3;
}

/**
 请求方式，默认为 XXRequestMethodPost
 */
- (XXRequestMethod)requestMethod {
    return XXRequestMethodGet;
}

/**
 请求所需要的参数
 
 @return 参数字典
 */
//- (NSDictionary *)requestParamDictionary {
////    return nil;
//    return @{
//             @"CellPhoneNumber" : self.CellPhoneNumber ?: @"",
//             @"Password" : self.Password ?: @""
//             };
//}

/**
 定制缓存策略，默认NSURLRequestUseProtocolCachePolicy
 
 @return 缓存策略
 */
- (NSURLRequestCachePolicy)cachePolicy {
    return NSURLRequestUseProtocolCachePolicy;
}

/**
 请求失败之后的重试次数，默认为0
 @warning 仅限XXNetworkResponseFailureStatus 或 XXNetworkNotReachableStatus 失败状态下，起作用
 @return 重试次数
 */
- (NSUInteger)requestRetryCountWhenFailure {
    return 0;
}

/**
 请求连接的超时时间。默认15秒
 
 @return 超时时长
 */
- (NSTimeInterval)requestTimeoutInterval {
    return 3;
}


- (BOOL)enableDebugLog {
    return YES;
}

- (XXNetworkPriorityType)networkPriorityType {
    
    XXNetworkPriorityType type = (XXNetworkPriorityType)[@[@(XXNetworkPriorityTypeVeryHigh),@(XXNetworkPriorityTypeVeryLow),@(XXNetworkPriorityTypeDefaultLow),@(XXNetworkPriorityTypeDefaultHigh),@(XXNetworkPriorityTypeDefaultNormal)][arc4random()%5] intValue];
    return type;
}

- (XXRequestHandleSameRequestType)handleSameRequestType {
    return XXRequestHandleSameRequestTypeBothContinue;
}


@end
