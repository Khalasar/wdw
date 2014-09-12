//
//  Place.h
//  WegDesWandels
//
//  Created by Andre St on 18.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Place : NSObject <MKAnnotation>

- (instancetype) initWithPlaceDictionary:(NSDictionary *) placeDictionary;

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (strong, nonatomic) NSString *placeID;
@property (nonatomic) int imageCount;
- (NSString *) loadBodyText;

- (NSArray *) loadImages;

- (NSArray *) loadCaptions;

@end
