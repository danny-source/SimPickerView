//
//  CenterLayout.h
//  TestScrollTable
//
//  Created by CHING PING on 2014/12/19.
//  Copyright (c) 2014年 CHING PING. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG
#define DMLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define DMLog(...) do { } while (0)
#endif

@interface CenterLayout : UICollectionViewFlowLayout
@property (atomic, strong) NSMutableDictionary *storedAttributes;
@property (atomic, strong) NSIndexPath *focusedIndex;

- (instancetype)initWithCellHeight:(CGFloat)cellHeight displayedItems:(NSInteger)displayedItems minimumLineSpacing:(CGFloat)minimumLineSpacing;
@end
