//
//  PhotoViewPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverController.h"

@class PhotoViewControllerPad;

@interface PhotoViewPad : NIPhotoScrollView <PopoverControllerDelegate> {
	UIActivityIndicatorView *activityIndicator;
	UIButton *playButton;
	NSData *gifData;
	
	PhotoViewControllerPad *photoViewController;
	
	PopoverController *popoverController;
}

@property (nonatomic, strong) PhotoViewControllerPad *photoViewController;

- (void)setGifData:(NSData *)data;
- (void)dismissPopover;

@end
