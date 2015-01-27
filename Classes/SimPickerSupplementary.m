//
//  SimPickerSupplementary.m
//  SimPickerView
//
//  Created by CHING PING on 2015/1/27.
//  Copyright (c) 2015年 CHING PING. All rights reserved.
//

#import "SimPickerSupplementary.h"

@implementation SimPickerSupplementary

- (void)awakeFromNib {
    // Initialization code
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touchesEventDelegate != nil) {
        [self.touchesEventDelegate getTouchInViewKind: self.reuseIdentifier];
    }

}
@end
