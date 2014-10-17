//
//  PlaceViewController.m
//  WegDesWandels
//
//  Created by Andre St on 18.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "PlaceViewController.h"
#import "MapViewController.h"
#import "GalleryViewController.h"
#import "ImageCell.h"
#import "MCLocalization.h"
#import "FXBlurView.h"
#import "Helper.h"
#import "UIFont+ScaledFont.h"

@interface PlaceViewController ()
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UILabel *headline;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showOnMapBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollection;
@property (strong, nonatomic)GalleryViewController *photoVC;
// for images
@property (nonatomic, strong) NSArray *pageImages;
@property (strong, nonatomic)UIImageView *backgroundImageView;
@property (strong, nonatomic)FXBlurView *blurView;
@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@property (strong, nonatomic)NSUserDefaults *userDefaults;
@property (weak, nonatomic) IBOutlet UIButton *playSoundBtn;
@property (nonatomic)BOOL audioGuide;
@end

@implementation PlaceViewController

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@synthesize pageImages = _pageImages;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init standard user defaults
    self.userDefaults = [NSUserDefaults standardUserDefaults];
                         
    // loadg images for collection view
    self.pageImages = [self.place loadImages];
    [self addBackgroundImageView];
    //self.tabBarController.delegate = self;
    
    self.body.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view.subviews setValue:@YES forKey:@"hidden"];
    [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"placeCollectionCell"];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localize)
                                                 name:MCLocalizationLanguageDidChangeNotification
                                               object:nil];
    [self localize];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        [self.playSoundBtn setImage:[UIImage imageNamed:@"volume-high-out"] forState:UIControlStateNormal];
    }

    // hide all subviews for a better disappear look
    [self.view.subviews setValue:@YES forKey:@"hidden"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self usePreferredFonts];
    [self.view.subviews setValue:@NO forKey:@"hidden"];
    
    if (self.audioGuide && self.playSound) {
        [self toggleAudio:self.playSoundBtn];
        self.playSound = NO;
    }
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.view sendSubviewToBack:self.backgroundImageView];
    [self.view sendSubviewToBack:self.blurView];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //[self showTabBar: self.tabBarController];
    
    [self updateLayout];
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

#pragma mark - design/layout changed

- (void)updateLayout
{
    self.backgroundImageView.frame = self.view.bounds;
    self.blurView.frame = self.backgroundImageView.bounds;
    UIView *shadowView = [self.view viewWithTag:1];
    shadowView.frame = self.backgroundImageView.bounds;
    
    self.body.contentInset = UIEdgeInsetsMake(-10, -5, 0, 0);
}

- (void) addBackgroundImageView
{
    self.backgroundImageView = [[UIImageView alloc] initWithImage:self.pageImages.firstObject];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.backgroundImageView setFrame:self.view.bounds];
    [self.view addSubview: self.backgroundImageView];
    
    self.blurView = [Helper createAndShowBlurView:self.backgroundImageView];
}

#pragma mark - fonts methods

-(void)preferredFontsChanged:(NSNotification *)notification
{
    [self usePreferredFonts];
}

-(void)usePreferredFonts
{
    self.body.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleBody scale:[Helper getScaleLevel]];
    self.headline.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:[Helper getScaleLevel]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:[Helper getScaleLevel]]
       }
     forState:UIControlStateNormal];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:[Helper getScaleLevel]],
      NSFontAttributeName, nil]];
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
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell: tappedCell];
    
    self.photoVC = [[GalleryViewController alloc] init];
    self.photoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"galleryVC"];
    self.photoVC.pageImages = self.pageImages;
    self.photoVC.tappedImage = indexPath;
    self.photoVC.imageCaptions = [self.place loadCaptions];
    self.photoVC.firstCall = YES;
    // present
    [self presentViewController:self.photoVC animated:YES completion:nil];
}

#pragma mark - localize method
//TODO LOCALIZE BUTTON
- (void)localize
{
    _body.text = [self.place loadBodyText];
    if (IPAD) {
        self.title = self.place.title;
    }else{
        self.headline.text = self.place.title;
    }
    self.showOnMapBtn.title = [MCLocalization stringForKey:@"onMapBtn"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[MCLocalization stringForKey:@"backBtn"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

- (void)showTabBar:(UITabBarController *)tabbarcontroller
{
    tabbarcontroller.tabBar.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        for (UIView *view in tabbarcontroller.view.subviews) {
            if ([view isKindOfClass:[UITabBar class]]) {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y-49.f, view.frame.size.width, view.frame.size.height)];
            }
            else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height-49.f)];
            }
        }
    } completion:^(BOOL finished) {
        //do smth after animation finishes
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            // iOS 7
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        } else {
            // iOS 6
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        }
    }];
}

#pragma mark - sound methods

- (IBAction)toggleAudio:(UIButton *)sender {
    
    if (self.speechSynthesizer.paused) {
        NSLog(@"paused");
        [self.speechSynthesizer continueSpeaking];
        [sender setImage:[UIImage imageNamed:@"volume-high-on"] forState:UIControlStateNormal];
    }else if (self.speechSynthesizer.speaking) {
        NSLog(@"speaking");
        [self.speechSynthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        [sender setImage:[UIImage imageNamed:@"volume-high-out"] forState:UIControlStateNormal];
    }else {
        NSLog(@"new");
        NSString *currentLang = [[NSString alloc] initWithString:[self.userDefaults stringForKey:@"currentLang"]];
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString: self.body.text];
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:currentLang];
        NSLog(@"av lang %@", utterance.voice);
        //utterance.pitchMultiplier = 0.5f;
        utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
        utterance.preUtteranceDelay = 0.2f;
        utterance.postUtteranceDelay = 0.2f;
        
        [self.speechSynthesizer speakUtterance:utterance];
        
        [sender setImage:[UIImage imageNamed:@"volume-high-on"] forState:UIControlStateNormal];
    }
    
}

-(AVSpeechSynthesizer *)speechSynthesizer
{
    if (!_speechSynthesizer) {
        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return _speechSynthesizer;
}

-(BOOL)audioGuide
{
    if ([self.userDefaults objectForKey:@"audioGuide"]){
         return [self.userDefaults boolForKey:@"audioGuide"];
    }
    return false;
}

#pragma mark - tabbar delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"tabbar: %@", viewController.class);
}

@end
