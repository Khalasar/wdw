//
//  ImageCell.m
//  WegDesWandels
//
//  Created by Andre St on 06.08.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "ImageCell.h"

@interface ImageCell ()
@end

@implementation ImageCell

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //we create the UIImageView in this overwritten init so that we always have it at hand.
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        if ( IPAD ) {
            self.imageView.frame = CGRectMake(0, 0, 350, 250);
        }else{
            self.imageView.frame = CGRectMake(0, 0, 150, 100);
        }
        //[self.imageView.layer setBorderColor:[[UIColor colorWithWhite:1 alpha:0.5f] CGColor]];
        //[self.imageView.layer setBorderWidth:2.0];
        
        //set specs and special wants for the imageView here.
        [self addSubview: self.imageView]; //the only place we want to do this addSubview: is here!
        
        //You wanted the imageView to react to touches and gestures. We can do that here too.
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
