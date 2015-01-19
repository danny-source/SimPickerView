//
//  SimPickerView.h
//  SimPickerView
//
//  Created by CHING PING on 2014/12/31.
//  Copyright (c) 2014年 CHING PING. All rights reserved.
//

#import <UIKit/UIKit.h>



@class SimPickerView;


@protocol SimPickerDelegateProtocol <NSObject>
- (NSInteger)numberOfRowsInPickerView:(SimPickerView *)pickerView;
- (NSString *)pickerView:(SimPickerView *)pickerView titleForRow:(NSInteger)row;
- (void)pickerView:(SimPickerView *)pickerView didSelectRow:(NSInteger)row;
@end


@interface SimPickerView : UIView<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *focusImageView;
// properties to define the look of pickerview
@property CGFloat CellHeight;
@property NSInteger DisplayedItems;
@property (strong, nonatomic) id<SimPickerDelegateProtocol> delegate;
@property CGFloat MinLineSpacing;
@property (strong, nonatomic) UIButton *buttonDisclosure;

- (NSIndexPath *)getFocusIndexPath;
// insert / add / delete
//- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)insertItem:(id)newItem atIndexPath:(NSIndexPath *)indexPath;
//- (void)appendItem:(id)newItem afterIndexPath:(NSIndexPath *)indexPath;
- (void)reloadData;
@end

