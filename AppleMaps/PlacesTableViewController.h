//
//  PlacesTableViewController.h
//  WegDesWandels
//
//  Created by Andre St on 18.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@interface PlacesTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property(strong, nonatomic)NSArray *places;


@end
