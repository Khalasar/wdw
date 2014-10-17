//
//  PlaceViewController.h
//  WegDesWandels
//
//  Created by Andre St on 18.07.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import <AVFoundation/AVFoundation.h>

@interface PlaceViewController : UIViewController <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, AVSpeechSynthesizerDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) BOOL playSound;
@end
