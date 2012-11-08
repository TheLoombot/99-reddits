//
//  AlbumViewCellItem.h
//  99reddits
//
//  Created by Frank Jacob on 10/13/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItem.h"

@class RedditsAppDelegate;

@interface AlbumViewCellItem : UIButton {
	RedditsAppDelegate *appDelegate;
	
	PhotoItem *photo;
	
	UIImageView *overlayView;
	UIImageView *favoriteOverlayView;
	
	BOOL bFavorites;
}

@property (nonatomic, retain) PhotoItem *photo;
@property (nonatomic) BOOL bFavorites;

@end
