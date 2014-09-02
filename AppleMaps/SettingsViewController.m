//
//  SettingsViewController.m
//  WegDesWandels
//
//  Created by Andre St on 28.08.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "SettingsViewController.h"
#import "MCLocalization.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *languagePicker;
@property (strong, nonatomic) NSArray *languages;
@property (strong, nonatomic) NSArray *languagesCode;
@property (strong, nonatomic) NSArray *langCodeText;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@end

@implementation SettingsViewController

@synthesize languages;
@synthesize languagesCode;
@synthesize langCodeText;

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
    languages = @[@"Deutsch", @"English"];
    languagesCode = @[@"de-DE", @"en-GB"];
    langCodeText = @[@"de", @"en"];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.userDefaults synchronize];
}

- (IBAction)fontSizeChanged:(UISlider *)sender {
    NSLog(@"fontsize: %f", sender.value);
    [UIFont systemFontOfSize:[sender value]];
}

- (IBAction)changeAudioGuide:(UISwitch *)sender {
    [self.userDefaults setBool:YES forKey:@"audioGuide"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return languages.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return languages[row];
}

#pragma mark - PickerView Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    NSString *langCode = languagesCode[row];
    [MCLocalization sharedInstance].language = langCodeText[row];

    [self.userDefaults setObject:langCode forKey:@"currentLang"];
}

@end
