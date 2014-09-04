//
//  PlaceViewController.m
//  WegDesWandels
//
//  Created by Andre St on 18.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "PlaceViewController.h"
#import "MapViewController.h"
#import "PhotoGalleryViewController.h"
#import "ImageCell.h"
#import "MCLocalization.h"
#import "FXBlurView.h"
#import "Helper.h"

@interface PlaceViewController ()
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UILabel *headline;
@property (weak, nonatomic) IBOutlet UIButton *showOnMapButton;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollection;
@property (strong, nonatomic)PhotoGalleryViewController *photoVC;
// for images
@property (nonatomic, strong) NSArray *pageImages;
@property (strong, nonatomic)UIImageView *backgroundImageView;
@property (strong, nonatomic)FXBlurView *blurView;
@end

@implementation PlaceViewController

@synthesize pageImages = _pageImages;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // localize
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localize)
                                                 name:MCLocalizationLanguageDidChangeNotification
                                               object:nil];
    [self localize];
    
    // for scrolling images
    self.pageImages = [self.place loadImages];
    
    [self addBackgroundImageView];
    [self.view.subviews setValue:@YES forKey:@"hidden"];
    [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"placeCollectionCell"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.view sendSubviewToBack:self.backgroundImageView];
    [self.view sendSubviewToBack:self.blurView];
    
    [self.view.subviews setValue:@NO forKey:@"hidden"];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredFontsChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view.subviews setValue:@YES forKey:@"hidden"];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateLayout];
}

- (void)updateLayout
{
    self.backgroundImageView.frame = self.view.bounds;
    self.blurView.frame = self.backgroundImageView.bounds;
    UIView *shadowView = [self.view viewWithTag:1];
    shadowView.frame = self.backgroundImageView.bounds;
}

- (void) addBackgroundImageView
{
    self.backgroundImageView = [[UIImageView alloc] initWithImage:self.pageImages.firstObject];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.backgroundImageView setFrame:self.view.bounds];
    [self.view addSubview: self.backgroundImageView];
    
    self.blurView = [Helper createAndShowBlurView:self.backgroundImageView];
}

-(void)preferredFontsChanged:(NSNotification *)notification
{
    [self usePreferredFonts];
}

-(void)usePreferredFonts
{
    self.body.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.headline.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"mapButtonPressed"]) {
        if ([segue.destinationViewController isKindOfClass:[MapViewController class]]) {
            MapViewController *mvc = [segue destinationViewController];
            mvc.place = self.place;
        }
    }
}

#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pageImages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *myCell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:@"placeCollectionCell"
                                    forIndexPath:indexPath];
    
    UIImage *image;
    long row = [indexPath row];
    
    image = self.pageImages[row];
    myCell.imageView.image = image;
    
    // add Tap Gesture Recognizer to show bigger image
    UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onButtonTapped:)];
    [tap setNumberOfTapsRequired:1];
    [myCell addGestureRecognizer:tap];
    
    
    return myCell;
}

#pragma mark - Collection View Tap
-(void)onButtonTapped:(id)sender
{
    ImageCell *tappedCell = (ImageCell *)[(UITapGestureRecognizer *) sender view];
    
    self.photoVC = [[PhotoGalleryViewController alloc] init];
    self.photoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"photoVC"];
    self.photoVC.pageImages = self.pageImages;
    self.photoVC.tappedImage = tappedCell.imageView.image;
    
    [[self navigationController] pushViewController:self.photoVC animated:YES];
    
    //the response to the gesture.
    //mind that this is done in the cell. If you don't want things to happen from this cell.
    //then you can still activate this the way you did in your question.
    
}

#pragma mark - localize method

- (void)localize
{
    _nameLabel.text = [MCLocalization stringForKey:self.place.title];
    _body.text = [self.place loadBodyText];
}
@end
