//
//  Route.m
//  WegDesWandels
//
//  Created by Andre St on 20.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "Route.h"
#import "ControllerHelper.h"
#import "Place.h"

@interface Route ()
@property(strong, nonatomic)NSDictionary *routeDictionary;
@property(strong, nonatomic)NSArray *waypointsArray;
@property(strong, nonatomic)NSArray *placesArray;
@end

@implementation Route

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
    
    for (Place *place in self.placesArray) {
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

// Create the polyline for the route and add this to the map. Also it at annotations for the places.
-(void) createRouteAndAddAnnotationForPlaces
{
    NSDictionary *placesDict = [[NSDictionary alloc] init];
    placesDict = [ControllerHelper readJSONFile:@"places"];
    NSString *routeID = [[NSString alloc] init];
    NSMutableArray *placesArray = [[NSMutableArray alloc] init];
    
    for (NSString *waypointID in self.waypointsArray) {
        Place *place = [[Place alloc] initWithPlaceDictionary:placesDict[waypointID]];
        [self.mapView addAnnotation:place];
        [placesArray addObject:place];
        
        routeID = place.routeID;
    }
    
    MKPolyline *polyline = [self createPolylineForRoute:routeID];
    self.placesArray = [[NSArray alloc] initWithArray:placesArray];
    
    [self.mapView addOverlay:polyline];
}

- (MKPolyline *) createPolylineForRoute:(NSString *)routeID
{
    NSString  *filename = [NSString stringWithFormat:@"Route%@", routeID];
    NSString *thePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
    NSArray *pointsArray = [NSArray arrayWithContentsOfFile:thePath];
    
    NSInteger pointsCount = pointsArray.count;
    CLLocationCoordinate2D pointsToUse[pointsCount];
    
    int i = 0;
    for (NSDictionary *attraction in pointsArray) {
        CGPoint point = CGPointFromString(attraction[@"location"]);
        pointsToUse[i] = CLLocationCoordinate2DMake(point.x,point.y);
        i++;
    }
    
    MKPolyline *myPolyline = [MKPolyline polylineWithCoordinates:pointsToUse count:pointsCount];
    
    return myPolyline;
}

@end
