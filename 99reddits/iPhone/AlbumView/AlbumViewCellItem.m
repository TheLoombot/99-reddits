//
//  AlbumViewCellItem.m
//  99reddits
//
//  Created by Frank Jacob on 10/13/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import "AlbumViewCellItem.h"
#import "AlbumViewCell.h"
#import "AlbumViewController.h"
#import "RedditsAppDelegate.h"

@implementation AlbumViewCellItem

@synthesize photo;
@synthesize bFavorites;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		overlayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
		[self addSubview:overlayView];
		
		favoriteOverlayView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 25, 25)];
		[self addSubview:favoriteOverlayView];
		
		self.photo = nil;
    }
    return self;
}

- (void)dealloc {
	appDelegate = nil;
	[photo release];
	[overlayView release];
	[favoriteOverlayView release];
	[super dealloc];
}

- (void)setPhoto:(PhotoItem *)_photo {
	[photo release];
	photo = nil;
	
	if (_photo) {
		self.hidden = NO;
		
		photo = [_photo retain];
		
		if (bFavorites) {
			overlayView.hidden = YES;
			overlayView.image = nil;
			
			favoriteOverlayView.hidden = YES;
			favoriteOverlayView.image = nil;
		}
		else {
			if ([photo isShowed]) {
				overlayView.hidden = NO;
				overlayView.image = [UIImage imageNamed:@"Overlay.png"];
			}
			else {
				overlayView.hidden = YES;
				overlayView.image = nil;
			}
			
			if ([appDelegate isFavorite:photo]) {
				favoriteOverlayView.hidden = NO;
				favoriteOverlayView.image = [UIImage imageNamed:@"FavoritesMask.png"];
			}
			else {
				favoriteOverlayView.hidden = YES;
				favoriteOverlayView.image = nil;
			}
		}
	}
	else {
		self.hidden = YES;
		overlayView.image = nil;
		favoriteOverlayView.image = nil;
	}
}

@end
