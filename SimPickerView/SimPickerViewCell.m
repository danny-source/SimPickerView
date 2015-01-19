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

- (void)addDisclosureButton:(UIButton *)button
{
    [self.disclosurePlaceHolder addSubview: button];
}
@end
