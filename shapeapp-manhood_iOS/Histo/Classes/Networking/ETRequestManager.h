//
//  ETRequestManager.h
//  Histo
//
//  Created by Viktor Gubriienko on 30.05.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const kServerDomain;
extern NSString *const kServerErrorCodeKey;
extern NSString *const kServerErrorMessageKey;

typedef enum : NSUInteger {
    ServerErrorCodeNoUserWithID     = 10000,
    ServerErrorCodeBadUserID        = 10001,
    ServerErrorCodeJobInProgress    = 11000,
    ServerErrorCodeJobFailed        = 11001,
    ServerErrorCodeNoMeasurements   = 11002,
    ServerErrorCodeMeasurementError = 11003,
} ServerErrorCode;

@class ETFlow;
@interface ETRequestManager : NSObject

+ (instancetype)sharedInstance;

- (NSURLSessionDataTask*)createUserWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask*)authenticateUserWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask*)getMeasurmentsWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask*)analyzePhotosWithFlow:(ETFlow*)flow
                                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask*)validatePurchaseWithReceipt:(NSData*)receipt
                                             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask*)getHistogramDataForGroup:(NSString*)group
                                      withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask*)getSubscriptionStatusWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                                  failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
