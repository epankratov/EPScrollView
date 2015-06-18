//
//  DataItem.h
//  EPScrollView
//
//  Created by Eugene Pankratov on 23.04.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataItem : NSObject {

}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *additionalTitle;
@property (nonatomic, strong) NSString *synopsis;
@property (nonatomic, strong) NSString *imageOrigin;

- (instancetype)initWithNumber:(NSInteger)number;

@end
