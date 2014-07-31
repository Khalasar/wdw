//
//  MapViewController.m
//  AppleMaps
//
//  Created by Andre St on 16.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "MapViewController.h"
#import "PlaceViewController.h"
#import "ControllerHelper.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property BOOL updateUserLocation;
@property (strong, nonatomic)NSArray *annotationArray;
@end

@implementation MapViewController

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
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;

    
    if (self.place) { // call aspecific place and show on map
        [self addPlaceToMapAndCenterOnThatPlace];
        self.updateUserLocation = NO;
    }else if (self.route) { //call a route and show on mapo
        self.route.mapView = self.mapView;
        [self.route createRouteAndAddAnnotationForPlaces];
        [self.route centerRoute];
        self.updateUserLocation = NO;
    }else { // call map link in tabbar
        self.updateUserLocation = YES;
        NSDictionary *interestingPlaces = [ControllerHelper readJSONFile:@"places"];
        NSArray *placesValues = [[NSArray alloc] init];
        placesValues = [interestingPlaces allValues];
        for (id placeValue in placesValues) {
            Place *place = [[Place alloc] initWithPlaceDictionary: placeValue];
            [self.mapView addAnnotation:place];
        }
        //[self initAnnotations:interestingPlaces];
    }
    
    [self.view addSubview:self.mapView];
    
}

- (void) addPlaceToMapAndCenterOnThatPlace
{
    [self.mapView addAnnotation:self.place];
    // if showing map this annotation is standardly open
    [self.mapView selectAnnotation:self.place animated:YES];
    
    // NOTICE: The following is usefull if user not allow to get the current Location.
    // TODO: Refactor to own method!
    CLLocationDistance regionWidth = 200;
    CLLocationDistance regionHeight = 200;
    MKCoordinateRegion startRegion =
        MKCoordinateRegionMakeWithDistance(self.place.coordinate, regionWidth, regionHeight);
    self.updateUserLocation = NO;
    [self.mapView setRegion:startRegion
                   animated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.updateUserLocation) {
        [self.mapView setCenterCoordinate:userLocation.location.coordinate
                                 animated:YES];
        
        self.updateUserLocation = NO;
    }
    
}

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
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                            reuseIdentifier: reuseID];
        view.canShowCallout = YES;
    }

    view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //view.image = [UIImage imageNamed:@"map_pin.png"];
    view.annotation = annotation;
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
