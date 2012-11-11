//
//  AlbumViewCellPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumViewControllerPad;
@class AlbumViewCellItemPad;

@interface AlbumViewCellPad : UITableViewCell {
	AlbumViewControllerPad *albumViewController;
	
	NSMutableArray *photosArray;
	int row;
	
	NSMutableArray *itemViewsArray;
	
	BOOL bFavorites;
}

@property (nonatomic, retain) AlbumViewControllerPad *albumViewController;
@property (nonatomic, retain) NSMutableArray *photosArray;
@property (nonatomic) int row;
@property (nonatomic) BOOL bFavorites;

- (void)setImage:(UIImage *)image index:(int)index;

@end
