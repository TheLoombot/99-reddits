//
//  MainViewCellPad.m
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "MainViewCellPad.h"
#import "UserDef.h"
#import "RedditsAppDelegate.h"
#import "MainViewControllerPad.h"
#import <QuartzCore/QuartzCore.h>

@implementation MainViewCellPad

@synthesize mainViewController;
@synthesize subReddit;
@synthesize nameLabel;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.contentView.backgroundColor = [UIColor clearColor];
		
		appDelegate = (RedditsAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		imageOutlineView = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 120, 120)];
		imageOutlineView.backgroundColor = [UIColor whiteColor];
		if (isIOS7Below)
			imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 108, 108)];
		else
			imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
		[imageOutlineView addSubview:imageView];
		[self.contentView addSubview:imageOutlineView];
		
		tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
		tapButton.frame = imageOutlineView.frame;
		[tapButton setImage:[UIImage imageNamed:@"ButtonOverlay.png"] forState:UIControlStateHighlighted];
		[tapButton addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:tapButton];
		
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityIndicator.center = imageOutlineView.center;
		[activityIndicator startAnimating];
		[self.contentView addSubview:activityIndicator];
		nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 135, 120, 40)];
		nameLabel.font = [UIFont boldSystemFontOfSize:15];
		nameLabel.numberOfLines = 2;
		nameLabel.textColor = [UIColor colorWithRed:146 / 255.0 green:146 / 255.0 blue:146 / 255.0 alpha:1.0];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:nameLabel];
		deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		deleteButton.frame = CGRectMake(0, 0, 29, 29);
		[deleteButton setBackgroundImage:[UIImage imageNamed:@"DeleteButton.png"] forState:UIControlStateNormal];
		[deleteButton addTarget:self action:@selector(onDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:deleteButton];
		unshowedBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
		if (isIOS7Below)
			unshowedBackImageView.image = [[UIImage imageNamed:@"BadgeBack.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
		else
			unshowedBackImageView.image = [[UIImage imageNamed:@"BadgeRedBack.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
		[self.contentView addSubview:unshowedBackImageView];
		unshowedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
		if (isIOS7Below)
			unshowedLabel.font = [UIFont boldSystemFontOfSize:14];
		else
			unshowedLabel.font = [UIFont boldSystemFontOfSize:17];
		unshowedLabel.backgroundColor = [UIColor clearColor];
		unshowedLabel.textColor = [UIColor whiteColor];
		[self.contentView addSubview:unshowedLabel];
	}
	return self;
}


- (void)setUnshowedCount:(int)_unshowedCount totalCount:(int)_totalCount loading:(BOOL)_loading {
	unshowedCount = _unshowedCount;
	totalCount = _totalCount;
	loading = _loading;
	bFavorites = NO;
	deleteButton.alpha = 1.0;
	
	if (loading) {
		if (![activityIndicator isAnimating]) {
			activityIndicator.hidden = NO;
			[activityIndicator startAnimating];
		}
	}
	else {
		if ([activityIndicator isAnimating]) {
			activityIndicator.hidden = YES;
			[activityIndicator stopAnimating];
		}
	}
	
	if (unshowedCount == 0) {
		unshowedBackImageView.hidden = YES;
		unshowedLabel.hidden = YES;
	}
	else {
		unshowedBackImageView.hidden = NO;
		unshowedLabel.hidden = NO;
		
		unshowedLabel.frame = CGRectMake(0, 0, 200, 20);
		unshowedLabel.text = [NSString stringWithFormat:@"%d", unshowedCount];
		[unshowedLabel sizeToFit];
		
		CGRect rect = unshowedLabel.frame;
		rect.size.width = ceil(rect.size.width);
		rect.size.height = 20;
		rect.origin.x = imageOutlineView.frame.origin.x + imageOutlineView.frame.size.width + 2 - rect.size.width;
		rect.origin.y = imageOutlineView.frame.origin.y + imageOutlineView.frame.size.height - 11;
		unshowedLabel.frame = rect;
		
		rect.origin.x -= 10;
		rect.origin.y -= 3;
		rect.size.width += 20;
		rect.size.height += 9;
		unshowedBackImageView.frame = rect;
	}
}

- (void)setTotalCount:(int)_totalCount {
	totalCount = _totalCount;
	bFavorites = YES;
	deleteButton.alpha = 0.0;
	
	if ([activityIndicator isAnimating]) {
		activityIndicator.hidden = YES;
		[activityIndicator stopAnimating];
	}
	
	unshowedBackImageView.hidden = YES;
	unshowedLabel.hidden = YES;
}

- (void)applyLayoutAttributes:(MainViewLayoutAttributesPad *)layoutAttributes {
	[self setEditing:layoutAttributes.editing];
}

- (void)setEditing:(BOOL)_editing {
	editing = _editing;
	deleteButton.hidden = !editing;
	tapButton.hidden = editing;
}

- (void)onTap:(id)sender {
	if (editing)
		return;
	
	[mainViewController showSubReddit:subReddit];
}

- (void)onDeleteButton:(id)sender {
	if (!editing)
		return;
	
	[mainViewController removeSubReddit:subReddit];
}

- (void)setThumbImage:(UIImage *)thumbImage animated:(BOOL)animated {
	[animateImageView.layer removeAllAnimations];
	[animateImageView removeFromSuperview];
	animateImageView = nil;

	if (thumbImage == nil) {
		imageOutlineView.frame = CGRectMake(15, 15, 120, 120);
		if (isIOS7Below)
			imageView.frame = CGRectMake(6, 6, 108, 108);
		else
			imageView.frame = CGRectMake(0, 0, 120, 120);
		imageView.image = [UIImage imageNamed:@"DefaultAlbumIcon.png"];
		imageEmpty = YES;
	}
	else {
		int width = thumbImage.size.width;
		int height = thumbImage.size.height;
		if (width > height) {
			width = 108;
			height = height * width / thumbImage.size.width;
		}
		else {
			height = 108;
			width = width * height / thumbImage.size.height;
		}
		CGRect rect = CGRectMake((int)(108 - width) / 2 + 21, (int)(108 - height) / 2 + 21, width, height);
		rect.origin.x -= 6;
		rect.origin.y -= 6;
		rect.size.width += 12;
		rect.size.height += 12;
		imageOutlineView.frame = rect;

		rect.origin.x -= 15;
		rect.origin.y -= 15;
		rect.size.width = 29;
		rect.size.height = 29;
		deleteButton.frame = rect;

		rect = unshowedLabel.frame;
		rect.size.width = ceil(rect.size.width);
		rect.size.height = 20;
		rect.origin.x = imageOutlineView.frame.origin.x + imageOutlineView.frame.size.width + 2 - rect.size.width;
		rect.origin.y = imageOutlineView.frame.origin.y + imageOutlineView.frame.size.height - 11;
		unshowedLabel.frame = rect;

		rect.origin.x -= 10;
		rect.origin.y -= 3;
		rect.size.width += 20;
		rect.size.height += 9;
		unshowedBackImageView.frame = rect;

		if (isIOS7Below)
			imageView.frame = CGRectMake(6, 6, width, height);
		else
			imageView.frame = CGRectMake(0, 0, width + 12, height + 12);

		if (animated || imageEmpty) {
			imageView.image = [UIImage imageNamed:@"DefaultAlbumIcon.png"];
			animateImageView = [[UIImageView alloc] initWithFrame:imageView.frame];
			animateImageView.image = thumbImage;
			[imageOutlineView addSubview:animateImageView];

			animateImageView.alpha = 0.0;
			[UIView animateWithDuration:0.2
							 animations:^(void) {
								 animateImageView.alpha = 1.0;
							 }
							 completion:^(BOOL finished) {
								 [animateImageView removeFromSuperview];
								 animateImageView = nil;
								 if (finished) {
									 imageView.image = thumbImage;
								 }
							 }];
		}
		else {
			imageView.image = thumbImage;
		}
		imageEmpty = NO;
	}

	tapButton.frame = imageOutlineView.frame;
}

@end
