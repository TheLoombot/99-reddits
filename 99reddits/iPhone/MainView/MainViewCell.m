//
//  MainViewCell.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 99 reddits. All rights reserved.
//

#import "MainViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MainViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.textLabel.font = [UIFont boldSystemFontOfSize:16];
		self.textLabel.textColor = [UIColor blackColor];
		self.textLabel.backgroundColor = [UIColor clearColor];
		
		unshowedBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
		unshowedBackImageView.image = [[UIImage imageNamed:@"BadgeBack.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
		[self addSubview:unshowedBackImageView];
		unshowedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
		unshowedLabel.font = [UIFont boldSystemFontOfSize:14];
		unshowedLabel.backgroundColor = [UIColor clearColor];
		unshowedLabel.textColor = [UIColor whiteColor];
		[self addSubview:unshowedLabel];

		self.imageView.contentMode = UIViewContentModeScaleAspectFill;
		
		first = YES;
    }
    return self;
}

- (void)dealloc {
	[activityIndicator release];
	[unshowedBackImageView release];
	[unshowedLabel release];
	[animateImageView release];
	[super dealloc];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (first) {
		first = NO;
		return;
	}
	
	if (bFavorites)
		[self setTotalCount:totalCount];
	else
		[self setUnshowedCount:unshowedCount totalCount:totalCount loading:loading];
}

- (void)setUnshowedCount:(int)_unshowedCount totalCount:(int)_totalCount loading:(BOOL)_loading {
	bFavorites = NO;
	
	unshowedCount = _unshowedCount;
	totalCount = _totalCount;
	loading = _loading;

	if (loading) {
		self.accessoryView = activityIndicator;
		[activityIndicator startAnimating];
	}
	else
		self.accessoryView = nil;
	
	if (unshowedCount == 0) {
		unshowedBackImageView.hidden = YES;
		unshowedLabel.hidden = YES;
	}
	else {
		unshowedBackImageView.hidden = NO;
		unshowedLabel.hidden = NO;
		
		CGRect frame = self.textLabel.frame;
		frame.size.width = 180;
		self.textLabel.frame = frame;
		
		unshowedLabel.frame = CGRectMake(0, 0, 200, 20);
		unshowedLabel.text = [NSString stringWithFormat:@"%d", unshowedCount];
		[unshowedLabel sizeToFit];
		
		CGRect rect = unshowedLabel.frame;
		rect.size.width = ceil(rect.size.width);
		rect.size.height = 20;
		rect.origin.x = 275 - rect.size.width;
		rect.origin.y = 17;
		unshowedLabel.frame = rect;
		
		rect.origin.x -= 10;
		rect.origin.y -= 3;
		rect.size.width += 20;
		rect.size.height += 9;
		unshowedBackImageView.frame = rect;
	}
}

- (void)setTotalCount:(int)_totalCount {
	bFavorites = YES;

	unshowedCount = 0;
	totalCount = _totalCount;
	loading = NO;
	
	if (loading) {
		self.accessoryView = activityIndicator;
		[activityIndicator startAnimating];
	}
	else
		self.accessoryView = nil;
	
	unshowedBackImageView.hidden = YES;
	unshowedLabel.hidden = YES;
	
	CGRect frame = self.textLabel.frame;
	frame.size.width = 180;
	self.textLabel.frame = frame;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	[UIView animateWithDuration:0.2
					 animations:^(void) {
						 if (editing) {
							 unshowedBackImageView.alpha = 0.0;
							 unshowedLabel.alpha = 0.0;
						 }
						 else {
							 unshowedBackImageView.alpha = 1.0;
							 unshowedLabel.alpha = 1.0;
						 }
					 }];
}

- (void)setThumbImage:(UIImage *)thumbImage animated:(BOOL)animated {
	[animateImageView.layer removeAllAnimations];
	[animateImageView removeFromSuperview];
	[animateImageView release];
	animateImageView = nil;

	if (thumbImage == nil) {
		self.imageView.image = [UIImage imageNamed:@"DefaultAlbumIcon.png"];
		imageEmpty = YES;
	}
	else {
		if (animated || imageEmpty) {
			self.imageView.image = [UIImage imageNamed:@"DefaultAlbumIcon.png"];
			animateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
			animateImageView.image = thumbImage;
			[self.contentView addSubview:animateImageView];

			animateImageView.alpha = 0.0;
			[UIView animateWithDuration:0.2
							 animations:^(void) {
								 animateImageView.alpha = 1.0;
							 }
							 completion:^(BOOL finished) {
								 [animateImageView removeFromSuperview];
								 [animateImageView release];
								 animateImageView = nil;
								 self.imageView.image = thumbImage;
							 }];
		}
		else {
			self.imageView.image = thumbImage;
		}
		imageEmpty = NO;
	}
}

@end
