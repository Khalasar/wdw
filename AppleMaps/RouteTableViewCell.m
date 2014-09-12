//
//  RouteTableViewCell.m
//  WegDesWandels
//
//  Created by Andre St on 07.09.14.
//  Copyright (c) 2014 André Stuhrmann. All rights reserved.
//

#import "RouteTableViewCell.h"
#import "MCLocalization.h"

@interface RouteTableViewCell ()

@end

@implementation RouteTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
