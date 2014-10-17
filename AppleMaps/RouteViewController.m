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
#import "UIFont+ScaledFont.h"

@interface RouteViewController ()
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) FXBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIView *contentBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeCity;
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeRegion;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeCountry;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeType;
@property (weak, nonatomic) IBOutlet UITextView *routeDescription;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showOnMapBtn;
@end

@implementation RouteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackgroundImageView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view sendSubviewToBack:self.backgroundImageView];
    [self.view sendSubviewToBack:self.blurView];
    self.contentBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.contentBackgroundView.layer.cornerRadius = 5;
    
    [self.view.subviews setValue:@NO forKey:@"hidden"];
    [self usePreferredFonts];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self localize];
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
    self.routeDescription.contentInset = UIEdgeInsetsMake(-10, -5, 0, 0);
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

#pragma mark - fonts methods

-(void)preferredFontsChanged:(NSNotification *)notification
{
    [self usePreferredFonts];
}

-(void)usePreferredFonts
{
    self.cityLabel.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleSubheadline scale:[Helper getScaleLevel]];
    self.regionLabel.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleSubheadline scale:[Helper getScaleLevel]];
    self.countryLabel.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleSubheadline scale:[Helper getScaleLevel]];
    self.typeLabel.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleSubheadline scale:[Helper getScaleLevel]];
    self.routeCity.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleCaption1 scale:[Helper getScaleLevel]];
    self.routeCountry.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleCaption1 scale:[Helper getScaleLevel]];
    self.routeRegion.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleCaption1 scale:[Helper getScaleLevel]];
    self.routeType.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleCaption1 scale:[Helper getScaleLevel]];
    self.routeDescription.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleBody scale:[Helper getScaleLevel]];

    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:[Helper getScaleLevel]],
      NSFontAttributeName, nil]];

    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:[Helper getScaleLevel]]
       }
     forState:UIControlStateNormal];
}

#pragma mark - localize functions

- (void)localize
{
    //self.title = self.route.name;
    self.routeCity.text = self.route.city;
    self.routeCountry.text = self.route.country;
    self.routeRegion.text = self.route.region;
    self.routeType.text = self.route.type;
    self.routeDescription.text = self.route.description;
    self.cityLabel.text = [MCLocalization stringForKey:@"city"];
    self.regionLabel.text = [MCLocalization stringForKey:@"region"];
    self.countryLabel.text = [MCLocalization stringForKey:@"country"];
    self.typeLabel.text = [MCLocalization stringForKey:@"tour_type"];
    self.showOnMapBtn.title = [MCLocalization stringForKey:@"onMapBtn"];


}

@end
