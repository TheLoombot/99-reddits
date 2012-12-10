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
		activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		activityIndicator.center = self.center;
		activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[activityIndicator startAnimating];
		[self addSubview:activityIndicator];
		
		playButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		playButton.frame = CGRectMake(0, 0, 73, 73);
		playButton.center = self.center;
		playButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		[playButton setBackgroundImage:[UIImage imageNamed:@"PlayButton.png"] forState:UIControlStateNormal];
		[self addSubview:playButton];
		
		UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPlay:)];
		[playButton addGestureRecognizer:gesture];
		[gesture release];
    }
    return self;
}

- (void)dealloc {
	[activityIndicator release];
	[playButton release];
	[gifData release];
	[photoViewController release];
	[popoverController release];
	[super dealloc];
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
	[gifViewController release];
	
	[popoverController showPopover:NO];
}

- (void)setGifData:(NSData *)data {
	[gifData release];
	gifData = nil;
	
	if (data) {
		gifData = [data retain];
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
	[popoverController release];
	popoverController = nil;
}

@end
