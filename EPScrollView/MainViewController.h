//
//  MainViewController.h
//  EPScrollView
//
//  Created by Eugene Pankratov on 30.03.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPScrollView.h"
#import "ItemView.h"

@interface MainViewController : UIViewController <EPScrollViewDataSource> {

}

@property (nonatomic, strong) IBOutlet EPScrollView *scrollView;

@end
