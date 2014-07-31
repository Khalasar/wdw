//
//  RouteViewController.m
//  WegDesWandels
//
//  Created by Andre St on 24.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "RouteViewController.h"
#import "MapViewController.h"

@interface RouteViewController ()
@property (weak, nonatomic) IBOutlet UILabel *headline;

@end

@implementation RouteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.headline.text = self.route.name;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"onRouteMapButtonPressed"]) {
        if ([segue.destinationViewController isKindOfClass:[MapViewController class]]) {
            MapViewController *mvc = [segue destinationViewController];
            mvc.route = self.route;
        }
    }
}


@end
