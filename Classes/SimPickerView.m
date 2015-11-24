//
//  SimPickerView.m
//  SimPickerView
//
//  Created by CHING PING on 2014/12/31.
//  Copyright (c) 2014年 CHING PING. All rights reserved.
//

#import "SimPickerView.h"
#import "CenterLayout.h"
#import "SimPickerViewCell.h"


#define CellID @"cell"
#define HeaderID    @"HeaderID"
#define FooterID    @"FooterID"

#pragma mark - private interface
@interface SimPickerView() {
    BOOL _isScrolling;
    NSInteger _lastSelectIndex;
    BOOL _needForceDidSelectRow;
}
@property CGPoint offsetBeforeRecording;
@property BOOL trackingFocusedCell;
@end

#pragma mark - implementations
@implementation SimPickerView


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        CGRect effectFrame = self.frame;
        effectFrame.size.width = [[UIScreen mainScreen] bounds].size.width;
        [self commonInit: effectFrame];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        [self commonInit: frame];
     }
    return self;
}

- (void)commonInit:(CGRect)frame
{
    _DisplayedItems = 5;
    _MinLineSpacing = 1;
    _CellHeight = (frame.size.height - (_MinLineSpacing * (_DisplayedItems -1))) / _DisplayedItems;

    _collectionView = [[UICollectionView alloc]
                       initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)
                       collectionViewLayout: [[CenterLayout alloc] initWithCellHeight: _CellHeight  displayedItems: _DisplayedItems]];


    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    [self addSubview: _collectionView];

    UINib *nib = [UINib nibWithNibName: @"SimPickerViewCell" bundle: nil];
    [_collectionView registerNib: nib forCellWithReuseIdentifier: CellID];

    UINib *suppNib = [UINib nibWithNibName: @"SimPickerSupplementaryView" bundle: nil];
    [_collectionView registerNib: suppNib forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier: HeaderID];

    [_collectionView registerNib: suppNib forSupplementaryViewOfKind: UICollectionElementKindSectionFooter withReuseIdentifier: FooterID];
    [_collectionView addGestureRecognizer:[self makeTapGestureRecognizer]];//利用Tap來捲動PickerView 上/下

    [self addSubview: [self makeFocusGlass]];
    self.buttonDisclosure = [self makeButtonDisclosure];
    self.buttonDelete = [self makeButtonDelete];
    self.swipeGestureDirectionRight = [self makeSwipeGestureRecognizerDirectionRight];
    self.swipeGestureDirectionLeft = [self makeSwipeGestureRecognizerDirectionLeft];
    self.longGesture = [self makeLongGestureRecognizer];
    self.tapGesture = [self makeTapGestureRecognizerForCell];//註冊焦點中的Cell的Tap Gesture，並且忽略它
    _isScrolling = NO;
    _lastSelectIndex = 0;
    _needForceDidSelectRow = NO;
}

// mark disclosure take effect only when
// view did appear, must be called
// from the view controller's viewDidAppear

- (void)markFirstDisclosure
{
    static dispatch_once_t once;
    dispatch_once(&once, ^ {

        [self collectionView: self.collectionView didSelectItemAtIndexPath: [NSIndexPath indexPathForItem: 0 inSection: 0]];
    });
}

- (UISwipeGestureRecognizer *)makeSwipeGestureRecognizerDirectionRight
{
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(swipeGestureRecognized:)];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    return gesture;
}
- (UISwipeGestureRecognizer *)makeSwipeGestureRecognizerDirectionLeft
{
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(swipeGestureRecognized:)];
    [gesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    return gesture;
}

- (UILongPressGestureRecognizer *)makeLongGestureRecognizer
{
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureRecognized:)];
    [gesture setMinimumPressDuration:1];
    return gesture;
}

- (UITapGestureRecognizer *)makeTapGestureRecognizer
{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    return gesture;
}
- (UITapGestureRecognizer *)makeTapGestureRecognizerForCell
{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizedForCell:)];
    return gesture;
}

- (UIGestureRecognizer *)makeGestureRecognizer
{
    UIGestureRecognizer *gesture = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(allGestureRecognized:)];
    return gesture;
}

- (UIImageView *)makeFocusGlass
{
    NSInteger emptyItemSpaces = self.DisplayedItems / 2;
    CGRect focusPlaceholder = CGRectInset(self.collectionView.frame, 0, (self.CellHeight + self.MinLineSpacing) * emptyItemSpaces);

    UIImageView *imageView = [[UIImageView alloc] initWithFrame: focusPlaceholder];
    imageView.image = [UIImage imageNamed: @"glass"];
    [self addSubview: imageView];
    return imageView;
}

