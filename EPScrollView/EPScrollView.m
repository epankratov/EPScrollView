//
//  EPScrollView.m
//  EPScrollView
//
//  Created by Eugene Pankratov on 30.03.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import "EPScrollView.h"

const CGFloat _defaultItemHeight    = 380;
const CGFloat _defaultCapacity      = 10;

@interface EPScrollView () {
    NSMutableArray *_visibleViews;
    NSMutableArray *_visibleViewsIndexes;
}

@end

@implementation EPScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _visibleViews        = [[NSMutableArray alloc] initWithCapacity:_defaultCapacity];
        _visibleViewsIndexes = [[NSMutableArray alloc] initWithCapacity:_defaultCapacity];
        [self setBackgroundColor:[UIColor clearColor]];
        self.delegate = self;
    }
    return self;
}

- (void)reloadData
{
    if (self.dataSource) {
        NSUInteger viewsCount = [self.dataSource extendedScrollViewNumberOfItems:self];
        // Do something here
        for (NSUInteger i = 0; i < viewsCount; i++) {
            UIView *viewToAdd = [self.dataSource extendedScrollView:self viewForItem:i];
            [viewToAdd setFrame:[self rectForViewAtIndex:i]];
            [self addSubview:viewToAdd];
            [_visibleViewsIndexes addObject:[NSNumber numberWithUnsignedLong:i]];
        }
        self.contentSize = CGSizeMake(self.bounds.size.width, _defaultItemHeight * viewsCount);
    }
}

- (CGRect)rectForViewAtIndex:(NSInteger)index
{
    CGFloat itemHeight = _defaultItemHeight;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(extendedScrollView:heightForItem:)]) {
        itemHeight = [self.dataSource extendedScrollView:self heightForItem:index];
    }
    CGRect frame = CGRectMake(0, index * itemHeight, self.bounds.size.width, itemHeight);
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
    NSLog(@"The view has scrolled");
}

@end
