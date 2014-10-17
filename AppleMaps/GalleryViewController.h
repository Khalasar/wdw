//
//  GalleryViewController.h
//  WegDesWandels
//
//  Created by Andre St on 05.09.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryViewController : UICollectionViewController < UIGestureRecognizerDelegate >

@property(strong, nonatomic) NSArray *pageImages;
@property(strong, nonatomic) NSArray *imageCaptions;
@property(strong, nonatomic) NSIndexPath *tappedImage;
@property(nonatomic)BOOL firstCall;

@end
