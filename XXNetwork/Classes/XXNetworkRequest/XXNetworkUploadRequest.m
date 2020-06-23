//
//  XXNetworkUploadRequest.m
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import "XXNetworkUploadRequest.h"

@interface XXUploadModel : NSObject <XXUploadRequestParameterProtocol>

@end

@interface XXNetworkUploadRequest ()<XXNetworkRequestConfigProtocol>

@property (nonatomic, strong,readwrite) NSArray <XXUploadRequestParameterProtocol> *parameter;

@end

@implementation XXNetworkUploadRequest

+ (instancetype)uploadWithTotalCount:(NSInteger)totalCount enumerateObjectsUsingBlock:(XXUploadSetupParameterBlock)uploadBlock {
    return [[self alloc]initWithTotalCount:totalCount enumerateObjectsUsingBlock:uploadBlock];
}

- (instancetype)initWithTotalCount:(NSInteger)totalCount enumerateObjectsUsingBlock:(XXUploadSetupParameterBlock)uploadBlock {
    if (self = [super init]) {
        
        NSMutableArray *tempArr = [[NSMutableArray alloc]initWithCapacity:totalCount];
        for (NSInteger i = 0; i < totalCount; i++) {
            XXUploadModel *model = [XXUploadModel new];
            if (uploadBlock) {
                uploadBlock(model,i);
            }
            [tempArr addObject:model];
        }
        self.parameter = tempArr.copy;
    }
    return self;
}

- (NSTimeInterval)requestMinTimeInterval {
    return self.minRequestTime ?: 0;
}

- (NSString *)serviceIdentifierKey {
    return self.xx_serviceIdentifierKey;
}

- (NSString *)requestMethodName {
    return self.xx_requestMethodName;
}

- (BOOL)isCorrectWithResponseData:(nonnull id)responseData {
    if (self.isCorrectBlock) {
        return self.isCorrectBlock(responseData);
    }else if (responseData) {
        return YES;
    }
    return NO;
}

/**
 当POST的内容带有文件等富文本时使用
 
 @return ConstructingBlock
 */
- (AFConstructingBlock)constructingBoXXBlock {
    return ^(id<AFMultipartFormData> formData) {
        
        [self.parameter enumerateObjectsUsingBlock:^(id <XXUploadRequestParameterProtocol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [formData appendPartWithFileData:obj.data name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
            
        }];
        
    };
}


/**
 请求所需要的参数
 
 @return 参数字典
 */
- (NSDictionary *)requestParamDictionary {
    return self.paramDictionary;
}


/**
 请求连接的超时时间。默认15秒 上传大文件设置的长一些
 
 @return 超时时长
 */
- (NSTimeInterval)requestTimeoutInterval {
    return 120;
}


- (BOOL)enableDebugLog {
    return YES;
}

- (XXRequestHandleSameRequestType)handleSameRequestType {
    return XXRequestHandleSameRequestTypeBothContinue;
}

@end





@implementation XXUploadModel
@synthesize data,fileName,name = _name,mimeType = _mimeType;

- (NSString *)name {
    if (!_name) {
        _name = @"avatarfile";
    }
    return _name;
}

- (NSString *)mimeType {
    if (!_mimeType) {
        _mimeType = @"image/jpeg";
    }
    return _mimeType;
}


@end
