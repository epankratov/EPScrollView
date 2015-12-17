//
//  EPScrollView.h
//  EPScrollView
//
//  Created by Eugene Pankratov on 30.03.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EPScrollViewDataSource;
@protocol EPScrollViewDelegate;

@interface EPScrollView : UIScrollView <UIScrollViewDelegate> {

}

@property (nonatomic, weak) id <EPScrollViewDataSource> dataSource;
@property (nonatomic, weak) id <EPScrollViewDelegate> scrollDelegate;
@property (nonatomic) CGFloat itemHeight;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)reloadData;
- (void)updateData;
- (CGRect)rectForViewWithIndex:(NSInteger)index;
// returns nil if cell is not visible or index path is out of range
- (UIView *)viewWithIndex:(NSInteger)index;
- (NSArray *)visibleViews;
- (NSInteger)firstVisible;
- (NSInteger)lastVisible;
- (NSInteger)rowPosition;

@end

@protocol EPScrollViewDataSource <NSObject>

@required

- (NSUInteger)extendedScrollViewNumberOfItems:(EPScrollView *)scrollView;
- (UIView *)extendedScrollView:(EPScrollView *)scrollView viewForItem:(NSInteger)index;

@optional

- (NSUInteger)extendedScrollViewNumberOfColumns:(EPScrollView *)scrollView;
- (NSUInteger)extendedScrollView:(EPScrollView *)scrollView heightForItem:(NSInteger)index;

@end

@protocol EPScrollViewDelegate <NSObject>

@optional

- (void)extendedScrollViewDidReloadData:(EPScrollView *)scrollView;
- (void)extendedScrollViewDidBeginScroll:(EPScrollView *)scrollView;
- (void)extendedScrollViewDidEndScroll:(EPScrollView *)scrollView;
- (void)extendedScrollViewDidScrollForward:(EPScrollView *)scrollView;
- (void)extendedScrollViewDidScrollBackward:(EPScrollView *)scrollView;

@end
