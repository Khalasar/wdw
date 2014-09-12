//
//  MainViewController.m
//  AppleMaps
//
//  Created by Andre St on 18.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "Downloader.h"
#import "Helper.h"
#import "FXBlurView.h"
#import "UIFont+ScaledFont.h"
#import "MCLocalization.h"

@interface MainViewController ()
@property (strong, nonatomic)NSDictionary *readedJson;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) FXBlurView *blurView;
@property (nonatomic)BOOL downloadStarted;
@property (weak, nonatomic) IBOutlet UIButton *placesBtn;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic)CGFloat scaleLevel;
- (IBAction)showInterestingPlaces:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *routesBtn;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@end

@implementation MainViewController

#define PLACES_URL @"http://192.168.178.27:8080/places.json"
#define TRANSLATIONS_URL @"http://192.168.178.27:8080/translations.json"
#define STANDARD_URL @"http://192.168.178.27:8080/"

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
    
    [self addBackgroundImageView];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    [self addNotifications];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view.subviews setValue:@YES forKey:@"hidden"];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.view.subviews setValue:@NO forKey:@"hidden"];
    self.progressView.hidden = YES;
    [self.view sendSubviewToBack:self.backgroundImageView];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self updateLayout];
}

#pragma mark - fonts methods

-(void)preferredFontsChanged:(NSNotification *)notification
{
    [self updateBtnLayout];
}

#pragma mark - helper(notification, layout)

- (void)addNotifications
{
    // notification for localization
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localize)
                                                 name:MCLocalizationLanguageDidChangeNotification
                                               object:nil];
    [self localize];
    
    // notification to change font size
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredFontsChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

-(void)updateBtnLayout
{
    self.scaleLevel = [Helper getScaleLevel];
    
    for (UIView *view in self.view.subviews)
    {
        if ([view isMemberOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)view;
            btn.layer.borderWidth = 1.0f;
            btn.layer.borderColor = [[UIColor whiteColor] CGColor];
            btn.layer.cornerRadius = 5.0f;
            btn.layer.backgroundColor = [[UIColor colorWithWhite:1 alpha:0.5] CGColor];
            btn.titleLabel.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleBody scale: self.scaleLevel];
        }
    }
}

- (void)updateLayout
{
    self.backgroundImageView.frame = self.view.bounds;
    self.blurView.frame = self.backgroundImageView.bounds;
    UIView *shadowView = [self.view viewWithTag:1];
    shadowView.frame = self.backgroundImageView.bounds;
    [self updateBtnLayout];
}

- (void) addBackgroundImageView
{
    self.backgroundImageView = [[UIImageView alloc] initWithImage:
                                [UIImage imageNamed:@"backgroundImage1.jpg"]];
    [self.backgroundImageView setFrame:self.view.bounds];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview: self.backgroundImageView];
    
    self.blurView = [Helper createAndShowBlurView:self.backgroundImageView];
}

#pragma mark - Downloading Methods

- (IBAction)startDownloading:(id)sender {
    self.progressView.hidden = NO;
    
    NSURL *downloadURL = [NSURL URLWithString:PLACES_URL];
    [self downloadFromURL:downloadURL];
    
    downloadURL = [NSURL URLWithString:TRANSLATIONS_URL];
    [self downloadFromURL:downloadURL];
}

- (void)downloadFromURL:(NSURL *)url
{
    NSURLSessionDownloadTask *download = [[Downloader shared] downloadTaskWithURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProgress:)
                                                 name:@"DownloadProgress"
                                               object:download];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishDownload:)
                                                 name:@"DownloadCompletion"
                                               object:download];
    
    [download resume];
}

- (void)updateProgress:(NSNotification *)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.progressView.progress = [[notification userInfo][@"progress"] floatValue];
    }];
}
-(void)finishDownload:(NSNotification *)notification
{
    if ([notification.userInfo[@"url"] isEqualToString:PLACES_URL]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.progressView.hidden = YES;
        }];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self startNextDownload];
    [Helper loadTranslationFile];
}

// TODO Download only images if updated at newer
- (void)startNextDownload
{
    // start next Download
    if (!self.downloadStarted) {
        NSArray *places = [Helper readJSONFileFromDocumentDirectory:@"places" file:@"places.json"];
        for (NSDictionary *place in places) {
            NSLog(@"place %@", place[@"id"]);
            NSString *imageUrl = [[NSString alloc] initWithFormat:@"places/%@/get_images", place[@"id"]];
            NSURL *downloadURL = [NSURL URLWithString:[STANDARD_URL stringByAppendingString:imageUrl]];
            [self downloadFromURL:downloadURL];
        }
        self.downloadStarted = true;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(IBAction)showInterestingPlaces:(id)sender {
}

#pragma mark - localization

- (void) localize
{
    self.placesBtn.titleLabel.text = [MCLocalization stringForKey:@"placesBtn"];
    self.routesBtn.titleLabel.text = [MCLocalization stringForKey:@"routesBtn"];
    self.downloadBtn.titleLabel.text = [MCLocalization stringForKey:@"downloadBtn"];
}

@end
