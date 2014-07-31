//
//  Place.m
//  WegDesWandels
//
//  Created by Andre St on 18.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "Place.h"

@interface Place ()
    @property(strong, nonatomic) NSDictionary *placeDictionary;
@end

@implementation Place

- (instancetype)initWithPlaceDictionary:(NSDictionary *) placeDictionary
{
    self = [super init];
    self.placeDictionary = placeDictionary;
    
    // init Coordinate
    CLLocationDegrees latitude  = [self.placeDictionary[@"lat"] doubleValue];
    CLLocationDegrees longitude = [self.placeDictionary[@"lng"] doubleValue];
    self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    //init Name
    self.name = self.placeDictionary[@"title"];
    self.title = self.placeDictionary[@"title"];
    //init Subtitle
    self.subtitle = self.placeDictionary[@"subtitle"];
    // init routeID
    self.routeID = self.placeDictionary[@"id"];
    
    return self;
}

@end
