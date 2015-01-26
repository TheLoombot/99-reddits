//
//  AlbumViewCellPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItem.h"

@class AlbumViewControllerPad;

@interface AlbumViewCellPad : UICollectionViewCell {
	AlbumViewControllerPad __weak *albumViewController;

	PhotoItem __weak *photo;
	BOOL bFavorites;

	UIView *imageOutlineView;
	UIImageView *favoriteOverlayView;
	UIImageView *animateImageView;
	UIImageView *imageView;
	UIButton *tapButton;

	BOOL imageEmpty;
}

@property (nonatomic, weak) AlbumViewControllerPad *albumViewController;
@property (nonatomic, weak) PhotoItem *photo;
@property (nonatomic) BOOL bFavorites;

- (void)setThumbImage:(UIImage *)thumbImage animated:(BOOL)animated;

@end