- (UIButton *)makeButtonDisclosure
{
    UIButton *button = [[UIButton alloc] init];
    // buttom frame will be setup in [SimPickerViewCell addButton:]
    [button addTarget: self action: @selector(buttonDisclosurePressed:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *image = [UIImage imageNamed: @"arrow-disclosure"];
    [button setImage: image forState: UIControlStateNormal];
    return button;
}

- (UIButton *)makeButtonDelete
{
    UIButton *button = [[UIButton alloc] init];
    // buttom frame will be setup in [SimPickerViewCell addButton:]
    [button addTarget: self action: @selector(buttonDeletePressed:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *image = [UIImage imageNamed: @"delete"];
    [button setImage: image forState: UIControlStateNormal];
    return button;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(numberOfRowsInPickerView:)]) {
        return [self.delegate numberOfRowsInPickerView: self];
    }
    else {
        DMLog(@"no available delegate object");
        return 0;
    }

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimPickerViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier: CellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(pickerView:titleForRow:)]) {
        cell.name.text = [self.delegate pickerView: self titleForRow: indexPath.row];
    }
    else {
        cell.name.text = @"";
        DMLog(@"no available title");
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SimPickerSupplementary *supplementaryView = nil;
    if ([kind isEqualToString: UICollectionElementKindSectionHeader]) {
        supplementaryView = [self.collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: HeaderID forIndexPath: indexPath];
        supplementaryView.touchesEventDelegate = self;
    }
    else if ([kind isEqualToString: UICollectionElementKindSectionFooter]) {
        supplementaryView = [self.collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: FooterID forIndexPath: indexPath];
        supplementaryView.touchesEventDelegate = self;
    }
    else {
        NSAssert(NO, @"Invalid kind, should not happen");
    }
    return supplementaryView;
}
#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    CGSize itemSize = CGSizeMake(self.collectionView.bounds.size.width, self.CellHeight);
    //DMLog(@"itemSize = %.2f, %.2f", itemSize.width, itemSize.height);
    return itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //DMLog(@"select item %ld", (long)indexPath.item);

    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SimPickerViewCell *cell = (SimPickerViewCell *)obj;
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }];
    NSInteger focusIndex = [self getFocusIndexPath].row;
    //假如正在連續Tap 或 focusIndex != idnexPath.row 才能使用程式去捲動PickerView
    if (focusIndex != indexPath.row) {
        [self.collectionView selectItemAtIndexPath: indexPath animated: YES scrollPosition: UICollectionViewScrollPositionCenteredVertically];
//        NSLog(@"=x=");
    }else {
        [self.collectionView selectItemAtIndexPath: indexPath animated: NO scrollPosition: UICollectionViewScrollPositionCenteredVertically];
//        NSLog(@"===");
    }
    SimPickerViewCell *cell = (SimPickerViewCell *)[self.collectionView cellForItemAtIndexPath: indexPath];
    //使用動畫捲動時，在還未定位到Item位置時所取到的cell = Nil(因未還進入視野中不會有cell)
    //focusIndex 與程式指定的 indexPath.row 相同(代表動畫已經滑到該指定位置)時再觸發delegate didSelectRow
    if ((cell != Nil) && (focusIndex == indexPath.row)){
        [self cleanEventsOnFocusCell: cell];
        [self setupEventsOnFocusCell: cell];
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(pickerView:didSelectRow:)]) {
            if (_needForceDidSelectRow || (_lastSelectIndex != focusIndex)) {
                _needForceDidSelectRow = NO;
                [self.delegate pickerView: self didSelectRow: indexPath.item];
            }
        }
        _lastSelectIndex = indexPath.row;
    }else {
//        DMLog(@"didSelectItemAtIndexPath:cell is nil");
    }


}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SimPickerViewCell *cell = (SimPickerViewCell *)[self.collectionView cellForItemAtIndexPath: indexPath];
    [self cleanEventsOnFocusCell: cell];
}


- (NSIndexPath *)getLastIndexPath
{
    NSInteger lastItem = [self.collectionView numberOfItemsInSection: 0] - 1;
    return [NSIndexPath indexPathForItem: lastItem inSection:0];
}


- (void)reloadDataWithCompleteion:(void (^)(void))completeion;
{
    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SimPickerViewCell *cell = (SimPickerViewCell *)obj;
        [self cleanEventsOnFocusCell:cell];
    }];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {
        NSIndexPath *focusedIndexPath = [self getFocusIndexPath];
        [self didSelectItemAtRowInternal:focusedIndexPath.row];
        completeion();
    }];

}

// remove comment if we want have a chance
// to animate add/delete operations ourself.

