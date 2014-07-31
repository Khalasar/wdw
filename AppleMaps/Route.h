//
//  Route.h
//  WegDesWandels
//
//  Created by Andre St on 20.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Route : NSObject

@property(strong, nonatomic)NSString *name;
@property(strong, nonatomic)MKMapView *mapView;
- (instancetype) initWithRouteDictionary:(NSDictionary *) routeDictionary;
- (void) createRouteAndAddAnnotationForPlaces;
- (void) centerRoute;

@end
