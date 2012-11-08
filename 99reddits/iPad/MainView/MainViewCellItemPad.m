//
//  MainViewCellItemPad.m
//  99reddits
//
//  Created by Frank Jacob on 11/8/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "MainViewCellItemPad.h"
#import "MainViewCellPad.h"

@implementation MainViewCellItemPad

@synthesize mainViewCell;
@synthesize nameLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		tapView = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 120, 120)];
		tapView.backgroundColor = [UIColor whiteColor];
		[self addSubview:tapView];
		imageView = [[UIImageView alloc] initWithFrame:CGRectMake(21, 21, 108, 108)];
		[self addSubview:imageView];
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityIndicator.center = tapView.center;
		[activityIndicator startAnimating];
		[self addSubview:activityIndicator];
		nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 135, 120, 40)];
		nameLabel.font = [UIFont boldSystemFontOfSize:15];
		nameLabel.numberOfLines = 2;
		nameLabel.textColor = [UIColor colorWithRed:146 / 255.0 green:146 / 255.0 blue:146 / 255.0 alpha:1.0];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:nameLabel];
    }
    return self;
}

- (void)dealloc {
	[tapView release];
	[imageView release];
	[activityIndicator release];
	[deleteButton release];
	[unshowedBackImageView release];
	[unshowedLabel release];
	[nameLabel release];
	[super dealloc];
}

- (void)setImage:(UIImage *)image {
	if (image == nil) {
		tapView.frame = CGRectMake(15, 15, 120, 120);
		imageView.frame = CGRectMake(21, 21, 120, 120);
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
		CGRect rect = CGRectMake((int)(108 - width) / 2 + 21, (int)(108 - height) / 2 + 21, width, height);
		imageView.frame = rect;
		imageView.image = image;
		
		rect.origin.x -= 6;
		rect.origin.y -= 6;
		rect.size.width += 12;
		rect.size.height += 12;
		tapView.frame = rect;
	}
}

- (void)setUnshowedCount:(int)_unshowedCount totalCount:(int)_totalCount loading:(BOOL)_loading {
	unshowedCount = _unshowedCount;
	totalCount = _totalCount;
	loading = _loading;
	bFavorites = NO;
	
	if (loading)
		activityIndicator.hidden = NO;
	else
		activityIndicator.hidden = YES;
}

- (void)setTotalCount:(int)_totalCount {
	totalCount = _totalCount;
	bFavorites = YES;
	
	activityIndicator.hidden = YES;
}

- (void)showDeleteButton:(BOOL)show {
	deleteButton.hidden = !show;
}

@end
