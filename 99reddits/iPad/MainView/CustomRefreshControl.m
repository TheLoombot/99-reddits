//
//  CustomRefreshControl.m
//  99reddits
//
//  Created by Frank Jacob on 10/26/13.
//  Copyright (c) 2013 99 reddits. All rights reserved.
//

#import "CustomRefreshControl.h"

@implementation CustomRefreshControl

- (void)layoutSubviews {
	[super layoutSubviews];

	if (!isIOS7Below) {
		CGRect frame = self.frame;
		frame.origin.y += 64;
		self.frame = frame;
	}
}

@end
