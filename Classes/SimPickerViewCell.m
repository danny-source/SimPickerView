//
//  SimPickerViewCell.m
//  SimPickerView
//
//  Created by CHING PING on 2014/12/31.
//  Copyright (c) 2014年 CHING PING. All rights reserved.
//

#import "SimPickerViewCell.h"

@implementation SimPickerViewCell

- (void)awakeFromNib {
    self.disclosurePlaceHolder.backgroundColor = [UIColor clearColor];
}

- (void)addButton:(UIButton *)button
{
    button.frame = self.disclosurePlaceHolder.bounds;
    [self.disclosurePlaceHolder addSubview: button];
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [transition setDuration:0.15];
    [self.disclosurePlaceHolder.layer addAnimation:transition forKey:nil];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [transition setDuration:0.15];
    [self.name.layer addAnimation:transition forKey:nil];
    self.name.alpha = self.selected ?  1 : 0.6;
//    self.name.font = self.selected ? [UIFont systemFontOfSize:19.0]:[UIFont systemFontOfSize:17.0];

}
@end
