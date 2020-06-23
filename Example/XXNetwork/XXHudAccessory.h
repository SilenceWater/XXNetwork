//
//  XXHudAccessory.h
//  XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//  Copyright © 2020 Monster . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XXNetwork/XXNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@interface XXHudAccessory : NSObject <XXNetworkAccessoryProtocol>

- (instancetype)initWithView:(UIView *)view msg:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
