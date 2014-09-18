//
//  RoutesTableViewController.m
//  WegDesWandels
//
//  Created by Andre St on 20.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "RoutesViewController.h"
#import "Helper.h"
#import "Route.h"
#import "RouteViewController.h"
#import "MCLocalization.h"
#import "FXBlurView.h"
#import "RouteTableViewCell.h"
#import "UIFont+ScaledFont.h"

@interface RoutesViewController ()
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) FXBlurView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *routesTableView;
@end

@implementation RoutesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadRoutes];
    
    [self addBackgroundImageView];
    
    self.routesTableView.delegate = self;
    self.routesTableView.dataSource = self;
    
    [self localize];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view sendSubviewToBack:self.backgroundImageView];
    [self.view sendSubviewToBack:self.blurView];
    
    //self.routesTableView.layer.borderWidth = 2.0f;
    //self.routesTableView.layer.borderColor = [[UIColor whiteColor]CGColor];
    [self.routesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view.subviews setValue:@NO forKey:@"hidden"];
    [self usePreferredFonts];
    [self.routesTableView reloadData];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // hide all subviews for a better disappear look
    [self.view.subviews setValue:@YES forKey:@"hidden"];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateLayout];
}

- (void)updateLayout
{
    self.backgroundImageView.frame = self.view.bounds;
    self.blurView.frame = self.backgroundImageView.bounds;
    UIView *shadowView = [self.view viewWithTag:1];
    shadowView.frame = self.backgroundImageView.bounds;
}


- (void) addBackgroundImageView
{
    self.backgroundImageView = [[UIImageView alloc] initWithImage:
                                [UIImage imageNamed:@"background3.jpg"]];
    [self.backgroundImageView setFrame:self.view.bounds];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview: self.backgroundImageView];
    
    self.blurView = [Helper createAndShowBlurView:self.backgroundImageView];
}

-(void) loadRoutes
{
    if ([Helper existFile:@"routes.json" inDocumentsDirectory:@[@"routes"]]) {
        self.routes = [Helper readJSONFileFromDocumentDirectory:@"routes"
                                                           file:@"routes.json"];
    }else{
        [Helper showAlertIfPlacesNotLoaded];
        //self.routes = [Helper readJSONFile:@"routes"];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.routes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"aRouteCell";
    RouteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier
                                                            forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[RouteTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    Route *route = [[Route alloc] initWithRouteDictionary:self.routes[indexPath.row]];
    
    cell.title.text = route.name;
    cell.title.tintColor = [UIColor whiteColor];
    cell.title.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale: [Helper getScaleLevel]];
    cell.subtitle.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleSubheadline scale: [Helper getScaleLevel]];
    cell.subtitle.text = route.name;
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [[UIColor whiteColor]CGColor];
    cell.layer.cornerRadius = 5.0f;
    cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow = 100.0;
    
    return heightForRow;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"routeCellPressed"]) {
        NSIndexPath *indexPath = [self.routesTableView indexPathForCell:sender];
        
        Route *route =
            [[Route alloc] initWithRouteDictionary:self.routes[indexPath.row]];
        
        if ([segue.destinationViewController isKindOfClass:[RouteViewController class]]) {
            RouteViewController *rvc = [segue destinationViewController];
            rvc.route = route;
        }
    }
}

#pragma mark - fonts methods

-(void)preferredFontsChanged:(NSNotification *)notification
{
    [self usePreferredFonts];
    [self.routesTableView reloadData];
}

-(void)usePreferredFonts
{
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale: [Helper getScaleLevel]],
      NSFontAttributeName, nil]];
}

#pragma mark - localization

- (void) localize
{
    self.title = [MCLocalization stringForKey:@"routesBtn"];
    self.navigationItem.backBarButtonItem.title = [MCLocalization stringForKey:@"backBtn"];
}


@end
