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
- (void)addViewsToRowStartingWithNumber:(NSInteger)number;
- (void)removeViewsFromRowStartingWithNumber:(NSInteger)number;
// Get from datasource columns count
- (NSInteger)columnsCount;

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
    _rowPosition = 0;
    // Cleanup internal data
    [_viewsRect removeAllObjects];
    [_visibleViews removeAllObjects];
    [_visibleViewsIndexes removeAllObjects];
    // Proceed only with valid datasource
    if (self.dataSource) {
        NSUInteger viewsCount = [self.dataSource extendedScrollViewNumberOfItems:self];
        NSUInteger columnsCount = [self columnsCount];
        NSUInteger visibleCount = 0;
        NSUInteger totalHeight = 0;
        NSUInteger currentColumn = 0;
        CGFloat width = self.bounds.size.width / columnsCount;
        // Calculate and store frames for each individual view
        for (NSUInteger i = 0; i < viewsCount; i++) {
            CGFloat height = [self heightForViewAtIndex:i];
            CGRect viewFrame = CGRectMake(width * currentColumn, totalHeight, width, height);
            if (totalHeight < self.bounds.size.height) {
                visibleCount++;
            }
            [_viewsRect addObject:[NSValue valueWithCGRect:viewFrame]];
            if (++currentColumn == columnsCount) {
                totalHeight += height;
                currentColumn = 0;
            } else if (i + 1 == viewsCount) {
                totalHeight += height;
            }
        }

        self.contentSize = CGSizeMake(self.bounds.size.width, totalHeight);
        // Add only views to visible row
        for (NSUInteger i = 0; i < visibleCount; i++) {
            [self addSingleViewWithIndex:i];
        }
    }
    if ([self.scrollDelegate respondsToSelector:@selector(extendedScrollViewDidReloadData:)])
        [self.scrollDelegate extendedScrollViewDidReloadData:self];
}

