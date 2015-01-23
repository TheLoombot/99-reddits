//
//  AlbumViewLayoutPad.m
//  99reddits
//
//  Created by Frank Jacob on 6/18/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import "AlbumViewLayoutPad.h"

@implementation AlbumViewLayoutPad

- (id)init {
	self = [super init];
	if (self) {
		self.itemSize = CGSizeMake(120, 120);
		self.minimumLineSpacing = 30;
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
			self.minimumInteritemSpacing = 23;
			self.sectionInset = UIEdgeInsetsMake(79, 23, 15, 23);
		}
		else {
			self.minimumInteritemSpacing = 28;
			self.sectionInset = UIEdgeInsetsMake(79, 28, 15, 28);
		}
	}

	return self;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
		NSInteger row = indexPath.item / 7;
		NSInteger col = indexPath.item % 7;
		attributes.frame = CGRectMake(23 + col * 143, 15 + row * 150, 120, 120);
	}
	else {
		NSInteger row = indexPath.item / 5;
		NSInteger col = indexPath.item % 5;
		attributes.frame = CGRectMake(28 + col * 148, 15 + row * 150, 120, 120);
	}
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
		if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
			NSInteger row = itemIndexPath.item / 7;
			NSInteger col = itemIndexPath.item % 7;
			attributes.frame = CGRectMake(23 + col * 143, 79 + row * 150, 120, 120);
		}
		else {
			NSInteger row = itemIndexPath.item / 5;
			NSInteger col = itemIndexPath.item % 5;
			attributes.frame = CGRectMake(28 + col * 148, 79 + row * 150, 120, 120);
		}
		attributes.alpha = 0.0;
		attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
		attributes.zIndex = -1;
	}
	else {
		if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
			NSInteger row = (itemIndexPath.item + count) / 7;
			NSInteger col = (itemIndexPath.item + count) % 7;
			attributes.frame = CGRectMake(23 + col * 143, 79 + row * 150, 120, 120);
		}
		else {
			NSInteger row = (itemIndexPath.item + count) / 5;
			NSInteger col = (itemIndexPath.item + count) % 5;
			attributes.frame = CGRectMake(28 + col * 148, 79 + row * 150, 120, 120);
		}
	}

	return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];

	if (attributes == nil)
		attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];

	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
		NSInteger row = itemIndexPath.item / 7;
		NSInteger col = itemIndexPath.item % 7;
		attributes.frame = CGRectMake(23 + col * 143, 79 + row * 150, 120, 120);
	}
	else {
		NSInteger row = itemIndexPath.item / 5;
		NSInteger col = itemIndexPath.item % 5;
		attributes.frame = CGRectMake(28 + col * 148, 79 + row * 150, 120, 120);
	}

	if ([deleteIndexPaths containsObject:itemIndexPath]) {
		attributes.alpha = 0.0;
		attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
		attributes.zIndex = -1;
	}

	return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
		self.minimumInteritemSpacing = 23;
		self.sectionInset = UIEdgeInsetsMake(79, 23, 15, 23);
	}
	else {
		self.minimumInteritemSpacing = 28;
		self.sectionInset = UIEdgeInsetsMake(79, 28, 15, 28);
	}

	return YES;
}

@end
