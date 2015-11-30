//
//  ETTransitionSegue.m
//  Histo
//
//  Created by Viktor Gubriienko on 02.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETTransitionSegue.h"
#import "TransitionManager.h"

@implementation ETTransitionSegue

-(void)perform {
    
    UIViewController<UIViewControllerTransitioningDelegate> *sourceViewController = [self sourceViewController];
    UIViewController *destinationController = [self destinationViewController];
    
    destinationController.transitioningDelegate = sourceViewController;
    destinationController.modalPresentationStyle = UIModalPresentationCustom;
    
    [sourceViewController presentViewController:destinationController animated:YES completion:nil];

}

@end
