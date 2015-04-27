//
//  UIImage+Extra.h
//  EPScrollView
//
//  Created by Eugene Pankratov on 27.04.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat kAnimationDuration;

@interface UIImage (Extra)

- (void)crossFadeToImageView:(UIImageView *)imageView;

@end
