//
//  ControllerHelper.h
//  WegDesWandels
//
//  Created by Andre St on 20.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXBlurView.h"

@interface Helper : NSObject

+ (NSArray *) readJSONFile:(NSString *) file;
+ (NSArray *) readJSONFileFromDocumentDirectory:(NSString *) directory file:(NSString *)filename;
+ (NSString *) getDocumentsPathForFile:(NSString *)filename inDirectory:(NSArray *)directoryArray;
+ (NSString *) getPathForJSONFile:(NSString *)filename;
+ (NSString *) getDocumentsDirectorsPathFor:(NSArray *)directoryArray;
+(NSString *)currentLanguage;
+ (BOOL)existFile:(NSString *)filename inDocumentsDirectory:(NSArray *)directoryArray;
+ (NSArray *) getPlacesArray:(NSArray *)array;
+ (FXBlurView *)createAndShowBlurView:(UIView *)underlyingView;
@end
