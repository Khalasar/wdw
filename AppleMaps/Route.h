//
//  Route.h
//  WegDesWandels
//
//  Created by Andre St on 20.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Place.h"

@interface Route : NSObject

@property(strong, nonatomic)NSString *name;
@property(strong, nonatomic)NSString *subtitle;
@property(strong, nonatomic)NSString *description;
@property(strong, nonatomic)NSString *country;
@property(strong, nonatomic)NSString *region;
@property(strong, nonatomic)NSString *city;
@property(strong, nonatomic)NSString *type;
@property(strong, nonatomic)MKMapView *mapView;
@property(strong, nonatomic)NSMutableArray *visitedPlaces;
- (instancetype) initWithRouteDictionary:(NSDictionary *) routeDictionary;
- (void) createRouteAndAddAnnotationForPlaces;
- (void) centerRoute;
- (NSArray *) createRegions;
- (Place *) getPlaceForCoordiante:(CLLocationCoordinate2D)coord;
- (void) addVisitedPlace:(Place *)place;
- (NSString *) distanceToNextPlaceFromUserLocation:(CLLocation *)userLocation;
-(Place *) getNextVisitPlace;
@end
