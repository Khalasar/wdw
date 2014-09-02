//
//  AppDelegate.h
//  AppleMaps
//
//  Created by Andre St on 16.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MapViewController *mapVC;

@property (copy, nonatomic) void (^backgroundSessionCompletionHandler)();

@end
