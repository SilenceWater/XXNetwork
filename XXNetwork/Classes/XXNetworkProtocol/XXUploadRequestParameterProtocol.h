//
//  XXUploadRequestParameterProtocol.h
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 上传参数协议
@protocol XXUploadRequestParameterProtocol <NSObject>

/*! 要上传的data  */
@property (nonatomic, strong) NSData *data;

/*! 文件name  */
@property (nonatomic, copy) NSString *fileName;

/*! 默认 avatarfile  */
@property (nonatomic, copy) NSString *name;

/*! 默认 image/jpeg  */
@property (nonatomic, copy) NSString *mimeType;

@end

NS_ASSUME_NONNULL_END
