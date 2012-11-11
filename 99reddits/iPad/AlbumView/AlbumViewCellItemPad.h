//
//  AlbumViewCellItemPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItem.h"

@class RedditsAppDelegate;

@interface AlbumViewCellItemPad : UIButton {
	RedditsAppDelegate *appDelegate;
	
	PhotoItem *photo;
	
	UIView *tapView;
	UIImageView *imageView;
	UIImageView *overlayView;
	UIImageView *favoriteOverlayView;
	
	BOOL bFavorites;
}

@property (nonatomic, retain) PhotoItem *photo;
@property (nonatomic) BOOL bFavorites;

- (void)setItemImage:(UIImage *)image;

@end
