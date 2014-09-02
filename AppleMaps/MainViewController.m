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

@interface MainViewController ()
@property (strong, nonatomic)NSDictionary *readedJson;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) FXBlurView *blurView;
@property (nonatomic)BOOL downloadStarted;
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
    self.blurView = [Helper createAndShowBlurView:self.backgroundImage];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // send mapView to back to show buttons on map
    [self.view sendSubviewToBack:self.backgroundImage];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
    self.backgroundImage.frame = self.view.bounds;
    self.blurView.frame = self.backgroundImage.bounds;
    UIView *shadowView = [self.view viewWithTag:1];
    shadowView.frame = self.backgroundImage.bounds;
}

- (IBAction)goToPlacesView:(id)sender {
    UISplitViewController *svc = (UISplitViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"placeSplitView"];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = svc;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)showInterestingPlaces:(id)sender {
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

@end
