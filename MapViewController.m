//
//  MapViewController.m
//  AppleMaps
//
//  Created by Andre St on 16.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "MapViewController.h"
#import "PlaceViewController.h"
#import "Helper.h"
#import <AVFoundation/AVFoundation.h>
#import "MCLocalization.h"
#import "UIFont+ScaledFont.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *routeInformationOverlayView;
@property (weak, nonatomic) IBOutlet UILabel *distanceField;
@property (weak, nonatomic) IBOutlet UILabel *nextPlaceField;
@property (weak, nonatomic) IBOutlet UIImageView *directionImage;

// Route handling
@property (strong, nonatomic) UIBarButtonItem *startRouteBtn;
@property (strong, nonatomic) UIBarButtonItem *pauseRouteBtn;
@property (strong, nonatomic)NSDate *startRouteDate;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic)BOOL routePaused;
@property (nonatomic)BOOL routeRuns;
@property (strong, nonatomic)CLLocationManager *locationManager;
@property (nonatomic)double degrees;
@property (nonatomic)CGFloat directionDegrees;

@property (strong, nonatomic) NSString *timeForRoute;
@property (nonatomic)NSTimeInterval pauseTimeInterval;
@property (strong, nonatomic)NSUserDefaults *userDefaults;
@property (strong, nonatomic)UIAlertView *alertView;
@property (strong, nonatomic)NSMutableArray *userLocationsArray;
@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@property (strong, nonatomic) NSString *directionsText;
@property (nonatomic)BOOL updateCurrentLocation;
@property (strong, nonatomic)NSMutableArray *placesArray;
@property (strong, nonatomic)UITapGestureRecognizer *tapGesture;
@end

@implementation MapViewController

@synthesize routePaused;

#define VISITED_PLACES @"visitedPlaces"

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
    // init mapView
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.updateCurrentLocation = NO;
    
    self.speechSynthesizer.delegate = self;
    
    // init user defaults to store data
    self.userDefaults = [NSUserDefaults standardUserDefaults];    
    [self initMapView];
    self.title = [MCLocalization stringForKey:@"mapLabel"];
    [self addNotifications];
}

- (void)addNotifications
{
    // notification for localization
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localize)
                                                 name:MCLocalizationLanguageDidChangeNotification
                                               object:nil];
    
    // notification to change font size
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredFontsChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void) initMapView
{
    // 1) call a specific place and show on map
    if (self.place) {
        [self addPlaceToMapAndCenterOnThatPlace:self.place];
        // "Go to current user position"-button
        MKUserTrackingBarButtonItem *buttonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
    // 2) call a route and show on map
    else if (self.route) {
        [self initRouteMapPage];
    }
    // 3) call map link in tabbar
    else {
        // "Go to current user position"-button
        MKUserTrackingBarButtonItem *buttonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
        self.navigationItem.rightBarButtonItem = buttonItem;
        
        self.updateCurrentLocation = YES;
        
        if ([Helper existFile:@"places.json" inDocumentsDirectory:@[@"places"]]) {
            [self loadPlaces];
            [self showAllPlacesOnMap];
        }else{
            NSLog(@"show alert view to download!");
        }
    }
}

-(void) loadPlaces
{
    NSArray *interestingPlaces = [Helper readJSONFileFromDocumentDirectory:@"places" file:@"places.json"];
    self.placesArray = [[NSMutableArray alloc] init];
    Place *place;
    for (NSDictionary *placeDict in interestingPlaces) {
        place = [[Place alloc] initWithPlaceDictionary:placeDict];
        [self.placesArray addObject:place];
    }
}

-(void) showAllPlacesOnMap
{
    for (Place *p in self.placesArray) {
        [self.mapView addAnnotation:p];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // send mapView to back to show buttons on map
    [self.view sendSubviewToBack:self.mapView];
    [self usePreferredFonts];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self showHideNavbarAndTabBar:nil];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.updateCurrentLocation) {
        [self centerRegionWithCoordinate:mapView.userLocation.coordinate andWidth:1000 andHeight:1000];
        self.updateCurrentLocation = NO;
     }
}

