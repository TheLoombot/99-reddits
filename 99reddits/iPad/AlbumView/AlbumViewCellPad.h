//
//  AlbumViewCellPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItem.h"

@class RedditsAppDelegate;
@class AlbumViewControllerPad;

@interface AlbumViewCellPad : UICollectionViewCell {
	RedditsAppDelegate *appDelegate;
	AlbumViewControllerPad __weak *albumViewController;

	PhotoItem *photo;
	BOOL bFavorites;

	UIView *imageOutlineView;
	UIImageView *favoriteOverlayView;
	UIImageView *animateImageView;
	UIImageView *imageView;
	UIButton *tapButton;

	BOOL imageEmpty;
}

@property (nonatomic, weak) AlbumViewControllerPad *albumViewController;
@property (nonatomic, strong) PhotoItem *photo;
@property (nonatomic) BOOL bFavorites;

- (void)setThumbImage:(UIImage *)thumbImage animated:(BOOL)animated;

@end
