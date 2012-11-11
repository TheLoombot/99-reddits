//
//  PhotoViewPad.h
//  99reddits
//
//  Created by Frank Jacob on 11/11/12.
//  Copyright (c) 2012 99 reddits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoViewControllerPad;

@interface PhotoViewPad : NIPhotoScrollView {
	UIActivityIndicatorView *activityIndicator;
	UIButton *playButton;
	NSData *gifData;
	
	PhotoViewControllerPad *photoViewController;
}

@property (nonatomic, retain) PhotoViewControllerPad *photoViewController;

- (void)setGifData:(NSData *)data;

@end
