//
//  AlbumViewCell.h
//  99reddits
//
//  Created by Frank Jacob on 10/13/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItem.h"

@class AlbumViewController;

@interface AlbumViewCell : UICollectionViewCell {
	AlbumViewController __weak *albumViewController;
	
	PhotoItem __weak *photo;
	BOOL bFavorites;

	UIImageView *favoriteOverlayView;
	UIImageView *animateImageView;
	UIButton *tapButton;

	BOOL imageEmpty;
}

@property (nonatomic, weak) AlbumViewController *albumViewController;
@property (nonatomic, weak) PhotoItem *photo;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) BOOL bFavorites;

- (void)setThumbImage:(UIImage *)thumbImage animated:(BOOL)animated;

@end
