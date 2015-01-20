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
- (void)callbackInsertItem:(id)item atRow:(NSInteger)row;
- (void)callbackDeleteRow:(NSInteger)deleteRow;
@end


@interface SimPickerView : UIView<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *focusImageView;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeGesture;
// properties to define the look of pickerview
@property CGFloat CellHeight;
@property NSInteger DisplayedItems;
@property (strong, nonatomic) id<SimPickerDelegateProtocol> delegate;
@property CGFloat MinLineSpacing;
@property (strong, nonatomic) UIButton *buttonDisclosure;

- (void)markFirstDisclosure;
- (NSIndexPath *)getFocusIndexPath;
// insert / add / delete
- (void)deleteRow:(NSInteger)deleteRow;
- (void)insertItem:(id)newItem atRow:(NSInteger)row;
- (void)insertItem:(id)newItem afterRow:(NSInteger)row;
- (void)reloadData;
@end

