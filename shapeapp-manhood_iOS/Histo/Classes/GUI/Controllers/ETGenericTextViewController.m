//
//  ETTermsViewController.m
//  Histo
//
//  Created by Idriss on 16/02/2014.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETGenericTextViewController.h"

@interface ETGenericTextViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backView;


@end

@implementation ETGenericTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage *image = (IS_LONG_IPHONE)?[UIImage imageNamed:@"camera_guide_bg-568h.png"]:[UIImage imageNamed:@"camera_guide_bg.png"];
    self.backView.image = image;
    
}

- (IBAction)dismissModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
