//
//  GalleryCell.m
//  WegDesWandels
//
//  Created by Andre St on 05.09.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "GalleryCell.h"
#import "MyLabel.h"
#import "MCLocalization.h"
#import "Helper.h"
#import "UIFont+ScaledFont.h"

@interface GalleryCell()
@property (weak, nonatomic) IBOutlet MyLabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *captionBackground;
@property (nonatomic) CGFloat scaleLevel;
@end

@implementation GalleryCell

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
        
        self.captionBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    }
    
    return self;
}

-(void)updateCellWithImage:(UIImage *)image andCaption:(NSString *)caption
{
    self.scaleLevel = [Helper getScaleLevel];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView setImage:image];
    self.captionLabel.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleBody scale:self.scaleLevel];
    self.captionLabel.text = caption;// [MCLocalization stringForKey:caption];
}


@end
