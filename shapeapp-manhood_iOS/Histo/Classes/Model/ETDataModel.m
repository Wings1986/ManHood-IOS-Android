//
//  ETDataModel.m
//  Histo
//
//  Created by Viktor Gubriienko on 27.05.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETDataModel.h"
#import "PDKeychainBindingsController.h"
#import "ETRequestManager.h"
#import "MBProgressHUD.h"
#import "UIAlertView+Blocks.h"
#import "ETAppDelegate.h"
#import "AFNetworking.h"
#import "ETSessionManager.h"
#import "ETStore.h"
#import "GAI.h"

NSString *const kDataModelDomain = @"kDataModelDomain";

@interface ETDataModel ()

@property (nonatomic, strong) UsersData *usersDataAll;
@property (nonatomic, strong) UsersData *usersData200;
@property (nonatomic, strong) UsersData *usersData20;
@property (nonatomic, strong) SelfUserData *userData;

@end



@implementation ETDataModel {
    NSString *_userID;
    NSString *_authToken;
}

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ sharedInstance = [self new]; });
    
    return sharedInstance;
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadUserData];
        [self loadHistogramData];
    }
    return self;
}

#pragma mark - Public

- (void)loadHistogramData {
    [self loadHistogramDataForGroup:@"all"];
    [self loadHistogramDataForGroup:@"200"];
    [self loadHistogramDataForGroup:@"20"];
}

- (void)loadHistogramDataForGroup:(NSString*)group {
    NSDictionary *mappings = @{@"all": @"usersDataAll",
                               @"200": @"usersData200",
                               @"20": @"usersData20"};
    
    UsersData *usersData = [[UsersData alloc] initWithContentsOfFile:[self histogramDataFilePathForGroup:group] rootKey:group];
    [self setValue:usersData forKey:mappings[group]];
}

- (void)loadUserData {
    if ( [[[NSUserDefaults standardUserDefaults] userGender] isEqualToString:userMale] ) {
        self.userData = [[SelfUserData alloc] initWithContentsOfFile:[self userDataFilePath]];
    }
}

