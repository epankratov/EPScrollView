//
//  MainViewController.m
//  EPScrollView
//
//  Created by Eugene Pankratov on 30.03.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import "MainViewController.h"
#import "Global.h"
#import "DataItem.h"
#import "DataFabric.h"

@interface MainViewController () {
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
    [self.scrollView setDataSource:self];
    self.view.backgroundColor = [UIColor commonGrayColor];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor navigationBarTintColor]];
    }
    else if ([self.navigationController.navigationBar respondsToSelector:@selector(setTintColor:)]) {
        [self.navigationController.navigationBar setTintColor:[UIColor navigationBarTintColor]];
    }

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
    return [[DataFabric sharedInstance] availabelItems].count;
}

- (NSUInteger)extendedScrollView:(EPScrollView *)scrollView heightForItem:(NSInteger)index
{
    return 380 + index * 10;
}

- (UIView *)extendedScrollView:(EPScrollView *)scrollView viewForItem:(NSInteger)index
{
    DataItem *item = [[[DataFabric sharedInstance] availabelItems] objectAtIndex:index];
    ItemView *view = [[ItemView alloc] initWithTitle:item.title andAdditionalTitle:item.additionalTitle andSynopsis:item.synopsis];
    return view;
}

@end
