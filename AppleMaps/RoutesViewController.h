//
//  RoutesTableViewController.h
//  WegDesWandels
//
//  Created by Andre St on 20.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoutesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(strong, nonatomic)NSArray *routes;
@property (weak, nonatomic) IBOutlet UITableView *routesTableView;

@end