- (void)deleteRow:(NSInteger)row
{
    NSIndexPath *last = [self getLastIndexPath];

    // check range
    if (row > last.item ||
        row < 0) {
        DMLog(@"delete indexPath error : %ld", (long)row);
        return;
    }

    if ([self.collectionView numberOfItemsInSection: 0] == 1) {
        return;
    }

    // Delete the item from the data source.
    if ([self.delegate callbackDeleteRow: row]) {
        // Now delete the items from the collection view.
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem: row inSection: 0];
        [self.collectionView deleteItemsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil]];
        _needForceDidSelectRow = YES;
        if ([indexPath isEqual: last]) {
            // the indexPath has just been deleted, refetch lastIndexPath
            [self collectionView:self.collectionView didSelectItemAtIndexPath: [self getLastIndexPath]];
        }
        else {
            [self collectionView:self.collectionView didSelectItemAtIndexPath: indexPath];
        }
    }
}


- (void)insertItem:(id)newItem atRow:(NSInteger)row
{
    // insert item to data source
    if ([self.delegate callbackInsertItem: newItem atRow: row]) {
        // Now add the items to the collection view.
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem: row inSection: 0];
        [self.collectionView insertItemsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil]];
        _needForceDidSelectRow = YES;
        [self collectionView:self.collectionView didSelectItemAtIndexPath: indexPath];
    }
}

- (void)insertItem:(id)newItem afterRow:(NSInteger)row
{
    [self insertItem: newItem atRow: row + 1];
}

#pragma mark - get focus info
- (NSIndexPath *)getFocusIndexPath
{
    CGPoint centerPoint = CGPointMake(self.collectionView.frame.size.width / 2 + self.collectionView.contentOffset.x, self.collectionView.frame.size.height /2 + self.collectionView.contentOffset.y);
    NSIndexPath *indexPathOfCentralCell = [self.collectionView indexPathForItemAtPoint:centerPoint];
    return  indexPathOfCentralCell;
}

- (NSIndexPath *)predictedFocusIndexPath
{
    return ((CenterLayout *)self.collectionView.collectionViewLayout).focusedIndex;
}

#pragma mark - scrolling handlers
- (CGFloat)yDiff: (CGPoint)point1 and:(CGPoint)point2
{
    return ABS(point2.y - point1.y);
}

- (BOOL)cellScrollOutFocus
{
    const CGFloat monitorOffset = _CellHeight/2;
    return (self.trackingFocusedCell &&
            [self yDiff: self.offsetBeforeRecording
                    and: [self.collectionView contentOffset]] > monitorOffset);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.trackingFocusedCell = YES;
    self.offsetBeforeRecording = [self.collectionView contentOffset];
//    NSLog(@"scrollViewWillBeginDragging");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self cellScrollOutFocus]) {
        // release buttons
        [self.buttonDelete removeFromSuperview];
        [self.buttonDisclosure removeFromSuperview];
        self.trackingFocusedCell = NO;
    }
    _isScrolling = YES;
//    NSLog(@"scrollViewDidScroll");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self collectionView: self.collectionView didSelectItemAtIndexPath: [self predictedFocusIndexPath]];
//        NSLog(@"scrollViewDidEndDragging-decelerate");
    }
//    NSLog(@"scrollViewDidEndDragging");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self collectionView: self.collectionView didSelectItemAtIndexPath: [self predictedFocusIndexPath]];
    _isScrolling = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _isScrolling = NO;
    [self setUserInteractionEnabled:YES];
    [self collectionView: self.collectionView didSelectItemAtIndexPath: [self getFocusIndexPath]];
//    NSLog(@"scrollViewDidEndScrollingAnimation");
}
#pragma mark - focus cell events setup/clean

- (void)setupEventsOnFocusCell: (SimPickerViewCell *)cell
{
    [cell addButton: self.buttonDisclosure];
    [cell addGestureRecognizer: self.swipeGestureDirectionRight];
    [cell addGestureRecognizer: self.swipeGestureDirectionLeft];
    [cell addGestureRecognizer: self.longGesture];
    [cell addGestureRecognizer: self.tapGesture];
}

- (void)cleanEventsOnFocusCell: (SimPickerViewCell *)cell
{
    [self.buttonDisclosure removeFromSuperview];
    [self.buttonDelete removeFromSuperview];
    [cell removeGestureRecognizer: self.swipeGestureDirectionRight];
    [cell removeGestureRecognizer: self.swipeGestureDirectionLeft];
    [cell removeGestureRecognizer: self.longGesture];
    [cell removeGestureRecognizer: self.tapGesture];
}

#pragma mark - Target Action

