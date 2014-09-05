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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view.subviews setValue:@NO forKey:@"hidden"];
    [self.view sendSubviewToBack:self.backgroundImageView];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self updateBtnLayout];
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

-(void)updateBtnLayout
{
    self.scaleLevel = [self.userDefaults objectForKey:@"scaleLevel"]?
        [[self.userDefaults valueForKey:@"scaleLevel"] floatValue] : 1;
    
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
}

- (IBAction)goToPlacesView:(id)sender {
    UISplitViewController *svc = (UISplitViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"placeSplitView"];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = svc;
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
    // downloadURL = [NSURL URLWithString:TRANSLATIONS_URL];
    // [self downloadFromURL:downloadURL];

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

}

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

-(IBAction)showInterestingPlaces:(id)sender {
}

@end
