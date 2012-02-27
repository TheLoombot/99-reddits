//
//  MainViewCell.m
//  99reddits
//
//  Created by Frank Jacob on 10/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewCell.h"
#import <QuartzCore/QuartzCore.h>


@implementation MainViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[activityIndicator startAnimating];
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.textLabel.font = [UIFont boldSystemFontOfSize:16];
		self.textLabel.textColor = [UIColor blackColor];
		self.textLabel.backgroundColor = [UIColor clearColor];
		
		braketLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		braketLabel.font = [UIFont systemFontOfSize:16];
		braketLabel.textColor = [UIColor grayColor];
		braketLabel.backgroundColor = [UIColor clearColor];
		braketLabel.text = @"(";
		[self addSubview:braketLabel];
		
		unshowedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		unshowedLabel.font = [UIFont systemFontOfSize:16];
		unshowedLabel.textColor = [UIColor colorWithRed:255 / 255.0 green:69 / 255.0 blue:0.0 alpha:1.0];
		unshowedLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:unshowedLabel];

		countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		countLabel.font = [UIFont systemFontOfSize:16];
		countLabel.textColor = [UIColor grayColor];
		countLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:countLabel];

		self.imageView.contentMode = UIViewContentModeScaleAspectFill;
		
		first = YES;
    }
    return self;
}

- (void)dealloc {
	[activityIndicator release];
	[braketLabel release];
	[unshowedLabel release];
	[countLabel release];
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
		if (self.accessoryView == nil)
			self.accessoryView = activityIndicator;
	}
	else
		self.accessoryView = nil;
	
	if (totalCount == 0) {
		braketLabel.hidden = YES;
		unshowedLabel.hidden = YES;
		countLabel.hidden = YES;
	}
	else {
		braketLabel.hidden = NO;
		unshowedLabel.hidden = NO;
		countLabel.hidden = NO;
		
		CGRect frame = self.textLabel.frame;
		if (frame.size.width > 173) {
			frame.size.width = 173;
			self.textLabel.frame = frame;
		}
		
		int x = frame.origin.x + frame.size.width + 10;
		
		int y = frame.origin.y;
		int h = frame.size.height;
		
		braketLabel.frame = CGRectMake(x, y, 300, h);
		[braketLabel sizeToFit];
		braketLabel.frame = CGRectMake(x, y, braketLabel.frame.size.width, h);
		
		x = braketLabel.frame.origin.x + braketLabel.frame.size.width - 1;
		
		if (unshowedCount == 0) {
			unshowedLabel.hidden = YES;

			countLabel.frame = CGRectMake(x, y, 300, h);
			countLabel.text = [NSString stringWithFormat:@"%d)", totalCount];
			[countLabel sizeToFit];
			countLabel.frame = CGRectMake(x, y, countLabel.frame.size.width, h);
		}
		else {
			unshowedLabel.frame = CGRectMake(x, y, 300, h);
			unshowedLabel.text = [NSString stringWithFormat:@"%d", unshowedCount];
			[unshowedLabel sizeToFit];
			unshowedLabel.frame = CGRectMake(x, y, unshowedLabel.frame.size.width, h);
			
			x = unshowedLabel.frame.origin.x + unshowedLabel.frame.size.width - 1;
			
			countLabel.frame = CGRectMake(x, y, 300, h);
			countLabel.text = [NSString stringWithFormat:@"/%d)", totalCount];
			[countLabel sizeToFit];
			countLabel.frame = CGRectMake(x, y, countLabel.frame.size.width, h);
		}
	}
}

- (void)setTotalCount:(int)_totalCount {
	bFavorites = YES;

	unshowedCount = 0;
	totalCount = _totalCount;
	loading = NO;
	
	if (loading) {
		if (self.accessoryView == nil)
			self.accessoryView = activityIndicator;
	}
	else
		self.accessoryView = nil;
	
	braketLabel.hidden = NO;
	unshowedLabel.hidden = NO;
	countLabel.hidden = NO;
	
	CGRect frame = self.textLabel.frame;
	if (frame.size.width > 173) {
		frame.size.width = 173;
		self.textLabel.frame = frame;
	}
	
	int x = frame.origin.x + frame.size.width + 10;
	
	int y = frame.origin.y;
	int h = frame.size.height;
	
	braketLabel.frame = CGRectMake(x, y, 300, h);
	[braketLabel sizeToFit];
	braketLabel.frame = CGRectMake(x, y, braketLabel.frame.size.width, h);
	
	x = braketLabel.frame.origin.x + braketLabel.frame.size.width - 1;
	
	if (unshowedCount == 0) {
		unshowedLabel.hidden = YES;
		
		countLabel.frame = CGRectMake(x, y, 300, h);
		countLabel.text = [NSString stringWithFormat:@"%d)", totalCount];
		[countLabel sizeToFit];
		countLabel.frame = CGRectMake(x, y, countLabel.frame.size.width, h);
	}
	else {
		unshowedLabel.frame = CGRectMake(x, y, 300, h);
		unshowedLabel.text = [NSString stringWithFormat:@"%d", unshowedCount];
		[unshowedLabel sizeToFit];
		unshowedLabel.frame = CGRectMake(x, y, unshowedLabel.frame.size.width, h);
		
		x = unshowedLabel.frame.origin.x + unshowedLabel.frame.size.width - 1;
		
		countLabel.frame = CGRectMake(x, y, 300, h);
		countLabel.text = [NSString stringWithFormat:@"/%d)", totalCount];
		[countLabel sizeToFit];
		countLabel.frame = CGRectMake(x, y, countLabel.frame.size.width, h);
	}
}

@end
