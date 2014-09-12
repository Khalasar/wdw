//
//  MapViewController.h
//  AppleMaps
//
//  Created by Andre St on 16.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Place.h"
#import "Route.h"

@import AVFoundation;

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, AVSpeechSynthesizerDelegate, UIGestureRecognizerDelegate>

@property(strong, nonatomic)Place *place;
@property(strong, nonatomic)Route *route;

@end
