//
//  ETHelpViewController.m
//  Histo
//
//  Created by Viktor Gubriienko on 21.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETHelpViewController.h"

@interface ETHelpViewController ()

@end

@implementation ETHelpViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = (IS_LONG_IPHONE)?[UIImage imageNamed:@"camera_guide_bg-568h.png"]:[UIImage imageNamed:@"camera_guide_bg.png"];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:image];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.tableView setupFirstSeparatorOnHeaderView];
}

@end
