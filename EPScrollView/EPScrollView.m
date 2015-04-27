//
//  EPScrollView.m
//  EPScrollView
//
//  Created by Eugene Pankratov on 30.03.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import "EPScrollView.h"
#import "Global.h"

const CGFloat _defaultItemHeight    = 380;
const CGFloat _defaultCapacity      = 10;

@interface EPScrollView () {
    NSMutableArray *_visibleViews;
    NSMutableArray *_viewsRect;
    NSMutableArray *_visibleViewsIndexes;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index;
- (void)initCommon;

@end

@implementation EPScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (void)reloadData
{
    if (self.dataSource) {
        NSUInteger viewsCount = [self.dataSource extendedScrollViewNumberOfItems:self];
        // Do something here
        NSUInteger totalHeight = 0;
        for (NSUInteger i = 0; i < viewsCount; i++) {
            UIView *viewToAdd = [self.dataSource extendedScrollView:self viewForItem:i];
            CGFloat height = [self heightForViewAtIndex:i];
            CGRect viewFrame = CGRectMake(0, totalHeight, self.bounds.size.width, height);
            [viewToAdd setFrame:viewFrame];
            [_viewsRect addObject:[NSValue valueWithCGRect:viewFrame]];
            totalHeight += height;
            [self addSubview:viewToAdd];
            [_visibleViewsIndexes addObject:[NSNumber numberWithUnsignedLong:i]];
        }
        self.contentSize = CGSizeMake(self.bounds.size.width, totalHeight);
    }
}

- (CGRect)rectForViewAtIndex:(NSInteger)index
{
    CGRect frame = [[_viewsRect objectAtIndex:index] CGRectValue];
    return frame;
}

// returns nil if cell is not visible or index is out of range
- (UIView *)itemViewForIndex:(NSInteger *)index
{
    return nil;
}

- (NSArray *)visibleViews
{
    return _visibleViews;
}

- (NSArray *)indexesForVisibleViews
{
    return _visibleViewsIndexes;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    VLog(@"The view has scrolled");
}

#pragma mark - Private methods

- (CGFloat)heightForViewAtIndex:(NSInteger)index
{
    CGFloat itemHeight = _defaultItemHeight;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(extendedScrollView:heightForItem:)])
        itemHeight = [self.dataSource extendedScrollView:self heightForItem:index];
    return itemHeight;
}

- (void)initCommon
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setScrollsToTop:YES];
    _visibleViews        = [[NSMutableArray alloc] initWithCapacity:_defaultCapacity];
    _viewsRect           = [[NSMutableArray alloc] initWithCapacity:_defaultCapacity];
    _visibleViewsIndexes = [[NSMutableArray alloc] initWithCapacity:_defaultCapacity];
    [super setDelegate:self];
}

@end
