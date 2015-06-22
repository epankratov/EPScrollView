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
    NSMutableArray *_viewsRect;
    NSMutableDictionary *_visibleViews;
    NSMutableArray *_visibleViewsIndexes;
    NSInteger _rowPosition;
    CGPoint _lastContentOffset;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index;
- (void)initCommon;
- (void)addViewAtIndex:(NSInteger)index;

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
    // Remove views
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // Set initial scroll position
    [self setContentOffset:CGPointZero];
    _lastContentOffset = CGPointMake(0, 0);
    // Cleanup internal data
    [_viewsRect removeAllObjects];
    [_visibleViews removeAllObjects];
    [_visibleViewsIndexes removeAllObjects];
    // Proceed only with valid datasource
    if (self.dataSource) {
        _rowPosition = 0;
        NSUInteger viewsCount = [self.dataSource extendedScrollViewNumberOfItems:self];
        NSUInteger visibleCount = 0;
        NSUInteger totalHeight = 0;
        // Calculate frames for each individual view and put it to the local storage
        for (NSUInteger i = 0; i < viewsCount; i++) {
            CGFloat height = [self heightForViewAtIndex:i];
            CGRect viewFrame = CGRectMake(0, totalHeight, self.bounds.size.width, height);
            if (totalHeight < self.bounds.size.height)
                visibleCount++;
            totalHeight += height;
            [_viewsRect addObject:[NSValue valueWithCGRect:viewFrame]];
        }
        self.contentSize = CGSizeMake(self.bounds.size.width, totalHeight);
        // Add only visible views
        for (NSUInteger i = 0; i < visibleCount; i++) {
            [self addViewAtIndex:i];
        }
    }
}

- (CGRect)rectForViewAtIndex:(NSInteger)index
{
    CGRect frame = CGRectZero;
    if (index < _viewsRect.count)
        frame = [[_viewsRect objectAtIndex:index] CGRectValue];
    return frame;
}

// returns nil if cell is not visible or index is out of range
- (UIView *)itemViewForIndex:(NSInteger)index
{
    if ([_visibleViewsIndexes containsObject:[NSNumber numberWithUnsignedLong:index]])
        return [_visibleViews objectForKey:[NSNumber numberWithInteger:index]];
    return nil;
}

- (NSArray *)visibleViews
{
    return [NSArray arrayWithArray:[_visibleViews allValues]];
}

- (NSArray *)visibleViewsIndexes
{
    return _visibleViewsIndexes;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger lastVisibleIndex  = -1;
    NSInteger firstVisibleIndex = [self.dataSource extendedScrollViewNumberOfItems:self];
    for (NSInteger i = 0; i < [_visibleViewsIndexes count]; i++) {
        NSInteger value = [[_visibleViewsIndexes objectAtIndex:i] integerValue];
        if (value < firstVisibleIndex)
            firstVisibleIndex = value;
        if (value > lastVisibleIndex)
            lastVisibleIndex = value;
    }
    CGRect lastVisibleFrame  = [self rectForViewAtIndex:lastVisibleIndex];
    CGRect firstVisibleFrame = [self rectForViewAtIndex:firstVisibleIndex];
    NSInteger direction = scrollView.contentOffset.y - _lastContentOffset.y;
    // Check scrolling to bottom
    if (direction > 0)
    {
        // Add new item to the bottom
        if (scrollView.contentOffset.y >= ((lastVisibleFrame.origin.y + lastVisibleFrame.size.height) - self.bounds.size.height)) {
            NSUInteger viewsCount = [self.dataSource extendedScrollViewNumberOfItems:self];
            if (lastVisibleIndex + 1 < viewsCount) {
                [self addViewAtIndex:lastVisibleIndex + 1];
            }
        }
        // But remove from top
        if (scrollView.contentOffset.y > (firstVisibleFrame.origin.y + firstVisibleFrame.size.height)) {
            [self removeViewAtIndex:firstVisibleIndex];
        }
    }
    // Check scrolling to top
    else if (direction < 0 && scrollView.contentOffset.y >= 0)
    {
        // Add again items to the top
        if (scrollView.contentOffset.y <= (firstVisibleFrame.origin.y + firstVisibleFrame.size.height) && firstVisibleIndex > 0) {
            [self addViewAtIndex:firstVisibleIndex - 1];
        }
        // But remove from the bottom
        NSInteger prevVisibleIndex = lastVisibleIndex - 1;
        if (prevVisibleIndex) {
            CGRect prevVisibleFrame = [self rectForViewAtIndex:prevVisibleIndex];
            if (scrollView.contentOffset.y < ((prevVisibleFrame.origin.y + prevVisibleFrame.size.height) - self.bounds.size.height)) {
                [self removeViewAtIndex:lastVisibleIndex];
            }
        }
    }
    _lastContentOffset = scrollView.contentOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat targetY = scrollView.contentOffset.y + velocity.y * 60.0;
    // TODO: use real heights instead of default one
    CGFloat targetIndex = round(targetY / _defaultItemHeight);
    if (velocity.y > 0) {
        targetIndex = ceil(targetY / _defaultItemHeight);
    } else {
        targetIndex = floor(targetY / _defaultItemHeight);
    }
    targetContentOffset->y = targetIndex * _defaultItemHeight;
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
    _viewsRect           = [[NSMutableArray alloc] initWithCapacity:_defaultCapacity];
    _visibleViews        = [[NSMutableDictionary alloc] initWithCapacity:_defaultCapacity];
    _visibleViewsIndexes = [[NSMutableArray alloc] initWithCapacity:_defaultCapacity];
    _rowPosition         = -1;
    _lastContentOffset   = CGPointMake(0, 0);
    [super setDelegate:self];
}

- (void)addViewAtIndex:(NSInteger)index
{
    NSNumber *nIndex = [NSNumber numberWithUnsignedLong:index];
    if ([_visibleViewsIndexes containsObject:nIndex]) {
        return;
    }
    UIView *viewToAdd = [self.dataSource extendedScrollView:self viewForItem:index];
    [viewToAdd setFrame:[self rectForViewAtIndex:index]];
    [self addSubview:viewToAdd];
    [_visibleViewsIndexes addObject:nIndex];
    [_visibleViews setObject:viewToAdd forKey:nIndex];
}

- (void)removeViewAtIndex:(NSInteger)index
{
    UIView *viewToRemove = [self itemViewForIndex:index];
    [viewToRemove removeFromSuperview];
    [_visibleViewsIndexes removeObject:[NSNumber numberWithUnsignedLong:index]];
    [_visibleViews removeObjectsForKeys:[NSArray arrayWithObject:[NSNumber numberWithInteger:index]]];
}

@end
