//
//  ETSupportTableViewController.m
//  Histo
//
//  Created by Idriss on 18/02/2014.
//  Copyright (c) 2014 histo. All rights reserved.
//
#import <MessageUI/MessageUI.h>

#import "ETSupportTableViewController.h"
#import "ETDataModel.h"
#import "UIDevice+Models.h"
#import "NSUserDefaults+Preferences.h"

@interface ETSupportTableViewController ()

<
MFMailComposeViewControllerDelegate
>

- (void)sendEmail;

@end



@implementation ETSupportTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = (IS_LONG_IPHONE)?[UIImage imageNamed:@"camera_guide_bg-568h.png"]:[UIImage imageNamed:@"camera_guide_bg.png"];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:image];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.tableView setupFirstSeparatorOnHeaderView];
    
}

#pragma mark - Table delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  /*
  if (indexPath.row == 0) {
    //[self leaveReview];
  } else
   */
  if (indexPath.row == 0) {
    [self sendEmail];
  }
}

#pragma mark - Actions

- (void)sendEmail
{
    int fakerand = arc4random() % 1000;
    NSString *destination = @"hello@manhoodapp.com";
    NSString *subject     = [NSString stringWithFormat:@"Support/Feedback #100%d", fakerand];
    
    NSString *body = [NSString stringWithFormat:@"\n\n\n\n------------------\nPlease do not remove this part\n78ef31%@629a4ac\n %@ %@ %@ version: %@ %@\n-----------------------------------",
                      [ETDataModel sharedInstance].userID,
                      [UIDevice hardwareModel],
                      [UIDevice currentDevice].systemName,
                      [UIDevice currentDevice].systemVersion,
                      [[NSBundle mainBundle] infoDictionary][(NSString*)kCFBundleVersionKey],
                      [NSUserDefaults standardUserDefaults].userGender];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    [picker setMailComposeDelegate:self];
    [picker setSubject:subject];
    [picker setMessageBody:body isHTML:NO];
    [picker setToRecipients:@[destination]];
    
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)leaveReview
{
  NSURL *appstoreURL = [NSURL URLWithString:@"https://itunes.apple.com/app/id849639776"];
    /*or itms-apps://itunes.com/app/ or https://itunes.apple.com/app/manhood */
  [[UIApplication sharedApplication] openURL:appstoreURL];
}

#pragma mark - Email delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