- (IBAction)changeMapType:(UISegmentedControl *)sender {
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

- (void) addPlaceToMapAndCenterOnThatPlace:(Place *)place
{
    [self.mapView removeAnnotation:place];
    [self.mapView addAnnotation:place];
    // if showing map this annotation is standardly open
    [self.mapView selectAnnotation:place animated:YES];
    
    [self centerRegionWithCoordinate:place.coordinate andWidth:100 andHeight:100];
}

- (void) centerRegionWithCoordinate:(CLLocationCoordinate2D)coord andWidth:(CLLocationDistance)width andHeight:(CLLocationDistance)height
{
    CLLocationDistance regionWidth = width;
    CLLocationDistance regionHeight = height;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(coord, regionWidth, regionHeight);
    [self.mapView setRegion:startRegion
                   animated:YES];
}

#pragma mark - fonts methods

-(void)preferredFontsChanged:(NSNotification *)notification
{
    [self usePreferredFonts];
}

-(void)usePreferredFonts
{
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:[Helper getScaleLevel]],
      NSFontAttributeName, nil]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:[Helper getScaleLevel]]
       }
     forState:UIControlStateNormal];
    
    self.distanceField.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleBody scale:[Helper getScaleLevel]];
    self.nextPlaceField.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleBody scale:[Helper getScaleLevel]];
    
    // change font size of ssegmented((standard hybrid, satellite)
    /*[self.segmentedControl setTitleTextAttributes:
     @{
       NSFontAttributeName:[UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:[Helper getScaleLevel]]
     }
                                         forState:UIControlStateNormal];*/
}

#pragma mark - localize method
- (void)localize
{
    self.title = [MCLocalization stringForKey:@"mapLabel"];
    [self.startRouteBtn setTitle: [MCLocalization stringForKey:@"startBtn"]];
    [self.pauseRouteBtn setTitle: [MCLocalization stringForKey:@"pauseBtn"]];
    // 1) call a specific place and show on map
    if (self.place) {
        [self addPlaceToMapAndCenterOnThatPlace:self.place];
    }
    // 2) call a route and show on map
    else if (self.route) {
        self.nextPlaceField.text = [self.route getNextVisitPlace].title;
        
        [self.route readdAnnotations];
    }
}

# pragma mark - alert view methods

-(void)goBack:(id)sender
{
    if(self.routeRuns)
    {
        self.alertView.tag = 0;
        [self.alertView show];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0 && buttonIndex == 1)
    {
        // save route details
        [Helper savePlacesArrayObject:self.route.visitedPlaces withKey:VISITED_PLACES];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

# pragma mark - map View delegate methods
// This method describe the look for the route polylines.
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString *reuseID = @"annoView";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier: reuseID];
    
    if (!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier: reuseID];
    }
    Place *placeAnno = (Place *)annotation;
    view.canShowCallout = YES;
    view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    view.image = [UIImage imageNamed:@"Map-Marker-Azure"];
    
    for (Place *place in self.route.visitedPlaces) {
        if (place.placeID == placeAnno.placeID) {
            view.image = [UIImage imageNamed:@"Map-Marker-Green"];
        }else{
            view.image = [UIImage imageNamed:@"Map-Marker-Azure"];
        }
    }
    view.annotation = placeAnno;
    
    return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"PressedPlaceOnMap" sender:view];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PressedPlaceOnMap"]) {
        if ([segue.destinationViewController isKindOfClass:[PlaceViewController class]]) {
            PlaceViewController *pvc = [segue destinationViewController];
            if ([[sender annotation] isKindOfClass:[Place class]]) {
                Place *place = [(MKPinAnnotationView *)sender annotation];
                pvc.place = place;
            }
        }
    }
}

#pragma mark - init Route method

