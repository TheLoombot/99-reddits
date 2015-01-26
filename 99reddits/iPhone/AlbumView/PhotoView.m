//
//  PhotoView.m
//  99reddits
//
//  Created by Frank Jacob on 2/27/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "PhotoView.h"

@implementation PhotoView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityIndicator.center = self.center;
		activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[activityIndicator startAnimating];
		[self addSubview:activityIndicator];
    }
    return self;
}

- (void)setImage:(UIImage *)image photoSize:(NIPhotoScrollViewPhotoSize)photoSize {
	[super setImage:image photoSize:photoSize];
	
	if (photoSize == NIPhotoScrollViewPhotoSizeOriginal && image != nil)
		activityIndicator.alpha = 0.0;
	else
		activityIndicator.alpha = 1.0;
}

@end
