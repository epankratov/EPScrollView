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
    NSArray *_movieOrigins;
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
    NSInteger count = arc4random() % 46 + 5;
    for (NSInteger i = 0; i < count; i++) {
        DataItem *item = [[DataItem alloc] initWithNumber:i];
        NSInteger count = _movieOrigins.count == 0 ? 10 : _movieOrigins.count;
        NSInteger number = arc4random() % count;
        item.imageOrigin = [_movieOrigins objectAtIndex:number];
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
        _movieOrigins = [[NSArray alloc] initWithObjects:@"1056-12565-000",
                         @"1056-12631-000",
                         @"1056-12622-000",
                         @"1056-12620-000",
                         @"1056-10216-000",
                         @"1050-10403-000",
                         @"1050-10528-000",
                         @"1056-10203-000",
                         @"1051-10129-000",
                         @"1056-12743-000",
                         @"1050-10456-000",
                         @"1140-12792-000",
                         @"1056-12739-000",
                         @"1050-10511-000",
                         @"1056-12680-000",
                         @"1140-11803-000",
                         nil];
        [self createNewItems];
    }
    return self;
}

@end