- (void) initRouteMapPage
{
    // add tap gesture recognizer to show and hide navbar and tabBar
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbarAndTabBar:)];
    self.tapGesture.delegate = self;
    
    //self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //self.locationManager.distanceFilter = 10;
    self.locationManager.delegate = self;
    
    // create back button and add method to check for back action
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc]initWithTitle:[MCLocalization stringForKey:@"backBtn"]
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(goBack:)];
    
    // create start bar button
    self.startRouteBtn = [[UIBarButtonItem alloc]initWithTitle:[MCLocalization stringForKey:@"startBtn"]
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(startRoute:)];
    
    // create pause bar button
    self.pauseRouteBtn = [[UIBarButtonItem alloc]initWithTitle:[MCLocalization stringForKey:@"pauseBtn"]
                                                         style:UIBarButtonItemStyleBordered
                                                        target:self
                                                        action:@selector(pauseRoute:)];
    
    self.navigationItem.leftBarButtonItem = backBtn;
    self.navigationItem.rightBarButtonItem = self.startRouteBtn;
    
    self.routeInformationOverlayView.hidden = NO;
    
    // init alert view to check if user is sure to stop route or go back
    self.alertView = [[UIAlertView alloc] initWithTitle:[MCLocalization stringForKey:@"warning"]
                                                message:[MCLocalization stringForKey:@"cancelMSG"]
                                               delegate:self
                                      cancelButtonTitle:[MCLocalization stringForKey:@"no"]
                                      otherButtonTitles:nil];
    [self.alertView addButtonWithTitle:[MCLocalization stringForKey:@"yes"]];
    
    self.route.mapView = self.mapView;
    [self.route createRouteAndAddAnnotationForPlaces];
    [self.route centerRoute];

    self.pauseTimeInterval = 0.0;
}

#pragma mark - failure message methods

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    NSLog(@"error%@",error);
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[MCLocalization stringForKey:@"error"]
                                                            message:[MCLocalization stringForKey:@"networkError"]
                                                           delegate:self
                                                  cancelButtonTitle:[MCLocalization stringForKey:@"okLabel"]
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[MCLocalization stringForKey:@"error"]
                                                            message:[MCLocalization stringForKey:@"deniedLocationError"]
                                                           delegate:self
                                                  cancelButtonTitle:[MCLocalization stringForKey:@"okLabel"]
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        break;
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[MCLocalization stringForKey:@"error"]
                                                            message:[MCLocalization stringForKey:@"unknownNetworkError"]
                                                           delegate:self
                                                  cancelButtonTitle:[MCLocalization stringForKey:@"okLabel"]
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        break;
    }
}

# pragma mark - action methods to control routes

- (IBAction)startRoute:(UIBarButtonItem *)sender {
    NSLog(@"Start Route");
    [self.mapView addGestureRecognizer:self.tapGesture];
    [self.locationManager startUpdatingLocation];
    [self startUpdateHeading];
    
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.rotateEnabled = NO;
    
    self.routeRuns = YES;
    
    // compass mode on
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    
    self.startRouteDate = [NSDate date];
    self.startRouteDate = [self.startRouteDate dateByAddingTimeInterval:((-1)*(self.pauseTimeInterval))];

    // start Timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                  target:self
                                                selector:@selector(timerRuns)
                                                userInfo:nil
                                                 repeats:YES];
    
    self.navigationItem.rightBarButtonItem = self.pauseRouteBtn;
    
    [self showHideNavbarAndTabBar:nil];
}

- (IBAction)pauseRoute:(UIBarButtonItem *)sender {

    NSLog(@"Pause Route");
    [self.locationManager stopUpdatingLocation];
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
    [self.locationManager stopUpdatingHeading];
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.rotateEnabled = YES;
    
    [self.timer invalidate];
    
    [self.startRouteBtn setTitle:@"Resume"];
    self.navigationItem.rightBarButtonItem = self.startRouteBtn;
}

