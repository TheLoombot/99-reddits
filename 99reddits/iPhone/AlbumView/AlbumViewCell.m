//
//  AlbumViewCell.m
//  99reddits
//
//  Created by Frank Jacob on 10/13/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import "AlbumViewCell.h"
#import "AlbumViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation AlbumViewCell

@synthesize albumViewController;
@synthesize photo;
@synthesize bFavorites;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.contentView.backgroundColor = [UIColor clearColor];

		appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];

		self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
		[self.contentView addSubview:self.imageView];

		favoriteOverlayView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 25, 25)];
		[self.contentView addSubview:favoriteOverlayView];

		tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
		tapButton.frame = self.imageView.frame;
		[tapButton setImage:[UIImage imageNamed:@"ButtonOverlay.png"] forState:UIControlStateHighlighted];
		[tapButton addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:tapButton];
	}
	return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];

  //No flickering images!
  self.imageView.image = nil;
}

- (void)onTap:(id)sender {
	[albumViewController onSelectPhoto:photo];
}

- (void)setPhoto:(PhotoItem *)_photo {
	photo = nil;

	photo = _photo;

	if (bFavorites) {
		favoriteOverlayView.hidden = YES;
		favoriteOverlayView.image = nil;
	}
	else {
		if ([appDelegate isFavorite:photo]) {
			favoriteOverlayView.hidden = NO;
			favoriteOverlayView.image = [UIImage imageNamed:@"FavoritesRedIcon.png"];
		}
		else {
			favoriteOverlayView.hidden = YES;
			favoriteOverlayView.image = nil;
		}
	}
}

- (void)setThumbImage:(UIImage *)thumbImage animated:(BOOL)animated {
	[animateImageView.layer removeAllAnimations];
	[animateImageView removeFromSuperview];
	animateImageView = nil;

	if (thumbImage == nil) {
		self.imageView.image = [UIImage imageNamed:@"DefaultPhoto.png"];
		imageEmpty = YES;
	}
	else {
		if (animated || imageEmpty) {
			self.imageView.image = [UIImage imageNamed:@"DefaultPhoto.png"];
			animateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
			animateImageView.image = thumbImage;
			[self.contentView addSubview:animateImageView];

			animateImageView.alpha = 0.0;
			[UIView animateWithDuration:0.2
							 animations:^(void) {
								 animateImageView.alpha = 1.0;
							 }
							 completion:^(BOOL finished) {
								 [animateImageView removeFromSuperview];
								 animateImageView = nil;
								 if (finished) {
									 self.imageView.image = thumbImage;
								 }
							 }];
		}
		else {
			self.imageView.image = thumbImage;
		}
		imageEmpty = NO;
	}
}

@end
