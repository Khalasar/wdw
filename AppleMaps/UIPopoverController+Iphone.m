//
//  UIPopoverController+Iphone.m
//  WegDesWandels
//
//  Created by Andre St on 11.09.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "UIPopoverController+Iphone.h"

@implementation UIPopoverController (overrides)
    + (BOOL)_popoversDisabled
    {
        return NO;
    }
@end