-(void)timerRuns
{
    // NSLog(@"Timer runs!");
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.startRouteDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    [dateFormatter setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    self.timeForRoute = [dateFormatter stringFromDate:timerDate];
    //NSLog(@"timer %@", self.timeForRoute);
    self.pauseTimeInterval = timeInterval;
}

#pragma mark - heading methods

- (void)startUpdateHeading
{
    //Start the compass updates. TODO Refactor
    if (CLLocationManager.headingAvailable ) {
        [self.locationManager startUpdatingHeading];
    }
    else {
        UIAlertView *noCompassAlert = [[UIAlertView alloc] initWithTitle:[MCLocalization stringForKey:@"noCompassTitle"]
                                                                 message:[MCLocalization stringForKey:@"noCompassError"]
                                                                delegate:nil
                                                       cancelButtonTitle:[MCLocalization stringForKey:@"okLabel"]
                                                       otherButtonTitles:nil];
        [noCompassAlert show];
    }
    
    [self calculateUserAngle:self.mapView.userLocation.location.coordinate];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    NSLog(@"degree: %f", self.degrees);
    self.directionDegrees = self.degrees - newHeading.magneticHeading;
    [self checkingForUserDirection];
    //arrowTransform = CGAffineTransformMakeRotation(cosAlpha);
    self.directionImage.transform = CGAffineTransformMakeRotation(self.directionDegrees * M_PI / 180);
}

#pragma mark - user direction methods

-(void) checkingForUserDirection
{
    if (abs(self.directionDegrees) >= 22.5 && abs(self.directionDegrees) <= 67.5) {
        self.directionsText = [MCLocalization stringForKey:@"BEAR_LEFT"];
    }else if (abs(self.directionDegrees) >= 67.5 && abs(self.directionDegrees) <= 112.5) {
        self.directionsText = [MCLocalization stringForKey:@"GO_LEFT"];
    }else if (abs(self.directionDegrees) >= 112.5 && abs(self.directionDegrees) <= 157.5) {
        self.directionsText = [MCLocalization stringForKey:@"SHARP_LEFT"];
    }else if (abs(self.directionDegrees) >= 157.5 && abs(self.directionDegrees) <= 202.5) {
        self.directionsText = [MCLocalization stringForKey:@"GO_BACK"];
    }else if (abs(self.directionDegrees) >= 202.5 && abs(self.directionDegrees) <= 247.5) {
        self.directionsText = [MCLocalization stringForKey:@"SHARP_RIGHT"];
    }else if (abs(self.directionDegrees) >= 247.5 && abs(self.directionDegrees) <= 292.5) {
        self.directionsText = [MCLocalization stringForKey:@"GO_RIGHT"];
    }else if (abs(self.directionDegrees) >= 292.5 && abs(self.directionDegrees) <= 337.5) {
        self.directionsText = [MCLocalization stringForKey:@"BEAR_RIGHT"];
    }else {
        self.directionsText = [MCLocalization stringForKey:@"GO_FORWARD"];
    }
}

-(void) calculateUserAngle:(CLLocationCoordinate2D)user {
    float fLat = user.latitude /180 * M_PI;
    float fLng = user.longitude /180 * M_PI;
    float tLat = self.route.getNextVisitPlace.coordinate.latitude /180 * M_PI;
    float tLng = self.route.getNextVisitPlace.coordinate.longitude /180 * M_PI;
    
    self.degrees = (atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng))) *180 / M_PI;
}

# pragma mark - Update Location methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations lastObject];
    [self.userLocationsArray addObject:currentLocation];
    //[self drawUserPath];
    [self updateMapOverlayWithCurrentLocation:currentLocation];
    [self openPlaceInfoIfNextPlaceIsNear:currentLocation];
    
	MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 50.0, 50.0);
	[self.mapView setRegion:userLocation animated:YES];
}

// Olde deprecated version of method for iOS <6.0 
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self locationManager:manager didUpdateLocations:[[NSArray alloc] initWithObjects:newLocation, nil]];
}

-(void) updateMapOverlayWithCurrentLocation:(CLLocation *)currentLocation
{
    // update distance field to next place
    self.distanceField.text = [self.route distanceToNextPlaceFromUserLocation:currentLocation];
    self.nextPlaceField.text = [self.route getNextVisitPlace].title;
    [self calculateUserAngle:currentLocation.coordinate];
}