- (void)showInAppPurchaseSuccess:(void(^)())successBlock {
    if ( [NSUserDefaults standardUserDefaults].isSubscriptionValid ) {
        if ( successBlock ) {
            successBlock();
        }
    } else if ([ETStore sharedInstance].oneMonthSubscriptionProduct && [ETStore userCanMakePurchases]) {
        
        typedef void (^SimpleBlock)(void);
        SimpleBlock showPurchaseBlock = ^() {
            NSString *price = [ETStore priceForProduct:[ETStore sharedInstance].oneMonthSubscriptionProduct];
            [UIAlertView showWithTitle:@"Join the Inner Circle!"
                               message:[NSString stringWithFormat:@"See the Hood, join the Inner Circle. Get the most details for only %@ per month", price]
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@[@"Restore", @"Join the Inner Circle"]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
                                  if ( [buttonTitle isEqualToString:@"Join the Inner Circle"] ) {
                                      [[ETStore sharedInstance] purchaseOneMonthSubscription];
                                  } else if ( [buttonTitle isEqualToString:@"Restore"] ) {
                                      [[ETStore sharedInstance] restorePurchasesWithFinishBlock:^(BOOL success, NSError *error) {
                                          NSString *title = success ? @"All purchases restored" : error.localizedDescription ;
                                          [UIAlertView showWithTitle:@""
                                                             message:title
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil
                                                            tapBlock:nil];
                                      }];
                                  }
                              }];
        };
        
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].windows.firstObject animated:YES];
        [[ETRequestManager sharedInstance] getSubscriptionStatusWithSuccess:^(NSURLSessionDataTask *task, id responseObject) {
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
            
            if ( [responseObject[@"expired"] boolValue] ) {
                showPurchaseBlock();
            } else {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
                [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"]; // "2014-07-05T14:33:11+00:00"
                
                [NSUserDefaults standardUserDefaults].subscriptionExpirationDate = [formatter dateFromString:responseObject[@"current_expiration_date"]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if ( successBlock ) {
                    successBlock();
                }
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
            showPurchaseBlock();
        }];
    } else {
        [UIAlertView showWithTitle:@"Can't connect to Apple Store"
                           message:@"Please try again later"
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil
                          tapBlock:nil];
    }
}

- (void)doStartupFlow:(FinishBlock)finishBlock {
    
    if ( finishBlock == nil ) {
        finishBlock = ^(BOOL result, NSError *error){};
    }
    
    typedef void (^SimpleBlock)(void);
    
    SimpleBlock showAlertBlock = ^{ // Done
        [UIAlertView showWithTitle:@"Connection error"
                           message:@"Please try again"
                 cancelButtonTitle:nil
                 otherButtonTitles:@[@"Retry"]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              [self doStartupFlow:finishBlock];
                          }];
    };
    
    SimpleBlock downloadAllHistogramData = ^{ // Done
        [self downloadHistogramDataForSliceRange:SliceRangeAll finishBlock:^(BOOL success, NSError *error) {
            if ( success ) {
                finishBlock(YES, nil);
            } else {
               // if (self.usersDataAll) {
                    finishBlock(YES, nil);
                //} else {
                //    showAlertBlock();
               // }
            }
        }];
    };
    
    
    SimpleBlock downloadUserDataBlock = ^{ // Done
        [self downloadUserMeasurementsData:^(BOOL success, NSError *error) {
            downloadAllHistogramData();
        }];
    };
    
    
    SimpleBlock userDataCheckBlock = ^{ // Done
        if ( [[NSUserDefaults standardUserDefaults].userGender isEqualToString:userMale] && self.userData == nil ) {
            downloadUserDataBlock();
        } else {
            downloadAllHistogramData();
        }
    };
    
    
    SimpleBlock authenticateUserBlock = ^{ // Done
        BOOL genderSet = [NSUserDefaults standardUserDefaults].userGender != nil;
        [self authenticateUser:^(BOOL success, NSError *error) {
            if ( success ) {
                if ( !genderSet && [NSUserDefaults standardUserDefaults].userGender ) {
                    [self showHistogramScreen];
                }
                userDataCheckBlock();
            } else {
                showAlertBlock();
            }
        }];
    };
    
    
    SimpleBlock checkAuthTokenBlock = ^{ // Done
        BOOL genderSet = [NSUserDefaults standardUserDefaults].userGender != nil;

        if ( genderSet && self.authToken ) {
            userDataCheckBlock();
        } else {
            authenticateUserBlock();
        }
    };
    
    
    SimpleBlock createNewUserBlock = ^{ // Done
        [self createUser:^(BOOL success, NSError *error) {
            if ( success ) {
                downloadAllHistogramData();
            } else {
                showAlertBlock();
            }
        }];
    };
    
    
    SimpleBlock userIDCheckBlock = ^{ // Done
        if ( self.userID ) {
            checkAuthTokenBlock();
        } else {
            createNewUserBlock();
        }
    };
    
    userIDCheckBlock();

}

