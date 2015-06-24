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
// Add/remove single view
- (void)addSingleViewWithIndex:(NSInteger)index;
- (void)removeSingleViewWithIndex:(NSInteger)index;
// Add/remove whole row
- (void)addViewsToRowNumber:(NSInteger)number;
- (void)removeViewsFromRowNumber:(NSInteger)number;

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
        NSUInteger columnsCount = 1;
        if ([self.dataSource respondsToSelector:@selector(extendedScrollViewNumberOfColumns:)]) {
            columnsCount = [self.dataSource extendedScrollViewNumberOfColumns:self] ? : 1;
        }
        NSUInteger visibleCount = 0;
        NSUInteger totalHeight = 0;
        CGFloat width = self.bounds.size.width / columnsCount;
        // Calculate and store frames for each individual view
        for (NSUInteger i = 0; i < viewsCount; i++) {
            CGFloat height = [self heightForViewAtIndex:i];
            for (NSUInteger j = 0; j < columnsCount; j++) {
                CGRect viewFrame = CGRectMake(width * j, totalHeight, width, height);
                if (totalHeight < self.bounds.size.height) {
                    visibleCount++;
                }
                [_viewsRect addObject:[NSValue valueWithCGRect:viewFrame]];
                VLog(@"Add item: %lu with frame: %@", (unsigned long) i * columnsCount + j, NSStringFromCGRect(viewFrame));
            }
            totalHeight += height;
            VLog(@"total height: %lu", (unsigned long) totalHeight);
        }

        self.contentSize = CGSizeMake(self.bounds.size.width, totalHeight);
        VLog(@"visible count: %lu", (unsigned long) visibleCount);
        // Add only views to visible row
        for (NSUInteger i = 0; i < visibleCount; i++) {
            [self addSingleViewWithIndex:i];
        }
    }
}

- (CGRect)rectForViewWithIndex:(NSInteger)index
{
    CGRect frame = CGRectZero;
    if (index < _viewsRect.count)
        frame = [[_viewsRect objectAtIndex:index] CGRectValue];
    return frame;
}

// returns nil if cell is not visible or index is out of range
- (UIView *)viewWithIndex:(NSInteger)index
{
    if ([_visibleViewsIndexes containsObject:[NSNumber numberWithUnsignedLong:index]])
        return [_visibleViews objectForKey:[NSNumber numberWithInteger:index]];
    return nil;
}

- (NSArray *)visibleViews
{
    return [NSArray arrayWithArray:[_visibleViews allValues]];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger lastVisibleRowIndex  = -1;
    NSInteger firstVisibleRowIndex = [self.dataSource extendedScrollViewNumberOfItems:self];
    for (NSInteger i = 0; i < [_visibleViewsIndexes count]; i++) {
        NSInteger value = [[_visibleViewsIndexes objectAtIndex:i] integerValue];
        // First is minimal index
        if (value < firstVisibleRowIndex)
            firstVisibleRowIndex = value;
        // Last is maximal index taken from indexes array
        if (value > lastVisibleRowIndex)
            lastVisibleRowIndex = value;
    }
    // Now get the frames
    CGRect lastVisibleFrame  = [self rectForViewWithIndex:lastVisibleRowIndex];
    CGRect firstVisibleFrame = [self rectForViewWithIndex:firstVisibleRowIndex];
    NSInteger direction = scrollView.contentOffset.y - _lastContentOffset.y;
    // Check scrolling to bottom
    if (direction > 0)
    {
        // Add new item to the bottom
        if (scrollView.contentOffset.y >= ((lastVisibleFrame.origin.y + lastVisibleFrame.size.height) - self.bounds.size.height)) {
            NSUInteger viewsCount = [self.dataSource extendedScrollViewNumberOfItems:self];
            if (lastVisibleRowIndex + 1 < viewsCount) {
                [self addViewsToRowNumber:lastVisibleRowIndex + 1];
            }
        }
        // But remove from top
        if (scrollView.contentOffset.y > (firstVisibleFrame.origin.y + firstVisibleFrame.size.height)) {
            [self removeViewsFromRowNumber:firstVisibleRowIndex];
        }
    }
    // Check scrolling to top
    else if (direction < 0 && scrollView.contentOffset.y >= 0)
    {
        if (scrollView.contentOffset.y == 0) {
            // We need to reload data when scoller returns to initial position too fast
            [self reloadData];
        } else {
            // Add again items to the top
            if (scrollView.contentOffset.y <= (firstVisibleFrame.origin.y + firstVisibleFrame.size.height) && firstVisibleRowIndex > 0) {
                [self addViewsToRowNumber:firstVisibleRowIndex - 1];
            }
            // But remove from the bottom
            NSInteger prevVisibleRowIndex = lastVisibleRowIndex - 1;
            if (prevVisibleRowIndex) {
                CGRect prevVisibleFrame = [self rectForViewWithIndex:prevVisibleRowIndex];
                if (scrollView.contentOffset.y < ((prevVisibleFrame.origin.y + prevVisibleFrame.size.height) - self.bounds.size.height)) {
                    [self removeViewsFromRowNumber:lastVisibleRowIndex];
                }
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

#pragma mark Single view operations

- (void)addSingleViewWithIndex:(NSInteger)index
{
    NSNumber *nIndex = [NSNumber numberWithUnsignedLong:index];
    if ([_visibleViewsIndexes containsObject:nIndex]) {
        return;
    }
    UIView *viewToAdd = [self.dataSource extendedScrollView:self viewForItem:index];
    [viewToAdd setFrame:[self rectForViewWithIndex:index]];
    [self addSubview:viewToAdd];
    [_visibleViewsIndexes addObject:nIndex];
    [_visibleViews setObject:viewToAdd forKey:nIndex];
}

- (void)removeSingleViewWithIndex:(NSInteger)index
{
    UIView *viewToRemove = [self viewWithIndex:index];
    [viewToRemove removeFromSuperview];
    [_visibleViewsIndexes removeObject:[NSNumber numberWithUnsignedLong:index]];
    [_visibleViews removeObjectsForKeys:[NSArray arrayWithObject:[NSNumber numberWithInteger:index]]];
}

#pragma mark Row operations

- (void)addViewsToRowNumber:(NSInteger)number
{
    NSUInteger columnsCount = 1;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(extendedScrollViewNumberOfColumns:)]) {
        columnsCount = [self.dataSource extendedScrollViewNumberOfColumns:self];
    }
    for (NSInteger i = 0; i < columnsCount; i++) {
        [self addSingleViewWithIndex:number + i];
    }
}

- (void)removeViewsFromRowNumber:(NSInteger)number
{
    NSUInteger columnsCount = 1;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(extendedScrollViewNumberOfColumns:)]) {
        columnsCount = [self.dataSource extendedScrollViewNumberOfColumns:self];
    }
    for (NSInteger i = 0; i < columnsCount; i++) {
        [self removeSingleViewWithIndex:number + i];
    }
}

@end
