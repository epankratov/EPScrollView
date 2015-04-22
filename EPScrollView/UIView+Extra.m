//
//  UIView+Extra.m
//  ViewsterGenres
//
//  Created by Eugene Pankratov on 24.12.13.
//  Copyright (c) 2014 Viewster.com. All rights reserved.
//

#import "UIView+Extra.h"

@implementation UIView (Extra)

- (CGFloat)width
{
	return self.frame.size.width;
}

- (CGFloat)height
{
	return self.frame.size.height;
}

- (CGFloat)x
{
	return self.frame.origin.x;
}

- (CGFloat)y
{
	return self.frame.origin.y;
}

@end
