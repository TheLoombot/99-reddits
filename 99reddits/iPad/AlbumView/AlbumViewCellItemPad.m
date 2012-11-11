//
//  AlbumViewCellItemPad.m
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "AlbumViewCellItemPad.h"
#import "AlbumViewCellPad.h"
#import "AlbumViewController.h"
#import "RedditsAppDelegate.h"

@implementation AlbumViewCellItemPad

@synthesize photo;
@synthesize bFavorites;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
		tapView.backgroundColor = [UIColor whiteColor];
		tapView.userInteractionEnabled = NO;
		[self addSubview:tapView];
		imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 108, 108)];
		[self addSubview:imageView];

		overlayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
//		[self addSubview:overlayView];
		
		favoriteOverlayView = [[UIImageView alloc] initWithFrame:CGRectMake(89, 89, 25, 25)];
		[self addSubview:favoriteOverlayView];
		
		self.photo = nil;
    }
    return self;
}

- (void)dealloc {
	appDelegate = nil;
	[photo release];
	[tapView release];
	[imageView release];
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

- (void)setItemImage:(UIImage *)image {
	if (image == nil) {
		tapView.frame = CGRectMake(0, 0, 120, 120);
		imageView.frame = CGRectMake(6, 6, 120, 120);
		imageView.image = nil;
	}
	else {
		int width = image.size.width;
		int height = image.size.height;
		if (width > height) {
			width = 108;
			height = height * width / image.size.width;
		}
		else {
			height = 108;
			width = width * height / image.size.height;
		}
		CGRect rect = CGRectMake((int)(108 - width) / 2 + 6, (int)(108 - height) / 2 + 6, width, height);
		imageView.frame = rect;
		imageView.image = image;
		
		rect.origin.x -= 6;
		rect.origin.y -= 6;
		rect.size.width += 12;
		rect.size.height += 12;
		tapView.frame = rect;
		overlayView.frame = rect;
		
		rect = imageView.frame;
		rect.origin.x += (rect.size.width - 25);
		rect.origin.y += (rect.size.height - 25);
		rect.size.width = 25;
		rect.size.height = 25;
		favoriteOverlayView.frame = rect;
	}
}

@end
