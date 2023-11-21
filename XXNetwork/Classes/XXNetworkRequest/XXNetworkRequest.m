//
//  XXNetworkRequest.m
//  Pods-XXNetwork_Example
//
//  Created by Monster . on 2020/6/23.
//

#import "XXNetworkRequest.h"
#import "XXNetworkManager.h"
#import "XXNetworkResponse.h"
#import "zlib.h"

@interface XXNetworkRequest ()

@property (nonatomic, weak) id <XXNetworkRequestConfigProtocol> requestConfigProtocol;

@property (nonatomic, strong) NSMutableArray *accessoryArray;

@property (nonatomic, assign) XXNetworkPriorityType priorityType;

@end

@implementation XXNetworkRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(XXNetworkRequestConfigProtocol)]) {
            _requestConfigProtocol = (id <XXNetworkRequestConfigProtocol>)self;
        } else {
            NSAssert(NO, @"子类必须实现XXNetworkRequestConfigProtocol协议");
        }
    }
    return self;
}

- (XXNetworkPriorityType)priorityType {
    if (!_priorityType) {
        if ([self.requestConfigProtocol respondsToSelector:@selector(networkPriorityType)]) {
            _priorityType = [self.requestConfigProtocol networkPriorityType];
        }else {
            _priorityType = XXNetworkPriorityTypeDefaultNormal;
        }
    }
    return _priorityType;
}

- (void)startRequest {
    [self accessoryWillStart];
    [[XXNetworkManager sharedInstance] addRequest:self];
    [self accessoryDidStart];
}


- (void)stopRequestByStatus:(XXNetworkStatus)status {
    [[XXNetworkManager sharedInstance] removeRequest:self];
    XXNetworkResponse *cancelResponse = [[XXNetworkResponse alloc] initWithResponseData:nil serviceIdentifierKey:nil requestTag:self.tag networkStatus:XXNetworkRequestCancelStatus];
    [self accessoryFinishByResponse:cancelResponse];
}

- (void)stopRequestByResponse:(XXNetworkResponse *)response {
    [[XXNetworkManager sharedInstance] removeRequest:self];
    [self accessoryFinishByResponse:response];
}

- (void)clearAllBlock {
    self.responseSuccessBlock = nil;
    self.requestProgressBlock = nil;
    self.responseFailBlock = nil;
}

- (void)dealloc {
    if (self.containerClass) {
        _containerClass = nil;
    }
    [[XXNetworkManager sharedInstance] removeRequest:self];
}

#pragma mark-
#pragma mark-Accessory

- (void)addNetworkAccessoryObject:(id <XXNetworkAccessoryProtocol>)accessoryDelegate {
    if (accessoryDelegate == nil)  return;
    
    if (_accessoryArray == nil) {
        _accessoryArray = [NSMutableArray array];
    }
    [self.accessoryArray addObject:accessoryDelegate];
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


- (void)accessoryFinishByResponse:(XXNetworkResponse *)response {
    for (id<XXNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidFinish)]) {
            [accessory networkRequestAccessoryDidFinish];
        }
        
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryByStatus:)]) {
            [accessory networkRequestAccessoryByStatus:response.networkStatus];
        }
        
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidEndByResponse:)]) {
            [accessory networkRequestAccessoryDidEndByResponse:response];
        }
    }
}

#pragma  mark -
#pragma  mark NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    
    [self sessionDidReceiveChallenge:challenge completionHandler:completionHandler];
}

#pragma  mark -
#pragma  mark for override in NSURLSessionDelegate
- (void)sessionDidReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
                 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    
    NSLog(@"adsdk session didReceiveChallenge %@",challenge.protectionSpace);
    // 如果是请求证书信任，我们再来处理，其他的不需要处理
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        NSURLCredential *cre = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        // 调用block
        completionHandler(NSURLSessionAuthChallengeUseCredential,cre);
    }
}

#pragma  mark -
#pragma  mark NSURLSessionDataDelegate
// 1.接收到服务器的响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [self sessionDidReceiveResponse:response completionHandler:completionHandler];
}

