//
//  MainViewController.m
//  EPScrollView
//
//  Created by Eugene Pankratov on 30.03.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController () {
    NSArray *_items;
}

@end

@implementation MainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _items = [NSArray arrayWithObjects:@"Item0", @"Item1", @"Item2", @"Item3", @"Item4", @"Item5", @"Item6", @"Item7", @"Item8", @"Item9", @"Item10", nil];
    [self.scrollView setDataSource:self];
    // Do any additional setup after loading the view, typically from a nib.
    [self.scrollView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [self.scrollView setFrame:self.view.bounds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)extendedScrollViewNumberOfItems:(EPScrollView *)scrollView
{
    return _items.count;
}

- (UIView *)extendedScrollView:(EPScrollView *)scrollView viewForItem:(NSInteger)index
{
    ItemView *view = [[ItemView alloc] initWithTitle:[_items objectAtIndex:index] andAdditionalTitle:[_items objectAtIndex:index]];
    view.layer.borderColor = [UIColor greenColor].CGColor;
    view.layer.borderWidth = 1.0;
    return view;
}

@end
