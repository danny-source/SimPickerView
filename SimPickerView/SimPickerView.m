//
//  SimPickerView.m
//  SimPickerView
//
//  Created by CHING PING on 2014/12/31.
//  Copyright (c) 2014年 CHING PING. All rights reserved.
//

#import "SimPickerView.h"
#import "CenterLayout.h"
#import "MyCell.h"

@implementation SimPickerView


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit: self.frame];
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
    _collectionView = [[UICollectionView alloc]
                       initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)
                       collectionViewLayout: [[CenterLayout alloc] initWithCellHeight: _CellHeight  displayedItems: _DisplayedItems minimumLineSpacing: _MinLineSpacing]];

    _CellHeight = (frame.size.height - (_MinLineSpacing * (_DisplayedItems -1))) / _DisplayedItems;

    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self addSubview: _collectionView];

    _items = [NSMutableArray arrayWithObjects:@"item 0", @"item 1", @"item 2", @"item 3", @"item 4", @"item 5", @"item 6", @"item 7", @"item 8", @"item 9", @"item 10", @"item 11", @"item 12" , @"item 13", @"item 14", @"item 15", @"item 16", nil];

    [_collectionView registerClass: [MyCell class] forCellWithReuseIdentifier: @"cell"];
    // we want only execute this for the first time
//    static dispatch_once_t once;
//    dispatch_once(&once, ^ {
//        [self collectionView:self.collectionView didSelectItemAtIndexPath: [NSIndexPath indexPathForItem: 0 inSection: 0]];
//    });

}


- (void)initFocusGlass
{
    NSInteger emptyItemSpaces = self.DisplayedItems / 2;
    CGRect focusPlaceholder = CGRectInset(self.collectionView.frame, 0, (self.CellHeight + self.MinLineSpacing) * emptyItemSpaces);

    self.focusImageView = [[UIImageView alloc] initWithFrame: focusPlaceholder];
    [self addSubview: self.focusImageView];

}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    cell.name.text = self.items[indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

    CGSize itemSize = CGSizeMake(self.collectionView.bounds.size.width, self.CellHeight);
    DMLog(@"itemSize = %.2f, %.2f", itemSize.width, itemSize.height);
    return itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //DMLog(@"select item %ld", (long)indexPath.item);
    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MyCell *cell = (MyCell *)obj;
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }];

    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];

    MyCell *cell = (MyCell *)[self.collectionView cellForItemAtIndexPath: indexPath];
    cell.backgroundColor = [UIColor colorWithWhite: 0.9 alpha: 1.0];

}


- (IBAction)onDelete:(id)sender
{
    NSArray *selectedItems = [self.collectionView indexPathsForSelectedItems];

    [selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self deleteItemAtIndexPath: obj];
    }];
}


- (IBAction)onAdd:(id)sender
{
    NSArray *selectedItems = [self.collectionView indexPathsForSelectedItems];

    // even we use single selection,
    // the API is still for multiple selection, so we use
    // map to accomodate the API
    [selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //[self insertItem:@"ipsum lorum" atIndexPath: obj];
        [self appendItem: @"Ipsum Loram" afterIndexPath: obj];
    }];

}



- (NSIndexPath *)getLastIndexPath
{
    NSInteger lastItem = [self.collectionView numberOfItemsInSection: 0] - 1;
    return [NSIndexPath indexPathForItem: lastItem inSection:0];
}


- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isLastOne = [indexPath isEqual: [self getLastIndexPath]];

    [self.collectionView performBatchUpdates:^{

        // Delete the item from the data source.
        [self.items removeObjectAtIndex: indexPath.item];
        // Now delete the items from the collection view.
        [self.collectionView deleteItemsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil]];

    } completion:^(BOOL finished) {

        NSIndexPath *focusedIndexPath = indexPath;

        if (isLastOne) {
            // the indexPath has been deleted
            focusedIndexPath = [self getLastIndexPath];
        }

        [self collectionView:self.collectionView didSelectItemAtIndexPath: focusedIndexPath];
    }];

}

- (void)insertItem:(id)newItem atIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView performBatchUpdates:^{

        // insert item to data source
        [self.items insertObject: newItem atIndex: indexPath.item];
        // Now add the items to the collection view.
        [self.collectionView insertItemsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil]];

    } completion:^(BOOL finished) {

        [self collectionView:self.collectionView didSelectItemAtIndexPath: indexPath];
    }];

}

- (void)appendItem:(id)newItem afterIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *target = [NSIndexPath indexPathForItem: indexPath.item + 1 inSection: indexPath.section];

    [self.collectionView performBatchUpdates:^{

        // insert item to data source
        [self.items insertObject: newItem atIndex: target.item];
        // Now add the items to the collection view.
        [self.collectionView insertItemsAtIndexPaths: [NSArray arrayWithObjects: target, nil]];

    } completion:^(BOOL finished) {

        [self collectionView:self.collectionView didSelectItemAtIndexPath: target];
    }];

}

#pragma mark - scrolling detection

- (NSIndexPath *)getFocusItemIndexPath
{
    return ((CenterLayout *)self.collectionView.collectionViewLayout).focusedIndex;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self collectionView: self.collectionView didSelectItemAtIndexPath: [self getFocusItemIndexPath]];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self collectionView: self.collectionView didSelectItemAtIndexPath: [self getFocusItemIndexPath]];
}


@end