// 2.接收到服务器的数据（可能调用多次）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self sessionDidReceiveData:data];
}

// 3.请求成功或者失败（如果失败，error有值）
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [self sessionDidCompleteWithError:error task:task];
}



// 1.接收到服务器的响应
- (void)sessionDidReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
     NSLog(@"adsdk session didReceiveResponse");
    // 允许处理服务器的响应，才会继续接收服务器返回的数据
    
    __weak __typeof(&*self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void) {
        __strong __typeof(&*weakSelf) strongSelf = weakSelf;
        //返回应答
//        if(strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(onResponse:)]){
//            [strongSelf.delegate onResponse:response];
//        }
    });
    
    completionHandler(NSURLSessionResponseAllow);
}

// 2.接收到服务器的数据（可能调用多次）
- (void)sessionDidReceiveData:(NSData *)data {
    // 处理每次接收的数据
    // 这里只供监控使用，无数据处理
    if (self.responseData == nil) {
        self.responseData = [NSMutableData data];
    }
    [self.responseData appendData:data];

}

// 3.请求成功或者失败（如果失败，error有值）
- (void)sessionDidCompleteWithError:(NSError *)error task:(NSURLSessionTask *)task {
    __weak __typeof(&*self) weakSelf = self;
    
    if (error) {
        if ([self.handleDelegate respondsToSelector:@selector(handleRequestFailure:error:)]) {
            [self.handleDelegate handleRequestFailure:task error:error];
        }
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong __typeof(&*weakSelf) strongSelf =weakSelf;
        @try {
            NSData *data = [strongSelf.responseData copy];
            NSError *error;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if (error) {
                if ([strongSelf.handleDelegate respondsToSelector:@selector(handleRequestFailure:error:)]) {
                    [strongSelf.handleDelegate handleRequestFailure:task error:error];
                }
            }else {
                if ([strongSelf.handleDelegate respondsToSelector:@selector(handleRequestSuccess:responseObject:)]) {
                    [strongSelf.handleDelegate handleRequestSuccess:task responseObject:responseObject];
                }
            }
            
        }@catch (NSException *exception) {
            // 定义一个解析错误返回
            if ([self.handleDelegate respondsToSelector:@selector(handleRequestFailure:error:)]) {
                [self.handleDelegate handleRequestFailure:task error:error];
            }
            return ;
        }
    });
    
}

- (NSData *) Encryption:(NSData *) data{
    Byte *_byte = (Byte*)[data bytes];
    for (int i = 0; i < [data length]; i++) {
        _byte[i] = _byte[i]^0x05;
    }
    NSData *postData = [NSData dataWithBytes:_byte length:[data length]];
    return postData;
}

#pragma mark - gzip解压
- (NSData *)gzipUnpack:(NSData *)pCompressedData{
    
    if ([pCompressedData length] == 0) return pCompressedData;
    
    unsigned full_length = (unsigned int)[pCompressedData length];
    unsigned half_length = (unsigned int)[pCompressedData length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length +     half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[pCompressedData bytes];
    strm.avail_in = (unsigned int)[pCompressedData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    
    while (!done){
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (unsigned int)([decompressed length] - strm.total_out);
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done){
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    return nil;
}


#pragma mark - jsonToDictionary
- (NSDictionary *)jsonDataToDictionary:(NSData *)data adUnitId:(NSString *)adUnitId{
    NSDictionary *jsonDic=nil;
    if (!data) {
        return nil;
    }
    @try {
        NSError *error;
        jsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
//            @throw [[NSException alloc] initWithName:@"Translate exception" reason:@"" userInfo:nil];
            return nil;
        }
        return jsonDic;
    }
    @catch (NSException *exception) {
        if (adUnitId) {
//            [CatchLog sendCatchLog:adUnitId catchType:1 errorLog:exception.description];
        }else{
//            [CatchLog sendCatchLog:@"" catchType:1 errorLog:exception.description];
        }
        return nil;
//        @throw [[NSException alloc] initWithName:@"Translate exception" reason:@"" userInfo:nil];
    }
}

@end
