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
		self.itemSize = CGSizeMake(75, 75);
		self.minimumInteritemSpacing = 0;
		self.minimumLineSpacing = 4;
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4);
	}

	return self;
}

- (void)dealloc {
	[deleteIndexPaths release];
	[insertIndexPaths release];
	[super dealloc];
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

	[deleteIndexPaths release];
	deleteIndexPaths = nil;
	[insertIndexPaths release];
	insertIndexPaths = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
	if (attributes == nil)
		return nil;

	if ([insertIndexPaths containsObject:itemIndexPath]) {
		int row = itemIndexPath.item / 4;
		int col = itemIndexPath.item % 4;
		attributes.frame = CGRectMake(4 + col * 79, 4 + row * 79, 75, 75);
		attributes.alpha = 0.0;
		attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
	}

	return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
	UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
	if (attributes == nil)
		return nil;

	if ([deleteIndexPaths containsObject:itemIndexPath]) {
		int row = itemIndexPath.item / 4;
		int col = itemIndexPath.item % 4;
		attributes.frame = CGRectMake(4 + col * 79, 4 + row * 79, 75, 75);
		attributes.alpha = 0.0;
		attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
	}

	return attributes;
}

@end
