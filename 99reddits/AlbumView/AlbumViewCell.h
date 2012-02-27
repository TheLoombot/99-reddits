//
//  AlbumViewCell.h
//  99reddits
//
//  Created by Frank Jacob on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AlbumViewController;
@class AlbumViewCellItem;

@interface AlbumViewCell : UITableViewCell {
	AlbumViewController *albumViewController;
	
	NSMutableArray *photosArray;
	int row;
	
	AlbumViewCellItem *item1;
	AlbumViewCellItem *item2;
	AlbumViewCellItem *item3;
	AlbumViewCellItem *item4;
	
	BOOL bFavorites;
}

@property (nonatomic, retain) AlbumViewController *albumViewController;
@property (nonatomic, retain) NSMutableArray *photosArray;
@property (nonatomic) int row;
@property (nonatomic) BOOL bFavorites;

- (void)setImage:(UIImage *)image index:(int)index;

@end
