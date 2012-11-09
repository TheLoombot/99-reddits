//
//  MainViewCellPad.m
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "MainViewCellPad.h"
#import "MainViewCellItemPad.h"
#import "UserDef.h"
#import "RedditsAppDelegate.h"
#import "MainViewControllerPad.h"

@implementation MainViewCellPad

@synthesize mainViewController;
@synthesize subRedditsArray;
@synthesize row;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
		appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		itemViewsArray = [[NSMutableArray alloc] init];
		for (int i = 0; i < LAND_COL_COUNT; i ++) {
			MainViewCellItemPad *cellItem = [[MainViewCellItemPad alloc] initWithFrame:CGRectMake(0, 0, 135, 175)];
			cellItem.mainViewCell = self;
			cellItem.tag = i;
			[self addSubview:cellItem];
			[itemViewsArray addObject:cellItem];
			[cellItem release];
		}
    }
    return self;
}

- (void)dealloc {
	[itemViewsArray release];
	[super dealloc];
}

- (void)setRow:(int)_row {
	row = _row;
	
	int colCount = PORT_COL_COUNT;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
		colCount = LAND_COL_COUNT;

	for (int i = 0; i < colCount; i ++) {
		MainViewCellItemPad *cellItem = [itemViewsArray objectAtIndex:i];
		int index = colCount * row + i - 1;
		if (index >= 0 && index > subRedditsArray.count - 1) {
			cellItem.alpha = 0.0;
		}
		else {
			cellItem.alpha = 1.0;
			
			if (index == -1) {
				[cellItem setTotalCount:appDelegate.favoritesItem.photosArray.count];
				cellItem.nameLabel.text = appDelegate.favoritesItem.nameString;
			}
			else {
				SubRedditItem *subReddit = [subRedditsArray objectAtIndex:index];
				[cellItem setUnshowedCount:subReddit.unshowedCount totalCount:subReddit.photosArray.count loading:subReddit.loading];
				cellItem.nameLabel.text = subReddit.nameString;
			}
		}
	}
}

- (void)setImage:(UIImage *)image index:(int)index {
	MainViewCellItemPad *cellItem = [itemViewsArray objectAtIndex:index];
	[cellItem setImage:image];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	int colCount = PORT_COL_COUNT;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
		colCount = LAND_COL_COUNT;
	
	if (colCount == PORT_COL_COUNT) {
		for (int i = 0; i < LAND_COL_COUNT; i ++) {
			MainViewCellItemPad *cellItem = [itemViewsArray objectAtIndex:i];
			cellItem.frame = CGRectMake(20 + 148 * i, 0, 135, 200);
			[cellItem setEditing:mainViewController.editing];

			int index = colCount * row + i;
			if (index > subRedditsArray.count) {
				cellItem.alpha = 0.0;
			}
			else {
				cellItem.alpha = 1.0;
			}
		}
		for (int i = PORT_COL_COUNT; i < LAND_COL_COUNT; i ++) {
			MainViewCellItemPad *cellItem = [itemViewsArray objectAtIndex:i];
			cellItem.alpha = 0.0;
		}
	}
	else {
		for (int i = 0; i < LAND_COL_COUNT; i ++) {
			MainViewCellItemPad *cellItem = [itemViewsArray objectAtIndex:i];
			cellItem.frame = CGRectMake(8 + 143 * i, 0, 135, 220);
			[cellItem setEditing:mainViewController.editing];
			
			int index = colCount * row + i;
			if (index > subRedditsArray.count) {
				cellItem.alpha = 0.0;
			}
			else {
				cellItem.alpha = 1.0;
			}
		}
	}
}

- (void)onClick:(int)index {
	int colCount = PORT_COL_COUNT;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
		colCount = LAND_COL_COUNT;
	[mainViewController showSubRedditAtIndex:row * colCount + index - 1];
}

- (void)onDeleteButton:(int)index {
	int colCount = PORT_COL_COUNT;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
		colCount = LAND_COL_COUNT;
	[mainViewController removeSubRedditAtIndex:row * colCount + index - 1];
}

@end