- (IBAction)buttonDisclosurePressed:(UIButton *)btn
{
    //DMLog(@"disclosure button pressed");
    NSIndexPath *focusIndexPath = [self getFocusIndexPath];
    if ([self.delegate respondsToSelector:@selector(buttonDisclosurePressed:onIndex:)]) {
        [self.delegate buttonDisclosurePressed: btn onIndex: focusIndexPath.item];
    }
}

- (IBAction)buttonDeletePressed:(UIButton *)btn
{
    //DMLog(@"delete button pressed");
    NSIndexPath *focusIndexPath = [self getFocusIndexPath];
    if ([self.delegate respondsToSelector:@selector(buttonDeletePressed:onIndex:)]) {
        [self.delegate buttonDeletePressed: btn onIndex: focusIndexPath.item];
    }
    [self deleteRow: focusIndexPath.row];

}

- (IBAction)swipeGestureRecognized:(UISwipeGestureRecognizer *)gestureRecognizer
{
//    DMLog(@"swipeGestureRecognized direction:%ld",(long)gestureRecognizer.direction);

    NSIndexPath *focusIndexPath = [self getFocusIndexPath];
    SimPickerViewCell *focusCell = (SimPickerViewCell *)[self.collectionView cellForItemAtIndexPath: focusIndexPath];
    if ( [self.delegate respondsToSelector: @selector(shouldShowDeleteButtonOnIndex:)] &&
        [self.delegate shouldShowDeleteButtonOnIndex: focusIndexPath.item] &&
        (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight)
        ) {
        [self.buttonDisclosure removeFromSuperview];
        [focusCell addButton: self.buttonDelete];
    }else {
        [self.buttonDelete removeFromSuperview];
        [focusCell addButton: self.buttonDisclosure];
    }
}

- (void)longGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    NSIndexPath *focusIndexPath = [self getFocusIndexPath];
    if ( [self.delegate respondsToSelector: @selector(longTouchPressedOnIndex:)]) {
        [self.delegate longTouchPressedOnIndex: focusIndexPath.item];
    }
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    NSIndexPath *focusIndexPath = [self getFocusIndexPath];
    SimPickerViewCell *focusCell = (SimPickerViewCell *)[self.collectionView cellForItemAtIndexPath: focusIndexPath];
    if (focusCell == Nil) {
        return;
    }
    CGPoint centerPoint = self.collectionView.center;
    CGFloat yUP = centerPoint.y - (focusCell.frame.size.height/2) - 2;
    CGFloat yDown = yUP + focusCell.frame.size.height + 2;
    CGFloat yNow = point.y;
    NSInteger rowVariable = 0;
    if (yNow < yUP) {
        rowVariable = -1;
    }
    if (yNow > yDown) {
        rowVariable = 1;
    }

    NSInteger row = focusIndexPath.row;
    NSInteger numberOfRow = 0;
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(numberOfRowsInPickerView:)])
    {
        numberOfRow = [self.delegate numberOfRowsInPickerView: self];
        NSInteger nextRow = MAX(0,MIN(row + rowVariable, numberOfRow -1));
        if (nextRow != focusIndexPath.row) {
            _needForceDidSelectRow = YES;
            [self setUserInteractionEnabled:NO];
            [self didSelectItemAtRowInternal:nextRow];
        }
    }

}
- (void)tapGestureRecognizedForCell:(UITapGestureRecognizer *)gestureRecognizer
{
//    NSLog(@"tapGestureRecognizedForCell");
}

- (void)allGestureRecognized:(UIGestureRecognizer *)gestureRecognizer
{
//    NSLog(@"allGestureRecognized");
}

// events come from supplementary view
- (void)getTouchInViewKind:(NSString *)reuseId
{
    //DMLog(@"get reuse id = %@", reuseId);
    if ([reuseId isEqualToString: HeaderID]) {
        [self collectionView: self.collectionView didSelectItemAtIndexPath: [NSIndexPath indexPathForItem: 0 inSection: 0]];
    }
    else if ([reuseId isEqualToString: FooterID]) {
        [self collectionView: self.collectionView didSelectItemAtIndexPath: [self getLastIndexPath]];
    }
    else {
        NSAssert1(NO, @"invalid reUse ID: %@", reuseId);
    }
}

#pragma mark - wrapper interface
- (void)didSelectItemAtRow:(NSInteger)row
{
    _needForceDidSelectRow = YES;
    [self collectionView: self.collectionView didSelectItemAtIndexPath: [NSIndexPath indexPathForItem: row inSection: 0]];
}

- (void)didSelectItemAtRowInternal:(NSInteger)row
{
    [self collectionView: self.collectionView didSelectItemAtIndexPath: [NSIndexPath indexPathForItem: row inSection: 0]];
}
@end
