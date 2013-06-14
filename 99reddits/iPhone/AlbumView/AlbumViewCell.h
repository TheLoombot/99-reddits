//
//  AlbumViewCell.h
//  99reddits
//
//  Created by Frank Jacob on 10/13/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItem.h"

@class RedditsAppDelegate;
@class AlbumViewController;

@interface AlbumViewCell : UICollectionViewCell {
	RedditsAppDelegate *appDelegate;
	AlbumViewController *albumViewController;
	
	PhotoItem *photo;
	BOOL bFavorites;

	UIImageView *favoriteOverlayView;
	UIImageView *animateImageView;
	UIImageView *imageView;
	UIButton *tapButton;

	BOOL imageEmpty;
}

@property (nonatomic, assign) AlbumViewController *albumViewController;
@property (nonatomic, retain) PhotoItem *photo;
@property (nonatomic) BOOL bFavorites;

- (void)setThumbImage:(UIImage *)thumbImage animated:(BOOL)animated;

@end
