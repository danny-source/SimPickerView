//
//  SimPickerSupplementary.h
//  SimPickerView
//
//  Created by CHING PING on 2015/1/27.
//  Copyright (c) 2015年 CHING PING. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickerSupplementaryTouch <NSObject>
- (void)getTouchInViewKind:(NSString *)reuseId;
@end

@interface SimPickerSupplementary : UICollectionReusableView
@property (nonatomic, weak) UIView<PickerSupplementaryTouch> *touchesEventDelegate;
@end
