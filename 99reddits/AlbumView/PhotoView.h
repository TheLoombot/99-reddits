//
//  PhotoView.h
//  99reddits
//
//  Created by Frank Jacob on 2/27/12.
//  Copyright (c) 2012 Bara. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PhotoViewController;

@interface PhotoView : NIPhotoScrollView {
	UIActivityIndicatorView *activityIndicator;
	UIButton *playButton;
	NSData *gifData;
	
	PhotoViewController *photoViewController;
}

@property (nonatomic, retain) PhotoViewController *photoViewController;

- (void)setGifData:(NSData *)data;

@end
