//
//  PageChooser.m
//  iPlayBook
//
//  Created by Viktor Gubriienko on 06.11.13.
//  Copyright (c) 2013 iPlayBook Apps. All rights reserved.
//

#import "PageChooser.h"

static CGFloat kPageControlHeight = 37.0f;

@interface PageChooser ()

<
UIScrollViewDelegate
>

@end



@implementation PageChooser {
    NSMutableArray *_cachedItems;
    UIScrollView *_scrollView;
    CGFloat _scrollPadding;
    BOOL _rightBorderSwipeDetected;
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (void)initialSetup {
    
    self.backgroundColor = [UIColor clearColor];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 self.bounds.size.width,
                                                                 self.bounds.size.height - kPageControlHeight)];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.clipsToBounds = NO;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f,
                                                                   _scrollView.bounds.size.height,
                                                                   self.bounds.size.width,
                                                                   kPageControlHeight)];
    _pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [_pageControl addTarget:self
                     action:@selector(tapPageControl)
           forControlEvents:UIControlEventValueChanged];
    [self addSubview:_pageControl];
    
    _cachedItems = [NSMutableArray new];
    _currentItem = NSNotFound;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    recognizer.numberOfTouchesRequired = 1;
    recognizer.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:recognizer];
}

#pragma mark - View

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateScrollLayout];
}

#pragma mark - Public

- (void)reloadData {
    
    [_cachedItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_cachedItems removeAllObjects];
    
    NSUInteger count = [_delegate numberOfItemsInPageChooser:self];
    for (NSInteger i = 0 ; i < count ; i++) {
        UIView *itemView = [_delegate pageChooser:self itemAtIndex:i];
        [_cachedItems addObject:itemView];
        [_scrollView addSubview:itemView];
    }
    
    _pageControl.numberOfPages = count;
    _currentItem = (count) ? 0 : NSNotFound;
    [self updateScrollLayout];
}

#pragma mark - Private

- (void)updateScrollLayout {
    
    _scrollPadding = _scrollView.frame.size.width / 2.0 - _itemSize.width / 2.0f - _itemIndent;
    
    [_cachedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *itemView = obj;
        itemView.frame = CGRectMake(_scrollPadding + idx * (_itemSize.width + _itemIndent * 2.0f) + _itemIndent,
                                    0.0f,
                                    _itemSize.width,
                                    _itemSize.height);
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollPadding * 2.0f + _cachedItems.count * (_itemSize.width + _itemIndent * 2.0f),
                                         _scrollView.frame.size.height);
    
}

- (void)setupPageControlCurrentPage {
    _pageControl.currentPage = [self itemIndexForOffset:_scrollView.contentOffset.x];
    [self updateCurrentItem];
}

- (void)scrollToItemWithIndex:(NSInteger)itemIndex {
    CGFloat offset = (_itemSize.width + _itemIndent * 2.0f) * itemIndex;
    [_scrollView setContentOffset:CGPointMake(offset, 0.0f) animated:YES];
}

- (NSInteger)itemIndexForOffset:(CGFloat)offset {
    NSInteger index = (offset + _scrollView.frame.size.width / 2.0f - _scrollPadding) / (_itemSize.width + _itemIndent * 2.0f);
    index = (index < 0 ) ? 0 : index ;
    index = (index >= _cachedItems.count ) ? _cachedItems.count - 1 : index ;
    return index;
}

- (void)updateCurrentItem {
    NSUInteger newItem = _pageControl.currentPage;
    if ( newItem != _currentItem) {
        _currentItem = newItem;
        
        if ( [_delegate respondsToSelector:@selector(pageChooser:currentItemChanged:)] ) {
            [_delegate pageChooser:self currentItemChanged:_currentItem];
        }
    }
}

#pragma mark - DynamicProperties

- (void)setScrollPadding:(CGFloat)scrollPadding {
    _scrollPadding = scrollPadding;
    
    [self updateScrollLayout];
}

- (void)setItemIndent:(CGFloat)itemIndent {
    _itemIndent = itemIndent;
    
    [self updateScrollLayout];
}

- (void)setItemSize:(CGSize)itemSize {
    _itemSize = itemSize;
    
    [self updateScrollLayout];
}

- (void)setCurrentItem:(NSUInteger)currentItem {
    
    if ( currentItem >= _cachedItems.count ) {
        return;
    }
    
    _currentItem = currentItem;
    
    [self scrollToItemWithIndex:_currentItem];
    [self setupPageControlCurrentPage];
}

- (void)setPagingEnabled:(BOOL)pagingEnabled {
    _scrollView.pagingEnabled = pagingEnabled;
}

- (BOOL)pagingEnabled {
    return _scrollView.pagingEnabled;
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ( scrollView.contentSize.width - scrollView.contentOffset.x < scrollView.bounds.size.width ) {
        if ( !_rightBorderSwipeDetected ) {
            if ( scrollView.bounds.size.width - (scrollView.contentSize.width - scrollView.contentOffset.x) > 0.0f ) {
                _rightBorderSwipeDetected = YES;
                if ( [_delegate respondsToSelector:@selector(pageChooserReachedRightBorder:)] ) {
                    [_delegate pageChooserReachedRightBorder:self];
                }
            }
        }
    } else {
        _rightBorderSwipeDetected = NO;
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ( !decelerate ) {
        [self setupPageControlCurrentPage];
        if ( !self.pagingEnabled ) {
            [self scrollToItemWithIndex:[self itemIndexForOffset:scrollView.contentOffset.x]];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setupPageControlCurrentPage];
    if ( !self.pagingEnabled ) {
        [self scrollToItemWithIndex:[self itemIndexForOffset:scrollView.contentOffset.x]];
    }
}

#pragma mark - Actions

- (void)tapPageControl {
    [self scrollToItemWithIndex:_pageControl.currentPage];
    [self updateCurrentItem];
}

- (void)tapped:(UITapGestureRecognizer*)sender {
    
    NSUInteger itemIndex = [self itemIndexForOffset:_scrollView.contentOffset.x
                            - _scrollView.bounds.size.width / 2.0f
                            + [sender locationInView:self].x];
    [self scrollToItemWithIndex:itemIndex];
    _pageControl.currentPage = itemIndex;
    [self updateCurrentItem];
    
    if ( [_delegate respondsToSelector:@selector(pageChooser:tappedItemWithIndex:)] ) {
        [_delegate pageChooser:self tappedItemWithIndex:itemIndex];
    }
    
}

@end
