//
//  PhotoViewPad.m
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import "PhotoViewPad.h"
#import "PhotoViewControllerPad.h"
#import "GifViewControllerPad.h"

@implementation PhotoViewPad

@synthesize photoViewController;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		if (isIOS7Below)
			self.backgroundColor = [UIColor blackColor];
		else
			self.backgroundColor = [UIColor whiteColor];
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		if (!isIOS7Below)
			activityIndicator.color = [UIColor blackColor];
		activityIndicator.center = self.center;
		activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[activityIndicator startAnimating];
		[self addSubview:activityIndicator];
		
		playButton = [UIButton buttonWithType:UIButtonTypeCustom];
		playButton.frame = CGRectMake(0, 0, 73, 73);
		playButton.center = self.center;
		playButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		[playButton setBackgroundImage:[UIImage imageNamed:@"PlayButton.png"] forState:UIControlStateNormal];
		[self addSubview:playButton];
		
		UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPlay:)];
		[playButton addGestureRecognizer:gesture];
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

- (void)onPlay:(UITapGestureRecognizer *)gesture {
	BOOL hidden = [UIApplication sharedApplication].statusBarHidden;
	if (!hidden)
		[photoViewController toggleChromeVisibility];
	
	GifViewControllerPad *gifViewController = [[GifViewControllerPad alloc] initWithNibName:@"GifViewControllerPad" bundle:nil];
	gifViewController.gifData = gifData;
	gifViewController.width = self.image.size.width;
	gifViewController.height = self.image.size.height;
	gifViewController.photoView = self;
	popoverController = [[PopoverController alloc] initWithContentViewController:gifViewController];
	popoverController.delegate = self;
	popoverController.fullscreen = YES;
	
	[popoverController showPopover:NO];
}

- (void)setGifData:(NSData *)data {
	gifData = nil;
	
	if (data) {
		gifData = data;
		playButton.hidden = NO;
	}
	else {
		playButton.hidden = YES;
	}
}

- (void)dismissPopover {
	[popoverController dismissPopover:NO];
}

// PopoverControllerDelegate
- (void)popoverControllerDidDismissed:(PopoverController *)controller {
	popoverController = nil;

	BOOL hidden = [UIApplication sharedApplication].statusBarHidden;
	if (hidden)
		[photoViewController toggleChromeVisibility];
}

@end
