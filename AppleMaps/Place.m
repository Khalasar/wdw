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
@property(strong, nonatomic) NSString *innerTitle;
@property(strong, nonatomic) NSString *innerSubtitle;
@end

@implementation Place

- (instancetype)initWithPlaceDictionary:(NSDictionary *) placeDictionary
{
    self = [super init];
    
    if (self) {
        
        self.place = placeDictionary;

        // init Coordinate
        CLLocationDegrees latitude  = [[self.place valueForKey:@"lat"] doubleValue];
        CLLocationDegrees longitude = [[self.place valueForKey:@"lng"] doubleValue];
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);

        // init routeID
        self.placeID = [self.place valueForKey:@"id"];
        // init image count
        self.imageCount = [[self.place valueForKey:@"images_count"] intValue];
        self.innerTitle = [self.place valueForKey:@"title"];
        self.innerSubtitle = [self.place valueForKey:@"subtitle"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeDouble:self.coordinate.latitude forKey:@"lat"];
    [encoder encodeDouble:self.coordinate.longitude forKey:@"lng"];
    [encoder encodeObject:self.placeID forKey:@"placeID"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.subtitle forKey:@"subtitle"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        CLLocationDegrees latitude  = [decoder decodeDoubleForKey:@"lat"];
        CLLocationDegrees longitude = [decoder decodeDoubleForKey:@"lng"];
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        self.placeID = [decoder decodeObjectForKey:@"placeID"];
        self.innerTitle = [decoder decodeObjectForKey:@"title"];
        self.innerSubtitle = [decoder decodeObjectForKey:@"subtitle"];
    }
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

- (NSArray *) loadCaptions
{
    NSMutableArray *captions = [[NSMutableArray alloc]init];
    for (id photo in [self.place valueForKey:@"photos"]) {
        [captions addObject:photo[@"caption"]];
    }
    
    return [[NSArray alloc]initWithArray:captions];
}

#pragma mark - getter

- (NSString *)title
{
    return [MCLocalization stringForKey:self.innerTitle];
}

- (NSString *)subtitle
{
    return [MCLocalization stringForKey:self.innerSubtitle];
}

@end
