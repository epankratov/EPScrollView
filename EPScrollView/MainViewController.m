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

- (void)handleTapOnNavbar;
- (IBAction)rightButtonTap:(id)sender;

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
    self.view.backgroundColor = [UIColor commonGrayColor];

    // Exclude bounds of the navigation bar
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }

    // Customize navigation bar
    [self.navigationItem setTitle:@"Extended scroll view"];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor commonGrayColor], UITextAttributeTextColor,
                                               [UIColor navigationButtonsColor], UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTranslucent:NO];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor navigationBarTintColor]];
    }
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setTintColor:)]) {
        [self.navigationController.navigationBar setTintColor:[UIColor navigationButtonsColor]];
    }
    // Add gesture recognizer
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnNavbar)];
    gestureRecognizer.numberOfTapsRequired = 1;
    [self.navigationController.navigationBar addGestureRecognizer:gestureRecognizer];
    // Set navigation buttons
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rightButtonTap:)];
    self.navigationItem.rightBarButtonItem = rightButton;

    // Do any additional setup after loading the view, typically from a nib.
    [self.scrollView setDataSource:self];
    [self.scrollView setScrollDelegate:self];
    [self.scrollView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [self.scrollView setFrame:self.view.bounds];
}

#pragma mark - Rotation support

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger orientation = isPad() ? UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown : UIInterfaceOrientationMaskPortrait;
    return orientation;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
}

#pragma mark - User interactions

- (void)handleTapOnNavbar
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (IBAction)rightButtonTap:(id)sender
{
    [[DataFabric sharedInstance] emptyItems];
    [[DataFabric sharedInstance] createNewItems];
    [self.scrollView reloadData];
}

#pragma mark - EPScrollViewDataSource methods

- (NSUInteger)extendedScrollViewNumberOfItems:(EPScrollView *)scrollView
{
    return [[DataFabric sharedInstance] availabelItems].count;
}

- (NSUInteger)extendedScrollView:(EPScrollView *)scrollView heightForItem:(NSInteger)index
{
    // For instance, we could use different heights for each item, something like this: 380 + index * 10
    return isPad() ? 400 : 380;
}

- (NSUInteger)extendedScrollViewNumberOfColumns:(EPScrollView *)scrollView
{
    return isPad() ? 2 : 1;
}

- (UIView *)extendedScrollView:(EPScrollView *)scrollView viewForItem:(NSInteger)index
{
    DataItem *item = [[[DataFabric sharedInstance] availabelItems] objectAtIndex:index];
    ItemView *view = [[ItemView alloc] initWithDataItem:item];
    return view;
}

#pragma mark - EPScrollViewDelegate methods

- (void)extendedScrollViewDidScrollForward:(EPScrollView *)scrollView
{
    VLog(@"Scroll view has scrolled forward: first item is %ld; last item it %ld", (long)[scrollView firstVisible], (long)[scrollView lastVisible]);
}

- (void)extendedScrollViewDidScrollBackward:(EPScrollView *)scrollView
{
    VLog(@"Scroll view has scrolled backward: first item is %ld; last item it %ld", (long)[scrollView firstVisible], (long)[scrollView lastVisible]);
}

@end
