//
//  XXViewController.m
//  XXNetwork
//
//  Created by Monster . on 06/23/2020.
//  Copyright (c) 2020 Monster .. All rights reserved.
//

#import "XXViewController.h"
#import <XXNetwork/XXNetwork.h>
#import "XXHudAccessory.h"
#import "XXTestNetwork.h"

@interface XXViewController () <XXNetworkResponseProtocol>

@end

@implementation XXViewController


#pragma mark -
#pragma mark - 👉 View Life Cycle 👈

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviewsContraints];
}

#pragma mark -
#pragma mark - 👉 Request 👈

/**
 请求成功的回调

 @param networkRequest 请求对象
 @param response 响应的数据（XXNetworkResponse）
 */
- (void)networkRequest:(XXNetworkRequest *)networkRequest succeedByResponse:(XXNetworkResponse *)response {
    
}

/**
 请求失败的回调

 @param networkRequest 请求对象
 @param response 响应的数据（XXNetworkResponse）
 */
- (void)networkRequest:(XXNetworkRequest *)networkRequest failedByResponse:(XXNetworkResponse *)response {
    
}

#pragma mark -
#pragma mark - 👉 DYNetworkResponseProtocol 👈

#pragma mark -
#pragma mark - 👉 UITableViewDelegate && data source 👈

#pragma mark -
#pragma mark - 👉 Event response 👈

- (IBAction)tapClickRequestAction:(id)sender {
    XXTestNetwork *request = [XXTestNetwork new];
    XXHudAccessory *hud = [[XXHudAccessory alloc]initWithView:self.view msg:@"加载中"];
    [request addNetworkAccessoryObject:hud];
//    request.Password = @"123456";
//    request.CellPhoneNumber = @"15038895697";
    request.responseDelegate = self;
    [request startRequest];
}

#pragma mark -
#pragma mark - 👉 Private Methods 👈

#pragma mark -
#pragma mark - 👉 Getters && Setters 👈

#pragma mark -
#pragma mark - 👉 SetupConstraints 👈

- (void)setupSubviewsContraints {
    
}

@end
