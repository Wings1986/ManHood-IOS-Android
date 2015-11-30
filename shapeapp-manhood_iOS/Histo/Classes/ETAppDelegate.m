//
//  ETAppDelegate.m
//  Histo
//
//  Created by Idriss on 16/02/2014.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETAppDelegate.h"
#import "ETFlow.h"
#import "Appirater.h"
#import "ETGeolocation.h"
#import "ETStore.h"
#import "ETNavigationController.h"
#import "ETRequestManager.h"
#import "NSUserDefaults+Preferences.h"
#import "ETDataModel.h"
#import "GAI.h"

#import "ETSessionManager.h"

static NSString *const kGAIKey = @"UA-50531426-2";

@implementation ETAppDelegate

#pragma mark - Access

+ (ETAppDelegate*)instance {
    return [UIApplication sharedApplication].delegate;
}

#pragma mark - Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //[[ETDataModel sharedInstance] cleanupData]; // Clean all local and iCloud data!!!!
    //[NSUserDefaults standardUserDefaults].subscriptionExpirationDate = nil;
    
    /*
    NSArray *fontNames = [UIFont familyNames];
    for (NSString *familyName in fontNames) {
        NSLog(@"Font family name = %@", familyName);
        NSArray *names = [UIFont fontNamesForFamilyName:familyName];
        NSLog(@"Font names = %@", names);
    }/**/
    
    [self startReachability];
    [self startGAI];
    [self startAppirater];
    [self setupGUI];
    [[ETDataModel sharedInstance] startiCloud];
    
    [NSObject dispatchAfter:1.0 block:^{
        [self startStore];
    }];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // Save UserID to iCloud
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    NSString *userID = [ETDataModel sharedInstance].userID;
    if ( userID && [store stringForKey:@"UserID"] == nil ) {
        [store setString:userID forKey:@"UserID"];
        if ( ![store synchronize] ) {
            NSLog(@"Can't synchronize iCloud");
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[ETGeolocation sharedInstance] stopUpdating];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[ETGeolocation sharedInstance] startUpdating];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Public

- (ETFlow*)createCameraFlow {
    
    ETFlow *flow = [ETFlow new];
    NSMutableArray *steps = [NSMutableArray new];
    
    ETFlowStep *step;
    
    {
        step = [ETFlowStep new];
        step.ID = @"FirstShot";
        step.type = @"Camera";
        step.options = @{@"HintImage": @"Front_camera_illustration.png",
                         @"HintTitle": @"Example of Front Picture",
                         @"Label": @"Front"};
        [steps addObject:step];
    }
    
    {
        step = [ETFlowStep new];
        step.ID = @"SecondShot";
        step.type = @"Camera";
        step.options = @{@"HintImage": @"Side_camera_illustration.png",
                         @"HintTitle": @"Example of Side Picture",
                         @"Label": @"Side"};
        [steps addObject:step];
    }
    
    {
        step = [ETFlowStep new];
        step.ID = @"FirstAdj";
        step.type = @"Adj";
        step.options = @{@"HintImage": @"Front_adjust_illustration.png",
                         @"OverlayImage": (IS_LONG_IPHONE) ? @"iPhone5_template.png" : @"iPhone4_template.png",
                         @"HintTitle": @"Example of Front Adjustment",
                         @"ImageDataStepID": @"FirstShot",
                         @"Label": @"Front"};
        [steps addObject:step];
    }
    
    {
        step = [ETFlowStep new];
        step.ID = @"SecondAdj";
        step.type = @"Adj";
        step.options = @{@"HintImage": @"Side_adjust_illustration.png",
                         @"OverlayImage": (IS_LONG_IPHONE) ? @"iPhone5_template.png" : @"iPhone4_template.png",
                         @"HintTitle": @"Example of Side Adjustment",
                         @"ImageDataStepID": @"SecondShot",
                         @"Label": @"Side"};
        [steps addObject:step];
    }
    
    flow.steps = steps;
    
    return flow;
}

- (void)purchaseOneMonthSubscription {
    [[ETStore sharedInstance] purchaseOneMonthSubscription];
}

- (void)restorePurchases {
    [[ETStore sharedInstance] restorePurchasesWithFinishBlock:^(BOOL success, NSError *error) {
        //NSLog(@"restorePurchases Error = [%@]", error);
    }];
}

#pragma mark - Private

- (void)startAppirater {
    [Appirater setAppId:@"849639776"];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:2];
    [Appirater setSignificantEventsUntilPrompt:2];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    
    [Appirater appLaunched:YES];
}

- (void)startStore {

    ETStore *store = [ETStore sharedInstance];
    
    [store setPaymentSuccessBlock:^(SKPaymentTransaction *transaction){
        
        NSDate *date = [NSUserDefaults standardUserDefaults].subscriptionExpirationDate;
        
        UIAlertView *alertView = [[UIAlertView new] initWithTitle:@"Subscription purchased"
                                                          message:[NSString stringWithFormat:@"Subscription valid until - %@", [date descriptionWithLocale:[NSLocale currentLocale]]]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [alertView show];
        
    }];
    
    [store setPaymentFailureBlock:^(SKPaymentTransaction *transaction, NSError *error){
        //NSLog(@"failed = [%@] %@", transaction.payment, error);
        
        UIAlertView *alertView = [[UIAlertView new] initWithTitle:@"Failed to buy"
                                                          message:[error localizedDescription]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [alertView show];
    }];
    
}

- (void)setupGUI {
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_window makeKeyAndVisible];
    _window.backgroundColor = [UIColor whiteColor];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if ( [[NSUserDefaults standardUserDefaults] userGender] ) {
        _window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"HistoNavCtrl"];
    } else {
        _window.rootViewController = [storyboard instantiateInitialViewController];
    }
    
    id appearance = [UINavigationBar appearanceWhenContainedIn:[ETNavigationController class], nil];
    [appearance setBackgroundColor:[UIColor clearColor]];
    [appearance setBarTintColor:[UIColor clearColor]];
    [appearance setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [appearance setShadowImage:[UIImage new]];
    
    [appearance setBackIndicatorImage:[[UIImage imageNamed:@"back_button.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [appearance setBackIndicatorTransitionMaskImage:[appearance backIndicatorImage]];
    
    UIFont *font= [UIFont fontWithName:@"Exo-ExtraBold" size:17.0f];
    [appearance setTitleTextAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    font = [UIFont fontWithName:@"Exo-Regular" size:14.0f];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]}
                                                forState:UIControlStateNormal];
    
}

- (void)startGAI {
#ifdef DEBUG
    [[GAI sharedInstance] setDryRun:YES];
#endif
    //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    [[GAI sharedInstance] trackerWithTrackingId:kGAIKey];
}

- (void)startReachability {
    AFNetworkReachabilityManager *reachManager = [AFNetworkReachabilityManager sharedManager];
    
    [reachManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [[ETStore sharedInstance] inetBecomeAvailable:status != AFNetworkReachabilityStatusNotReachable];
    }];
    
    [reachManager startMonitoring];
}

@end
