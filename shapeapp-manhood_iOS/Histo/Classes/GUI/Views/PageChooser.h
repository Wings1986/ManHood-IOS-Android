//
//  PageChooser.h
//  iPlayBook
//
//  Created by Viktor Gubriienko on 06.11.13.
//  Copyright (c) 2013 iPlayBook Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageChooser;
@protocol PageChooserDelegate <NSObject>

@required

- (NSUInteger)numberOfItemsInPageChooser:(PageChooser*)pageChooser;
- (UIView*)pageChooser:(PageChooser *)pageChooser itemAtIndex:(NSInteger)index;

@optional

- (void)pageChooser:(PageChooser *)pageChooser currentItemChanged:(NSUInteger)itemIndex;
- (void)pageChooser:(PageChooser *)pageChooser tappedItemWithIndex:(NSUInteger)itemIndex;
- (void)pageChooserReachedRightBorder:(PageChooser *)pageChooser;

@end



@interface PageChooser : UIView

@property (nonatomic, weak) id<PageChooserDelegate> delegate;

@property (nonatomic, readonly) UIPageControl *pageControl;
@property (nonatomic) CGFloat itemIndent;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) NSUInteger currentItem;
@property (nonatomic) BOOL pagingEnabled;

- (void)reloadData;

@end
