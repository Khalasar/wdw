//
//  GalleryCell.h
//  WegDesWandels
//
//  Created by Andre St on 05.09.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GalleryCell : UICollectionViewCell <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *imageName;
-(void)updateCellWithImage:(UIImage *)image andCaption:(NSString *)caption;

@end
