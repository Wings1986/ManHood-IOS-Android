//
//  ETStore.m
//  Histo
//
//  Created by Viktor Gubriienko on 07.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETStore.h"
#import "ETRequestManager.h"
#import "NSUserDefaults+Preferences.h"
#import "MBProgressHUD.h"
#import "AFNetworkReachabilityManager.h"

static NSString *const kPurchaseIDMonth = @"ManHoodMonth";

@interface ETStore ()

<
SKProductsRequestDelegate,
SKPaymentTransactionObserver
>

@end



@implementation ETStore {
    SKProductsRequest *_productsRequest;
    SKReceiptRefreshRequest *_receiptRefreshRequest;
    NSArray *_products;
    
    SKPaymentTransaction *_currentPaymentTransaction;
    
    StoreFinishBlock _finishBlock;
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
        
        if ([AFNetworkReachabilityManager sharedManager].reachable) {
            [self downloadProducts];
        }
        
        //[self refreshReceipts];
        [self startQueueObserver];
    }
    return self;
}

#pragma mark - Public

+ (BOOL)userCanMakePurchases {
    return [SKPaymentQueue canMakePayments];
}

+ (NSString*)priceForProduct:(SKProduct*)product {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    return [numberFormatter stringFromNumber:product.price];
}

- (void)purchaseOneMonthSubscription {
    if ( self.oneMonthSubscriptionProduct ) {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].windows.firstObject animated:YES];
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:self.oneMonthSubscriptionProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)restorePurchasesWithFinishBlock:(StoreFinishBlock)finishBlock {
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].windows.firstObject animated:YES];
    _finishBlock = [finishBlock copy];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)refreshReceipts {
    _receiptRefreshRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:@{}];
    _receiptRefreshRequest.delegate = self;
    [_receiptRefreshRequest start];
}

- (void)inetBecomeAvailable:(BOOL)inetAvailable {
    if (_products == nil && inetAvailable && _productsRequest == nil) {
        [self downloadProducts];
    }
}

#pragma mark - Private

- (void)downloadProducts {
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:@[kPurchaseIDMonth]]];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

- (SKProduct*)productWithID:(NSString*)productID {
    return [_products objectWithKey:@"productIdentifier" equalTo:productID];
}

- (void)startQueueObserver {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)validatePurchase:(SKPaymentTransaction*)transaction {
    
    SKPaymentTransaction *transactionToProcess = transaction;
//    if ( transaction.transactionState == SKPaymentTransactionStateRestored ) {
//        transactionToProcess = transaction.originalTransaction;
//    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSData *rawReceipt = transactionToProcess.transactionReceipt;
#pragma clang diagnostic pop
    
    NSDictionary *receiptDictionary = [NSPropertyListSerialization propertyListWithData:rawReceipt
                                                                                options:NSPropertyListImmutable
                                                                                 format:nil
                                                                                  error:nil];
    
//    NSString *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
//    [rawReceipt writeToFile:[dir stringByAppendingPathComponent:@"receipt"] atomically:YES];
    
    NSData *pi = [[NSData alloc] initWithBase64EncodedString:receiptDictionary[@"purchase-info"] options:0];
    NSDictionary *receiptInfo = [NSPropertyListSerialization propertyListWithData:pi
                                                                          options:NSPropertyListImmutable
                                                                           format:nil
                                                                            error:nil];

    if ( [transactionToProcess.payment.productIdentifier isEqualToString:kPurchaseIDMonth] ) {
        NSDate *storedDate = [NSUserDefaults standardUserDefaults].subscriptionExpirationDate;
        NSString *expireDateStr = receiptInfo[@"expires-date"];
        NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:[expireDateStr doubleValue] / 1000];
        
        if ( storedDate == nil ) {
            storedDate = [NSDate date];
        }
        
        if ( [expireDate compare:storedDate] == NSOrderedDescending ) {
            [self validateReceiptOnServer:rawReceipt withFinishBlock:^(id receiptResult, NSError *error) {
                if (receiptResult) {
                    //NSLog(@"receiptResult = [%@]", receiptResult);
                    
                    if ( [transaction.payment.productIdentifier isEqualToString:kPurchaseIDMonth] ) {
                        if ( [receiptResult[@"expired"] isEqualToNumber:@0] ) {
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
                            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"]; // "2014-07-05T14:33:11+00:00"
                            
                            NSDate *newExpireDate = [formatter dateFromString:receiptResult[@"current_expiration_date"]];
                            NSDate *storedDate = [NSUserDefaults standardUserDefaults].subscriptionExpirationDate;
                            if ( storedDate == nil ) {
                                storedDate = [NSDate date];
                            }
                            if ( [newExpireDate compare:storedDate] == NSOrderedDescending ) {
                                [NSUserDefaults standardUserDefaults].subscriptionExpirationDate = newExpireDate;
                                [NSUserDefaults standardUserDefaults].subscriptionReceipt = rawReceipt;
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                if ( self.paymentSuccessBlock ) {
                                    self.paymentSuccessBlock(transactionToProcess);
                                }
                            }
                        } else {
                            // Expired product
                        }
                    } else {
                        // Unknown product
                    }
                    
                } else {
                    if ( self.paymentFailureBlock ) {
                        self.paymentFailureBlock(transactionToProcess, error);
                    }
                }
                
                if ( _currentPaymentTransaction == transaction ) {
                    _currentPaymentTransaction = nil;
                    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
                }
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transactionToProcess];
            }];
            
            return;
        }
        
    }
    
    if ( _currentPaymentTransaction == transaction ) {
        _currentPaymentTransaction = nil;
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transactionToProcess];
    
    /*
     2014-06-19 23:24:19.384 ManHood[9679:60b] str = [{
     "original-purchase-date-pst" = "2014-04-08 08:53:18 America/Los_Angeles";
     "purchase-date-ms" = "1403209091921";
     "unique-identifier" = "6d2d8a2af2cbfe143ab78f561881aa7d34d1dea4";
     "original-transaction-id" = "1000000107179223";
     "expires-date" = "1403209391921";
     "transaction-id" = "1000000114620967";
     "original-purchase-date-ms" = "1396972398000";
     "web-order-line-item-id" = "1000000028060079";
     "bvrs" = "1.0";
     "unique-vendor-identifier" = "DEA24CEE-6324-4CBB-8C47-CF4CBAD9B0C7";
     "expires-date-formatted-pst" = "2014-06-19 13:23:11 America/Los_Angeles";
     "item-id" = "856106945";
     "expires-date-formatted" = "2014-06-19 20:23:11 Etc/GMT";
     "product-id" = "ManHoodMonth";
     "purchase-date" = "2014-06-19 20:18:11 Etc/GMT";
     "original-purchase-date" = "2014-04-08 15:53:18 Etc/GMT";
     "bid" = "com.shapeapptech.ManHood";
     "purchase-date-pst" = "2014-06-19 13:18:11 America/Los_Angeles";
     "quantity" = "1";
     }]
     */


}

