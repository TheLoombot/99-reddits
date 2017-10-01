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

@interface AlbumViewCell()

@property (strong, nonatomic) UIButton *tapButton;
@property (strong, nonatomic) UIImageView *animateImageView;
@property (strong, nonatomic) UIImageView *favoriteOverlayView;
@property (assign, nonatomic) BOOL isEmpty;

@end

@implementation AlbumViewCell

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
    self.clipsToBounds = YES;
		self.backgroundColor = [UIColor clearColor];
		self.contentView.backgroundColor = [UIColor clearColor];

		appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];

		self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
		[self.contentView addSubview:self.imageView];

		self.favoriteOverlayView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 25, 25)];
		[self.contentView addSubview:self.favoriteOverlayView];

		self.tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.tapButton.frame = self.imageView.frame;
    [self.tapButton setImage:[UIImage imageNamed:@"ButtonOverlay.png"] forState:UIControlStateHighlighted];
		[self.tapButton addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:self.tapButton];
	}
	return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];

  //No flickering images!
  self.imageView.image = nil;
}

- (void)onTap:(id)sender {
	[self.albumViewController onSelectPhoto:self.photo];
}

- (void)setPhoto:(PhotoItem *)aPhoto {
  _photo = nil;

	_photo = aPhoto;

	if (self.isInsideFavoriesAlbum) {
		self.favoriteOverlayView.hidden = YES;
		self.favoriteOverlayView.image = nil;
	}
	else {
		if ([appDelegate isFavorite:_photo]) {
			self.favoriteOverlayView.hidden = NO;
			self.favoriteOverlayView.image = [UIImage imageNamed:@"FavoritesRedIcon.png"];
		}
		else {
			self.favoriteOverlayView.hidden = YES;
			self.favoriteOverlayView.image = nil;
		}
	}
}

- (void)setThumbImage:(UIImage *)thumbImage animated:(BOOL)animated {
	[self.animateImageView.layer removeAllAnimations];
  [self.animateImageView removeFromSuperview];
	self.animateImageView = nil;

	if (thumbImage == nil) {
		self.imageView.image = [UIImage imageNamed:@"DefaultPhoto.png"];
		self.isEmpty = YES;
	}
	else {
		if (animated || self.isEmpty) {
			self.imageView.image = [UIImage imageNamed:@"DefaultPhoto.png"];
			self.animateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
			self.animateImageView.image = thumbImage;
			[self.contentView addSubview:self.animateImageView];

			self.animateImageView.alpha = 0.0;
			[UIView animateWithDuration:0.2
							 animations:^(void) {
								 self.animateImageView.alpha = 1.0;
							 }
							 completion:^(BOOL finished) {
								 [self.animateImageView removeFromSuperview];
								 self.animateImageView = nil;
								 if (finished) {
									 self.imageView.image = thumbImage;
								 }
							 }];
		}
		else {
			self.imageView.image = thumbImage;
		}
		self.isEmpty = NO;
	}
}

@end
