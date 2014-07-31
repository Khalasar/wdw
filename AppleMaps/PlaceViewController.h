//
//  PlaceViewController.h
//  WegDesWandels
//
//  Created by Andre St on 18.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@interface PlaceViewController : UIViewController

@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end
