//
//  ETDataModel.h
//  Histo
//
//  Created by Viktor Gubriienko on 27.05.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsersData.h"
#import "SelfUserData.h"
#import "NSUserDefaults+Preferences.h"
#import "ETFlow.h"


extern NSString *const kDataModelDomain;

typedef enum : NSUInteger {
    SliceRangeAll,
    SliceRange200,
    SliceRange20
} SliceRange;

typedef enum : NSUInteger {
    DataModelErrorCodeNoUserID = 1,
    DataModelErrorCodeNoAuthToken,
    DataModelErrorCodeNoUserData,
    DataModelErrorCodeNoJobID,
    DataModelErrorCodeUnknownError,
} DataModelErrorCode;


typedef void(^FinishBlock)(BOOL success, NSError *error);

@interface ETDataModel : NSObject

@property (nonatomic, readonly) UsersData *usersDataAll;
@property (nonatomic, readonly) UsersData *usersData200;
@property (nonatomic, readonly) UsersData *usersData20;
@property (nonatomic, readonly) SelfUserData *userData;

@property (nonatomic, readonly) NSString *userID;
@property (nonatomic, readonly) NSString *authToken;

+ (instancetype)sharedInstance;

- (void)startiCloud;

- (void)doStartupFlow:(FinishBlock)finishBlock;

- (void)showInAppPurchaseSuccess:(void(^)())successBlock;

- (void)createUser:(FinishBlock)finishBlock;
- (void)authenticateUser:(FinishBlock)finishBlock;
- (void)downloadHistogramDataForSliceRange:(SliceRange)range finishBlock:(FinishBlock)finishBlock;
- (void)analyzePhotosWithFlow:(ETFlow*)flow finishBlock:(FinishBlock)finishBlock;

- (void)cleanupData;
- (void)showChooseGenderScreen;
- (void)showHistogramScreen;

- (UsersData*)usersDataForGroup:(NSString*)group;
- (NSString*)groupFromSliceRange:(SliceRange)range;

+ (NSString*)fractionForValue:(float)input;

@end
