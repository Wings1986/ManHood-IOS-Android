//
//  NSUserDefaults+Preferences.h
//  Histo
//
//  Created by Idriss on 17/02/2014.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const userMale;
extern NSString * const userFemale;

extern NSString * const unitMetric;
extern NSString * const unitImperial;

@interface NSUserDefaults (Preferences)

@property (nonatomic, copy) NSString *userID; // THIS IS BACKUP STORAGE IN CASE SAVE TO KEYCHAIN FAIL
@property (nonatomic, copy) NSString *jobID;
@property (nonatomic, copy) NSDate *subscriptionExpirationDate;
@property (nonatomic, copy) NSData *subscriptionReceipt;

@property (nonatomic, readonly) BOOL isSubscriptionValid;

- (NSString*)userGender;
- (void)registerUserGender:(NSString*)userGender;

- (BOOL)privacyLock;
- (void)setPrivacyLock:(BOOL)lock;

- (NSString*)unitType;
- (void)setUnitType:(NSString*)unitType;

- (void)resetData;

@end
