//
//  RouteViewController.m
//  WegDesWandels
//
//  Created by Andre St on 24.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "RouteViewController.h"
#import "MapViewController.h"
#import "MCLocalization.h"
#import "FXBlurView.h"
#import "Helper.h"

@interface RouteViewController ()
@property (weak, nonatomic) IBOutlet UILabel *headline;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) FXBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIView *contentBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *routeName;
@property (weak, nonatomic) IBOutlet UILabel *routeCity;
@property (weak, nonatomic) IBOutlet UILabel *routeRegion;
@property (weak, nonatomic) IBOutlet UILabel *routeCountry;
@property (weak, nonatomic) IBOutlet UILabel *routeType;
@property (weak, nonatomic) IBOutlet UITextView *routeDescription;
@end

@implementation RouteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackgroundImageView];

    [self localize];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view sendSubviewToBack:self.backgroundImageView];
    [self.view sendSubviewToBack:self.blurView];
    self.contentBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.contentBackgroundView.layer.cornerRadius = 5;
    
    [self.view.subviews setValue:@NO forKey:@"hidden"];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // hide all subviews for a better disappear look
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
    self.backgroundImageView = [[UIImageView alloc] initWithImage:
                                [UIImage imageNamed:@"background3.jpg"]];
    [self.backgroundImageView setFrame:self.view.bounds];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview: self.backgroundImageView];
    
    self.blurView = [Helper createAndShowBlurView:self.backgroundImageView];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"onRouteMapButtonPressed"]) {
        if ([segue.destinationViewController isKindOfClass:[MapViewController class]]) {
            MapViewController *mvc = [segue destinationViewController];
            mvc.route = self.route;
        }
    }
}

#pragma mark - localize functions

- (void)localize
{
    self.headline.text = [MCLocalization stringForKey:self.route.name];
    self.routeName.text = [MCLocalization stringForKey:self.route.name];
    self.routeCity.text = [MCLocalization stringForKey:self.route.city];
    self.routeCountry.text = [MCLocalization stringForKey:self.route.country];
    self.routeRegion.text = [MCLocalization stringForKey:self.route.region];
    self.routeType.text = [MCLocalization stringForKey:self.route.type];
    self.routeDescription.text = [MCLocalization stringForKey:self.route.description];
}

@end
