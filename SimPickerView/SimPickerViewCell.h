//
//  SimPickerViewCell.h
//  SimPickerView
//
//  Created by CHING PING on 2014/12/31.
//  Copyright (c) 2014年 CHING PING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimPickerViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *disclosurePlaceHolder;

@property (weak, nonatomic) IBOutlet UILabel *name;

- (void)addDisclosureButton: (UIButton *)button;
@end
