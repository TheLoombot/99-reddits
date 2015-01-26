//
//  AlbumViewLayout.m
//  99reddits
//
//  Created by Frank Jacob on 6/14/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import "AlbumViewLayout.h"

@implementation AlbumViewLayout

- (id)init {
	self = [super init];
	if (self) {
		space = (screenWidth - 300) / 5;
		offset = (screenWidth - 300 - space * 3) / 2;
		
		self.itemSize = CGSizeMake(75, 75);
		self.minimumInteritemSpacing = 0;
		self.minimumLineSpacing = 4;
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.sectionInset = UIEdgeInsetsMake(4, offset, 4, offset);
	}

	return self;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	NSInteger row = indexPath.item / 4;
	NSInteger col = indexPath.item % 4;
	attributes.frame = CGRectMake(offset + col * (75 + space), 4 + row * 79, 75, 75);
    return attributes;
}

- (void)prepareLayout {
	[super prepareLayout];

	cellCount = [[self collectionView] numberOfItemsInSection:0];
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
	[super prepareForCollectionViewUpdates:updateItems];

	deleteIndexPaths = [[NSMutableArray alloc] init];
	insertIndexPaths = [[NSMutableArray alloc] init];

	for (UICollectionViewUpdateItem *update in updateItems) {
		if (update.updateAction == UICollectionUpdateActionDelete) {
			[deleteIndexPaths addObject:update.indexPathBeforeUpdate];
		}
		else if (update.updateAction == UICollectionUpdateActionInsert) {
			[insertIndexPaths addObject:update.indexPathAfterUpdate];
		}
	}
}

- (void)finalizeCollectionViewUpdates {
	[super finalizeCollectionViewUpdates];

	deleteIndexPaths = nil;
	insertIndexPaths = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];

	if (attributes == nil)
		attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];

	NSInteger count = 0;
	for (NSIndexPath *indexPath in insertIndexPaths) {
		if (indexPath.row < itemIndexPath.row)
			count --;
	}
	for (NSIndexPath *indexPath in deleteIndexPaths) {
		if (indexPath.row < itemIndexPath.row + deleteIndexPaths.count)
			count ++;
	}

	if ([insertIndexPaths containsObject:itemIndexPath]) {
		NSInteger row = itemIndexPath.row / 4;
		NSInteger col = itemIndexPath.row % 4;
		attributes.frame = CGRectMake(offset + col * (75 + space), 4 + row * 79, 75, 75);
		attributes.alpha = 0.0;
		attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
		attributes.zIndex = -1;
	}
	else {
		NSInteger row = (itemIndexPath.row + count) / 4;
		NSInteger col = (itemIndexPath.row + count) % 4;
		attributes.frame = CGRectMake(offset + col * (75 + space), 4 + row * 79, 75, 75);
	}

	return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];

	if (attributes == nil)
		attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];

	NSInteger row = itemIndexPath.row / 4;
	NSInteger col = itemIndexPath.row % 4;
	attributes.frame = CGRectMake(offset + col * (75 + space), 4 + row * 79, 75, 75);

	if ([deleteIndexPaths containsObject:itemIndexPath]) {
		attributes.alpha = 0.0;
		attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
		attributes.zIndex = -1;
	}

	return attributes;
}

@end
