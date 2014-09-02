//
//  OldRoute.m
//  WegDesWandels
//
//  Created by Andre St on 27.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "OldRoute.h"
#import "ControllerHelper.h"
#import "Place.h"

@interface OldRoute ()
@property(strong, nonatomic)NSDictionary *routeDictionary;
@property(strong, nonatomic)NSArray *waypointsArray;
@property(strong, nonatomic)NSArray *waypointPlacesArray;
@end

@implementation OldRoute
-(instancetype)initWithRouteDictionary:(NSDictionary *)routeDictionary{
    self = [super init];
    self.routeDictionary = routeDictionary;
    //init name
    self.name = self.routeDictionary[@"title"];
    self.waypointsArray = (NSArray *) self.routeDictionary[@"waypoints"];
    
    return self;
}

// TODO Refactor this method! (Too long)
-(void) centerRoute
{
    NSMutableArray *lats = [[NSMutableArray alloc] init];
    NSMutableArray *lngs = [[NSMutableArray alloc] init];
    
    for (Place *place in self.waypointPlacesArray) {
        [lats addObject:[NSNumber numberWithDouble: (double)place.coordinate.latitude]];
        [lngs addObject:[NSNumber numberWithDouble: (double)place.coordinate.longitude]];
    }
    [lats sortUsingSelector:@selector(compare:)];
    [lngs sortUsingSelector:@selector(compare:)];
    
    double smallestLat = [lats[0] doubleValue];
    double smallestLng = [lngs[0] doubleValue];
    double biggestLat = [[lats lastObject] doubleValue];
    double biggestLng = [[lngs lastObject] doubleValue];
    
    CLLocationCoordinate2D annotationsCenter =
    CLLocationCoordinate2DMake((biggestLat + smallestLat) / 2,
                               (biggestLng + smallestLng) / 2);
    
    MKCoordinateSpan annotationsSpan =
    MKCoordinateSpanMake((biggestLat - smallestLat),
                         (biggestLng - smallestLng));
    
    MKCoordinateRegion region =
    MKCoordinateRegionMake(annotationsCenter, annotationsSpan);
    [self.mapView setRegion:region];
}

// Creates an array of Places, wich are waypoints of the route.
-(void) waypointsOfRoute
{
    NSDictionary *placesDict = [[NSDictionary alloc] init];
    placesDict = [ControllerHelper readJSONFile:@"places"];
    NSMutableArray *placesArray = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D coordinatePlacesArray[6];
    int i = 0;
    
    NSLog(@"zahle: %lu", (unsigned long)self.waypointPlacesArray.count);
    for (NSString *waypointID in self.waypointsArray) {
        Place *place = [[Place alloc] initWithPlaceDictionary:placesDict[waypointID]];
        [self.mapView addAnnotation:place];
        [placesArray addObject:place];
        NSLog(@"coordinate %f", place.coordinate.latitude);
        coordinatePlacesArray[i] = place.coordinate;
        
        i++;
    }
    
    //  NSLog(@"asdasd: %@:", coordinatePlacesArray);
    
    MKPolyline *myPolyline = [MKPolyline polylineWithCoordinates:coordinatePlacesArray count:self.waypointsArray.count];
    
    [self.mapView addOverlay:myPolyline];
    NSLog(@"myPolyline wurde hinzugefügt");
    
    
    
    self.waypointPlacesArray = placesArray;
}

// Create the Polylines for the route and show them on the mapView.
-(void) createRouteForMap
{
    [self waypointsOfRoute];
    for (int i = 0; i < [self.waypointPlacesArray count] ; i++) {
        if (i > 0) {
            Place *startLocation = self.waypointPlacesArray[i-1];
            Place *endLocation = self.waypointPlacesArray[i];
            
            [self drawPolylineWithStartLocation:startLocation.coordinate
                                 andEndLocation:endLocation.coordinate];
        }
    }
}



// Gets a start and a end location coordinate and create the polyline response.
- (void)drawPolylineWithStartLocation:(CLLocationCoordinate2D)startLocation andEndLocation:(CLLocationCoordinate2D)endLocation
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [self createMapItem:startLocation];
    request.destination = [self createMapItem:endLocation];
    request.requestsAlternateRoutes = YES;
    request.transportType = MKDirectionsTransportTypeWalking;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"Error on draw Polyline in Route.m: %@", error);
         } else {
             [self showPolyline:response];
         }
     }];
}

// Creates an MKMapItem for the MKDirectionsRequest.
- (MKMapItem *)createMapItem:(CLLocationCoordinate2D)coordinate
{
    MKPlacemark *placemark  = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                    addressDictionary:nil];
    MKMapItem *mapItem      = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    return mapItem;
}

// Show the Polyline response on the map View
- (void)showPolyline:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes){
        //[self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}
@end