- (void)createUser:(FinishBlock)finishBlock {
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].windows.firstObject animated:YES];
    [[ETRequestManager sharedInstance] createUserWithSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
        
        if ( responseObject[@"AuthToken"] ) {
            self.authToken = responseObject[@"AuthToken"];
        }
        
        if ( responseObject[@"UserID"] ) {
            self.userID = responseObject[@"UserID"];
            if ( finishBlock ) {
                finishBlock(YES, nil);
            }
        } else {
            if ( finishBlock ) {
                finishBlock(NO, [NSError errorWithDomain:kDataModelDomain code:DataModelErrorCodeNoUserID userInfo:nil]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
        
        if ( finishBlock ) {
            finishBlock(NO, error);
        }
    }];
}

- (void)authenticateUser:(FinishBlock)finishBlock {
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].windows.firstObject animated:YES];
    [[ETRequestManager sharedInstance] authenticateUserWithSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
        
        if ( responseObject[@"AuthToken"] ) {
            self.authToken = responseObject[@"AuthToken"];
            [[NSUserDefaults standardUserDefaults] registerUserGender: ([responseObject[@"userSettings"][@"isMale"] isEqualToString:@"True"]) ? userMale : userFemale];
            if ( finishBlock ) {
                finishBlock(YES, nil);
            }
        } else {
            if ( finishBlock ) {
                finishBlock(NO, [NSError errorWithDomain:kDataModelDomain code:DataModelErrorCodeNoAuthToken userInfo:nil]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
        
        if ( ![self checkErrorForDeletedUser:error] ) {
            finishBlock(NO, error);
        }
    }];
}

- (void)downloadUserMeasurementsData:(FinishBlock)finishBlock {
    //[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].windows.firstObject animated:YES];
    [[ETRequestManager sharedInstance] getMeasurmentsWithSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        //[MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
        
        [NSUserDefaults standardUserDefaults].jobID = nil;
        
        NSArray *measurements = responseObject[@"measurements"];
        NSString *warning = responseObject[@"warning_message"];
        NSNumber *errorCode = responseObject[@"error_code"];
        NSString *errorMessage = responseObject[@"error_message"];
        
        if ( [measurements isKindOfClass:[NSArray class]] && measurements.count == 6 )
        {
            
            if ( warning ) {
                [NSObject dispatchAfter:0.0 block:^{
                    [UIAlertView showWithTitle:@"Room for improvements"
                                       message:warning
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil
                                      tapBlock:nil];
                }];
            }
            
            [measurements writeToFile:[self userDataFilePath] atomically:YES];
            [self loadUserData];
            if (finishBlock) {
                finishBlock(YES, nil);
            }
        } else if ( errorCode ) {
            NSDictionary *userInfo;
            if (errorMessage) {
                userInfo = @{NSLocalizedDescriptionKey: errorMessage};
            }
            
            if (finishBlock) {
                finishBlock(NO, [NSError errorWithDomain:kServerDomain code:errorCode.integerValue userInfo:userInfo]);
            }
        } else {
            if (finishBlock) {
                finishBlock(NO, [NSError errorWithDomain:kDataModelDomain code:DataModelErrorCodeNoUserData userInfo:nil]);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //[MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
        
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"you_json" ofType:@"json"];
        self.userData = [[SelfUserData alloc] initWithContentsOfFile1:filePath];
        
        
        if ( [self checkErrorForJobInProgress:error] ) {
            [NSObject dispatchAfter:3.0 block:^{
                [self downloadUserMeasurementsData:finishBlock];
            }];
        } else {
            [NSUserDefaults standardUserDefaults].jobID = nil;
            [self handleNetworkError:error
                      withRetryBlock:^{
                          [self downloadUserMeasurementsData:finishBlock];
                      } finishBlock:finishBlock];
        }
    }];
}

- (void)downloadHistogramDataForSliceRange:(SliceRange)range
                               finishBlock:(FinishBlock)finishBlock
{
    NSString *group = [self groupFromSliceRange:range];
    [[ETRequestManager sharedInstance] getHistogramDataForGroup:group
                                                    withSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        
        if ( responseObject[group] ) {
            id histogramData = responseObject[group];
            if ( histogramData ) {
                [histogramData writeToFile:[self histogramDataFilePathForGroup:group] atomically:YES];
            }
            [self loadHistogramDataForGroup:group];
            if (finishBlock) {
                finishBlock(YES, nil);
            }
        } else {
            if (finishBlock) {
                finishBlock(NO, [NSError errorWithDomain:kDataModelDomain code:DataModelErrorCodeUnknownError userInfo:nil]);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (finishBlock) {
            finishBlock(NO, error);
        }
    }];
}

- (void)analyzePhotosWithFlow:(ETFlow*)flow finishBlock:(FinishBlock)finishBlock {
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].windows.firstObject animated:YES];
    [[ETRequestManager sharedInstance] analyzePhotosWithFlow:flow success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if ( responseObject[@"job_id"] ) {
            [NSUserDefaults standardUserDefaults].jobID = responseObject[@"job_id"];

            [NSObject dispatchAfter:3 block:^{
                [self downloadUserMeasurementsData:^(BOOL success, NSError *error) {
                    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
                    if (finishBlock) {
                        finishBlock(success, error);
                    }
                }];
            }];

        } else {
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
            if (finishBlock) {
                finishBlock(NO, [NSError errorWithDomain:kDataModelDomain code:DataModelErrorCodeNoJobID userInfo:nil]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
        if ( finishBlock ) {
            finishBlock(NO, error);
        }
    }];
}

- (void)cleanupData {
    [[NSUserDefaults standardUserDefaults] resetData];
    [[PDKeychainBindingsController sharedKeychainBindingsController] storeString:nil forKey:@"AuthToken"];
    [self cleanDataDirectory];
    self.userID = nil;
       // [ETDataModel sharedInstance].userID = @"fc1d6225694e4daaa43d17a79be90527";
}

- (void)showChooseGenderScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [ETAppDelegate instance].window.rootViewController = [storyboard instantiateInitialViewController];
}

- (void)showHistogramScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [ETAppDelegate instance].window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"HistoNavCtrl"];
}

