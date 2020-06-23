//
//  XXHudAccessory.m
//  XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//  Copyright © 2020 Monster . All rights reserved.
//

#import "XXHudAccessory.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface XXHudAccessory ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation XXHudAccessory

- (instancetype)initWithView:(UIView *)view msg:(NSString *)msg {
    if (self = [super init]) {
        _hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:_hud];
        if (msg) {
            _hud.label.text = msg;
        }
    }
    return self;
}

- (void)networkRequestAccessoryWillStart {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud showAnimated:YES];
    });
}

- (void)networkRequestAccessoryByStatus:(XXNetworkStatus)networkStatus {
    switch (networkStatus) {
        case XXNetworkResponseDataSuccessStatus:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_hud hideAnimated:YES];
                });
            }
            break;
            
        default:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_hud hideAnimated:YES afterDelay:0.3];
            });
        }
            break;
    }
}

- (void)networkRequestAccessoryDidFinish {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud hideAnimated:YES afterDelay:0.3];
    });
}

- (void)networkRequestAccessoryDidEndByResponse:(XXNetworkResponse *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud hideAnimated:YES afterDelay:0.3];
    });
}


@end
