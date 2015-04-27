//
//  DataFabric.m
//  EPScrollView
//
//  Created by Eugene Pankratov on 23.04.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import "DataFabric.h"
#import "DataItem.h"

static DataFabric *_fabricInstance;

@interface DataFabric () {
    NSMutableArray *_availableItems;
    NSArray *_imageURLs;
}

- (instancetype)init;

@end

@implementation DataFabric

+ (DataFabric *)sharedInstance
{
    @synchronized(self)
    {
        if (_fabricInstance == nil) {
            _fabricInstance = [[DataFabric alloc] init];
        }
    }
    return _fabricInstance;
}

- (void)createNewItems
{
    NSInteger count = arc4random() % 5 + 5;
    for (NSInteger i = 0; i < count; i++) {
        DataItem *item = [[DataItem alloc] initWithNumber:i];
        NSInteger number = arc4random() % 10;
        item.imageURL = [_imageURLs objectAtIndex:number];
        [_availableItems addObject:item];
    }
}

- (void)emptyItems
{
    [_availableItems removeAllObjects];
}

- (NSArray *)availabelItems
{
    return (NSArray *)_availableItems;
}

#pragma mark - Private methods

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _availableItems = [[NSMutableArray alloc] init];
        _imageURLs = [[NSArray alloc] initWithObjects:@"http://image.api.viewster.com/movies/1056-12724-000/image?width=%lu&height=%lu",
                      @"http://image.api.viewster.com/movies/1056-12631-000/image?width=%lu&height=%lu",
                      @"http://image.api.viewster.com/movies/1056-10212-000/image?width=%lu&height=%lu",
                      @"http://image.api.viewster.com/movies/1112-13333-000/image?width=%lu&height=%lu",
                      @"http://image.api.viewster.com/movies/1056-10229-000/image?width=%lu&height=%lu",
                      @"http://image.api.viewster.com/movies/1056-10208-000/image?width=%lu&height=%lu",
                      @"http://image.api.viewster.com/movies/1056-12750-000/image?width=%lu&height=%lu",
                      @"http://image.api.viewster.com/movies/1056-10229-000/image?width=%lu&height=%lu",
                      @"http://image.api.viewster.com/movies/1056-12686-000/image?width=%lu&height=%lu",
                      @"http://image.api.viewster.com/movies/1056-12567-000/image?width=%lu&height=%lu",
                      nil];
        [self createNewItems];
    }
    return self;
}

@end