- (void)cleanupDataAndShowHistogramScreen {
    [[NSUserDefaults standardUserDefaults] resetData];
    [[PDKeychainBindingsController sharedKeychainBindingsController] storeString:nil forKey:@"UserID"];
    [[PDKeychainBindingsController sharedKeychainBindingsController] storeString:nil forKey:@"AuthToken"];
    [self cleanDataDirectory];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [ETAppDelegate instance].window.rootViewController = [storyboard instantiateInitialViewController];
}

- (UsersData*)usersDataForGroup:(NSString*)group {
    NSDictionary *mappings = @{@"all": @"usersDataAll",
                               @"200": @"usersData200",
                               @"20": @"usersData20"};
    
    return [self valueForKey:mappings[group]];
}

- (NSString*)groupFromSliceRange:(SliceRange)range {
    switch (range) {
        case SliceRangeAll: return @"all";
        case SliceRange200: return @"200";
        case SliceRange20: return @"20";
        default: return nil;
    }
}

+ (NSString*)fractionForValue:(float)input {
    
    NSInteger fractions = lroundf((input - (int)input) / (1.0 / 16.0));
     
    if(fractions == 0 || fractions == 16) {
        
        return  [NSString stringWithFormat:@"%ld",lroundf(input)];
        
    } else if(fractions == 2) {
        
        return  [NSString stringWithFormat:@"1/8"];
        
    } else if(fractions == 4) {
        
        return  [NSString stringWithFormat:@"1/4"];
        
    } else if(fractions == 5) {
        
        return  [NSString stringWithFormat:@"1/3"];
        
    } else if(fractions == 6) {
        
        return  [NSString stringWithFormat:@"3/8"];
        
    } else if(fractions == 8) {
        
        return  [NSString stringWithFormat:@"1/2"];
        
    } else if(fractions == 10) {
        
        return  [NSString stringWithFormat:@"5/8"];
        
    } else if(fractions == 11) {
        
        return  [NSString stringWithFormat:@"2/3"];
        
    } else if(fractions == 12) {
        
        return  [NSString stringWithFormat:@"3/4"];
        
    } else if(fractions == 14) {
        
        return  [NSString stringWithFormat:@"7/8"];
        
    } else {
        
        return  [NSString stringWithFormat:@"%ld/16", (long)fractions];
        
    }
}

#pragma mark - Private

