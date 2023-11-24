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




@end
