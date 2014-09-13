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
@property (nonatomic) float originalH;
@property (nonatomic) float originalY;
@end

@implementation GalleryCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"GalleryCelliPad"
                                                              owner:self
                                                            options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
        self.captionBackground.backgroundColor = [UIColor colorWithRed:0
                                                                 green:0
                                                                  blue:0
                                                                 alpha:0.5f];

        self.originalH = self.captionBackground.bounds.size.height;
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
    
    self.captionBackground.frame = CGRectMake(self.captionBackground.frame.origin.x, self.bounds.size.height - self.originalH, self.captionBackground.bounds.size.width, self.originalH);
    //[self performSelector:@selector(showHideBackBtn:)
    //           withObject:nil
    //           afterDelay:2];
}
- (IBAction)swipeUp:(UISwipeGestureRecognizer *)sender {
    [self showHideBackBtn:sender];
}

-(void)showHideBackBtn:(id) sender
{
    NSLog(@"here");
    if (self.captionBackground.bounds.size.height == 0) {
        [UIView animateWithDuration:0.5f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.captionBackground.frame =
                             CGRectMake(self.captionBackground.frame.origin.x,
                                        (self.bounds.size.height - self.originalH),
                                        self.captionBackground.bounds.size.width,
                                        self.originalH);
                         }completion:^(BOOL finished) {
                             NSLog(@"Animation is complete");
                         }];
        
        //backButton.hidden = NO;
    }else{
        [UIView animateWithDuration:0.5f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.captionBackground.frame =
                             CGRectMake(self.captionBackground.frame.origin.x,
                                        self.bounds.size.height,
                                        self.captionBackground.bounds.size.width,
                                        0);
                         }completion:^(BOOL finished) {
                             NSLog(@"Animation is complete");
                         }];
    }
}

#pragma mark - UIGestureRecognizer Delgate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //NSLog(@"1:%@; 2%@", gestureRecognizer,otherGestureRecognizer);
    return YES;
}

@end
