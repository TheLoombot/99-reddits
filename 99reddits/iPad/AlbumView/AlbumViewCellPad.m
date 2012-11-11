//
//  AlbumViewCellPad.m
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "AlbumViewCellPad.h"
#import "AlbumViewCellItemPad.h"
#import "AlbumViewControllerPad.h"
#import "UserDef.h"

@implementation AlbumViewCellPad

@synthesize albumViewController;
@synthesize photosArray;
@synthesize row;
@synthesize bFavorites;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		itemViewsArray = [[NSMutableArray alloc] init];
		for (int i = 0; i < LAND_COL_COUNT; i ++) {
			for (int i = 0; i < LAND_COL_COUNT; i ++) {
				AlbumViewCellItemPad *cellItem = [[AlbumViewCellItemPad alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
				[cellItem addTarget:self action:@selector(onItemClick:) forControlEvents:UIControlEventTouchUpInside];
				cellItem.tag = i;
				[self addSubview:cellItem];
				[itemViewsArray addObject:cellItem];
				[cellItem release];
			}
		}
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

- (void)setRow:(int)_row {
	for (AlbumViewCellItemPad *cellItem in itemViewsArray)
		cellItem.bFavorites = bFavorites;
	
	row = _row;
	
	int maxIndex = photosArray.count;
	
	int colCount = PORT_COL_COUNT;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
		colCount = LAND_COL_COUNT;
	
	for (int i = 0; i < colCount; i ++) {
		AlbumViewCellItemPad *cellItem = [itemViewsArray objectAtIndex:i];
		int index = row * colCount + i;
		if (index < maxIndex) {
			cellItem.photo = [photosArray objectAtIndex:index];
		}
		else {
			cellItem.photo = nil;
		}
	}
}

- (void)dealloc {
	[itemViewsArray release];
	[photosArray release];
	[albumViewController release];
	[super dealloc];
}

- (void)setImage:(UIImage *)image index:(int)index {
	AlbumViewCellItemPad *cellItem = [itemViewsArray objectAtIndex:index];
	[cellItem setItemImage:image];
}

- (void)onItemClick:(AlbumViewCellItemPad *)sender {
	[albumViewController onSelectPhoto:sender.photo];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	int colCount = PORT_COL_COUNT;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
		colCount = LAND_COL_COUNT;
	
	if (colCount == PORT_COL_COUNT) {
		for (int i = 0; i < LAND_COL_COUNT; i ++) {
			AlbumViewCellItemPad *cellItem = [itemViewsArray objectAtIndex:i];
			cellItem.frame = CGRectMake(28 + 148 * i, 15, 120, 120);
			
			int index = colCount * row + i;
			if (index >= photosArray.count) {
				cellItem.alpha = 0.0;
			}
			else {
				cellItem.alpha = 1.0;
			}
		}
		for (int i = PORT_COL_COUNT; i < LAND_COL_COUNT; i ++) {
			AlbumViewCellItemPad *cellItem = [itemViewsArray objectAtIndex:i];
			cellItem.alpha = 0.0;
		}
	}
	else {
		for (int i = 0; i < LAND_COL_COUNT; i ++) {
			AlbumViewCellItemPad *cellItem = [itemViewsArray objectAtIndex:i];
			cellItem.frame = CGRectMake(23 + 143 * i, 15, 120, 120);
			
			int index = colCount * row + i;
			if (index >= photosArray.count) {
				cellItem.alpha = 0.0;
			}
			else {
				cellItem.alpha = 1.0;
			}
		}
	}
}

@end
