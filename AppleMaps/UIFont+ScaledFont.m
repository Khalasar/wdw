//
//  UIFont+ScaledFont.m
//  WegDesWandels
//
//  Created by Andre St on 05.09.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "UIFont+ScaledFont.h"

@implementation UIFont (ScaledFont)

+ (UIFont *)myPreferredFontForTextStyle:(NSString *)style scale:(CGFloat)scaleFactor
{
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:style];
    CGFloat pointSize = descriptor.pointSize * scaleFactor;
    UIFont *font = [UIFont fontWithDescriptor:descriptor size:pointSize];
    return font;
}

@end
