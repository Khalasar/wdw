//
//  ControllerHelper.m
//  WegDesWandels
//
//  Created by Andre St on 20.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "ControllerHelper.h"

@implementation ControllerHelper

+ (NSDictionary *) readJSONFile:(NSString *) file
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:@"json"];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error: &error];
    //NSLog(@"error: %@", error);
    //NSLog(@"json: %@", json);
    
    return json;
}

@end
