//
//  UILabel+Extra.m
//  ViewsterHorror
//
//  Created by Eugene Pankratov on 17.03.15.
//  Copyright (c) 2015 Viewster.com. All rights reserved.
//

#import "UILabel+Extra.h"

@implementation UILabel (Extra)

- (void)adjustFontSizeToFit
{
    UIFont *font = self.font;
    CGSize size = self.frame.size;
    CGFloat minimumFontSize = 10.0f;
    
    for (CGFloat maxSize = self.font.pointSize; maxSize >= minimumFontSize; maxSize -= 1.f)
    {
        font = [font fontWithSize:maxSize];
        CGSize constraintSize = CGSizeMake(size.width, MAXFLOAT);
        CGSize labelSize = [self.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByCharWrapping];
//        CGSize labelSize = [self.text boundingRectWithSize:constraintSize options: attributes: context:];

        if (labelSize.height <= size.height)
        {
            self.font = font;
            [self setNeedsLayout];
            break;
        }
    }
    // set the font to the minimum size anyway
    self.font = font;
    [self setNeedsLayout];
}

@end
