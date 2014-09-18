//
//  PlacesTableViewController.m
//  WegDesWandels
//
//  Created by Andre St on 18.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "PlacesTableViewController.h"
#import "PlaceViewController.h"
#import "Helper.h"
#import "MCLocalization.h"
#import "FXBlurView.h"
#import "UIFont+ScaledFont.h"

@interface PlacesTableViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *filteredPlaces;
@property (strong,nonatomic) NSArray *placesArray;
@property (strong, nonatomic)FXBlurView *blurView;
@property (strong, nonatomic)UIImageView *backgroundImageView;
@property (nonatomic)CGFloat scaleLevel;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@end

@implementation PlacesTableViewController

#define PLACES_JSON @"places"

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self addBackgroundImageView];
    
    [self loadPlaces];
    
    self.placesArray = [Helper getPlacesArray:self.places];
    self.filteredPlaces = [NSMutableArray arrayWithCapacity:self.placesArray.count];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    [self localize];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view sendSubviewToBack:self.blurView];
    
    self.scaleLevel = [Helper getScaleLevel];
    [self.tableView reloadData];
    [self usePreferredFonts];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateLayout];
}

#pragma mark - helper

-(void) loadPlaces
{
    if ([Helper existFile:@"places.json" inDocumentsDirectory:@[@"places"]]) {
        self.places = [Helper readJSONFileFromDocumentDirectory:@"places"
                                                           file:@"places.json"];
    }else{
        [Helper showAlertIfPlacesNotLoaded];
    }
}

#pragma mark - fonts methods

-(void)preferredFontsChanged:(NSNotification *)notification
{
    [self usePreferredFonts];
    [self.tableView reloadData];
}

-(void)usePreferredFonts
{
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:self.scaleLevel],
      NSFontAttributeName, nil]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:[Helper getScaleLevel]]
       }
     forState:UIControlStateNormal];
}

#pragma mark - helper methods

- (void) addBackgroundImageView
{
    self.backgroundImageView = [[UIImageView alloc] initWithImage:
                                [UIImage imageNamed:@"backgroundImage2.jpg"]];
    [self.backgroundImageView setFrame:self.tableView.frame];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = self.backgroundImageView;
    
    self.blurView = [Helper createAndShowBlurView:self.backgroundImageView];
}

- (void)updateLayout
{
    // adjust background layout to device orientation
    self.backgroundImageView.frame = self.tableView.frame;
    self.blurView.frame = self.backgroundImageView.bounds;
    UIView *shadowView = [self.view viewWithTag:1];
    shadowView.frame = self.backgroundImageView.bounds;
}

#pragma mark - localize method

- (void)localize
{
    self.title = [MCLocalization stringForKey:@"placesBtn"];
    [self.tableView reloadData];
    self.navigationItem.backBarButtonItem.title = [MCLocalization stringForKey:@"backBtn"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredPlaces count];
    } else {
        return [self.placesArray count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"aPlaceCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    Place *place;
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        place = [self.filteredPlaces objectAtIndex:indexPath.row];
    } else {
        place = [self.placesArray objectAtIndex:indexPath.row];
    }

    //Place *place = [[Place alloc] initWithPlaceDictionary: self.places[indexPath.row]];
    cell.textLabel.text = place.title;
    cell.textLabel.font =  [UIFont myPreferredFontForTextStyle:UIFontTextStyleBody scale: self.scaleLevel];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"nameCellPressed"]) {
       // NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        Place *place;// = [[Place alloc] initWithPlaceDictionary: self.places[indexPath.row]];
        if (self.searchDisplayController.active) {
             NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            place = [self.filteredPlaces objectAtIndex:indexPath.row];
        } else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            place = [self.placesArray objectAtIndex:indexPath.row];
        }
        
        if ([segue.destinationViewController isKindOfClass:[PlaceViewController class]]) {
            PlaceViewController *pvc = [segue destinationViewController];
            pvc.place = place;
        }
    }
}

#pragma mark - Content filtering

-(void)filterContentForSearchText:(NSString*)searchText
                            scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredPlaces removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@",searchText];
    self.filteredPlaces = [NSMutableArray arrayWithArray:[self.placesArray filteredArrayUsingPredicate:predicate]];
}


#pragma mark - UISearchDisplayController Delegate Methods
- (BOOL) searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL) searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
