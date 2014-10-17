//
//  GalleryViewController.m
//  WegDesWandels
//
//  Created by Andre St on 05.09.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "GalleryViewController.h"
#import "GalleryCell.h"
#import "MCLocalization.h"
#import "UIFont+ScaledFont.h"
#import "Helper.h"

@interface GalleryViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) int currentIndex;
@property (strong, nonatomic)UIButton *backButton;
@property (nonatomic) CGFloat scaleLevel;
@end

@implementation GalleryViewController

@synthesize backButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerClass:[GalleryCell class] forCellWithReuseIdentifier:@"placeCollectionCell"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [self addBackButton];
    
    // add tap gesture recognizer to show and hide back button
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(showHideBackBtn:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self performSelector:@selector(showHideBackBtn:) withObject:nil afterDelay:2];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (_firstCall) {
        [self.collectionView scrollToItemAtIndexPath:_tappedImage atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        _firstCall = NO;
    }
}

-(void)showHideBackBtn:(id) sender
{
    if (backButton.alpha == 0) {
        
        [UIView animateWithDuration:0.5f
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             backButton.alpha = 1.0;
                         }
                         completion:nil
         ];
        
        //backButton.hidden = NO;
    }else{
        
        [UIView animateWithDuration:0.5f
                                 delay: 0
                               options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             backButton.alpha = 0.0;
                         }
                           completion:nil
         ];
    }
}

-(void) addBackButton
{
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:backButton];
    
    [backButton setTitle:[MCLocalization stringForKey:@"backBtn"] forState:UIControlStateNormal];
    [backButton setContentEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    //[backButton setFrame:cgrectm  CGRectMake(0, 0, 100, 100)];
    [backButton sizeToFit];
    backButton.titleLabel.numberOfLines = 1;
    backButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    backButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    backButton.center = CGPointMake(self.view.bounds.size.width - 50, 50);
    backButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    backButton.layer.borderWidth = 1.0f;
    backButton.layer.borderColor = [[UIColor whiteColor]CGColor];
    backButton.layer.cornerRadius = 7.0f;
    [backButton addTarget:self
                   action:@selector(goBack:)
         forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleBody scale:self.scaleLevel];
    [backButton setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor grayColor]
                     forState:UIControlStateHighlighted];
}

-(void) goBack:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return self.pageImages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GalleryCell *myCell = [collectionView
                           dequeueReusableCellWithReuseIdentifier:@"placeCollectionCell"
                           forIndexPath:indexPath];
    
    UIImage *image;
    long row = [indexPath row];
    
    image = self.pageImages[row];
    [myCell updateCellWithImage:image andCaption: self.imageCaptions[[indexPath row]]];
    
    return myCell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.frame.size;
}

#pragma mark - device rotation

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.collectionView setAlpha:0.0f];
    [backButton setAlpha:0.0f];
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    CGPoint currentOffset = [self.collectionView contentOffset];
    self.currentIndex = currentOffset.x / self.collectionView.frame.size.width;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    // Force realignment of cell being displayed
    CGSize currentSize = self.collectionView.bounds.size;
    float offset = self.currentIndex * currentSize.width;
    [self.collectionView setContentOffset:CGPointMake(offset, 0)];
    
    backButton.center = CGPointMake(self.view.bounds.size.width - 50, 50);
    
    // Fade the collectionView back in
    [UIView animateWithDuration:0.125f animations:^{
        [self.collectionView setAlpha:1.0f];
        [backButton setAlpha:1.0f];
    }];
    
}

- (CGFloat)scaleLevel
{
    return [Helper getScaleLevel];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
