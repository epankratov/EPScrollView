//
//  ItemView.h
//  EPScrollView
//
//  Created by Eugene Pankratov on 03.04.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataItem.h"

@interface ItemView : UIView {

}

@property (nonatomic, strong) DataItem *dataItem;

- (instancetype)initWithDataItem:(DataItem *)item;

@end
