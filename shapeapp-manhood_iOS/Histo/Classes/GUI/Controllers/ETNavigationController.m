//
//  ETNavigationController.m
//  Histo
//
//  Created by Viktor Gubriienko on 11.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETNavigationController.h"

@interface ETNavigationController ()

@end


@implementation ETNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
