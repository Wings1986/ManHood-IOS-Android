//
//  ETRequestManager.m
//  Histo
//
//  Created by Viktor Gubriienko on 30.05.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETRequestManager.h"
#import "ETSessionManager.h"
#import "NSUserDefaults+Preferences.h"
#import "SelfUserData.h"
#import "UsersData.h"
#import "UIDevice+Models.h"
#import "ETFlow.h"
#import "ETGeolocation.h"
#import "ETDataModel.h"

NSString *const kServerDomain = @"kServerDomain";
NSString *const kServerErrorCodeKey = @"error_code";
NSString *const kServerErrorMessageKey = @"error_msg";


@implementation ETRequestManager

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t done;
    dispatch_once(&done, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

#pragma mark - Factory

- (NSURLSessionDataTask*)createUserWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    
    NSString *gender = ([[NSUserDefaults standardUserDefaults].userGender isEqualToString:userMale]) ? @"True" : @"False" ;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [params setValue:gender forKey:@"is_male"];
    
    NSURLSessionDataTask *task = [[ETSessionManager sharedInstance] POST:@"createuser/"
                                                              parameters:params
                                                                 success:^(NSURLSessionDataTask *task, id responseObject)
                                  {
                                      if ( success ) {
                                          success(task, @{@"UserID": responseObject[@"user_uuid"],
                                                          @"AuthToken": [(NSHTTPURLResponse*)task.response allHeaderFields][@"HTTP_X_SESSION_ID"]});
                                      }
                                  }
                                                                 failure:^(NSURLSessionDataTask *task, NSError *error)
                                  {
                                      if ( failure ) {
                                          failure(task, [self customServerErrorFromError:error]);
                                      }
                                  }];
    
    return task;

}

- (NSURLSessionDataTask*)authenticateUserWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [params setValue:[ETDataModel sharedInstance].userID forKey:@"user_uuid"];
    
    NSURLSessionDataTask *task = [[ETSessionManager sharedInstance] POST:@"authorizeuser/"
                                                              parameters:params
                                                                 success:^(NSURLSessionDataTask *task, id responseObject)
                                  {
                                      if ( success ) {
                                          success(task, @{@"AuthToken": [(NSHTTPURLResponse*)task.response allHeaderFields][@"HTTP_X_SESSION_ID"],
                                                          @"userSettings": responseObject[@"userSettings"]});
                                      }
                                  }
                                                                 failure:^(NSURLSessionDataTask *task, NSError *error)
                                  {
                                      if ( failure ) {
                                          failure(task, [self customServerErrorFromError:error]);
                                      }
                                  }];
    return task;
}

- (NSURLSessionDataTask*)getMeasurmentsWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [params setValue:[ETDataModel sharedInstance].userID forKey:@"user_uuid"];
    if ( [NSUserDefaults standardUserDefaults].jobID ) {
        [params setValue:[NSUserDefaults standardUserDefaults].jobID forKey:@"job_id"];
    }
    
    NSURLSessionDataTask *task = [[ETSessionManager sharedInstance] POST:@"getmeasurments/"
                                                              parameters:params
                                                                 success:^(NSURLSessionDataTask *task, id responseObject)
                                  {
                                      if ( success ) {
                                          success(task, responseObject);
                                      }
                                  }
                                                                 failure:^(NSURLSessionDataTask *task, NSError *error)
                                  {
                                      if ( failure ) {
                                          failure(task, [self customServerErrorFromError:error]);
                                      }
                                  }];
    
    return task;
}

