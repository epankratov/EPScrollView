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
    NSInteger count = arc4random() % 10;
    for (NSInteger i = 0; i < count; i++) {
        DataItem *item = [[DataItem alloc] initWithNumber:i];
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
        [self createNewItems];
    }
    return self;
}

@end