-(void)openPlaceInfoIfNextPlaceIsNear:(CLLocation *)currentLocation
{
    Place *nextVisitPlace = self.route.getNextVisitPlace;
    CLLocation *nextLocation = [[CLLocation alloc]initWithLatitude:nextVisitPlace.coordinate.latitude
                                                         longitude:nextVisitPlace.coordinate.longitude];
    
    if ([currentLocation distanceFromLocation:nextLocation] <= 10) {
        if (nextVisitPlace != nil ) {
            // change annotation image if visited
            MKAnnotationView *av = [self.mapView viewForAnnotation:nextVisitPlace];
            av.image = [UIImage imageNamed:@"Map-Marker-Green"];
            
            [self.route addVisitedPlace:nextVisitPlace];
            // show this place
            PlaceViewController *pvc = [[PlaceViewController alloc] init];
            pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"placeVC"];
            pvc.place = nextVisitPlace;
            [[self navigationController] pushViewController:pvc animated:YES];
        }
   
    }
}

/*-(void)drawUserPath
{
    NSInteger pointsCount = [self.userLocationsArray count];
    CLLocationCoordinate2D coords[pointsCount];
    for (NSInteger i = 0; i < pointsCount; ++i) {
        coords[i] = [(CLLocation *) self.userLocationsArray[i] coordinate];
    }
    
    MKPolyline *myPolyline = [MKPolyline polylineWithCoordinates:coords count:pointsCount];
    [self.mapView addOverlay:myPolyline];
}*/

- (IBAction)tapOnOverlay:(UITapGestureRecognizer *)sender {
    NSString *currentLang = [[NSString alloc] initWithString:[self.userDefaults stringForKey:@"currentLang"]];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString: self.directionsText];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:currentLang];
    NSLog(@"av lang %@", utterance.voice);
    //utterance.pitchMultiplier = 0.5f;
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
    utterance.preUtteranceDelay = 0.2f;
    utterance.postUtteranceDelay = 0.2f;
    
    [self.speechSynthesizer speakUtterance:utterance];
}

-(NSTimer *)timer
{
    if (!_timer) {
        _timer = [[NSTimer alloc] init];
    }
    return _timer;
}

-(NSMutableArray *)userLocationsArray
{
    if (!_userLocationsArray) {
        _userLocationsArray = [[NSMutableArray alloc] init];
    }
    return _userLocationsArray;
}

-(UIAlertView *)alertView
{
    if (!_alertView) {
        _alertView = [[UIAlertView alloc] init];
    }
    return _alertView;
}

-(CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

-(AVSpeechSynthesizer *)speechSynthesizer
{
    if (!_speechSynthesizer) {
        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return _speechSynthesizer;
}

-(NSString *)directionsText
{
    if (!_directionsText) {
        _directionsText = [[NSString alloc] init];
    }
    return _directionsText;
}

#pragma mark - hide/show tabbar and navigation bar

-(void) showHideNavbarAndTabBar:(id) sender
{
    // write code to show/hide nav bar here
    // check if the Navigation Bar is shown
    if (!self.navigationController.navigationBar.hidden)
    {
        // hide the Navigation Bar
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self hideTabBar:self.tabBarController];
    }
    // if Navigation Bar is already hidden
    else
    {
        // Show the Navigation Bar
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self showTabBar:self.tabBarController];
    }
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

- (void)hideTabBar:(UITabBarController *)tabbarcontroller
{
    //self.tabBarController.view
    [UIView animateWithDuration: 0.2 animations:^{
        for (UIView *view in tabbarcontroller.view.subviews) {
            if ([view isKindOfClass:[UITabBar class]]) {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+49.f, view.frame.size.width, view.frame.size.height)];
            }
            else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height+49.f)];
            }
        }
    } completion:^(BOOL finished) {
        //do smth after animation finishes
        tabbarcontroller.tabBar.hidden = YES;
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            // iOS 7
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        } else {
            // iOS 6
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }
    }];
}

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.navigationBar.hidden;
}

#pragma mark - UIGestureRecognizer Delgate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //NSLog(@"1:%@; 2%@", gestureRecognizer,otherGestureRecognizer);
    return YES;
}

@end
