//
//  PhotoView.h
//  99reddits
//
//  Created by Frank Jacob on 2/27/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverController.h"

@class PhotoViewController;

@interface PhotoView : NIPhotoScrollView <PopoverControllerDelegate> {
	UIActivityIndicatorView *activityIndicator;
	UIButton *playButton;
	NSData *gifData;
	
	PhotoViewController *photoViewController;

	PopoverController *popoverController;
}

@property (nonatomic, strong) PhotoViewController *photoViewController;

- (void)setGifData:(NSData *)data;
- (void)dismissPopover;

@end
