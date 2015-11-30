//
//  ETViewController.m
//  Histo
//
//  Created by Idriss on 16/02/2014.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETWelcomeViewController.h"
#import "ETAppDelegate.h"

#import "NSUserDefaults+Preferences.h"
#import "ETNavigationController.h"
#import "ETDataModel.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

NSInteger const maleSegment   = 0;
NSInteger const femaleSegment = 1;

@interface ETWelcomeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIButton *guyButton;
@property (weak, nonatomic) IBOutlet UIButton *girlButton;
@property (strong, nonatomic) IBOutlet UIButton *enterButton;

- (IBAction)tapGuy;
- (IBAction)tapGirl;

@end



@implementation ETWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backImageView.image = (IS_LONG_IPHONE)?[UIImage imageNamed:@"welcome_bg-568h.png"]:[UIImage imageNamed:@"welcome_bg.png"];
    
    [NSObject dispatchAfter:0 block:^{
        if ( [ETDataModel sharedInstance].userID ) {
            [[ETDataModel sharedInstance] doStartupFlow:nil];
        }
    }];
}

#pragma mark - Actions

- (IBAction)tapGuy {
    _guyButton.selected = YES;
    _girlButton.selected = NO;
    _enterButton.enabled = YES;
    [[NSUserDefaults standardUserDefaults] registerUserGender:userMale];
}

- (IBAction)tapGirl {
    _guyButton.selected = NO;
    _girlButton.selected = YES;
    _enterButton.enabled = YES;
    [[NSUserDefaults standardUserDefaults] registerUserGender:userFemale];
}

#pragma mark - Segue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {

    NSString *gender = _girlButton.selected ? @"female" : @"male" ;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"           // Event category (required)
                                                          action:@"user_choosed_gender" // Event action (required)
                                                           label:gender                 // Event label
                                                           value:nil] build]];          // Event value
    return YES;
}

@end