- (NSURLSessionDataTask*)analyzePhotosWithFlow:(ETFlow*)flow
                                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    
    CLLocation *location = [ETGeolocation sharedInstance].currentLocation;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [params setValue:[ETDataModel sharedInstance].userID forKey:@"user_uuid"];
    [params setValue:[UIDevice hardwareModel] forKey:@"model"];
    [params setValue:[[flow stepWithID:@"FirstAdj"].data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]
              forKey:@"image_front"];
    [params setValue:[[flow stepWithID:@"SecondAdj"].data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]
              forKey:@"image_side"];
    [params setValue:@[@(location.coordinate.latitude), @(location.coordinate.longitude)]
              forKey:@"location"];
    
    NSURLSessionDataTask *task = [[ETSessionManager sharedInstance] POST:@"analysephotos/"
                                                              parameters:params
                                                                 success:^(NSURLSessionDataTask *task, id responseObject)
                                  {
                                      if ( success ) {
                                          success(task, responseObject);
                                      }
                                  }
                                                                 failure:^(NSURLSessionDataTask *task, NSError *error)
                                  {
                                      if ( failure ) {
                                          failure(task, [self customServerErrorFromError:error]);
                                      }
                                  }];
    
    return task;
}

- (NSURLSessionDataTask*)validatePurchaseWithReceipt:(NSData*)receipt
                                             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [params setValue:[ETDataModel sharedInstance].userID forKey:@"user_uuid"];
    [params setValue:[receipt base64EncodedStringWithOptions:0] forKey:@"receipt"];
    
    NSURLSessionDataTask *task = [[ETSessionManager sharedInstance] POST:@"verifyiapreceipt/"
                                                              parameters:params
                                                                 success:^(NSURLSessionDataTask *task, id responseObject)
                                  {
                                      if ( success ) {
                                          success(task, responseObject);
                                      }
                                  }
                                                                 failure:^(NSURLSessionDataTask *task, NSError *error)
                                  {
                                      if ( failure ) {
                                          failure(task, [self customServerErrorFromError:error]);
                                      }
                                  }];
    
    return task;
}

- (NSURLSessionDataTask*)getSubscriptionStatusWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                                  failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [params setValue:[ETDataModel sharedInstance].userID forKey:@"user_uuid"];
    
    NSURLSessionDataTask *task = [[ETSessionManager sharedInstance] POST:@"subscriptionstatus/"
                                                              parameters:params
                                                                 success:^(NSURLSessionDataTask *task, id responseObject)
                                  {
                                      if ( success ) {
                                          success(task, responseObject);
                                      }
                                  }
                                                                 failure:^(NSURLSessionDataTask *task, NSError *error)
                                  {
                                      if ( failure ) {
                                          failure(task, [self customServerErrorFromError:error]);
                                      }
                                  }];
    
    return task;
}

- (NSURLSessionDataTask*)getHistogramDataForGroup:(NSString*)group
                                      withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [params setValue:[ETDataModel sharedInstance].userID forKey:@"user_uuid"];
    if (![group isEqualToString:@"all"]) {
        CLLocation *location = [ETGeolocation sharedInstance].currentLocation;
        [params setValue:@[@(location.coordinate.latitude), @(location.coordinate.longitude)]
                  forKey:@"location"];
    }
    
    NSString *path = [NSString stringWithFormat:@"gethistogram%@/", group];
    
    NSURLSessionDataTask *task = [[ETSessionManager sharedInstance] POST:path
                                                              parameters:params
                                                                 success:^(NSURLSessionDataTask *task, id responseObject)
                                  {
                                      if ( success ) {
                                          success(task, responseObject);
                                      }
                                  }
                                                                 failure:^(NSURLSessionDataTask *task, NSError *error)
                                  {
                                      if ( failure ) {
                                          failure(task, [self customServerErrorFromError:error]);
                                      }
                                  }];
    
    return task;
}

#pragma mark - Private

- (NSError*)customServerErrorFromError:(NSError*)error {
    
    id responseObject = error.userInfo[AFNetworkingTaskDidCompleteSerializedResponseKey];
    NSNumber *errorCode = ( [responseObject isKindOfClass:[NSDictionary class]] ) ? responseObject[kServerErrorCodeKey] : nil;
    if ( errorCode ) {
        NSString *message = error.userInfo[AFNetworkingTaskDidCompleteSerializedResponseKey][kServerErrorMessageKey];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Server error [%ld]: %@",
                                                               (long)errorCode.integerValue,
                                                               message],
                                   NSUnderlyingErrorKey: error};
        error = [NSError errorWithDomain:kServerDomain
                                    code:errorCode.integerValue
                                userInfo:userInfo];
    }
    
    return error;
}

@end
