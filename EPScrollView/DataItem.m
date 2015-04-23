//
//  DataItem.m
//  EPScrollView
//
//  Created by Eugene Pankratov on 23.04.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import "DataItem.h"

@implementation DataItem

- (instancetype)initWithNumber:(NSInteger)number
{
    self = [super init];
    if (self) {
        self.title = [NSString stringWithFormat:@"Item #%lu", (unsigned long) number];
        self.additionalTitle = [NSString stringWithFormat:@"additional info #%lu", (unsigned long) number];
        self.synopsis = [NSString stringWithFormat:@"Here comes synopsis for the item #%lu. This might be very long description", (unsigned long) number];
    }
    return self;
}

@end
