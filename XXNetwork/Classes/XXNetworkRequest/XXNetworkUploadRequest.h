//
//  XXNetworkUploadRequest.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import "XXNetworkRequest.h"
#import "XXUploadRequestParameterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^XXUploadSetupParameterBlock)(id <XXUploadRequestParameterProtocol> parameter, NSInteger idx);
typedef BOOL(^XXUploadIsCorrectWithResponseDataBlock)(id responseData);

@interface XXNetworkUploadRequest : XXNetworkRequest


/// 上传请求实体构造函数
/// @param totalCount 总个数
/// @param uploadBlock 遍历回调
+ (instancetype)uploadWithTotalCount:(NSInteger)totalCount enumerateObjectsUsingBlock:(XXUploadSetupParameterBlock)uploadBlock;

/*! 服务器key  */
@property (nonatomic, copy) NSString *xx_serviceIdentifierKey;

/*! 请求方法  */
@property (nonatomic, copy) NSString *xx_requestMethodName;

/*! 请求参数  */
@property (nonatomic, strong) NSDictionary *paramDictionary;

/*! 最小请求时间（不设置，默认0）  */
@property (nonatomic) NSTimeInterval minRequestTime;

/** 上传文件数组 */
@property (nonatomic, strong, readonly) NSArray <XXUploadRequestParameterProtocol> *parameter;

/*! 校验返回block 此block会决定走成功还是失败代理（子类继承上传可忽略） */
@property (nonatomic, copy) XXUploadIsCorrectWithResponseDataBlock isCorrectBlock;


@end

NS_ASSUME_NONNULL_END
