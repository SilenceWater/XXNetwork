#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "XXNetwork.h"
#import "XXNetworkConfig.h"
#import "XXNetworkEnumerator.h"
#import "XXNetworkLogger.h"
#import "XXNetworkBatchManager.h"
#import "XXNetworkManager.h"
#import "XXNetworkAccessoryProtocol.h"
#import "XXNetworkBatchResponseProtocol.h"
#import "XXNetworkInterceptorProtocol.h"
#import "XXNetworkRequestConfigProtocol.h"
#import "XXNetworkResponseProtocol.h"
#import "XXNetworkServiceProtocol.h"
#import "XXUploadRequestParameterProtocol.h"
#import "XXNetworkBatchRequest.h"
#import "XXNetworkRequest.h"
#import "XXNetworkUploadRequest.h"
#import "XXNetworkResponse.h"

FOUNDATION_EXPORT double XXNetworkVersionNumber;
FOUNDATION_EXPORT const unsigned char XXNetworkVersionString[];

