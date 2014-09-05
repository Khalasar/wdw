//
//  UIFont+ScaledFont.h
//  WegDesWandels
//
//  Created by Andre St on 05.09.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (ScaledFont)

+ (UIFont *)myPreferredFontForTextStyle:(NSString *)style scale:(CGFloat)scaleFactor;

@end
