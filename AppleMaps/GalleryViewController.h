//
//  GalleryViewController.h
//  WegDesWandels
//
//  Created by Andre St on 05.09.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryViewController : UICollectionViewController

@property(strong, nonatomic) NSArray *pageImages;
@property(strong, nonatomic) NSIndexPath *tappedImage;

@end
