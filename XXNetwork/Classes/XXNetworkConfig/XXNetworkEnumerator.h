//
//  XXNetworkEnumerator.h
//  Pods
//
//  Created by Monster . on 2020/6/23.
//

#ifndef XXNetworkEnumerator_h
#define XXNetworkEnumerator_h

/**
 网络请求状态值

 - XXNetworkRequestCancelStatus: 请求被取消，暂不提供响应回调
 - XXNetworkNotReachableStatus: 网络不可达
 - XXNetworkRequestParamIncorrectStatus: 请求参数错误
 - XXNetworkResponseFailureStatus: 请求失败
 - XXNetworkResponseDataIncorrectStatus: 请求返回的数据错误，可能是接口错误等
 - XXNetworkResponseDataAuthenticationFailStatus: 请求返回的数据没有通过验证
 - XXNetworkResponseDataSuccessStatus: 数据请求成功
 */
typedef NS_ENUM(NSUInteger, XXNetworkStatus) {
    XXNetworkRequestCancelStatus,
    XXNetworkNotReachableStatus,
    XXNetworkRequestParamIncorrectStatus,
    XXNetworkResponseFailureStatus,
    XXNetworkResponseDataIncorrectStatus,
    XXNetworkResponseDataAuthenticationFailStatus,
    XXNetworkResponseDataSuccessStatus,
};


/**
 网络接口请求方式

 - XXRequestMethodPost: Post请求
 - XXRequestMethodGet: Get请求
 */
typedef NS_ENUM(NSUInteger, XXRequestMethod) {
    XXRequestMethodPost,
    XXRequestMethodGet,
};


/**
 请求序列化类型

 - XXRequestSerializerTypeHTTP: http
 - XXRequestSerializerTypeJSON: JSON
 - XXRequestSerializerTypePropertyList: Plist
 */
typedef NS_ENUM(NSUInteger, XXRequestSerializerType) {
    XXRequestSerializerTypeHTTP,
    XXRequestSerializerTypeJSON,
    XXRequestSerializerTypePropertyList,
};


/**
 响应数据序列化类型

 - XXResponseSerializerTypeJSON: json
 - XXResponseSerializerTypeHTTP: http
 - XXResponseSerializerTypeXMLParser: xml
 - XXResponseSerializerTypePropertyList: plist
 - XXResponseSerializerTypeImage: img
 */
typedef NS_ENUM(NSUInteger, XXResponseSerializerType) {
    XXResponseSerializerTypeJSON,
    XXResponseSerializerTypeHTTP,
    XXResponseSerializerTypeXMLParser,
    XXResponseSerializerTypePropertyList,
    XXResponseSerializerTypeImage,
};


/**
 处理正在执行的前一个相同方法的请求的方式

 - XXRequestHandleSameRequestTypeCancelCurrent: 取消正要启动的请求
 - XXRequestHandleSameRequestTypeCancelPrevious: 取消正在进行的请求
 - XXRequestHandleSameRequestTypeBothContinue: 不取消请求，请求同时执行
 */
typedef NS_ENUM(NSUInteger, XXRequestHandleSameRequestType) {
    XXRequestHandleSameRequestTypeCancelCurrent,
    XXRequestHandleSameRequestTypeCancelPrevious,
    XXRequestHandleSameRequestTypeBothContinue,
};


/**
 服务的验证结果状态
 
 - XXServiceAuthenticationStatusPass: 通过
 - XXServiceAuthenticationStatusWarning: 警告
 - XXServiceAuthenticationStatusWrong: 错误
 */
typedef NS_ENUM(NSInteger , XXServiceAuthenticationStatus) {
    XXServiceAuthenticationStatusPass = 0,
    XXServiceAuthenticationStatusWarning,
    XXServiceAuthenticationStatusWrong
};



/**
 队列处理优先级
 
 - XXNetworkPriorityTypeVeryHigh:      非常高
 - XXNetworkPriorityTypeDefaultHigh:   高
 - XXNetworkPriorityTypeDefaultNormal: 正常
 - XXNetworkPriorityTypeDefaultLow:    低
 - XXNetworkPriorityTypeVeryLow:       非常低
 */
typedef int  XXNetworkPriorityType NS_TYPED_EXTENSIBLE_ENUM;
static const XXNetworkPriorityType XXNetworkPriorityTypeVeryHigh      NS_AVAILABLE_IOS(10_0) = 1000;
static const XXNetworkPriorityType XXNetworkPriorityTypeDefaultHigh   NS_AVAILABLE_IOS(10_0) = 750;
static const XXNetworkPriorityType XXNetworkPriorityTypeDefaultNormal NS_AVAILABLE_IOS(10_0) = 500;
static const XXNetworkPriorityType XXNetworkPriorityTypeDefaultLow    NS_AVAILABLE_IOS(10_0) = 250;
static const XXNetworkPriorityType XXNetworkPriorityTypeVeryLow       NS_AVAILABLE_IOS(10_0) = 50;


#endif /* XXNetworkEnumerator_h */
