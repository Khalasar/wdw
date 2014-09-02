//
//  RouteViewController.m
//  WegDesWandels
//
//  Created by Andre St on 24.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "RouteViewController.h"
#import "MapViewController.h"
#import "MCLocalization.h"

@interface RouteViewController ()
@property (weak, nonatomic) IBOutlet UILabel *headline;

@end

@implementation RouteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // check if locale changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localize)
                                                 name:MCLocalizationLanguageDidChangeNotification
                                               object:nil];
    [self localize];
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

#pragma mark - localize functions

- (void)localize
{
    self.headline.text = [MCLocalization stringForKey:self.route.name];
}

@end