- (NSString*)dataDirectory {
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    dir = [dir stringByAppendingPathComponent:@"data"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    return dir;
}

- (void)cleanDataDirectory {
    [[NSFileManager defaultManager] removeItemAtPath:[self dataDirectory] error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:[self dataDirectory]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
}

- (NSString*)userDataFilePath {
    return [[self dataDirectory] stringByAppendingPathComponent:@"userData.plist"];
}

- (NSString*)histogramDataFilePathForGroup:(NSString*)group {
    return [[self dataDirectory] stringByAppendingPathComponent:[group stringByAppendingPathExtension:@"plist"]];
}

- (BOOL)checkErrorForDeletedUser:(NSError*)error {

    if ( [error.domain isEqualToString:kServerDomain] && ( error.code == ServerErrorCodeBadUserID || error.code == ServerErrorCodeNoUserWithID ) )
    {
        [[ETDataModel sharedInstance] cleanupData];
        [[ETDataModel sharedInstance] showChooseGenderScreen];
        return YES;
    }
    
    return NO;
}

- (BOOL)checkErrorForBadAuthToken:(NSError*)error {
    
    if ( [error.domain isEqualToString:AFNetworkingErrorDomain] && ( error.code == NSURLErrorBadServerResponse) ) {
        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
        if ( response.statusCode == 403 ) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)checkErrorForJobInProgress:(NSError*)error {
    return [error.domain isEqualToString:kServerDomain] && error.code == ServerErrorCodeJobInProgress;
}

- (void)handleNetworkError:(NSError*)error withRetryBlock:(void(^)())retryBlock finishBlock:(FinishBlock)finishBlock {
    if ( [self checkErrorForDeletedUser:error] ) {
        //DO NOTHING
    } else if ( [self checkErrorForBadAuthToken:error] ) {
        [self authenticateUser:^(BOOL success, NSError *error) {
            if ( success ) {
                if ( retryBlock ) {
                    retryBlock();
                }
            } else {
                if (finishBlock) {
                    finishBlock(NO, error);
                }
            }
        }];
    } else {
        if (finishBlock) {
            finishBlock(NO, error);
        }
    }
}

#pragma mark - DynamicProperties

- (NSString *)userID {
    if ( _userID == nil ) {
        PDKeychainBindingsController *keychain = [PDKeychainBindingsController sharedKeychainBindingsController];
        _userID = [keychain stringForKey:@"UserID"];
        
        if ( _userID == nil ) { // If keychain is empty try to load from userDefaults
            _userID = [NSUserDefaults standardUserDefaults].userID;
            if ( _userID ) { // If userID exists try to store in keychain and remove from userDefualts
                if ( [keychain storeString:_userID forKey:@"UserID"] && [[keychain stringForKey:@"UserID"] isEqualToString:_userID] ) {
                    [NSUserDefaults standardUserDefaults].userID = nil;
                }
            }
        }
        
        if (_userID) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker set:@"&uid" value:_userID];
        }
    }
    
    return _userID;
}

- (void)setUserID:(NSString *)userID {
    _userID = userID;
    
    PDKeychainBindingsController *keychain = [PDKeychainBindingsController sharedKeychainBindingsController];
    if ( ![keychain storeString:userID forKey:@"UserID"] ) {
        [NSUserDefaults standardUserDefaults].userID = userID;
    }
    
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    [store setString:userID forKey:@"UserID"];
    [store synchronize];
    
    if (_userID) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:@"&uid" value:_userID];
    }
}

- (NSString *)authToken {
    
    if ( _authToken == nil ) {
        _authToken = [[PDKeychainBindingsController sharedKeychainBindingsController] stringForKey:@"AuthToken"];
    }
    
    return _authToken;
}

- (void)setAuthToken:(NSString *)authToken {
    _authToken = authToken;
    
    PDKeychainBindingsController *keychain = [PDKeychainBindingsController sharedKeychainBindingsController];
    [keychain storeString:authToken forKey:@"AuthToken"];
    [[ETSessionManager sharedInstance].requestSerializer setValue:_authToken forHTTPHeaderField:@"X-SESSION-ID"];
}


#pragma mark - iCloud

- (void)startiCloud {
    
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storeDidChange:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:store];
    
    [store synchronize];
}

- (void)storeDidChange:(NSNotification*)notif {
    NSDictionary *userInfo = notif.userInfo;
    NSInteger reason = [userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] integerValue];
    NSArray *keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey];
    
    NSUbiquitousKeyValueStore *iCloud = notif.object;
    
    if ( userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] == nil ) {
        return;
    }
    
    switch (reason) {
        case NSUbiquitousKeyValueStoreAccountChange:
        case NSUbiquitousKeyValueStoreServerChange:
        case NSUbiquitousKeyValueStoreInitialSyncChange: {
            
            if ( [keys containsObject:@"UserID"] ) {
                NSString *cloudUserID = [iCloud stringForKey:@"UserID"];
                if ( self.userID == nil || ! [cloudUserID isEqualToString:self.userID] ) {
                    
                    [self cleanupData];
                    self.userID = cloudUserID;
                    [self authenticateUser:^(BOOL success, NSError *error) {
                        if ( success ) {
                            [self showHistogramScreen];
                        } else {
                            // Will authenticate with other request
                        }
                    }];
                }
            }
        } break;
        default:
            break;
    }
}

@end
