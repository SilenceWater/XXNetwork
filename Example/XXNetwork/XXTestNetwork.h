//
//  XXTestNetwork.h
//  XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//  Copyright © 2020 Monster . All rights reserved.
//

#import <XXNetwork/XXNetworkRequest.h>

NS_ASSUME_NONNULL_BEGIN

/// 测试请求类
@interface XXTestNetwork : XXNetworkRequest <XXNetworkRequestConfigProtocol>

@property (nonatomic, copy) NSString *CellPhoneNumber;

@property (nonatomic, copy) NSString *Password;

@end

NS_ASSUME_NONNULL_END
