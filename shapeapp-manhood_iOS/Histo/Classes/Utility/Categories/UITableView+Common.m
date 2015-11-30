//
//  UITableView+Common.m
//  Histo
//
//  Created by Viktor Gubriienko on 11.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "UITableView+Common.h"

static const NSInteger kSeparatorTag = 12370;

@implementation UITableView (Common)

- (void)setupFirstSeparatorOnHeaderView {
    
    if ( [self viewWithTag:kSeparatorTag] ) {
        return;
    }
    
    UIView *firstSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                      self.tableHeaderView.frame.size.height - 0.5f,
                                                                      self.tableHeaderView.frame.size.width,
                                                                      0.5f)];
    firstSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    firstSeparator.backgroundColor = self.separatorColor;
    firstSeparator.tag = kSeparatorTag;
    [self.tableHeaderView addSubview:firstSeparator];
}

@end
