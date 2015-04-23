//
//  DataFabric.h
//  EPScrollView
//
//  Created by Eugene Pankratov on 23.04.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataFabric : NSObject {

}

+ (DataFabric *)sharedInstance;
- (void)createNewItems;
- (NSArray *)availabelItems;

@end
