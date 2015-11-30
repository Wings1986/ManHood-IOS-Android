//
//  ETStore.h
//  Histo
//
//  Created by Viktor Gubriienko on 07.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>

typedef void (^StoreSuccessBlock)(SKPaymentTransaction *transaction);
typedef void (^StoreFailureBlock)(SKPaymentTransaction *transaction, NSError *error);
typedef void (^StoreFinishBlock)(BOOL success, NSError *error);

@interface ETStore : NSObject

@property (nonatomic, readonly) SKProduct *oneMonthSubscriptionProduct;
@property (nonatomic, copy) StoreSuccessBlock paymentSuccessBlock;
@property (nonatomic, copy) StoreFailureBlock paymentFailureBlock;

+ (instancetype)sharedInstance;

+ (BOOL)userCanMakePurchases;
+ (NSString*)priceForProduct:(SKProduct*)product;

- (void)purchaseOneMonthSubscription;

- (void)restorePurchasesWithFinishBlock:(StoreFinishBlock)finishBlock;

- (void)inetBecomeAvailable:(BOOL)inetAvailable;

@end
