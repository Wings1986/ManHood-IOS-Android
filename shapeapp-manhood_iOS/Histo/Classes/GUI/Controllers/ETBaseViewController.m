//
//  ETBaseViewController.m
//  Histo
//
//  Created by Viktor Gubriienko on 10.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETBaseViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface ETBaseViewController ()

@end

@implementation ETBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:[self className]];
    
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

@end
