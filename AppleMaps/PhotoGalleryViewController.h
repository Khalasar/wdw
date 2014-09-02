//
//  PhotoGalleryViewController.h
//  WegDesWandels
//
//  Created by Andre St on 02.08.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoGalleryViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *pageImages;
@property (strong, nonatomic) UIImage *tappedImage;
@end
