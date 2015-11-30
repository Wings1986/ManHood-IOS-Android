//
//  NSUserDefaults+Preferences.m
//  Histo
//
//  Created by Idriss on 17/02/2014.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "NSUserDefaults+Preferences.h"
#import "PDKeychainBindingsController.h"

static NSString * const userGenderKey = @"ETUserGenderKey";
NSString * const userMale      = @"UserMale";
NSString * const userFemale    = @"UserFemale";

static NSString * const privacyLock   = @"ETPrivacyLock";

static NSString * const unitKey       = @"ETUnitType";
NSString * const unitMetric    = @"UnitMetric";
NSString * const unitImperial  = @"UnitImperial";

static NSString *const kUserID = @"kUserID";
static NSString *const kJobID = @"kJobID";
static NSString *const kSubscriptionExpirationDate = @"kSubscriptionExpirationDate";
static NSString *const kSubscriptionReceipt = @"kSubscriptionReceipt";

@implementation NSUserDefaults (Preferences)



- (NSString*)userGender
{
  return [self stringForKey:userGenderKey];
}

- (void)registerUserGender:(NSString*)userGender
{
  [self setValue:userGender forKey:userGenderKey];
  [self synchronize];

}


- (BOOL)privacyLock
{
  return [self boolForKey:privacyLock];
}

- (void)setPrivacyLock:(BOOL)lock
{
  [self setBool:lock forKey:privacyLock];
  [self synchronize];
}

- (NSString*)unitType
{
  NSString *unit = [self stringForKey:unitKey];
  if (!unit){
    unit = unitImperial;
  }
  return unit;
}

- (void)setUnitType:(NSString*)unitType
{
  [self setValue:unitType forKey:unitKey];
}

- (void)setJobID:(NSString *)jobID {
    [self setObject:jobID forKey:kJobID];
}

- (NSString *)jobID {
    return [self stringForKey:kJobID];
}

- (void)setSubscriptionExpirationDate:(NSDate*)subscriptionExpirationDate {
    [self setObject:subscriptionExpirationDate forKey:kSubscriptionExpirationDate];
}

- (NSDate *)subscriptionExpirationDate {
    return [self objectForKey:kSubscriptionExpirationDate];
}

- (BOOL)isSubscriptionValid {
    return [self.subscriptionExpirationDate compare:[NSDate date]] == NSOrderedDescending;
}

- (void)setSubscriptionReceipt:(NSData *)subscriptionReceipt {
    [self setObject:subscriptionReceipt forKey:kSubscriptionReceipt];
}

- (NSData *)subscriptionReceipt {
    return [self dataForKey:kSubscriptionReceipt];
}

#pragma mark - 

- (NSString *)userID {
    NSString *userID = [self stringForKey:kUserID];
    return userID;
}

- (void)setUserID:(NSString *)userID {
    [self setObject:userID forKey:kUserID];
    [self synchronize];
}

- (void)resetData {
    [self removeObjectForKey:kUserID];
    [self removeObjectForKey:privacyLock];
    [self removeObjectForKey:userGenderKey];
    [self removeObjectForKey:kJobID];
    [self removeObjectForKey:kSubscriptionExpirationDate];
    [self removeObjectForKey:kSubscriptionReceipt];
    [self synchronize];
}

@end
