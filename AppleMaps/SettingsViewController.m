//
//  SettingsViewController.m
//  WegDesWandels
//
//  Created by Andre St on 28.08.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "SettingsViewController.h"
#import "MCLocalization.h"
#import "LanguageTableViewController.h"
#import "Helper.h"
#import "MyLabel.h"
#import "UIFont+ScaledFont.h"
#import "UIPopoverController+Iphone.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet MyLabel *fontSizeLabel;
@property (weak, nonatomic) IBOutlet MyLabel *langSettingLabel;
@property (weak, nonatomic) IBOutlet MyLabel *audioGuideLabel;
@property (weak, nonatomic) IBOutlet UISlider *fontSizeSlider;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic, getter=theNewPopover) UIPopoverController *newPopover;
@property (strong, nonatomic)UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIView *fontView;
@property (weak, nonatomic) IBOutlet UIView *languageView;
@property (weak, nonatomic) IBOutlet UIView *audioView;
@property (weak, nonatomic) IBOutlet UILabel *guideLabel;
@property (nonatomic)CGFloat scaleLevel;
@end

@implementation SettingsViewController

@synthesize popover;

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
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.fontSizeSlider.value = [Helper getScaleLevel];
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.5]CGColor];
    self.tableView.layer.cornerRadius = 5.0f;
    self.tableView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    // notification for localization
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localize)
                                                 name:MCLocalizationLanguageDidChangeNotification
                                               object:nil];
    [self localize];
    [self layoutViews];
    [self addNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.userDefaults synchronize];
}

- (void)addNotifications
{
    // notification for localization
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localize)
                                                 name:MCLocalizationLanguageDidChangeNotification
                                               object:nil];
    [self localize];
    
    // notification to change font size
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredFontsChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)layoutViews
{
    self.languageView.layer.cornerRadius = 10.0f;
    self.fontView.layer.cornerRadius = 10.0f;
    self.audioView.layer.cornerRadius = 10.0f;
    
    self.fontSizeLabel.layer.cornerRadius = 10.0f;
    self.langSettingLabel.layer.cornerRadius = 10.0f;
    self.audioGuideLabel.layer.cornerRadius = 10.0f;
    
    self.fontSizeLabel.leftInset = 10;
    self.langSettingLabel.leftInset = 10;
    self.audioGuideLabel.leftInset = 10;
}

- (IBAction)fontSizeChangedEnd:(UISlider *)sender {
    [UIFont systemFontOfSize:[sender value]];
    [self.userDefaults setFloat:[sender value] forKey:@"scaleLevel"];
    NSLog(@"fontsize: %f", sender.value);
    self.scaleLevel = [sender value];
    [self usePreferredFonts];
    [self.tableView reloadData];
}

- (IBAction)changeAudioGuide:(UISwitch *)sender {
    [self.userDefaults setBool:YES forKey:@"audioGuide"];
}

#pragma mark - TableView DataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"theLanguageCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    NSString *currentLang = [Helper currentLanguageLong];
    
    cell.detailTextLabel.text = currentLang;
    cell.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleBody scale:self.scaleLevel];
    cell.textLabel.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleSubheadline scale:self.scaleLevel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.newPopover == nil)
    {
        
        LanguageTableViewController *tasksViewController = [[LanguageTableViewController alloc] init];
        tasksViewController.delegate = self;
        //LanguageTableViewController.navigationItem.title = @"Whatever you like";
        UINavigationController *navController =  [[UINavigationController alloc] initWithRootViewController:tasksViewController];
        popover = [[UIPopoverController alloc] initWithContentViewController:navController];
        
        popover.delegate = self;
        
        self.newPopover = popover;
    }
    _newPopover.popoverContentSize = CGSizeMake(320, 360);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [_newPopover presentPopoverFromRect:cell.bounds
                                 inView:cell.contentView
               permittedArrowDirections:UIPopoverArrowDirectionUp
                               animated:YES];
}

- (void) dismissPopover
{
    [popover dismissPopoverAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - fonts methods

-(void)preferredFontsChanged:(NSNotification *)notification
{
    [self usePreferredFonts];
}

-(void)usePreferredFonts
{
    self.fontSizeLabel.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:self.scaleLevel];
    self.langSettingLabel.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:self.scaleLevel];
    self.audioGuideLabel.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:self.scaleLevel];
    self.guideLabel.font = [UIFont myPreferredFontForTextStyle:UIFontTextStyleBody scale:self.scaleLevel];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont myPreferredFontForTextStyle:UIFontTextStyleHeadline scale:self.scaleLevel],
      NSFontAttributeName, nil]];
}

#pragma mark - localize method
- (void)localize
{
    self.title = [MCLocalization stringForKey:@"settingsHeadline"];
    self.fontSizeLabel.text = [MCLocalization stringForKey:@"fontSizeLabel"];
    self.langSettingLabel.text = [MCLocalization stringForKey:@"langSettingsLabel"];
    self.audioGuideLabel.text = [MCLocalization stringForKey:@"audioLabel"];
    self.guideLabel.text = [MCLocalization stringForKey:@"audioGuideLabel"];
}

@end
