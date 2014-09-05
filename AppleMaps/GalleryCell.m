//
//  GalleryCell.m
//  WegDesWandels
//
//  Created by Andre St on 05.09.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "GalleryCell.h"

@interface GalleryCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation GalleryCell

/*- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //we create the UIImageView in this overwritten init so that we always have it at hand.
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        self.imageView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
        [self.imageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.imageView.layer setBorderWidth:2.0];
        
        //set specs and special wants for the imageView here.
        [self addSubview: self.imageView]; //the only place we want to do this addSubview: is here!
        
        //You wanted the imageView to react to touches and gestures. We can do that here too.
        
    }
    return self;
}*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"GalleryCelliPad" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
    }
    
    return self;
}

-(void)updateCell:(UIImage *)image
{
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView setImage:image];
}


@end
