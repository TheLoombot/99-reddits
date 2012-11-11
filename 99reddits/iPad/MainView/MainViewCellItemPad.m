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
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
		[tapView addGestureRecognizer:tapGesture];
		[tapGesture release];
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
		deleteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		deleteButton.frame = CGRectMake(0, 0, 29, 29);
		[deleteButton setBackgroundImage:[UIImage imageNamed:@"DeleteButton.png"] forState:UIControlStateNormal];
		[deleteButton addTarget:self action:@selector(onDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:deleteButton];
		unshowedBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
		unshowedBackImageView.image = [[UIImage imageNamed:@"BadgeBack.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
		[self addSubview:unshowedBackImageView];
		unshowedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
		unshowedLabel.font = [UIFont boldSystemFontOfSize:14];
		unshowedLabel.backgroundColor = [UIColor clearColor];
		unshowedLabel.textColor = [UIColor whiteColor];
		[self addSubview:unshowedLabel];
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
		
		rect.origin.x -= 15;
		rect.origin.y -= 15;
		rect.size.width = 29;
		rect.size.height = 29;
		deleteButton.frame = rect;
		
		rect = unshowedLabel.frame;
		rect.size.width = ceil(rect.size.width);
		rect.size.height = 20;
		rect.origin.x = tapView.frame.origin.x + tapView.frame.size.width + 2 - rect.size.width;
		rect.origin.y = tapView.frame.origin.y + tapView.frame.size.height - 11;
		unshowedLabel.frame = rect;
		
		rect.origin.x -= 10;
		rect.origin.y -= 3;
		rect.size.width += 20;
		rect.size.height += 9;
		unshowedBackImageView.frame = rect;
	}
}

- (void)setUnshowedCount:(int)_unshowedCount totalCount:(int)_totalCount loading:(BOOL)_loading {
	unshowedCount = _unshowedCount;
	totalCount = _totalCount;
	loading = _loading;
	bFavorites = NO;
	
	if (loading) {
		activityIndicator.hidden = NO;
		[activityIndicator startAnimating];
	}
	else {
		activityIndicator.hidden = YES;
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
		rect.origin.x = tapView.frame.origin.x + tapView.frame.size.width + 2 - rect.size.width;
		rect.origin.y = tapView.frame.origin.y + tapView.frame.size.height - 11;
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
	
	activityIndicator.hidden = YES;
	
	unshowedBackImageView.hidden = YES;
	unshowedLabel.hidden = YES;
}

- (void)setEditing:(BOOL)_editing {
	editing = _editing;
	if (bFavorites)
		deleteButton.hidden = YES;
	else
		deleteButton.hidden = !editing;
}

- (void)onTapGesture:(id)sender {
	if (editing)
		return;
	
	[mainViewCell onClick:self.tag];
}

- (void)onDeleteButton:(id)sender {
	if (!editing)
		return;

	[mainViewCell onDeleteButton:self.tag];
}

@end
