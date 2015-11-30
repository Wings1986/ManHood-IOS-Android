//
//  TransitionManager.m
//  TB_CustomTransitionIOS7
//
//  Created by Yari Dareglia on 10/22/13.
//  Copyright (c) 2013 Bitwaker. All rights reserved.
//

#import "TransitionManager.h"

static const NSTimeInterval kTransitionDuration = 0.4;

@implementation TransitionManager


#pragma mark - UIViewControllerAnimatedTransitioning -

//Define the transition duration
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 1.0;
}


//Define the transition
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    //STEP 1
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect sourceRect = [transitionContext initialFrameForViewController:fromVC];
    
    /*STEP 2:   Draw different transitions depending on the view to show
                for sake of clarity this code is divided in two different blocks
     */
    
    //STEP 2A: From the First View(INITIAL) -> to the Second View(MODAL)
    if(self.transitionTo == MODAL){
       
        UIView *container = [transitionContext containerView];
        [container insertSubview:toVC.view aboveSubview:fromVC.view];
        
        [fromVC viewWillDisappear:YES];
        
        toVC.view.alpha = 0.0f;
        toVC.view.transform = CGAffineTransformMakeTranslation(-fromVC.view.bounds.size.width, 0.0f);
        
        [UIView animateWithDuration:kTransitionDuration
                         animations:^{
                             toVC.view.alpha = 1.0f;
                             toVC.view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             [fromVC viewDidDisappear:YES];
                             [transitionContext completeTransition:YES];
                         }];
    }
    
    //STEP 2B: From the Second view(MODAL) -> to the First View(INITIAL)
    else{
        
        UIView *container = [transitionContext containerView];
        [container insertSubview:toVC.view belowSubview:fromVC.view];
        
        [toVC viewWillAppear:YES];
        
        [UIView animateWithDuration:kTransitionDuration
                         animations:^{
                             fromVC.view.transform = CGAffineTransformMakeTranslation(-fromVC.view.bounds.size.width, 0.0f);
                             fromVC.view.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             [toVC viewDidAppear:YES];
                             [transitionContext completeTransition:YES];
                         }];
    }
}

@end
