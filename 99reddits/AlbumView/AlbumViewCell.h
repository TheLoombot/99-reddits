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
}

@property (nonatomic, assign) AlbumViewController *albumViewController;
@property (nonatomic, assign) NSMutableArray *photosArray;
@property (nonatomic) int row;

- (void)setImage:(UIImage *)image index:(int)index;

@end
