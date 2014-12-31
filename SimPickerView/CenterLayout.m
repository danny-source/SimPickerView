//
//  CenterLayout.m
//  TestScrollTable
//
//  Created by CHING PING on 2014/12/19.
//  Copyright (c) 2014年 CHING PING. All rights reserved.
//

#import "CenterLayout.h"


@implementation CenterLayout {
    CGSize contentSize;
    CGFloat yOffsetForAllItems;
    CGFloat cellHeight_;
    NSInteger displayedItems_;
    NSInteger emptyItems_;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _focusedIndex = [NSIndexPath indexPathForItem: 0 inSection: 0];
    }
    return self;
}

- (instancetype)initWithCellHeight:(CGFloat)cellHeight displayedItems:(NSInteger)displayedItems minimumLineSpacing:(CGFloat)minimumLineSpacing
{
    self = [self init];
    if (self) {
        cellHeight_ = cellHeight;
        displayedItems_ = displayedItems;
        emptyItems_ = displayedItems_/2;
        // item 的間隔, property of parent class
        self.minimumLineSpacing = minimumLineSpacing;
    }
    return self;
}

- (void)prepareLayout
{
    self.itemSize = CGSizeMake(self.collectionView.frame.size.width, cellHeight_);
    // clean out anything we cached previously
    self.storedAttributes = [NSMutableDictionary dictionary];
    // 呼叫 parent，framework 的 prepareLayout 內建是沒有任何動作
    [super prepareLayout];

    // 計算 collection view 的高度
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    CGFloat contentHeight = (itemCount + emptyItems_ * 2) * cellHeight_ + (itemCount + emptyItems_ * 2 - 1) * self.minimumLineSpacing;
    // 這個 function 的目的，就是算出 collection view content size ，並算出起始的 item 的 y pos

    contentSize = CGSizeMake(self.collectionView.bounds.size.width, contentHeight);
    self.collectionView.contentSize = contentSize;
    yOffsetForAllItems = emptyItems_ * (cellHeight_ + self.minimumLineSpacing);
    //DMLog(@"content size = (%f, %f)",contentSize.width, contentSize.height);

    // 為每一個 item 設定位置
    for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem: i inSection: 0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath: indexPath];
        attributes.frame = CGRectMake(0, yOffsetForAllItems + i * (cellHeight_ + self.minimumLineSpacing),
                                      self.collectionView.contentSize.width, cellHeight_);
        //DMLog(@"attributes.frame = (%.2f, %.2f, %.2f, %.2f)", attributes.frame.origin.x, attributes.frame.origin.y, attributes.frame.size.width, attributes.frame.size.height);
        self.storedAttributes[indexPath] = attributes;
    }

}

- (CGSize)collectionViewContentSize
{
    return contentSize;
}


- (CGPoint)targetContentOffsetForProposedContentOffset: (CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    //proposedContentOffset是没有对齐到网格时本来应该停下的位置
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat virticalCenter = proposedContentOffset.y + (CGRectGetHeight(self.collectionView.bounds) / 2.0);
    CGRect targetRect = CGRectMake(0.0, proposedContentOffset.y , self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [self layoutAttributesForElementsInRect:targetRect];

    //对当前屏幕中的UICollectionViewLayoutAttributes逐个与屏幕中心进行比较，找出最接近中心的一个

// DEBUG_FINAL_INDEXPATH
  NSIndexPath *finalIndexPath;

    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemVirticalCenter = layoutAttributes.center.y;
        if (ABS(itemVirticalCenter - virticalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemVirticalCenter - virticalCenter;

//DEBUG_FINAL_INDEXPATH
          finalIndexPath = layoutAttributes.indexPath;

        }
    }
//  DEBUG_FINAL_INDEXPATH
    DMLog(@"final index = %ld", finalIndexPath.item);
    self.focusedIndex = finalIndexPath;
    return CGPointMake(proposedContentOffset.x, proposedContentOffset.y + offsetAdjustment);
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // 銜接上一個 rect 不然會有漏算的 cell
    rect.origin.y -= yOffsetForAllItems;
    //DMLog(@"range rect = (%.2f, %.2f, %.2f, %.2f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    NSMutableArray *allItems = [[super layoutAttributesForElementsInRect: rect] mutableCopy];
    [allItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UICollectionViewLayoutAttributes *attributes = obj;
        UICollectionViewLayoutAttributes *storedAttributes = (UICollectionViewLayoutAttributes *)self.storedAttributes[attributes.indexPath];
        attributes.frame = storedAttributes.frame;

        //DMLog(@"rect(%ld) = (%.2f, %.2f, %.2f, %.2f)",attributes.indexPath.item, attributes.frame.origin.x, attributes.frame.origin.y, attributes.frame.size.width, attributes.frame.size.height);
    }];
    return allItems;
}


// add/delete item will query here
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.storedAttributes[indexPath];
}


@end
