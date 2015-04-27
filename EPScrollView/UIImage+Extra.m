//
//  UIImage+Extra.m
//  EPScrollView
//
//  Created by Eugene Pankratov on 27.04.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import "UIImage+Extra.h"

const CGFloat kAnimationDuration = 0.75;

@implementation UIImage (Extra)

- (void)crossFadeToImageView:(UIImageView *)imageView
{
    CATransition *transition = [CATransition animation];
    transition.duration = kAnimationDuration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [imageView.layer addAnimation:transition forKey:nil];
    [imageView setImage:self];
}

@end
