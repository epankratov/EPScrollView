//
//  EPScrollView.h
//  EPScrollView
//
//  Created by Eugene Pankratov on 30.03.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EPScrollViewDataSource;
@protocol EPScrollViewDataSource;

@interface EPScrollView : UIScrollView <UIScrollViewDelegate> {

}

@property (nonatomic, assign) id <EPScrollViewDataSource> dataSource;
@property (nonatomic) CGFloat itemHeight;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)reloadData;
- (CGRect)rectForViewAtIndex:(NSInteger)index;
// returns nil if cell is not visible or index path is out of range
- (UIView *)itemViewForIndex:(NSInteger)index;
- (NSArray *)visibleViews;
- (NSArray *)visibleViewsIndexes;

@end

@protocol EPScrollViewDataSource <NSObject>

@required

- (NSUInteger)extendedScrollViewNumberOfItems:(EPScrollView *)scrollView;
- (UIView *)extendedScrollView:(EPScrollView *)scrollView viewForItem:(NSInteger)index;

@optional

- (NSUInteger)extendedScrollViewNumberOfColumns:(EPScrollView *)scrollView;
- (NSUInteger)extendedScrollView:(EPScrollView *)scrollView heightForItem:(NSInteger)index;

@end
