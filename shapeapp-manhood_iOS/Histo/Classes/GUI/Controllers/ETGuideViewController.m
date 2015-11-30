//
//  ETGuideViewController.m
//  Histo
//
//  Created by Viktor Gubriienko on 11.03.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETGuideViewController.h"
#import "PageChooser.h"
#import "ETCameraViewController.h"
#import "ETAppDelegate.h"
#import "ETGuidePageView.h"
#import "NSUserDefaults+Preferences.h"
#import "UIDevice+Models.h"

@interface ETGuideViewController ()

<
PageChooserDelegate
>

@property (weak, nonatomic) IBOutlet UIImageView *backView;
@property (weak, nonatomic) IBOutlet PageChooser *pageChooser;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)tapCancel:(UIBarButtonItem *)sender;

@end



@implementation ETGuideViewController {
    NSArray *_pageData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = (IS_LONG_IPHONE)?[UIImage imageNamed:@"camera_guide_bg-568h.png"]:[UIImage imageNamed:@"camera_guide_bg.png"];
    _backView.image = image;
    
    BOOL female = [[[NSUserDefaults standardUserDefaults] userGender] isEqualToString:userFemale];
    
    _pageData = @[@{@"i": @"ill1.png", @"t": @"STEP 1", @"d": @"Sit in front of a mirror"},
                  @{@"i": @"ill2.png", @"t": @"STEP 2", @"d": @"Wear a white/blue/green/black T-shirt"},
                  @{@"i": @"ill3.png", @"t": @"STEP 3", @"d": @"Take off the cover"},
                  @{@"i": @"ill4.png", @"t": @"STEP 4", @"d": @"Press the phone to the bone"},
                  @{@"i": @"ill5.png", @"t": @"STEP 5", @"d": @"Make sure the edges of the phone and your manhood are as visible as possible"},
                  @{@"i": @"ready_to_go_icon.png", @"t": (female) ? @"That’s how to do it" : @"Ready to Go",
                                                   @"d": (female) ? @"This is the way for guys to digitally measure themselves" : @"I got it! Time to measure!"},
                  ];
    
    _pageChooser.delegate = self;
    _pageChooser.itemIndent = 0.0f;
    _pageChooser.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.44 green:0.45 blue:0.44 alpha:1];
    _pageChooser.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    _pageChooser.pagingEnabled = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGSize itemSize = self.view.frame.size;
    itemSize.height -= 100;
    _pageChooser.itemSize = itemSize;
    
    [_pageChooser reloadData];
}

#pragma mark - PageChooser delegate

- (NSUInteger)numberOfItemsInPageChooser:(PageChooser *)pageChooser {
    return _pageData.count;
}

- (UIView *)pageChooser:(PageChooser *)pageChooser itemAtIndex:(NSInteger)index {
    
    ETGuidePageView *view = [ETGuidePageView loadViewFromXIB];
    view.frame = CGRectMake(0.0f, 0.0f, _pageChooser.itemSize.width, _pageChooser.itemSize.height);
    view.imageView.image = [UIImage imageNamed:_pageData[index][@"i"]];
    view.titleLabel.text = _pageData[index][@"t"];
    view.descriptionLabel.text = _pageData[index][@"d"];
    view.backgroundColor = [UIColor clearColor];
    
    CGRect frame = view.descriptionLabel.frame;
    CGFloat newHeight = [view.descriptionLabel sizeThatFits:CGSizeMake(frame.size.width, CGFLOAT_MAX)].height;
    CGFloat yChange = newHeight - frame.size.height;
    view.descriptionLabel.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y - yChange,
                                             frame.size.width,
                                             newHeight);
    
    frame = view.titleLabel.frame;
    view.titleLabel.frame = CGRectMake(frame.origin.x,
                                       frame.origin.y - yChange,
                                       frame.size.width,
                                       frame.size.height);
    
    frame = view.imageView.frame;
    view.imageView.frame = CGRectMake(frame.origin.x,
                                       frame.origin.y,
                                       frame.size.width,
                                       frame.size.height - yChange);
    
    return view;
}

- (void)pageChooser:(PageChooser *)pageChooser currentItemChanged:(NSUInteger)itemIndex {
    [self.navigationItem setLeftBarButtonItem:(itemIndex == 0) ? _cancelButton : nil animated:YES];
}

- (void)pageChooser:(PageChooser *)pageChooser tappedItemWithIndex:(NSUInteger)itemIndex {
    if ( itemIndex == _pageData.count - 1 ) {
        if ( [[[NSUserDefaults standardUserDefaults] userGender] isEqualToString:userMale] ) {
            [self showCameraCtrl];
        } else {
            [self tapCancel:nil];
        }

    }
}

/* Swipe to next screen
- (void)pageChooserReachedRightBorder:(PageChooser *)pageChooser {
    [self showCameraCtrl];
}
*/

#pragma mark - Private

- (void)showCameraCtrl {
    
    if ( ![UIDevice isiPhoneOriPod] ) {
        [UIAlertView showWithTitle:@"Only iPhone and iPod Touch are supported for taking measurements"
                           message:nil
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              [self tapCancel:nil];
                          }];
    } else {
        ETCameraViewController *cameraScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"ETCameraViewController"];
        cameraScreen.flow = [[ETAppDelegate instance] createCameraFlow];
        [self.navigationController pushViewController:cameraScreen animated:YES];
    }
}

#pragma mark - Actions

- (IBAction)tapCancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
