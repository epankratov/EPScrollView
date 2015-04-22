//
//  UIColor+Extra.m
//  ViewsterGenres
//
//  Created by Eugene Pankratov on 11.03.14.
//  Copyright (c) 2014 Viewster.com. All rights reserved.
//

#import "UIColor+Extra.h"
#import "Global.h"

@implementation UIColor (Extra)

+ (UIColor *)mainBackgroundColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)barTintColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)genresYellowColor
{
    return RGBA_COLOR(245.0, 151.0, 25.0, 1.0);
}

+ (UIColor *)navigationBarTintColor
{
    return RGBA_COLOR(0, 0, 0, 0);
}

+ (UIColor *)splashLabelColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)mainLabelColor
{
    return RGBA_COLOR(21.0, 25.0, 36.0, 1.0);
}

+ (UIColor *)descriptionLabelColor
{
    return RGBA_COLOR(125.0, 128.0, 137.0, 1.0);
}

+ (UIColor *)headerBackgroundColor
{
    return RGBA_COLOR(219.0, 224.0, 228.0, 1.0);
}

+ (UIColor *)headerTextColor
{
    return RGBA_COLOR(82.0, 84.0, 86.0, 1.0);
}

+ (UIColor *)commonGrayColor
{
    return RGBA_COLOR(211.0, 214.0, 219.0, 1.0);
}

@end
