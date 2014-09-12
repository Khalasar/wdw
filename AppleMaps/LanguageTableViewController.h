//
//  LanguageTableViewController.h
//  WegDesWandels
//
//  Created by Andre St on 10.09.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DismissPopoverDelegate
- (void) dismissPopover;
@end

@interface LanguageTableViewController : UITableViewController
@property (nonatomic, assign) id<DismissPopoverDelegate> delegate;
@end
