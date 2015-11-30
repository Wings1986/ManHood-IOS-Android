//
//  ETSettingsViewController.m
//  Histo
//
//  Created by Idriss on 18/02/2014.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <Social/Social.h>

#import "ETSettingsTableViewController.h"
#import "ETShareUtility.h"
#import "NSUserDefaults+Preferences.h"
#import "ETDataModel.h"

@interface ETSettingsTableViewController ()

@property (strong, nonatomic) IBOutlet UISwitch *privacySwitch;
@property (strong, nonatomic) IBOutlet UILabel *metricLabel;
@property (nonatomic, retain) NSString *unitType;

- (IBAction)tapBack:(UIBarButtonItem *)sender;
- (IBAction)setPrivacyLock:(UISwitch*)switchButton;

@end



@implementation ETSettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.unitType = [[NSUserDefaults standardUserDefaults] unitType];
    
    self.privacySwitch.on = [[NSUserDefaults standardUserDefaults] privacyLock];
    self.metricLabel.text = [self textForUnit:self.unitType];
    
    UIImage *image = (IS_LONG_IPHONE)?[UIImage imageNamed:@"camera_guide_bg-568h.png"]:[UIImage imageNamed:@"camera_guide_bg.png"];
   
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:image];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:NULL];

}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        [[ETDataModel sharedInstance] showInAppPurchaseSuccess:^{
            [UIAlertView showWithTitle:@"You are in the Inner Circle!"
                               message:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil
                              tapBlock:nil];
        }];
    } else if (indexPath.row == 1) {
        [self switchUnits];
    } else if (indexPath.row == 4) {
        [self share];
    }
}

#pragma mark - Recognizers

- (IBAction)swipeBack:(UISwipeGestureRecognizer *)sender {
    if ( sender.state == UIGestureRecognizerStateEnded ) {
        [self tapBack:nil];
    }
}

#pragma mark - IBActions

- (void)share {
    [ETShareUtility tellAFriendViaEmailOnViewController:self];
}

- (IBAction)setPrivacyLock:(UISwitch*)switchButton
{
    [[NSUserDefaults standardUserDefaults] setPrivacyLock:switchButton.on];
}

- (void)switchUnits
{
    if ([self.unitType isEqualToString:unitImperial]) {
        self.unitType = unitMetric;
    } else {
        self.unitType = unitImperial;
    }
    
    [[NSUserDefaults standardUserDefaults] setUnitType:self.unitType];
    self.metricLabel.text = [self textForUnit:self.unitType];
    
}

- (NSString*)textForUnit:(NSString*)unitType
{
    if ([unitType isEqualToString:unitImperial]) {
        return @"in";
    } else {
        return @"cm";
    }
}

#pragma mark - Actions

- (IBAction)tapBack:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
