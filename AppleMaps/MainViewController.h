//
//  MainViewController.h
//  AppleMaps
//
//  Created by Andre St on 18.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
- (IBAction)showInterestingPlaces:(id)sender;

@end
