//
//  ControllerHelper.m
//  WegDesWandels
//
//  Created by Andre St on 20.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "Helper.h"
#import "MCLocalization.h"
#import "Place.h"
#import "FXBlurView.h"

@implementation Helper

+ (NSArray *) readJSONFile:(NSString *) file
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:@"json"];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error: &error];
    //NSLog(@"error: %@", error);
    //NSLog(@"json: %@", json);
    
    return json;
}

+ (NSArray *) readJSONFileFromDocumentDirectory:(NSString *) directory file:(NSString *)filename
{
    NSString *filePath = [self getDocumentsPathForFile:filename inDirectory:@[directory]];
    
    NSData *fileContent = [[NSFileManager defaultManager] contentsAtPath:filePath];
    
    NSError *error = nil;
        
    NSArray *json = [NSJSONSerialization JSONObjectWithData:fileContent
                                                         options:kNilOptions
                                                           error: &error];
    //NSLog(@"error: %@", error);
    //NSLog(@"json: %@", json);
    
    return json;
}

+ (NSString *) getDocumentsPathForFile:(NSString *)filename inDirectory:(NSArray *)directoryArray
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath  = [[NSString alloc] initWithString:paths[0]];
    for (NSString *directory in directoryArray) {
        docsPath = [docsPath stringByAppendingPathComponent:directory];
    }

    NSString *filePath = [docsPath stringByAppendingPathComponent:filename];
    
    return filePath;
}

+ (NSString *) getPathForJSONFile:(NSString *)filename
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    
    return filePath;
}

+ (NSString *)getDocumentsDirectorsPathFor:(NSArray *)directoryArray
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath  = [[NSString alloc] initWithString:paths[0]];
    for (NSString *directory in directoryArray) {
        docsPath = [docsPath stringByAppendingPathComponent:directory];
    }
    
    return docsPath;
}

+ (BOOL)existFile:(NSString *)filename inDocumentsDirectory:(NSArray *)directoryArray
{
    NSString *path = [self getDocumentsPathForFile:filename inDirectory:directoryArray];
    
    return [[NSFileManager defaultManager]fileExistsAtPath:path];
}

+ (NSString *)currentLanguage
{
    return [[MCLocalization sharedInstance] language];
}

+ (NSString *)currentLanguageLong
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *currentLang = [userDefaults stringForKey:@"currentLangLong"]? [userDefaults stringForKey:@"currentLangLong"] : @"Choose language";
    return currentLang;
}

+ (NSArray *) getPlacesArray:(NSArray *)array
{
    NSMutableArray *placesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < array.count; ++i) {
        Place *place = [[Place alloc] initWithPlaceDictionary: array[i]];
        [placesArray addObject:place];
    }
    
    return [[NSArray alloc] initWithArray:placesArray];
}

+ (FXBlurView *)createAndShowBlurView:(UIView *)underlyingView
{
    FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:underlyingView.bounds];
    blurView.underlyingView = underlyingView;
    blurView.tintColor = [UIColor clearColor];
    //blurView.updateInterval = 1;
    blurView.blurRadius = 15.f;
    blurView.dynamic = YES;
    //_blurView.alpha = 0.f;
    [underlyingView addSubview:blurView];
    [self createOpaqueViewFor:blurView];
    
    return blurView;
}

+ (void) createOpaqueViewFor:(UIView *)view
{
    UIView *shadowView = [[UIView alloc] initWithFrame:view.bounds];
    shadowView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    shadowView.tag = 1;
    [view addSubview:shadowView];
}

+ (void) loadTranslationFile
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // for localization
    NSString *path = [Helper getDocumentsPathForFile:@"translations.json" inDirectory:@[@"translations"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"file exists");
    }else{
        path = [Helper getPathForJSONFile:@"translations"];
    }
    [MCLocalization loadFromJSONFile:path defaultLanguage:@"en"];
    [MCLocalization sharedInstance].language = [userDefaults stringForKey:@"currentLangCode"];
}

+ (CGFloat) getScaleLevel
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"scaleLevel"]? [[userDefaults valueForKey:@"scaleLevel"] floatValue] : 1;
}

@end
