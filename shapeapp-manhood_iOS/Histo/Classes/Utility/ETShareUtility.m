//
//  ETShareUtility.m
//  Histo
//
//  Created by Viktor Gubriienko on 01.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETShareUtility.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

@interface ETShareUtility ()

@end



@implementation ETShareUtility

+ (void)shareHistogramSnapshot:(UIImage*)snapshot onViewController:(UIViewController*)ctrl {
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[@"#ManHoodApp", snapshot]
                                                                               applicationActivities:nil];
    
    [activityView setExcludedActivityTypes:@[UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]];
    [ctrl presentViewController:activityView animated:YES completion:nil];
}

+ (void)shareTheAppViaEmailOnViewController:(UIViewController*)ctrl {
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[@"Help me map our Hood! #ManHoodApp"]
                                                                               applicationActivities:nil];
    [activityView setExcludedActivityTypes:@[UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]];
    [ctrl presentViewController:activityView animated:YES completion:^{
    }];
}

+ (void)tellAFriendViaEmailOnViewController:(UIViewController*)ctrl {
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[@"Help me map our Hood! #ManHoodApp"]
                                                                               applicationActivities:nil];
    [activityView setExcludedActivityTypes:@[UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]];
    [ctrl presentViewController:activityView animated:YES completion:^{
    }];
}

+ (void)shareTheAppViaMessageOnViewController:(UIViewController*)ctrl {
    if([MFMessageComposeViewController canSendText]) {
        NSArray *recipents = nil;
        NSString *message = @"Let's go";
        
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = (id<MFMessageComposeViewControllerDelegate>)self;
        [messageController setRecipients:recipents];
        [messageController setBody:message];
        [ctrl presentViewController:messageController animated:YES completion:nil];
    }
}

+ (void)shareTheAppViaTwitterOnViewController:(UIViewController*)ctrl {
    SLComposeViewController *shareCtrl = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [shareCtrl setInitialText:@"Check Out/Measure Up with ManHood... it shows you measurements for the men in the neighbourhood! www.manhoodapp.com"];
    
    [ctrl presentViewController:shareCtrl animated:YES completion:nil];
}

+ (void)shareTheAppViaFacebookOnViewController:(UIViewController*)ctrl {
    SLComposeViewController *shareCtrl = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [shareCtrl setInitialText:@"Check Out/Measure Up with ManHood... it shows you measurements for the men in the neighbourhood! www.manhoodapp.com"];
    
    [ctrl presentViewController:shareCtrl animated:YES completion:nil];
}

#pragma mark - MessageUI delegates

+ (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