- (void)updateData
{
    // Cleanup internal data
    [_viewsRect removeAllObjects];
    // Proceed only with valid datasource
    if (self.dataSource) {
        NSUInteger viewsCount = [self.dataSource extendedScrollViewNumberOfItems:self];
        NSUInteger columnsCount = [self columnsCount];
        NSUInteger visibleCount = 0;
        NSUInteger totalHeight = 0;
        NSUInteger currentColumn = 0;
        CGFloat width = self.bounds.size.width / columnsCount;
        // Calculate and store frames for each individual view
        for (NSUInteger i = 0; i < viewsCount; i++) {
            CGFloat height = [self heightForViewAtIndex:i];
            CGRect viewFrame = CGRectMake(width * currentColumn, totalHeight, width, height);
            if (totalHeight < self.bounds.size.height) {
                visibleCount++;
            }
            [_viewsRect addObject:[NSValue valueWithCGRect:viewFrame]];
            if (++currentColumn == columnsCount) {
                totalHeight += height;
                currentColumn = 0;
            } else if (i + 1 == viewsCount) {
                totalHeight += height;
            }
        }
        
        self.contentSize = CGSizeMake(self.bounds.size.width, totalHeight);
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

- (NSInteger)firstVisible
{
    if ([_visibleViewsIndexes count] == 0)
        return 0;
    return [[_visibleViewsIndexes objectAtIndex:0] integerValue];
}

- (NSInteger)lastVisible
{
    if ([_visibleViewsIndexes count] == 0)
        return 0;
    return [[_visibleViewsIndexes objectAtIndex:[_visibleViewsIndexes count] - 1] integerValue];
}

- (NSInteger)rowPosition
{
    return _rowPosition;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger columnsCount = [self columnsCount];
    NSInteger lastVisibleItem  = [self lastVisible];
    NSInteger firstVisibleItem = [self firstVisible];
    // Now get the frames
    CGRect lastVisibleFrame  = [self rectForViewWithIndex:lastVisibleItem];
    CGRect firstVisibleFrame = [self rectForViewWithIndex:firstVisibleItem];
    NSInteger direction = scrollView.contentOffset.y - _lastContentOffset.y;
    // Check scrolling to bottom
    if (direction > 0)
    {
        // Add new item to the bottom
        if (scrollView.contentOffset.y >= ((lastVisibleFrame.origin.y + lastVisibleFrame.size.height) - self.bounds.size.height)) {
            NSUInteger viewsCount = [self.dataSource extendedScrollViewNumberOfItems:self];
            if (lastVisibleItem + 1 < viewsCount) {
                [self addViewsToRowStartingWithNumber:lastVisibleItem + 1];
                _rowPosition++;
                if (self.scrollDelegate && [self.scrollDelegate respondsToSelector:@selector(extendedScrollViewDidScrollForward:)]) {
                    [self.scrollDelegate extendedScrollViewDidScrollForward:self];
                }
            }
        }
        // But remove from top
        if (scrollView.contentOffset.y > (firstVisibleFrame.origin.y + firstVisibleFrame.size.height)) {
            [self removeViewsFromRowStartingWithNumber:firstVisibleItem];
            if (self.scrollDelegate && [self.scrollDelegate respondsToSelector:@selector(extendedScrollViewDidScrollForward:)]) {
                [self.scrollDelegate extendedScrollViewDidScrollForward:self];
            }
        }
    }
    // Check scrolling to the top
    else if (direction < 0 && scrollView.contentOffset.y >= 0)
    {
        if (scrollView.contentOffset.y == 0) {
            // We need to reload data when scoller returns to initial position too fast
            [self reloadData];
            // TODO: refactor this workaround
        } else {
            // Restore items at the top
            if (scrollView.contentOffset.y <= (firstVisibleFrame.origin.y + firstVisibleFrame.size.height) && firstVisibleItem - columnsCount >= 0) {
                [self addViewsToRowStartingWithNumber:firstVisibleItem - columnsCount];
            }
            // But remove hidden items from the bottom
            NSInteger deleteFromItemNumber = lastVisibleItem - columnsCount + 1;
            if (deleteFromItemNumber >= 0)
            {
                CGRect deleteItemWithFrame = [self rectForViewWithIndex:deleteFromItemNumber];
                if (scrollView.contentOffset.y  < (deleteItemWithFrame.origin.y - self.bounds.size.height)) {
                    [self removeViewsFromRowStartingWithNumber:deleteFromItemNumber];
                    _rowPosition--;
                    if (self.scrollDelegate && [self.scrollDelegate respondsToSelector:@selector(extendedScrollViewDidScrollBackward:)]) {
                        [self.scrollDelegate extendedScrollViewDidScrollBackward:self];
                    }
                }
            }
        }
    }
    _lastContentOffset = scrollView.contentOffset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.scrollDelegate && [self.scrollDelegate respondsToSelector:@selector(extendedScrollViewDidBeginScroll:)]) {
        [self.scrollDelegate extendedScrollViewDidBeginScroll:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollDelegate && [self.scrollDelegate respondsToSelector:@selector(extendedScrollViewDidEndScroll:)]) {
        [self.scrollDelegate extendedScrollViewDidEndScroll:self];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSInteger columnsCount = [self columnsCount];
    NSUInteger viewsCount = [self.dataSource extendedScrollViewNumberOfItems:self];
    NSInteger targetViewIndex = _rowPosition * columnsCount;
    CGFloat realVelocity = velocity.y * 60.0;
    // Update scroll position in forward direction
    if (realVelocity > 0) {
        NSInteger multiplier = 1;
        // Increase multiplier when scroll speed is very high for iPhone devices but do not forget about bounds
        if (realVelocity > 100 && (targetViewIndex + columnsCount * 2 < viewsCount) && isPhone())
            multiplier = 2;
        columnsCount *= multiplier;
        targetViewIndex += columnsCount;
    }
    // or in backward direction
    else if (realVelocity < 0) {
        if (isPhone())
            targetViewIndex = [self lastVisible] - 1;
        targetViewIndex -= columnsCount;
    }
    CGFloat targetHeight = [self rectForViewWithIndex:(int)targetViewIndex].origin.y;
    targetContentOffset->y = targetHeight;
}

// This method was used previously but it's not operating with variable item height
- (void)scrollViewWillEndDraggingOld:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat itemHeight = isPad() ? 400 : 380;
    CGFloat targetY = scrollView.contentOffset.y + velocity.y * 60.0;
    CGFloat targetIndex = round(targetY / itemHeight);
    if (velocity.y > 0) {
        targetIndex = ceil(targetY / itemHeight);
    } else {
        targetIndex = floor(targetY / itemHeight);
    }
    targetContentOffset->y = targetIndex * itemHeight;
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
    // Sort indexes, so we have always ascending order
    [_visibleViewsIndexes sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *a = obj1;
        NSNumber *b = obj2;
        if ([a integerValue] < [b integerValue])
            return NSOrderedAscending;
        if ([a integerValue] > [b integerValue])
            return NSOrderedDescending;
        return NSOrderedSame;
    }];
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

- (void)addViewsToRowStartingWithNumber:(NSInteger)number
{
    NSInteger columnsCount = [self columnsCount];
    for (NSInteger i = 0; i < columnsCount; i++) {
        NSUInteger viewsCount = [self.dataSource extendedScrollViewNumberOfItems:self];
        if (number + i < viewsCount) {
            [self addSingleViewWithIndex:number + i];
        }
    }
}

- (void)removeViewsFromRowStartingWithNumber:(NSInteger)number
{
    NSInteger columnsCount = [self columnsCount];
    for (NSInteger i = 0; i < columnsCount; i++) {
        [self removeSingleViewWithIndex:number + i];
    }
}

- (NSInteger)columnsCount
{
    NSInteger columnsCount = 1;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(extendedScrollViewNumberOfColumns:)]) {
        columnsCount = [self.dataSource extendedScrollViewNumberOfColumns:self];
    }
    return columnsCount;
}

@end
