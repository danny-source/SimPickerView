//
//  SimPickerView.h
//  SimPickerView
//
//  Created by CHING PING on 2014/12/31.
//  Copyright (c) 2014年 CHING PING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimPickerView : UIView<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) UIImageView *focusImageView;
// properties to define the look of pickerview
@property CGFloat CellHeight;
@property NSInteger DisplayedItems;
@property CGFloat MinLineSpacing;

- (NSIndexPath *)getSelectedIndexPath;
// insert / add / delete
- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)insertItem:(id)newItem atIndexPath:(NSIndexPath *)indexPath;
- (void)appendItem:(id)newItem afterIndexPath:(NSIndexPath *)indexPath;
@end
