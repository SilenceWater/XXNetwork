//
//  XXNetworkHandleResponseProtocol.h
//  XXNetwork
//
//  Created by 王大仙 on 2023/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XXNetworkRequest;
@protocol XXNetworkRequestConfigProtocol;

@protocol XXNetworkHandleResponseProtocol <NSObject>

- (void)handleRequestProgress:(NSProgress *)progress request:(__kindof XXNetworkRequest<XXNetworkRequestConfigProtocol> *)request;

- (void)handleRequestSuccess:(NSURLSessionDataTask *)sessionDataTask responseObject:(id)response;

- (void)handleRequestFailure:(NSURLSessionDataTask *)sessionDataTask error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
