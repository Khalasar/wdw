//
//  Place.m
//  WegDesWandels
//
//  Created by Andre St on 18.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "Place.h"
#import "Helper.h"
#import "MCLocalization.h"

@interface Place ()
@property(strong, nonatomic) NSDictionary *place;
@property(strong, nonatomic) NSMutableArray *imagesArray;
@end

@implementation Place

- (instancetype)initWithPlaceDictionary:(NSDictionary *) placeDictionary
{
    self = [super init];
    self.place = placeDictionary;

    // init Coordinate
    CLLocationDegrees latitude  = [[self.place valueForKey:@"lat"] doubleValue];
    CLLocationDegrees longitude = [[self.place valueForKey:@"lng"] doubleValue];
    self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    //init Name
    self.title = [self.place valueForKey:@"title"];
    //init Subtitle
    self.subtitle = [self.place valueForKey:@"subtitle"];
    // init routeID
    self.placeID = [self.place valueForKey:@"id"];
    // init image count
    self.imageCount = [[self.place valueForKey:@"images_count"] intValue];
        
    return self;
}

- (NSArray *) loadImages
{
    self.imagesArray = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSString *fileFolder = [[NSString alloc]initWithFormat:@"%@", self.placeID];
    NSString *imagePath = [[NSString alloc] initWithString:[Helper getDocumentsDirectorsPathFor:@[@"places", fileFolder, @"images"]]];
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imagePath
                                                                            error:&error];
    
    for (NSString *file in fileList) {
        NSString *filePath = [imagePath stringByAppendingPathComponent:file];
        [self.imagesArray addObject:[UIImage imageWithContentsOfFile:filePath]];
    }
   
    NSArray *images = [[NSArray alloc] initWithArray:self.imagesArray];
    
    return images;
}

- (NSString *) loadBodyText
{
    NSString *fileFolder = [[NSString alloc]initWithFormat:@"%@", self.placeID];
    NSString *filename = [[NSString alloc]initWithFormat:@"%@_text",[Helper currentLanguage]];
    
    NSString *file = [Helper getDocumentsPathForFile:filename
                                         inDirectory:@[@"places", fileFolder, @"text"]];
    
    NSString* content = [NSString stringWithContentsOfFile:file
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];

    return content;
}

@end
