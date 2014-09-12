//
//  MyLabel.m
//  WegDesWandels
//
//  Created by Andre St on 11.09.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "MyLabel.h"

@implementation MyLabel

@synthesize topInset, bottomInset, leftInset, rightInset;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIEdgeInsets insets = {self.topInset, self.leftInset,
        self.bottomInset, self.rightInset};
    
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}


@end
