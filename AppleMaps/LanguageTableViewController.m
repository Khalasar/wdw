//
//  LanguageTableViewController.m
//  WegDesWandels
//
//  Created by Andre St on 10.09.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "LanguageTableViewController.h"
#import "MCLocalization.h"

@interface LanguageTableViewController ()
@property (strong, nonatomic) NSArray *languages;
@property (strong, nonatomic) NSArray *languagesCode;
@property (strong, nonatomic) NSArray *langCodeText;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation LanguageTableViewController

id<DismissPopoverDelegate> delegate;
@synthesize languages;
@synthesize languagesCode;
@synthesize langCodeText;

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
    self.title = @"Languages";
    
    languages = @[@"Deutsch", @"English"];
    languagesCode = @[@"de-DE", @"en-GB"];
    langCodeText = @[@"de", @"en"];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return languages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"aLanguageCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.tintColor = [UIColor blackColor];
    cell.textLabel.text = languages[indexPath.row];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MCLocalization sharedInstance].language = langCodeText[indexPath.row];
    [self.userDefaults setObject:languagesCode[indexPath.row] forKey:@"currentLang"];
    [self.userDefaults setObject:languages[indexPath.row] forKey:@"currentLangLong"];
    [self.userDefaults setObject:langCodeText[indexPath.row] forKey:@"currentLangCode"];
    [self.delegate dismissPopover];
}

#pragma mark - localize method
- (void)localize
{
    self.title = [MCLocalization stringForKey:@"language"];
}

@end