#pragma mark - Product delegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    if ( request == _productsRequest ) {
        _products = response.products;
        _productsRequest = nil;
        if ( response.invalidProductIdentifiers ) {
            NSLog(@"Invalid purchases %@", response.invalidProductIdentifiers);
        }
        
        if (_products == nil) {
            _products = @[];
        }
    } else /*if ( request == (id)_receiptRefreshRequest )*/ {
        _receiptRefreshRequest = nil;
        if ( response.invalidProductIdentifiers ) {
            NSLog(@"Invalid purchases %@", response.invalidProductIdentifiers);
        }
    }
}

- (void)validateReceiptOnServer:(NSData*)receipt withFinishBlock:(void(^)(id receiptResult, NSError *error))finishBlock {
    [[ETRequestManager sharedInstance] validatePurchaseWithReceipt:receipt
                                                           success:^(NSURLSessionDataTask *task, id responseObject) {
                                                               if ( finishBlock ) {
                                                                   finishBlock(responseObject, nil);
                                                               }
                                                           } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                               if ( finishBlock ) {
                                                                   finishBlock(nil, error);
                                                               }
                                                           }];
    return;
    /*
    // Create the JSON object that describes the request
    NSError *error;
    NSDictionary *requestContents = @{@"receipt-data": [receipt base64EncodedStringWithOptions:0],
                                      @"password": @"4599c3db5a6c4ec7b50108bc47b64ec2"};
    
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                          options:0
                                                            error:&error];
    if (!requestData) {
        if (finishBlock) {
            finishBlock(nil, error);
        }
    }
    
    // Create a POST request with the receipt data.
    NSURL *productionStoreURL = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
    NSURL *sandboxStoreURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:sandboxStoreURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    
    // Make a connection to the iTunes Store on a background queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   if (finishBlock) {
                                       finishBlock(nil, error);
                                   }
                               } else {
                                   NSError *error;
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if (!jsonResponse) {
                                       if (finishBlock) {
                                           finishBlock(nil, error);
                                       }
                                   }

                                   if (finishBlock) {
                                       finishBlock(jsonResponse, nil);
                                   }
                               }
                           }];
     */
}

#pragma mark - Queue delegate

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                _currentPaymentTransaction = transaction;
            } break;
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored: {
                
                [self validatePurchase:transaction];

            } break;
            case SKPaymentTransactionStateFailed: {
                if ( _currentPaymentTransaction == transaction ) {
                    _currentPaymentTransaction = nil;
                    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
                }

                if ( self.paymentFailureBlock ) {
                    self.paymentFailureBlock(transaction, transaction.error);
                }
                
                [queue finishTransaction:transaction];
                
            } break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    //NSLog(@"Removed TR = [%@]", transactions);
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
    StoreFinishBlock block = _finishBlock;
    _finishBlock = nil;
    if ( block ) {
        block(NO, error);
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].windows.firstObject animated:YES];
    StoreFinishBlock block = _finishBlock;
    _finishBlock = nil;
    if ( block ) {
        block(YES, nil);
    }
}

#pragma mark - DynamicProperties

- (SKProduct *)oneMonthSubscriptionProduct {
    return [self productWithID:kPurchaseIDMonth];
}

@end
