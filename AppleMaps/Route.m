//
//  Route.m
//  WegDesWandels
//
//  Created by Andre St on 20.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "Route.h"
#import "Helper.h"
#import "Place.h"
#import "MCLocalization.h"

@interface Route ()
@property(strong, nonatomic)NSDictionary *route;
@property(strong, nonatomic)NSArray *waypointsArray;
@property(strong, nonatomic)NSArray *placesArray;
@property(strong, nonatomic)NSString *routeID;

@end

@implementation Route

#define REGION_RADIUS 5

-(instancetype)initWithRouteDictionary:(NSDictionary *)route{
    self = [super init];
    if (self) {
        self.route = route;
        //init route properties
        self.subtitle = self.route[@"subtitle"];
        self.waypointsArray = (NSArray *) self.route[@"waypoints"];
        self.routeID = self.route[@"id"];
        self.description = self.route[@"description"];
        self.country = self.route[@"country"];
        self.region = self.route[@"region"];
        self.city = self.route[@"city"];
        self.type = self.route[@"type"];
        //self.name = self.route[@"title"];
        [self initPlacesArray];
    }
    return self;
}

-(void) initPlacesArray
{
    NSArray *places = [[NSArray alloc] init];
    
    if ([Helper existFile:@"places.json" inDocumentsDirectory:@[@"places"]]) {
        places = [Helper readJSONFileFromDocumentDirectory:@"places" file:@"places.json"];
    }else{
        return;
    }
    
    NSMutableArray *placesArray = [[NSMutableArray alloc] init];
    for (NSString* waypointID in self.waypointsArray) {
        for (NSDictionary *placeDict in places) {
            if ([placeDict[@"id"] isEqualToString:waypointID]){
                Place *place = [[Place alloc] initWithPlaceDictionary: placeDict];
                [placesArray addObject:place];
                break;
            }
        }
    }
    self.placesArray = [[NSArray alloc] initWithArray:placesArray];
}

-(Place *) getNextVisitPlace
{
    Place *nextPlace = [[Place alloc]init];
    if (self.visitedPlaces.count >= self.placesArray.count) {
        NSLog(@"All Places visited!");
    }else{
        nextPlace = self.placesArray[[self.visitedPlaces count]];
    }
    
    return nextPlace;
}

-(void)addVisitedPlace:(Place *)place
{
    [self.visitedPlaces addObject:place];
}

-(NSString *)distanceToNextPlaceFromUserLocation:(CLLocation *)userLocation
{
    Place *nextPlace = [self getNextVisitPlace];
    CLLocation *nextPlaceLoc = [[CLLocation alloc]initWithLatitude:nextPlace.coordinate.latitude
                                                         longitude:nextPlace.coordinate.longitude];
    
    CLLocationDistance distance = [userLocation distanceFromLocation: nextPlaceLoc];
    long nearest = lroundf((float)distance);

    
    return [NSString stringWithFormat:@"%ld m", nearest];
}

// TODO Refactor this method! (Too long)
-(void) centerRoute // method from codeschool tutorial
{
    NSMutableArray *lats = [[NSMutableArray alloc] init];
    NSMutableArray *lngs = [[NSMutableArray alloc] init];
    
    for (Place *place in self.placesArray) {
        [lats addObject:[NSNumber numberWithDouble: (double)place.coordinate.latitude]];
        [lngs addObject:[NSNumber numberWithDouble: (double)place.coordinate.longitude]];
    }
    [lats sortUsingSelector:@selector(compare:)];
    [lngs sortUsingSelector:@selector(compare:)];
    
    if (lats.count > 0) {
        double smallestLat = [lats[0] doubleValue];
        double smallestLng = [lngs[0] doubleValue];
        double biggestLat = [[lats lastObject] doubleValue];
        double biggestLng = [[lngs lastObject] doubleValue];
        
        CLLocationCoordinate2D annotationsCenter =
        CLLocationCoordinate2DMake((biggestLat + smallestLat) / 2,
                                   (biggestLng + smallestLng) / 2);
        
        MKCoordinateSpan annotationsSpan = MKCoordinateSpanMake((biggestLat - smallestLat) + 0.005,
                                                                (biggestLng - smallestLng) + 0.005); // 0.001 to show the route complete
        
        MKCoordinateRegion region = MKCoordinateRegionMake(annotationsCenter, annotationsSpan);
        [self.mapView setRegion:region];
    }
}

-(void) readdAnnotations
{
    for (Place *place in self.placesArray) {
        [self.mapView removeAnnotation:place];
        [self.mapView addAnnotation:place];
    }
}

// Create the polyline for the route and add this to the map. Also it at annotations for the places.
-(void) createRouteAndAddAnnotationForPlaces
{
    for (Place *place in self.placesArray) {
        [self.mapView addAnnotation:place];
    }
    
    MKPolyline *polyline = [self createPolylineForRoute:self.routeID];
    
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

-(NSArray *) createRegions
{
    NSMutableArray *regionArray= [[NSMutableArray alloc] init];
    //NSLog(@"count places: %d", [self.placesArray count]);
    for (Place *place in self.placesArray) {
        NSString *identifier = [[NSString alloc] initWithFormat:@"id_%@", place.placeID];
        CLRegion *region;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
            region = [[CLCircularRegion alloc] initWithCenter:place.coordinate
                                                       radius:REGION_RADIUS
                                                   identifier: identifier];
        }
        else // ios below 7
        {
            region = [[CLRegion alloc] initCircularRegionWithCenter:place.coordinate
                                                                       radius:REGION_RADIUS
                                                                   identifier: identifier];
        }
        region.notifyOnExit = NO;
        
        [regionArray addObject:region];
    }
    NSArray *regions = [[NSArray alloc] initWithArray:regionArray];
    
    return regions;
}

- (Place *) getPlaceForCoordiante:(CLLocationCoordinate2D)coord
{
    for (Place *place in self.placesArray) {
        if (place.coordinate.latitude == coord.latitude && place.coordinate.longitude == coord.longitude) {
            return place;
        }
    }
    return nil;
}

-(NSMutableArray *)visitedPlaces
{
    if (!_visitedPlaces) {
        _visitedPlaces = [[NSMutableArray alloc] init];
    }
    return _visitedPlaces;
}

#pragma mark - getter

- (NSString *)name
{
    return self.route[@"title"];// [MCLocalization stringForKey: self.route[@"title"]];
}

@end
