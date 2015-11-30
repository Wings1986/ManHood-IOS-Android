//
//  ETSessionManager.m
//  Histo
//
//  Created by Viktor Gubriienko on 30.05.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETSessionManager.h"
#import "AFNetworking.h"
#import "etDataModel.h"

//static NSString *const kBaseURL = @"http://54.72.157.118/api/";
static NSString *const kBaseURL = @"https://www.shapeapptech1.com/api/";

@implementation ETSessionManager

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t done;
    dispatch_once(&done, ^{
        
        // Securing password
        // Real password: @"T<7]/d#33\\)+7;,mbJXM-W]"
        NSString *encoded = @"R:5[-b!11Z')59*k`HVK+U[";
        NSMutableString *decoded = [NSMutableString new];
        for (NSInteger i = 0; i < encoded.length; ++i) {
            [decoded appendFormat:@"%C", (unichar)([encoded characterAtIndex:i] + 2)];
        }

        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.HTTPAdditionalHeaders = @{};
        
        NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:@"www.shapeapptech1.com"
                                                                                      port:443
                                                                                  protocol:@"https"
                                                                                     realm:@"ShapeApp Server"
                                                                      authenticationMethod:NSURLAuthenticationMethodDefault];
        NSURLCredential *credential = [NSURLCredential credentialWithUser:@"mobileclient"
                                                                 password:decoded
                                                              persistence:NSURLCredentialPersistenceForSession];
        [config.URLCredentialStorage setDefaultCredential:credential forProtectionSpace:protectionSpace];
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]
                                  sessionConfiguration:config];
         
        AFCompoundResponseSerializer *responseSerializers = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:
                                                             @[[AFJSONResponseSerializer serializer],
                                                               [AFHTTPResponseSerializer serializer]]];
        [sharedInstance setResponseSerializer:responseSerializers];
        
        AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        if ( [ETDataModel sharedInstance].authToken ) {
            [requestSerializer setValue:[ETDataModel sharedInstance].authToken forHTTPHeaderField:@"X-SESSION-ID"];
        }
        [sharedInstance setRequestSerializer:requestSerializer];

        [sharedInstance setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate]];
        [sharedInstance securityPolicy].allowInvalidCertificates = YES;
    });
    
    return sharedInstance;
}

@end
