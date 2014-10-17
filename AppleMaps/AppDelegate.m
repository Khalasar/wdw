//
//  AppDelegate.m
//  AppleMaps
//
//  Created by Andre St on 16.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "AppDelegate.h"
#import "Downloader.h"
#import "MCLocalization.h"
#import "Helper.h"
#import "GalleryViewController.h"

@implementation AppDelegate

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad


// TODO: Use translations from backend!
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.tintColor = [UIColor whiteColor];
    
    [Helper loadTranslationFile];
    
    return YES;
}

- (void)application:(UIApplication *)application
handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
    self.backgroundSessionCompletionHandler = completionHandler;
    
    [Downloader shared];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSUInteger)application:(UIApplication *)application
supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (IPAD) {
        return UIInterfaceOrientationMaskAll;
    }else{
        if ([[self.window.rootViewController presentedViewController]
             isKindOfClass:[GalleryViewController class]]) {
            return UIInterfaceOrientationMaskAllButUpsideDown;
        } else {
            
            if ([[self.window.rootViewController presentedViewController]
                 isKindOfClass:[UINavigationController class]]) {
                
                // look for it inside UINavigationController
                UINavigationController *nc = (UINavigationController *)[self.window.rootViewController presentedViewController];
                
                // is at the top?
                if ([nc.topViewController isKindOfClass:[GalleryViewController class]]) {
                    return UIInterfaceOrientationMaskAllButUpsideDown;
                    
                    // or it's presented from the top?
                } else if ([[nc.topViewController presentedViewController]
                            isKindOfClass:[GalleryViewController class]]) {
                    return UIInterfaceOrientationMaskAllButUpsideDown;
                }
            }
        }
        return UIInterfaceOrientationMaskPortrait;
    }
    
}

@end
