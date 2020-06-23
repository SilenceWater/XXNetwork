//
//  XXNetworkBatchRequest.m
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import "XXNetworkBatchRequest.h"
#import "XXNetworkResponseProtocol.h"
#import "XXNetworkRequest.h"
#import "XXNetworkManager.h"
#import "XXNetworkResponse.h"
#import "XXNetworkBatchManager.h"

@interface XXNetworkBatchRequest ()<XXNetworkResponseProtocol>

@property (nonatomic) NSInteger completedCount;
@property (nonatomic, strong) NSArray <XXNetworkRequest *>*requestArray;
@property (nonatomic, strong) NSMutableArray <XXNetworkResponse *>*responseArray;
@property (nonatomic, strong) NSMutableArray *accessoryArray;

@end

@implementation XXNetworkBatchRequest {
    NSOperationQueue *_queue;
}

- (instancetype)initWithRequestArray:(NSArray<XXNetworkRequest *> *)requestArray {
    self = [super init];
    if (self) {
        _maxConcurrentCount = 3;
        _requestArray = requestArray;
        _responseArray = [NSMutableArray array];
        _completedCount = -1;
    }
    return self;
}

- (void)startBatchRequest {
    if (self.completedCount > -1 ) {
        NSLog(@"\n\n\n🐷🐷🐷 ->批量请求正在进行，请勿重复启动!<- 🐷🐷🐷\n\n\n");
        return;
    }
    [self accessoryWillStart];
    
    [[XXNetworkBatchManager sharedInstance] addBatchRequest:self];
    
    _completedCount = 0;

    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc]init];
        _queue.maxConcurrentOperationCount = self.maxConcurrentCount;
    }

    NSArray *tempArr = [self.requestArray sortedArrayUsingComparator:^NSComparisonResult(XXNetworkRequest * _Nonnull obj1, XXNetworkRequest * _Nonnull obj2) {
        if ((int)obj1.priorityType > (int)obj2.priorityType) {
            return NSOrderedAscending;
        }else if ((int)obj1.priorityType == (int)obj2.priorityType) {
            return NSOrderedSame;
        }
        return NSOrderedDescending;
    }];

    self.requestArray = tempArr.copy;

    for (XXNetworkRequest * _Nonnull request in self.requestArray) {
        request.responseDelegate = self;
        request.containerClass = self;
        SEL sel = NSSelectorFromString(@"clearAllBlock");
        [request performSelector:sel withObject:nil afterDelay:0];
        [[XXNetworkManager sharedInstance] addRequest:request];
//        NSOperation * op = [NSBlockOperation blockOperationWithBlock:^{
//
//        }];
//        op.qualityOfService = NSQualityOfServiceUserInteractive;
//        switch (request.priorityType) {
//                case XXNetworkPriorityTypeVeryHigh:
//                    op.queuePriority = NSOperationQueuePriorityVeryHigh;
//                break;
//                case XXNetworkPriorityTypeDefaultHigh:
//                    op.queuePriority = NSOperationQueuePriorityHigh;
//                break;
//                case XXNetworkPriorityTypeDefaultLow:
//                    op.queuePriority = NSOperationQueuePriorityLow;
//                break;
//                case XXNetworkPriorityTypeVeryLow:
//                    op.queuePriority = NSOperationQueuePriorityVeryLow;
//                break;
//            default:
//                    op.queuePriority = NSOperationQueuePriorityNormal;
//                break;
//        }
//        [_queue addOperation:op];
    }
    
    [self accessoryDidStart];
}


- (void)stopBatchRequest {
    _delegate = nil;
    [_queue cancelAllOperations];
    for (XXNetworkRequest *networkRequest in self.requestArray) {
        [[XXNetworkManager sharedInstance] removeRequest:networkRequest];
    }
}

#pragma mark -
#pragma mark - XXNetworkAccessoryProtocol

- (void)addNetworkAccessoryObject:(id<XXNetworkAccessoryProtocol>)accessoryDelegate {
    if (!accessoryDelegate) return;
    if (!_accessoryArray) {
        _accessoryArray = [[NSMutableArray alloc]init];
    }
    [_accessoryArray addObject:accessoryDelegate];
}

- (void)accessoryWillStart {
    for (id<XXNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryWillStart)]) {
            [accessory networkRequestAccessoryWillStart];
        }
    }
}

- (void)accessoryDidStart {
    for (id<XXNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidStart)]) {
            [accessory networkRequestAccessoryDidStart];
        }
    }
}

- (void)accessoryFinish {
    for (id<XXNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidFinish)]) {
            [accessory networkRequestAccessoryDidFinish];
        }
    }
}

- (void)accessoryFinishByResponse:(XXNetworkResponse *)response {
    for (id<XXNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryByStatus:)]) {
            [accessory networkRequestAccessoryByStatus:response.networkStatus];
        }
        
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidEndByResponse:)]) {
            [accessory networkRequestAccessoryDidEndByResponse:response];
        }
    }
}

#pragma mark-
#pragma mark-XXNetworkResponseProtocol

- (void)networkRequest:(XXNetworkRequest *)networkRequest succeedByResponse:(XXNetworkResponse *)response {
    self.completedCount++;
    [self.responseArray addObject:response];
    if (self.completedCount == self.requestArray.count) {
        [self networkBatchRequestCompleted];
    }
}

- (void)networkRequest:(XXNetworkRequest *)networkRequest failedByResponse:(XXNetworkResponse *)response {
    self.completedCount++;
    [self.responseArray addObject:response];
    
    if (self.completedCount == self.requestArray.count) {
        [self networkBatchRequestCompleted];
    }
}

- (void)networkBatchRequestCompleted {
    
    if ([self.delegate respondsToSelector:@selector(networkBatchRequest:completedByResponseArray:)]) {
        [self.delegate networkBatchRequest:self completedByResponseArray:self.responseArray];
    }else if(self.batchResponseFinishBlock) {
        self.batchResponseFinishBlock(self.responseArray);
    }
    
    
    
    self.completedCount = -1;
    [self accessoryFinish];
    [[XXNetworkBatchManager sharedInstance] removeBatchRequest:self];
}

- (void)dealloc {

    [self accessoryFinish];
}



@end
